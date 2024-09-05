//
//  Image.swift
//
//
//  Created by cristian on 6/08/24.
//

import Foundation
import NIOHTTP1

extension Docker {
    
    final class Image {
        
        let params: DockerImageName
        let client: DockerClientProtocol
        
        init(params: DockerImageName, client: DockerClientProtocol) {
            self.params = params
            self.client = client
        }
    }
}
