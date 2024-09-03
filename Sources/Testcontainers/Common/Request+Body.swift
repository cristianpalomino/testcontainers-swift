//
//  Request+Body.swift
//
//
//  Created by cristian on 26/07/24.
//

import Foundation

extension Request where Body: Encodable {
    
    var encode: (Body?) throws -> Data {
        return { body in
            do {
                return try JSONEncoder().encode(body)
            } catch {
                fatalError(String(describing: error))
            }
        }
    }
}
