//
//  ListImages.swift
//
//
//  Created by cristian on 16/07/24.
//

import Foundation

final class ListImages: AsyncOperation, Request {
    let body: EmptyBody? = nil
    typealias Response = [DockerImage]
    
    var host: String = "http://localhost:2377"
    var path: String = "/images/json"
    var method: HTTPMethod = .get
    var query: [String: String]? = ["all": "true"]
    
    var images: [DockerImage]?
    
    override func main() {
        URLSession.shared.send(self) { [weak self] result in
            guard let self else { return }
            defer { finish() }
            
            switch result {
            case let .success(images):
                self.images = images
            case let .failure(failure):
                print("\(#function)\n\(failure.localizedDescription)")
            }
        }
    }
}

struct DockerImage: Decodable {
    let containers: Int
    let created: Int
    let id: String
    let labels: [String: String]?
    let parentId: String
    let repoDigests: [String]
    let repoTags: [String]
    let sharedSize: Int
    let size: Int
    
    enum CodingKeys: String, CodingKey {
        case containers = "Containers"
        case created = "Created"
        case id = "Id"
        case labels = "Labels"
        case parentId = "ParentId"
        case repoDigests = "RepoDigests"
        case repoTags = "RepoTags"
        case sharedSize = "SharedSize"
        case size = "Size"
    }
}
