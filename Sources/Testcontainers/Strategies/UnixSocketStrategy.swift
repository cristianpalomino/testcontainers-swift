//
//  UnixSocketStrategy.swift
//  Testcontainers
//
//  Created by cristian on 20/08/24.
//

import Foundation
import Logging

final class UnixSocketStrategy: DockerClientStrategyProtocol {
    let logger: Logger
    
    init(logger: Logger) {
        self.logger = logger
    }
    
    var home: URL {
#if os(iOS)
        return URL(fileURLWithPath: NSHomeDirectory())
#else
        return FileManager.default.homeDirectoryForCurrentUser
#endif
    }
    
    var paths: [String] {
        if let dockerHost = ProcessInfo.processInfo.environment["DOCKER_HOST"],
           dockerHost.hasPrefix("unix://") {
            return [dockerHost.replacingOccurrences(of: "unix://", with: "")]
        }
        
        return [
            "/var/run/docker.sock",
            getSocketPathFromHomeRunDir().relativePath,
            getSocketPathFromHomeDesktopDir().relativePath,
            getSocketPathFromRunDir().relativePath
        ]
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
    
    private func getSocketPathFromHomeRunDir() -> URL {
        return home
            .appendingPathComponent(".docker")
            .appendingPathComponent("run")
            .appendingPathComponent("docker.sock")
    }
    
    private func getSocketPathFromHomeDesktopDir() -> URL {
        return home
            .appendingPathComponent(".docker")
            .appendingPathComponent("desktop")
            .appendingPathComponent("docker.sock")
    }
    
    private func getSocketPathFromRunDir() -> URL {
        let uid = getuid()
        return URL(fileURLWithPath: "/run")
            .appendingPathComponent("user")
            .appendingPathComponent(String(uid))
            .appendingPathComponent("docker.sock")
    }
}
