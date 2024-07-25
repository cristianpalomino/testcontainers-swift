//
//  CreateContainer.swift
//
//
//  Created by cristian on 16/07/24.
//

import Foundation

final class CreateContainer: AsyncOperation, Request {
    typealias Body = ContainerConfig
    typealias Response = Container
    
    struct Container: Decodable {
        let Id: String
    }
    
    var body: ContainerConfig?
    var host: String = "http://localhost:2377"
    var path: String = "/containers/create"
    var method: HTTPMethod = .post
    
    var imageName: String?
    private(set) var containerId: String?
    private let exposedPort: Int
    
    init(exposedPort: Int) {
        self.exposedPort = exposedPort
    }
    
    override func main() {
        guard let imageName = imageName else {
            fatalError("Unable to create the container, missing the image name")
        }
        
        let portBinding = PortBinding(hostPort: "0")
        let portBindings = ["\(exposedPort)/tcp": [portBinding]]
        let hostConfig = HostConfig(portBindings: portBindings, capAdd: ["NET_ADMIN"])
        body = ContainerConfig(image: imageName, hostConfig: hostConfig)
        
        URLSession.shared.send(self) { [weak self] result in
            guard let self else { return }
            defer { finish() }
            
            switch result {
            case let .success(response):
                self.containerId = response.Id
            case let .failure(error):
                fatalError(error.localizedDescription)
            }
        }
    }
}
