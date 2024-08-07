//
//  Request+HTTPClientRequest.swift
//
//
//  Created by cristian on 6/08/24.
//

import Foundation
import AsyncHTTPClient
import NIOHTTP1

extension Request {
    
    func make() -> HTTPClient.Request {
        let endpoint = applyQueriesIfAvailable(to: applyParamsIfAvailable())
        
        guard let url = URL(httpURLWithSocketPath: host, uri: endpoint) else {
            fatalError("Unable to create a valid URL.")
        }
        
        do {
            let request = try HTTPClient.Request(
                url: url,
                method: method,
                headers: headers,
                body: .data(try encode(body))
            )
            return request
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}
