//
//  Request+HTTPClientRequest.swift
//
//
//  Created by cristian on 6/08/24.
//

import Foundation
import AsyncHTTPClient
import NIOHTTP1
import Logging

extension Request {
    
    func make(host: String, logger: Logger) -> HTTPClient.Request {
        let endpoint = applyQueriesIfAvailable(to: applyParamsIfAvailable())
        
        let url = (host.contains("http")) ? URL(string: "\(host)\(endpoint)") : URL(httpURLWithSocketPath: host, uri: endpoint)
        
        guard let url = url else {
            fatalError("Unable to create a valid URL.")
        }
        
        do {
            let body = try encode(body)
            let request = try HTTPClient.Request(
                url: url,
                method: method,
                headers: headers,
                body: .data(body)
            )
            
            let log = """
            \nSending
            URL: \(request.url)|\(request.method)
            Body: \(String(data: body, encoding: .utf8) ?? "-")
            """
            logger.info(Logger.Message(stringLiteral: log))
            
            return request
        } catch {
            fatalError(String(describing: error))
        }
    }
}
