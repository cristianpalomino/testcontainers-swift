//
//  UnixSocketStrategy.swift
//  Testcontainers
//
//  Created by cristian on 20/08/24.
//

import Foundation
import Logging

final class UnixSocketStrategy: DockerClientStrategyProtocol {
    
    let logger: Logger = Logger(label: String(describing: UnixSocketStrategy.self))
    
    var paths: [String] {
        return ["/var/run/docker.sock"]
    }
    
    func getHosts() -> [String] {
        var hosts: [String] = []
        for path in paths {
            guard let host = path.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
                continue
            }
            let urlString = "http+unix://\(host)"
            hosts.append(urlString)
        }
        return hosts
    }
}
