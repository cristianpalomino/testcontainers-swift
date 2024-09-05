//
//  Request+Image.swift
//
//
//  Created by cristian on 7/08/24.
//

import Foundation
import NIOHTTP1

extension Docker.Image.Request {
    
    struct Create: Request {
        typealias Body = EmptyBody
        typealias Response = Void
        
        var path: String = "/images/create"
        var method: HTTPMethod = .POST
        var query: [String: String]? = [:]
        
        public init(params: DockerImageName) {
            self.query?["fromImage"] = params.name
            self.query?["tag"] = params.tag
        }
    }
}
