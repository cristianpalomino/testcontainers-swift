import Foundation
import AsyncHTTPClient
import Logging
import NIO

public final class GenericContainer {
    
    static let uuid = UUID().uuidString
    
    private let logger: Logger
    private let imageParams: DockerImageName
    private let configuration: ContainerConfig
    
    private var docker: Docker?
    private var container: Docker.Container?
    private var image: Docker.Image?
    
    public init(image: DockerImageName, configuration: ContainerConfig, logger: Logger) {
        self.imageParams = image
        self.configuration = configuration
        self.logger = logger
        
        guard let client = DockerClientStrategy().resolve() else {
            self.docker = nil
            self.logger.error("❌ Unable to resolve a Docker client")
            return
        }
        self.docker = Docker(client: client)
    }
    
    public convenience init(
        image: DockerImageName,
        port: Int,
        logger: Logger = Logger(label: String(describing: GenericContainer.self))
    ) {
        let configuration: ContainerConfig = .build(image: image.name, tag: image.tag, exposed: port)
        self.init(image: image, configuration: configuration, logger: logger)
    }
    
    public convenience init(
        name: String,
        tag: String = "latest",
        port: Int,
        logger: Logger = Logger(label: String(describing: GenericContainer.self))
    ) {
        let configuration: ContainerConfig = .build(image: name, tag: tag, exposed: port)
        let image = DockerImageName(name: name, tag: tag)
        self.init(image: image, configuration: configuration, logger: logger)
    }
    
    public convenience init(
        image: String,
        port: Int,
        logger: Logger = Logger(label: String(describing: GenericContainer.self))
    ) throws {
        let image = try DockerImageName(image: image)
        let configuration: ContainerConfig = .build(image: image.name, tag: image.tag, exposed: port)
        self.init(image: image, configuration: configuration, logger: logger)
    }
    
    public func start() -> EventLoopFuture<ContainerInspectInfo> {
        guard let docker else {
            return MultiThreadedEventLoopGroup(numberOfThreads: 1).next()
                .makeFailedFuture("Unable to resolve a Docker client")
        }
        
        let infoFuture = docker.info()
        let versionFuture = infoFuture.and(docker.version())
            .map { info, version in
                self.logger.info("🐳 Connected to Docker:")
                self.logger.info("→ Server Version: \(info.ServerVersion)")
                self.logger.info("→ API Version: \(version.ApiVersion)")
                self.logger.info("→ Operating System: \(info.OperatingSystem)")
                self.logger.info("→ Total Memory: \(info.MemTotal / (1024 * 1024)) MB")
                self.logger.info("→ Labels: \(info.Labels)")
            }
        
        return versionFuture.flatMap { _ in
            docker.pull(params: self.imageParams).map { image in
                self.image = image
                return image
            }
        }.flatMap { _ in
            docker.create(container: self.configuration).map { container in
                self.container = container
                return container
            }
        }.flatMap { container in
            container.start().map { container }
        }.flatMap { container in
            container.inspect()
        }
    }
    
    public func remove() -> EventLoopFuture<Void> {
        guard let docker else {
            return MultiThreadedEventLoopGroup(numberOfThreads: 1).next()
                .makeFailedFuture("Unable to resolve a Docker client")
        }
        
        guard let container = container else {
            return docker.client.eventLoop.next().makeFailedFuture("Container not found")
        }
        
        return container.kill()
    }
}
