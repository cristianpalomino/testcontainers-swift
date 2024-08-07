//
//  Request+Query.swift
//
//
//  Created by cristian on 6/08/24.
//

import Foundation

extension Request {
    
    func applyQueriesIfAvailable(to pathWithParams: String) -> String {
        var pathWithQueries = pathWithParams
        
        if let query = query, !query.isEmpty {
            let separator = pathWithParams.contains("?") ? "&" : "?"
            pathWithQueries.append(separator)
            
            let queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }
            let queryString = queryItems.map { "\($0.name)=\($0.value ?? "")" }.joined(separator: "&")
            
            pathWithQueries.append(queryString)
        }
        
        return pathWithQueries
    }
}
