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
    var containerId: String?
    var port: Int
    
    var host: String = "http://localhost:2377"
    var path: String = "/containers/create"
    var method: HTTPMethod = .post
    
    init(port: Int) {
        self.port = port
    }
    
    override func main() {
        guard let imageName = (dependencies.first as? PullImage)?.imageName else {
            finish()
            return
        }
        
        let portBinding = PortBinding(hostPort: "0")
        let portBindings = ["\(port)/tcp": [portBinding]]
        let hostConfig = HostConfig(portBindings: portBindings, capAdd: ["NET_ADMIN"])
        body = ContainerConfig(image: imageName, hostConfig: hostConfig)
        
        print("Creating Docker Container \(imageName)")
        
        URLSession.shared.send(self) { [weak self] result in
            guard let self else { return }
            defer { finish() }
            
            switch result {
            case let .success(response):
                self.containerId = response.Id
                print("Docker Container created successfully...!")
            case let .failure(error):
                print("An error happened creating the Docker Container...! \n\(error.localizedDescription)")
            }
        }
    }
}
