//
//  Request+Params.swift
//
//
//  Created by cristian on 6/08/24.
//

import Foundation

extension Request {
    
    func applyParamsIfAvailable() -> String {
        var pathWithParams = path
        if let parameters = parameters {
            for (key, value) in parameters {
                pathWithParams = pathWithParams.replacingOccurrences(of: ":\(key)", with: value)
            }
        }
        return pathWithParams
    }
}
