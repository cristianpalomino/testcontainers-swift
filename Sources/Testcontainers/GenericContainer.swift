import Foundation
import AsyncHTTPClient
import Logging
import NIO

public final class GenericContainer {
    
    static let uuid = UUID().uuidString
    
    private let logger: Logger
    private let imageParams: ImageParams
    private let configuration: ContainerConfig
    
    private var docker: Docker?
    private var container: Docker.Container?
    private var image: Docker.Image?
    
    public init(image: ImageParams, configuration: ContainerConfig, logger: Logger? = nil) {
        self.imageParams = image
        self.configuration = configuration
        self.logger = logger ?? Logger(label: "GenericContainer")
        
        guard let client = DockerClientStrategy().resolve() else {
            self.docker = nil
            self.logger.error("Unable to resolve a Docker client")
            return
        }
        self.docker = Docker(client: client)
    }
    
    public convenience init(name: String, tag: String = "latest", port: Int) {
        let configuration: ContainerConfig = .build(image: name, exposed: port)
        let image = ImageParams(name: name, tag: tag, src: nil, repo: nil)
        self.init(image: image, configuration: configuration)
    }
    
    public func start() -> EventLoopFuture<ContainerInspectInfo> {
        guard let docker else {
            return MultiThreadedEventLoopGroup(numberOfThreads: 1).next()
                .makeFailedFuture("Unable to resolve a Docker client")
        }
        
        let infoFuture = docker.info()
        let versionFuture = infoFuture.and(docker.version())
            .map { info, version in
                let labels = info.Labels
                var serverInfo = """
            \nConnected to docker:
              Server Version: \(info.ServerVersion)
              API Version: \(version.ApiVersion)
              Operating System: \(info.OperatingSystem)
              Total Memory: \(info.MemTotal / (1024 * 1024)) MB
            """
                if !labels.isEmpty {
                    serverInfo.append("\n  Labels:\n")
                    labels.forEach { label in
                        serverInfo.append("    \(label)\n")
                    }
                }
                self.logger.info(Logger.Message(stringLiteral: serverInfo))
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
