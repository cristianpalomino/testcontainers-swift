//
//  Docker+Container.swift
//
//
//  Created by cristian on 6/08/24.
//

import Foundation
import NIOHTTP1
import NIOCore
import Logging

public protocol DockerContainerOperations {
    func start() -> EventLoopFuture<Void>
    func inspect() -> EventLoopFuture<ContainerInspectInfo>
    func stop() -> EventLoopFuture<Void>
    func remove() -> EventLoopFuture<Void>
    func kill() -> EventLoopFuture<Void>
}

extension Docker {

    final class Container {

        let id: String
        let client: DockerClientProtocol
        let logger: Logger

        init(id: String, client: DockerClientProtocol, logger: Logger) {
            self.id = id
            self.client = client
            self.logger = logger
        }
    }
}

extension Docker.Container: DockerContainerOperations {

    func start() -> EventLoopFuture<Void> {
        let request = Docker.Container.Request.Start(id: id)
        logger.info("📦 Starting container \(id)...")
        return client.send(request)
    }

    func inspect() -> EventLoopFuture<ContainerInspectInfo> {
        let request = Docker.Container.Request.Get(id: id)
        logger.debug("🔍 Inspecting container \(id)...")
        return client.send(request)
    }

    func stop() -> EventLoopFuture<Void> {
        let request = Docker.Container.Request.Stop(id: id)
        logger.info("📦 Stopping container \(id)...")
        return client.send(request)
    }

    func remove() -> EventLoopFuture<Void> {
        let request = Docker.Container.Request.Remove(id: id)
        logger.info("📦 Removing container \(id)...")
        return client.send(request)
    }

    func kill() -> EventLoopFuture<Void> {
        let request = Docker.Container.Request.Remove(id: id)
        logger.warning("⚠ Killing container \(id)...")
        return client.send(request)
    }
}
