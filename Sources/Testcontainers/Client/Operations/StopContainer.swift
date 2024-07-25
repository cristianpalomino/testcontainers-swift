//
//  StopContainer.swift
//
//
//  Created by cristian on 16/07/24.
//

import Foundation

final class StopContainer: AsyncOperation, Request {
    typealias Body = EmptyBody
    typealias Response = String
    
    var path: String = "/containers/:id/stop"
    var method: HTTPMethod = .post
    var parameters: [String: String]?
    
    let containerId: String
    
    init(containerId: String) {
        self.containerId = containerId
        self.parameters = ["id": containerId]
    }
    
    override func main() {
        URLSession.shared.send(self) { [weak self] result in
            guard let self else { return }
            defer { finish() }
            
            switch result {
            case let .success(string):
                print(string)
                print("Docker container stopped...!")
            case let .failure(error):
                fatalError(error.localizedDescription)
            }
        }
    }
}
