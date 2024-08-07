//
//  Request+Container.swift
//
//
//  Created by cristian on 7/08/24.
//

import Foundation
import NIOHTTP1
import AsyncHTTPClient

extension Docker.Container.Request {
    
    struct Create: Request {
        struct Response: Decodable {
            let Id: String
            let Warnings: [String]
        }
        
        var body: ContainerConfig?
        var path: String = "/containers/create"
        var method: HTTPMethod = .POST
        
        init(configuration: ContainerConfig) {
            self.body = configuration
        }
    }
    
    struct Start: Request {
        typealias Body = EmptyBody
        typealias Response = Void
        
        var path: String = "/containers/:id/start"
        var method: HTTPMethod = .POST
        var parameters: [String: String]? = [:]
        
        init(id: String) {
            self.parameters = ["id": id]
        }
    }
    
    struct Stop: Request {
        typealias Body = EmptyBody
        typealias Response = Void
        
        var path: String = "/containers/:id/stop"
        var method: HTTPMethod = .POST
        var parameters: [String: String]? = [:]
        
        init(id: String) {
            self.parameters = ["id": id]
        }
    }
    
    struct Get: Request {
        typealias Body = EmptyBody
        typealias Response = ContainerInspectInfo
        
        var path: String = "/containers/:id/json"
        var method: HTTPMethod = .GET
        var query: [String: String]?
        var parameters: [String: String]?
        
        init(
            id: String,
            size: String = "false"
        ) {
            self.parameters = ["id": id]
            self.query = ["size": size]
        }
    }
    
    struct List: Request {
        typealias Body = EmptyBody
        typealias Response = [ContainerInfo]
        
        var path: String = "/containers/json"
        var method: HTTPMethod = .GET
        var query: [String: String]?
        
        init(
            all: String = "true",
            limit: String? = nil,
            size: String? = nil,
            filters: String? = nil
        ) {
            self.query = ["all": all]
            if let limit = limit {
                self.query?["limit"] = limit
            }
            if let size = size {
                self.query?["size"] = size
            }
            if let filters = filters {
                self.query?["filters"] = filters
            }
        }
    }
    
    struct Kill: Request {
        typealias Body = EmptyBody
        typealias Response = Void
        
        var path: String = "/containers/:id/kill"
        var method: HTTPMethod = .POST
        var parameters: [String : String]?
        var query: [String: String]?
        
        init(
            id: String,
            signal: String = "SIGKILL"
        ) {
            self.parameters = ["id": id]
            self.query = ["signal": signal]
        }
    }
    
    struct Remove: Request {
        typealias Body = EmptyBody
        typealias Response = Void
        
        var path: String = "/containers/:id"
        var method: HTTPMethod = .DELETE
        var parameters: [String : String]?
        var query: [String: String]?
        
        init(
            id: String,
            force: String = "true",
            v: String? = nil,
            link: String? = nil
        ) {
            self.parameters = ["id": id]
            self.query = ["force": force]
            if let v = v {
                self.query?["v"] = v
            }
            if let link = link {
                self.query?["link"] = link
            }
        }
    }
}
