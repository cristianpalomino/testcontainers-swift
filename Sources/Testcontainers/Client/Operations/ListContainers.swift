//
//  ListContainers.swift
//
//
//  Created by cristian on 16/07/24.
//

import Foundation

final class ListContainers: AsyncOperation, Request {
    let body: EmptyBody? = nil
    typealias Response = [DockerContainer]
    
    var path: String = "/containers/json"
    var method: HTTPMethod = .get
    var query: [String: String]? = ["all": "true"]
    
    var containers: [DockerContainer]?
    
    override func main() {
        URLSession.shared.send(self) { [weak self] result in
            guard let self else { return }
            defer { finish() }
            
            switch result {
            case let .success(containers):
                self.containers = containers
            case let .failure(error):
                fatalError(error.localizedDescription)
            }
        }
    }
}

extension ListContainers {
    struct DockerContainer: Decodable {
        let id: String
        let names: [String]
        let image: String
        let imageID: String
        let command: String
        let created: Int
        let ports: [Port]
        let labels: [String: String]?
        let state: String
        let status: String
        let hostConfig: HostConfig
        let networkSettings: NetworkSettings
        let mounts: [Mount]
        
        enum CodingKeys: String, CodingKey {
            case id = "Id"
            case names = "Names"
            case image = "Image"
            case imageID = "ImageID"
            case command = "Command"
            case created = "Created"
            case ports = "Ports"
            case labels = "Labels"
            case state = "State"
            case status = "Status"
            case hostConfig = "HostConfig"
            case networkSettings = "NetworkSettings"
            case mounts = "Mounts"
        }
    }
    
    struct Port: Decodable { }
    
    struct HostConfig: Decodable {
        let networkMode: String
        
        enum CodingKeys: String, CodingKey {
            case networkMode = "NetworkMode"
        }
    }
    
    struct NetworkSettings: Decodable {
        let networks: Networks
        
        enum CodingKeys: String, CodingKey {
            case networks = "Networks"
        }
    }
    
    struct Networks: Decodable {
        let bridge: Bridge
        
        enum CodingKeys: String, CodingKey {
            case bridge = "bridge"
        }
    }
    
    struct Bridge: Decodable {
        let ipamConfig: String?
        let links: String?
        let aliases: String?
        let macAddress: String
        let driverOpts: String?
        let networkID: String
        let endpointID: String
        let gateway: String
        let ipAddress: String
        let ipPrefixLen: Int
        let ipv6Gateway: String
        let globalIPv6Address: String
        let globalIPv6PrefixLen: Int
        let dnsNames: String?
        
        enum CodingKeys: String, CodingKey {
            case ipamConfig = "IPAMConfig"
            case links = "Links"
            case aliases = "Aliases"
            case macAddress = "MacAddress"
            case driverOpts = "DriverOpts"
            case networkID = "NetworkID"
            case endpointID = "EndpointID"
            case gateway = "Gateway"
            case ipAddress = "IPAddress"
            case ipPrefixLen = "IPPrefixLen"
            case ipv6Gateway = "IPv6Gateway"
            case globalIPv6Address = "GlobalIPv6Address"
            case globalIPv6PrefixLen = "GlobalIPv6PrefixLen"
            case dnsNames = "DNSNames"
        }
    }
    
    struct Mount: Decodable {
        let type: String
        let name: String
        let source: String
        let destination: String
        let driver: String
        let mode: String
        let rw: Bool
        let propagation: String
        
        enum CodingKeys: String, CodingKey {
            case type = "Type"
            case name = "Name"
            case source = "Source"
            case destination = "Destination"
            case driver = "Driver"
            case mode = "Mode"
            case rw = "RW"
            case propagation = "Propagation"
        }
    }
}
