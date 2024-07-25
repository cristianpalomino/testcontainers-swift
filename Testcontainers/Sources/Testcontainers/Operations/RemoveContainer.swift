//
//  RemoveContainer.swift
//
//
//  Created by cristian on 16/07/24.
//

import Foundation

final class RemoveContainer: AsyncOperation, Request {
    let body: EmptyBody? = nil
    typealias Response = String
    
    var host: String = "http://localhost:2377"
    var path: String = "/containers/:id"
    var method: HTTPMethod = .delete
    var parameters: [String: String]?
    var query: [String: String]?
    
    let containerId: String
    
    init(containerId: String) {
        self.containerId = containerId
        self.parameters = ["id": containerId]
        self.query = ["v": "false", "force": "true"]
    }
    
    override func main() {
        print("Removing Docker container Id: \(containerId)")
        
        URLSession.shared.send(self) { [weak self] result in
            guard let self else { return }
            defer { finish() }
            
            switch result {
            case let .success(string):
                print(string)
                print("Docker container removed...!")
            case let .failure(error):
                print("An error happened removing the Docker container...!\n\(error.localizedDescription)")
            }
        }
    }
}
