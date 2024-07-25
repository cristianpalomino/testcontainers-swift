//
//  StartContainer.swift
//
//
//  Created by cristian on 16/07/24.
//

import Foundation

final class StartContainer: AsyncOperation, Request {
    let body: EmptyBody? = nil
    typealias Response = String
    
    var host: String = "http://localhost:2377"
    var path: String = "/containers/:id/start"
    var method: HTTPMethod = .post
    var parameters: [String: String]?
    
    var containerId: String?
    
    init(containerId: String? = nil) {
        self.containerId = containerId
    }
    
    override func main() {
        guard let id = containerId else {
            fatalError("Unable to start the container, missing the container id")
        }
        parameters = ["id": id]
        
        URLSession.shared.send(self) { [weak self] result in
            guard let self else { return }
            defer { finish() }
            
            switch result {
            case let .success(string):
                print(string)
            case let .failure(error):
                fatalError(error.localizedDescription)
            }
        }
    }
}
