import Foundation
import AsyncHTTPClient
import Combine

public final class GenericContainer {
    
    static let uuid = UUID().uuidString
    
    private let name: String
    private let configuration: ContainerConfig
    
    private let docker: Docker
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
        let docker = Docker(client: HTTPClient.shared)
        self.init(name: name, configuration: configuration, docker: docker)
    }
    
    public func start() -> AnyPublisher<ContainerInspectInfo, Error> {
        return docker.pull(image: name)
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
    
    func stop() -> AnyPublisher<Void, Error> {
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
