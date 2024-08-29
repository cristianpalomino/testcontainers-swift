//
//  RootlessUnixSocketStrategy.swift
//  Testcontainers
//
//  Created by cristian on 20/08/24.
//

import Foundation
import Logging

final class RootlessUnixSocketStrategy: DockerClientStrategyProtocol {
    
    var logger = Logger(label: "RootlessUnixSocketStrategy")
    
    var home: URL {
        return FileManager.default.homeDirectoryForCurrentUser
    }
    
    var paths: [String] {
        if let dockerHost = ProcessInfo.processInfo.environment["DOCKER_HOST"],
        dockerHost.hasPrefix("unix://") {
            return [dockerHost.replacingOccurrences(of: "unix://", with: "")]
        }

        return [
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
