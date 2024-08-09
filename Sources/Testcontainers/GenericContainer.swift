import Foundation
import AsyncHTTPClient
import Logging
import NIO

public final class GenericContainer {
    
    let logger = Logger(label: "testcontainers.GenericContainer")
    
    static let uuid = UUID().uuidString
    
    private let name: String
    private let configuration: ContainerConfig
    
    private var docker: Docker
    private var container: Docker.Container?
    private var image: Docker.Image?
    
    init(name: String, configuration: ContainerConfig, docker: Docker) {
        self.docker = docker
        self.name = name
        self.configuration = configuration
    }
    
    convenience init(name: String, port: Int) {
        let configuration: ContainerConfig = .build(image: name, exposed: port)
        let docker = Docker(client: DockerHTTPClient(host: Configuration.DockerLocal))
        self.init(name: name, configuration: configuration, docker: docker)
    }
    
    public func start() -> EventLoopFuture<ContainerInspectInfo> {
        let pingFuture = docker.ping()
            .flatMapError { _ in
                self.docker = Docker(client: DockerHTTPClient(host: Configuration.Testcontainers))
                return self.docker.ping()
            }
        let infoFuture = pingFuture
            .flatMap { _ in
                self.docker.info()
            }
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
            self.docker.pull(image: self.name).map { image in
                self.image = image
                return image
            }
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
    
    func remove() -> EventLoopFuture<Void> {
        guard let container = container else {
            return docker.client.eventLoop.next().makeFailedFuture("Container not found")
        }
        
        return container.kill().flatMap { _ in
            container.remove()
        }
    }
}
