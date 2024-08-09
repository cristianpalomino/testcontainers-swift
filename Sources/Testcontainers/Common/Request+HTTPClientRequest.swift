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
    
    func make(host: String) -> HTTPClient.Request {
        let endpoint = applyQueriesIfAvailable(to: applyParamsIfAvailable())
        
        let url = (host.contains("http")) ? URL(string: "\(host)\(endpoint)") : URL(httpURLWithSocketPath: host, uri: endpoint)
        
        guard let url = url else {
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
