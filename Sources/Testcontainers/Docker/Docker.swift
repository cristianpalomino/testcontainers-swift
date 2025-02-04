//
//  Docker.swift
//
//
//  Created by cristian on 6/08/24.
//

import Foundation
import NIOCore
import Logging

public protocol DockerOperations {
    var client: DockerClientProtocol { get }
    var logger: Logger { get }

    func ping() -> EventLoopFuture<Void>
    func info() -> EventLoopFuture<Info>
    func version() -> EventLoopFuture<Version>
    func pull(params: DockerImageName) -> EventLoopFuture<Void>
    func create(container configuration: ContainerConfig) -> EventLoopFuture<DockerContainerOperations>
}

final class Docker: DockerOperations {
    let client: DockerClientProtocol
    let logger: Logger

    init(client: DockerClientProtocol, logger: Logger) {
        self.client = client
        self.logger = logger
    }
}

extension Docker {

    func ping() -> EventLoopFuture<Void> {
        let request = Docker.Request.Ping()
        logger.debug("🐳 Sending ping request to host: \(client.host)")
        return client.send(request)
    }

    func info() -> EventLoopFuture<Info> {
        let request = Docker.Request.GetInfo()
        logger.debug("🐳 Sending info request to host: \(client.host)")
        return client.send(request)
    }

    func version() -> EventLoopFuture<Version> {
        let request = Docker.Request.GetVersion()
        logger.debug("🐳 Sending version request to host: \(client.host)")
        return client.send(request)
    }

    func pull(params: DockerImageName) -> EventLoopFuture<Void> {
        let request = Docker.Image.Request.Create(params: params)
        logger.info("🐳 Pulling image \(params.conventionName)...")
        return client.send(request)
    }

    func create(container configuration: ContainerConfig) -> EventLoopFuture<DockerContainerOperations> {
        let request = Docker.Container.Request.Create(configuration: configuration)
        logger.debug("📦 Creating container using configuration: \(configuration)")
        return client.send(request).map {
            self.logger.info("📦 Created container: \($0.Id)")
            return Docker.Container(id: $0.Id, client: self.client, logger: self.logger)
        }
    }
}

extension Docker.Container {
    enum Request { }
}

extension Docker.Image {
    enum Request { }
}

extension Docker {
    enum Request { }
}
