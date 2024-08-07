//
//  Request.swift
//
//
//  Created by cristian on 17/07/24.
//

import Foundation
import NIOHTTP1

extension String: Error { }

struct EmptyBody: Encodable { }
struct EmptyResponse: Decodable { }

protocol Request {
    associatedtype Body: Encodable
    associatedtype Response
    
    var host: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var parameters: [String: String]? { get set }
    var query: [String: String]? { get set }
    var headers: HTTPHeaders { get }
    var body: Body? { get }
    
    var encode: (Body?) throws -> Data { get }
    var decode: (Data) throws -> Response { get }
}

extension Request {
    
    var host: String {
        return Configuration.socketPath
    }
    
    var method: HTTPMethod {
        return .GET
    }
    
    var headers: HTTPHeaders {
        return [
            "Content-Type": "application/json",
            "User-Agent": "tc-swift/1.0.0",
            "Host": "localhost",
            "x-tc-sid": GenericContainer.uuid
        ]
    }
    
    var parameters: [String: String]? {
        get { return nil }
        set { }
    }
    
    var query: [String: String]? {
        get { return nil }
        set { }
    }
    
    var body: Body? {
        return nil
    }
    
    var encoder: (Body?) throws -> Data? {
        return { _ in
            return nil
        }
    }
}
