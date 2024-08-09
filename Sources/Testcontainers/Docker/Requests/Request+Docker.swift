//
//  Request+Docker.swift
//
//
//  Created by cristian on 8/08/24.
//

import Foundation
import NIOHTTP1
import AsyncHTTPClient

extension Docker.Request {
    
    struct Ping: Request {
        typealias Body = EmptyBody
        typealias Response = Void
        
        var path: String = "/_ping"
        var method: HTTPMethod = .GET
    }

    struct GetInfo: Request {
        typealias Body = EmptyBody
        typealias Response = Info
        
        var path: String = "/info"
        var method: HTTPMethod = .GET
    }
}
