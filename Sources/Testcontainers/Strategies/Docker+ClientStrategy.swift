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

    let logger: Logger
    let strategies: [DockerClientStrategyProtocol]

    init(logger: Logger, strategies: [DockerClientStrategyProtocol] = []) {
        self.logger = logger
        if strategies.isEmpty {
            self.strategies = [
                TestcontainersStrategy(logger: logger),
                UnixSocketStrategy(logger: logger)
            ]
        } else {
            self.strategies = strategies
        }
    }

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
            logger.debug("Resolving Docker host: \(host)")

            let hostClient = DockerHTTPClient(host: host)
            let docker = Docker(client: hostClient, logger: logger)

            docker.ping().whenComplete { result in
                queue.sync {
                    if client == nil {
                        switch result {
                        case .success:
                            let hostName = URL(string: host)?.host(percentEncoded: false) ?? host
                            self.logger.info("🐳 Resolved Docker host at: \(hostName)")
                            client = hostClient
                        case .failure(let error):
                            self.logger.debug("Failed ping to host: \(host), error: \(error)")
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
