import Foundation
import AsyncHTTPClient
import Logging
import NIO

public enum ContainerError: Error {
    case unableToResolve
}

public final class GenericContainer {

    static let uuid = UUID().uuidString

    private let logger: Logger
    private let imageParams: DockerImageName
    private let configuration: ContainerConfig

    private var docker: DockerOperations
    private var container: DockerContainerOperations?
    private lazy var sideContainers: [SideContainer] = {
        return [RyukSideContainer(docker: docker, logger: logger)]
    }()

    public init(
        image: DockerImageName,
        configuration: ContainerConfig,
        logger: Logger
    ) throws {
        self.imageParams = image
        self.configuration = configuration
        self.logger = logger

        guard let client = DockerClientStrategy(logger: logger).resolve() else {
            throw ContainerError.unableToResolve
        }

        self.docker = Docker(client: client, logger: logger)
    }

    public convenience init(
        image: DockerImageName,
        port: Int,
        logger: Logger = Logger(label: String(describing: GenericContainer.self))
    ) throws {
        let configuration: ContainerConfig = .build(image: image.name, tag: image.tag, exposed: port)
        try self.init(image: image, configuration: configuration, logger: logger)
    }

    public convenience init(
        name: String,
        tag: String = "latest",
        port: Int,
        logger: Logger = Logger(label: String(describing: GenericContainer.self))
    ) throws {
        let configuration: ContainerConfig = .build(image: name, tag: tag, exposed: port)
        let image = DockerImageName(name: name, tag: tag)
        try self.init(image: image, configuration: configuration, logger: logger)
    }

    public convenience init(
        image: String,
        port: Int,
        logger: Logger = Logger(label: String(describing: GenericContainer.self))
    ) throws {
        let image = try DockerImageName(image: image)
        let configuration: ContainerConfig = .build(image: image.name, tag: image.tag, exposed: port)
        try self.init(image: image, configuration: configuration, logger: logger)
    }

    public func start(retrieveHostInfo: Bool = false) -> EventLoopFuture<ContainerInspectInfo> {
        let hostInfoFuture = retrieveHostInfo ? self.retrieveDockerInfo() : self.docker.client.eventLoop.makeSucceededFuture(())

        let sideContainersFuture = EventLoopFuture.andAllSucceed(
            sideContainers.map { $0.start() },
            on: docker.client.eventLoop
        )

        return sideContainersFuture.flatMap { _ in
            hostInfoFuture.flatMap { _ in
                self.createContainer()
            }
        }
    }

    public func remove() -> EventLoopFuture<Void> {
        guard let container = container else {
            return docker.client.eventLoop.next().makeFailedFuture("Container not found")
        }

        let sideContainersFuture = EventLoopFuture.andAllSucceed(
            sideContainers.map { $0.remove() },
            on: docker.client.eventLoop
        )

        return sideContainersFuture.flatMap { _ in
            container.stop().flatMap { _ in
                container.remove()
            }
        }
    }

    private func retrieveDockerInfo() -> EventLoopFuture<Void> {
        let infoFuture = docker.info()
        return infoFuture.and(docker.version())
            .map { info, version in
                self.logger.info("🐳 Docker Info:")
                self.logger.info("→ Server Version: \(info.ServerVersion)")
                self.logger.info("→ API Version: \(version.ApiVersion)")
                self.logger.info("→ Operating System: \(info.OperatingSystem)")
                self.logger.info("→ Total Memory: \(info.MemTotal / (1024 * 1024)) MB")
                self.logger.info("→ Labels: \(info.Labels)")
            }
    }

    private func createContainer() -> EventLoopFuture<ContainerInspectInfo> {
        return docker.pull(params: self.imageParams).flatMap { _ in
            return self.docker.create(container: self.configuration)
        }.flatMap { container in
            self.container = container
            return container.start().flatMap { _ in
                return container.inspect()
            }
        }
    }
}

public extension GenericContainer {
    func getSideContainer<T: SideContainer>() -> T? {
        return sideContainers.first { $0 is T } as? T
    }

    func getSideContainers() -> [SideContainer] {
        return sideContainers
    }
}
