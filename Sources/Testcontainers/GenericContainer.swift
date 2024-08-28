import Foundation
import AsyncHTTPClient
import Logging
import NIO

public final class GenericContainer {
    
    let logger = Logger(label: "GenericContainer")
    
    static let uuid = UUID().uuidString
    
    private let name: String
    private let configuration: ContainerConfig
    
    private var docker: Docker?
    private var container: Docker.Container?
    private var image: Docker.Image?
    
    init(name: String, configuration: ContainerConfig) {
        self.name = name
        self.configuration = configuration
        
        guard let client = DockerClientStrategy().resolve() else {
            self.docker = nil
            logger.error("Unable to resolve a Docker client")
            return
        }
        self.docker = Docker(client: client)
    }
    
    convenience init(name: String, port: Int) {
        let configuration: ContainerConfig = .build(image: name, exposed: port)
        self.init(name: name, configuration: configuration)
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
            docker.pull(image: self.name).map { image in
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
    
    func remove() -> EventLoopFuture<Void> {
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
