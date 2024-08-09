//
//  Congfiguration.swift
//
//
//  Created by cristian on 26/07/24.
//

import Foundation

struct Configuration {
    
    static let DockerLocal: String = "/var/run/docker.sock" // Local
    static let Testcotainers: String = "http://127.0.0.1:53084" // To read from ~/.testcontainers.properties
}
