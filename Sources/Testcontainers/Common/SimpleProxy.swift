//
//  SimpleProxy.swift
//
//
//  Created by cristian on 17/07/24.
//

import Vapor

final class SimpleProxy {
    
    let app: Application
    let client: UnixSocketClient
    
    init() {
        self.app = Application(.testing)
        self.client = UnixSocketClient()
        try? configure(app)
    }
    
    func start() throws {
        guard client.open() else {
            fatalError("Unable to connect to \(client.host)")
        }
        try app.start()
    }
    
    func stop() {
        client.close()
        app.shutdown()
    }
    
    func configure(_ app: Application) throws {
        app.http.server.configuration.port = 8001

//        app.post("unix", use: unix)
        app.get("proxy", use: proxy)
        app.post("proxy", use: proxy)
        app.delete("proxy", use: proxy)
    }
    
    func unix(req: Vapor.Request) throws -> EventLoopFuture<Vapor.Response> {
        guard let body = req.body.string else {
            throw Abort(.badRequest, reason: "No body found...!")
        }
        
        guard let unixResponse = client.sendRequest(body),
              let data = unixResponse.data(using: .utf8)
        else {
            throw Abort(.internalServerError)
        }
        
        let response = Vapor.Response(
            status: .ok,
            headers: [:],
            body: Response.Body(data: data)
        )
        return req.client.eventLoop.makeSucceededFuture(response)
    }
    
    func proxy(req: Vapor.Request) throws -> EventLoopFuture<Vapor.Response> {
        let baseURL = req.url.string.replacingOccurrences(of: "/proxy?url=", with: "")
        let baseURI = URI(string: baseURL)
        
        let clientRequest = ClientRequest(
            method: req.method,
            url: baseURI,
            headers: req.headers,
            body: req.body.data
        )
        
        return req.client.send(clientRequest).map { (clientResponse: Vapor.ClientResponse) in
            let responseBody: Vapor.Response.Body
            if let buffer = clientResponse.body {
                responseBody = Vapor.Response.Body(buffer: buffer)
            } else {
                responseBody = Vapor.Response.Body()
            }
            
            let response = Vapor.Response(
                status: clientResponse.status,
                headers: clientResponse.headers,
                body: responseBody
            )
            return response
        }
    }
}
