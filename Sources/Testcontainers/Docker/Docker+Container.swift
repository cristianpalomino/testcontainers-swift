//
//  Docker+Container.swift
//
//
//  Created by cristian on 6/08/24.
//

import Foundation
import NIOHTTP1
import NIOCore

extension Docker {
    
    final class Container {
        
        let id: String
        let client: DockerClientProtocol
        
        init(id: String, client: DockerClientProtocol) {
            self.id = id
            self.client = client
        }
    }
}

extension Docker.Container {
    
    func start() -> EventLoopFuture<Void> {
        let request = Docker.Container.Request.Start(id: id)
        return client.send(request)
    }
    
    func inspect() -> EventLoopFuture<ContainerInspectInfo> {
        let request = Docker.Container.Request.Get(id: id)
        return client.send(request)
    }
    
    func stop() -> EventLoopFuture<Void> {
        let request = Docker.Container.Request.Stop(id: id)
        return client.send(request)
    }
    
    func remove() -> EventLoopFuture<Void> {
        let request = Docker.Container.Request.Remove(id: id)
        return client.send(request)
    }
    
    func kill() -> EventLoopFuture<Void> {
        let request = Docker.Container.Request.Remove(id: id)
        return client.send(request)
    }
}
