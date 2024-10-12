//
//  TestcontainersStrategy.swift
//  Testcontainers
//
//  Created by cristian on 20/08/24.
//

import Foundation
import Logging

struct TestcontainersStrategy: DockerClientStrategyProtocol {
    
    let logger: Logger = Logger(label: String(describing: TestcontainersStrategy.self))
    var paths: [String]
    
    init(paths: [String] = []) {
        self.paths = paths
        self.loadPaths()
    }
    
    mutating func loadPaths() {
        let home = FileManager.default.homeDirectoryForCurrentUser
        let path = home.appendingPathComponent(".testcontainers.properties").path
        let properties = loadProperties(from: path)
        if let tcHost = properties["tc.host"] {
            paths.append(tcHost.replacingOccurrences(of: "tcp", with: "http"))
        }
        if let dockerHost = properties["docker.host"] {
            paths.append(dockerHost.replacingOccurrences(of: "tcp", with: "http"))
        }
    }
    
    func getHosts() -> [String] {
        var hosts: [String] = []
        for path in paths {
            hosts.append(path)
        }
        return hosts
    }
    
    private func loadProperties(from path: String) -> [String: String] {
        var properties: [String: String] = [:]
        do {
            let fileContents = try String(contentsOfFile: path, encoding: .utf8)
            let lines = fileContents.split(separator: "\n")
            
            for line in lines {
                let trimmedLine = line.trimmingCharacters(in: .whitespaces)
                if trimmedLine.hasPrefix("#") || trimmedLine.isEmpty {
                    continue
                }
                let keyValue = trimmedLine.split(
                    separator: "=",
                    maxSplits: 1,
                    omittingEmptySubsequences: true
                )
                if keyValue.count == 2 {
                    let key = keyValue[0].trimmingCharacters(in: .whitespaces)
                    let value = keyValue[1].trimmingCharacters(in: .whitespaces)
                    properties[key] = value
                }
            }
        } catch {
            logger.debug("Error reading the file: \(String(describing: error))")
        }
        
        return properties
    }
}
