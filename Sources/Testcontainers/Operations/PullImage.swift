//
//  PullImage.swift
//
//
//  Created by cristian on 16/07/24.
//

import Foundation

final class PullImage: AsyncOperation, Request {
    let body: EmptyBody? = nil
    typealias Response = String
    
    var host: String = "http://localhost:2377"
    var path: String = "/images/create"
    var method: HTTPMethod = .post
    var query: [String : String]?
    
    private(set) var imageName: String?
    
    init(name: String) {
        self.query = ["fromImage": name,
                      "tag": "latest"]
    }
    
    override func main() {
        URLSession.shared.send(self) { [weak self] result in
            guard let self else { return }
            defer { finish() }
            
            switch result {
            case .success:
                guard let name = self.query?["fromImage"], let tag = self.query?["tag"] else {
                    fatalError("An error happened generating the image name")
                }
                self.imageName = "\(name):\(tag)"
            case let .failure(error):
                fatalError(error.localizedDescription)
            }
        }
    }
}
