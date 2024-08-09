import Foundation
import AsyncHTTPClient
import Combine

public final class GenericContainer {
    
    static let uuid = UUID().uuidString
    
    private let name: String
    private let configuration: ContainerConfig
    
    private var docker: Docker
    private var container: Docker.Container?
    private var image: Docker.Image?
    private var cancellables = Set<AnyCancellable>()
    
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
    
    public func start() -> AnyPublisher<ContainerInspectInfo, Error> {
        let pingPublisher = docker.ping()
        let infoPublisher = pingPublisher
            .catch { _ in
                self.docker = Docker(client: DockerHTTPClient(host: Configuration.Testcotainers))
                return self.docker.ping()
            }
            .flatMap { _ in
                self.docker.info()
            }
        let versionPublisher = infoPublisher
            .combineLatest(self.docker.version())
        let serverInfoPublisher = versionPublisher
            .handleEvents(receiveOutput: { info, version in
                let labels = info.Labels
                var serverInfo = """
                Connected to docker: 
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
                print(serverInfo)
            })
        let pullPublisher = serverInfoPublisher
            .flatMap { _ in
                self.docker.pull(image: self.name)
            }
        let imagePublisher = pullPublisher
            .handleEvents(receiveOutput: { image in
                self.image = image
            })
        let createPublisher = imagePublisher
            .flatMap { _ in
                self.docker.create(container: self.configuration)
            }
        let containerPublisher = createPublisher
            .handleEvents(receiveOutput: { container in
                self.container = container
            })
        let startPublisher = containerPublisher
            .flatMap { container in
                container.start().map { container }
            }
        let inspectPublisher = startPublisher
            .flatMap { container in
                container.inspect()
            }
        let resultPublisher = inspectPublisher
            .eraseToAnyPublisher()
        
        return resultPublisher
    }
    
    func remove() -> AnyPublisher<Void, Error> {
        guard let container = container else {
            return Fail(error: "Container not found").eraseToAnyPublisher()
        }
        
        return container.kill()
            .flatMap { _ in
                container.remove()
            }
            .eraseToAnyPublisher()
    }
}
