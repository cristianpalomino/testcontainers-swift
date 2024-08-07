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
        
        public init(
            fromImage: String,
            fromSrc: String? = nil,
            repo: String? = nil,
            tag: String = "latest"
        ) {
            self.query?["fromImage"] = fromImage
            self.query?["tag"] = tag
            if let fromSrc = fromSrc {
                self.query?["fromSrc"] = fromSrc
            }
            if let repo = repo {
                self.query?["repo"] = repo
            }
        }
    }
}
