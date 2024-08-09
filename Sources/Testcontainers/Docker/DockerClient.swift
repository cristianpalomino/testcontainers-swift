//
//  DockerClient.swift
//  
//
//  Created by cristian on 9/08/24.
//

import Foundation
import AsyncHTTPClient
import NIOHTTP1
import NIOCore
import Logging

protocol DockerClientProtocol {
    var host: String { get }
    var eventLoop: EventLoop { get }
    
    func send<T: Testcontainers.Request>(request: T, completion: @escaping (Result<T.Response, Error>) -> Void)
    func send<T: Testcontainers.Request>(_ request: T) -> EventLoopFuture<T.Response>
}

final class DockerHTTPClient: DockerClientProtocol {
    
    var host: String
    let client: HTTPClient
    lazy var eventLoop = client.eventLoopGroup.next()
    
    private lazy var logger: Logger = {
        var logger = Logger(label: #file)
        logger.logLevel = .trace
        return logger
    }()
    
    init(host: String) {
        self.host = host
        let configuration = HTTPClient.Configuration()
        self.client = HTTPClient(configuration: configuration)
    }
    
    deinit {
        _ = client.shutdown()
    }
    
    func send<T: Testcontainers.Request>(request: T, completion: @escaping (Result<T.Response, Error>) -> Void) {
        client.execute(request: request.make(host: host), delegate: HTTPClientResponse(), logger: logger)
            .futureResult
            .whenComplete { result in
                switch result {
                case let .success(data):
                    do {
                        let response = try request.decode(data)
                        completion(.success(response))
                    } catch {
                        completion(.failure(error))
                    }
                case let .failure(error):
                    completion(.failure(error))
                }
            }
    }
    
    func send<T>(_ request: T) -> NIOCore.EventLoopFuture<T.Response> where T : Request {
        let promise = eventLoop.makePromise(of: T.Response.self)
        
        client.execute(request: request.make(host: host), delegate: HTTPClientResponse())
            .futureResult
            .whenComplete { result in
                switch result {
                case let .success(data):
                    do {
                        let response = try request.decode(data)
                        promise.succeed(response)
                    } catch {
                        promise.fail(error)
                    }
                case let .failure(error):
                    promise.fail(error)
                }
            }
        
        return promise.futureResult
    }
}
