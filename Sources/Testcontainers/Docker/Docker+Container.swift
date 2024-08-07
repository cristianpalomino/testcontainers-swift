//
//  Container.swift
//
//
//  Created by cristian on 6/08/24.
//

import Foundation
import Combine
import NIOHTTP1

extension Docker {
    
    final class Container {
        
        let id: String
        let client: DockerClientProtocol
        
        init(id: String, client: DockerClientProtocol) {
            self.id = id
            self.client = client
        }
        
        func start() -> AnyPublisher<Void, Error> {
            let request = Docker.Container.Request.Start(id: id)
            return client.send(request)
        }
        
        func inspect() -> AnyPublisher<ContainerInspectInfo, Error> {
            let request = Docker.Container.Request.Get(id: id)
            return client.send(request)
        }
        
        func stop() -> AnyPublisher<Void, Error> {
            let request = Docker.Container.Request.Stop(id: id)
            return client.send(request)
        }
        
        func remove() -> AnyPublisher<Void, Error> {
            let request = Docker.Container.Request.Remove(id: id)
            return client.send(request)
        }
        
        func kill() -> AnyPublisher<Void, Error> {
            let request = Docker.Container.Request.Remove(id: id)
            return client.send(request)
        }
    }
}
