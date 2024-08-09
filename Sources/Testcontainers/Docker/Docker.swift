//
//  Docker.swift
//
//
//  Created by cristian on 6/08/24.
//

import Foundation
import NIOCore

final class Docker {
    
    let client: DockerClientProtocol
    
    init(client: DockerClientProtocol) {
        self.client = client
    }
}

extension Docker {
    
    func ping() -> EventLoopFuture<Void> {
        let request = Docker.Request.Ping()
        return client.send(request)
    }
    
    func info() -> EventLoopFuture<Info> {
        let request = Docker.Request.GetInfo()
        return client.send(request)
    }
    
    func version() -> EventLoopFuture<Version> {
        let request = Docker.Request.GetVersion()
        return client.send(request)
    }
    
    func pull(image name: String) -> EventLoopFuture<Docker.Image> {
        let request = Docker.Image.Request.Create(fromImage: name)
        return client.send(request)
            .map { Docker.Image(name: name, client: self.client) }
    }
    
    func create(container configuration: ContainerConfig) -> EventLoopFuture<Docker.Container> {
        let request = Docker.Container.Request.Create(configuration: configuration)
        return client.send(request)
            .map { Docker.Container(id: $0.Id, client: self.client) }
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
