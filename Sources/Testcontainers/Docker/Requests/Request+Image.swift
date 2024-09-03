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
        
        public init(params: ImageParams) {
            self.query?["fromImage"] = params.name
            self.query?["tag"] = params.tag
            if let fromSrc = params.src {
                self.query?["fromSrc"] = fromSrc
            }
            if let repo = params.repo {
                self.query?["repo"] = repo
            }
        }
    }
}
