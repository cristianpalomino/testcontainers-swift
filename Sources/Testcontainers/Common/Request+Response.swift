//
//  Request+Response.swift
//
//
//  Created by cristian on 26/07/24.
//

import Foundation

extension Request where Response == Void {
    
    var decode: (Data) throws -> Response {
        return { _ in return () }
    }
}

extension Request where Response == String {
    
    var decode: (Data) throws -> Response {
        return {
            guard let string = String(data: $0, encoding: .utf8) else {
                fatalError("Unable to decode the received data to string.")
            }
            return string
        }
    }
}

extension Request where Response: Decodable {
    
    var decode: (Data) throws -> Response {
        return {
            let decoder = JSONDecoder()
            return try decoder.decode(Response.self, from: $0)
        }
    }
}
