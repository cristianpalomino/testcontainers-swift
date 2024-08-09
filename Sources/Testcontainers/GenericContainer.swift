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
        return docker.ping()
            .catch { _ in
                self.docker = Docker(client: DockerHTTPClient(host: Configuration.Testcotainers))
                return self.docker.ping()
            }
            .flatMap { _ in
                self.docker.info()
            }
            .handleEvents(receiveOutput: { info in
                let serverInfo = """
                Connected to docker: 
                  Server Version: \(info.ServerVersion)
                  API Version:
                  Operating System: \(info.OperatingSystem)
                  Total Memory: \(info.MemTotal)
                  Labels: 
                    \(info.Labels)
                """
                print(serverInfo)
            })
            .flatMap { _ in
                self.docker.pull(image: self.name)
            }
            .handleEvents(receiveOutput: { image in
                self.image = image
            })
            .flatMap { _ in
                self.docker.create(container: self.configuration)
            }
            .handleEvents(receiveOutput: { container in
                self.container = container
            })
            .flatMap { container in
                container.start().map { container }
            }
            .flatMap { container in
                container.inspect()
            }
            .eraseToAnyPublisher()
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
