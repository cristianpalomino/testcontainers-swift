//
//  Docker+ClientStrategy.swift
//  Testcontainers
//
//  Created by cristian on 20/08/24.
//

import Foundation
import Logging
import NIO

final class DockerClientStrategy {
    
    var strategies: [DockerClientStrategyProtocol] = [
        TestcontainersStrategy(),
        UnixSocketStrategy()
    ]
    
    func resolve() -> DockerHTTPClient? {
        for strategy in strategies {
            if let client = strategy.resolve() {
                return client
            }
        }
        return nil
    }
}

protocol DockerClientStrategyProtocol {
    var logger: Logger { get }
    var paths: [String] { get }
    func getHosts() -> [String]
    func resolve() -> DockerHTTPClient?
}

extension DockerClientStrategyProtocol {
    
    func resolve() -> DockerHTTPClient? {
        let dispatchGroup = DispatchGroup()
        var client: DockerHTTPClient?
        let queue = DispatchQueue(label: "testcontainers.client.strategy")
        
        for host in getHosts() {
            dispatchGroup.enter()
            logger.info("Resolving host: \(host)")
            
            let hostClient = DockerHTTPClient(host: host)
            let docker = Docker(client: hostClient)
            
            docker.ping().whenComplete { result in
                queue.sync {
                    if client == nil {
                        switch result {
                        case .success:
                            self.logger.info("Successfull ping to host: \(host)")
                            client = hostClient
                        case .failure(let error):
                            self.logger.warning("Failed ping to host: \(host), error: \(error)")
                        }
                    }
                    dispatchGroup.leave()
                }
            }
        }
        
        dispatchGroup.wait()
        return client
    }
}
