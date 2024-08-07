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
        
        let name: String
        let client: DockerClientProtocol
        
        init(name: String, client: DockerClientProtocol) {
            self.name = name
            self.client = client
        }
    }
}
