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
        
        let params: ImageParams
        let client: DockerClientProtocol
        
        init(params: ImageParams, client: DockerClientProtocol) {
            self.params = params
            self.client = client
        }
    }
}
