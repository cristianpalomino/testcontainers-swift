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

    private var docker: Docker
    private var container: Docker.Container?

    public let ryukService: RyukService

    public init(image: DockerImageName, configuration: ContainerConfig, logger: Logger) throws {
        self.imageParams = image
        self.configuration = configuration
        self.logger = logger

        self.ryukService = RyukService(
            logger: Logger(label: "org.testcontainers.ryuk"),
            sessionId: UUID().uuidString
        )

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
        if let ryukFuture = ryukService.start() {
            return ryukFuture.flatMap { _ in
                self.startContainer(retrieveHostInfo: retrieveHostInfo)
            }
        }
        return startContainer(retrieveHostInfo: retrieveHostInfo)
    }

    private func startContainer(retrieveHostInfo: Bool) -> EventLoopFuture<ContainerInspectInfo> {
        if retrieveHostInfo {
            let infoFuture = docker.info()
            let versionFuture = infoFuture.and(docker.version())
                .map { info, version in
                    self.logger.info("🐳 Docker Info:")
                    self.logger.info("→ Server Version: \(info.ServerVersion)")
                    self.logger.info("→ API Version: \(version.ApiVersion)")
                    self.logger.info("→ Operating System: \(info.OperatingSystem)")
                    self.logger.info("→ Total Memory: \(info.MemTotal / (1024 * 1024)) MB")
                    self.logger.info("→ Labels: \(info.Labels)")
                }

            return versionFuture.flatMap { _ in
                self.createContainer()
            }
        }

        return createContainer()
    }

    private func createContainer() -> EventLoopFuture<ContainerInspectInfo> {
        docker.pull(params: self.imageParams).map { image in
            return image
        }.flatMap { _ in
            self.docker.create(container: self.configuration).map { container in
                self.container = container
                return container
            }
        }.flatMap { container in
            container.start().map { container }
        }.flatMap { container in
            container.inspect()
        }
    }

    public func remove() -> EventLoopFuture<Void>? {
        let containerRemoveFuture = container?.stop().flatMap { _ in
            self.container?.remove()
        }
        let ryukRemoveFuture = ryukService?.stop().flatMap { _ in
            self.ryukService.remove()
        }

        return containerRemoveFuture.and(ryukRemoveFuture).map { _ in
            self.container = nil
            self.logger.info("🗑️ Container and associated Ryuk service removed")
        }
    }
}
