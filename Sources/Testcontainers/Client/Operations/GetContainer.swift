//
//  GetContainer.swift
//
//
//  Created by cristian on 16/07/24.
//

import Foundation

final class GetContainer: AsyncOperation, Request {
    let body: EmptyBody? = nil
    typealias Response = DockerContainer
    
    var path: String = "/containers/:id/json"
    var method: HTTPMethod = .get
    var parameters: [String: String]?
    
    var port: String?
    var containerId: String?
    private let exposedPort: Int
    
    init(containerId: String? = nil, exposedPort: Int) {
        self.exposedPort = exposedPort
        self.containerId = containerId
    }
    
    override func main() {
        guard let id = containerId else {
            fatalError("Unable to start the container, missing the container id")
        }
        parameters = ["id": id]
        
        URLSession.shared.send(self) { [weak self] result in
            guard let self else { return }
            defer { finish() }
            
            switch result {
            case let .success(response):
                self.port = response.networkSettings.ports?["\(exposedPort)/tcp"]??.first?.hostPort
            case let .failure(error):
                fatalError(error.localizedDescription)
            }
        }
    }
}

extension GetContainer {
    struct DockerContainer: Decodable {
        let id: String
        let created: String
        let name: String
        let networkSettings: NetworkSettings
        
        enum CodingKeys: String, CodingKey {
            case id = "Id"
            case created = "Created"
            case name = "Name"
            case networkSettings = "NetworkSettings"
        }
    }
    
    struct NetworkSettings: Decodable {
        let bridge: String?
        let sandboxID: String?
        let sandboxKey: String?
        let ports: [String: [Port]?]?
        let hairpinMode: Bool?
        let linkLocalIPv6Address: String?
        let linkLocalIPv6PrefixLen: Int?
        let secondaryIPAddresses: [String]?
        let secondaryIPv6Addresses: [String]?
        let endpointID: String?
        let gateway: String?
        let globalIPv6Address: String?
        let globalIPv6PrefixLen: Int?
        let ipAddress: String?
        let ipPrefixLen: Int?
        let ipv6Gateway: String?
        let macAddress: String?
        let networks: Networks?
        
        enum CodingKeys: String, CodingKey {
            case bridge = "Bridge"
            case sandboxID = "SandboxID"
            case sandboxKey = "SandboxKey"
            case ports = "Ports"
            case hairpinMode = "HairpinMode"
            case linkLocalIPv6Address = "LinkLocalIPv6Address"
            case linkLocalIPv6PrefixLen = "LinkLocalIPv6PrefixLen"
            case secondaryIPAddresses = "SecondaryIPAddresses"
            case secondaryIPv6Addresses = "SecondaryIPv6Addresses"
            case endpointID = "EndpointID"
            case gateway = "Gateway"
            case globalIPv6Address = "GlobalIPv6Address"
            case globalIPv6PrefixLen = "GlobalIPv6PrefixLen"
            case ipAddress = "IPAddress"
            case ipPrefixLen = "IPPrefixLen"
            case ipv6Gateway = "IPv6Gateway"
            case macAddress = "MacAddress"
            case networks = "Networks"
        }
    }
    
    struct Port: Decodable {
        let hostIp: String?
        let hostPort: String?
        
        enum CodingKeys: String, CodingKey {
            case hostIp = "HostIp"
            case hostPort = "HostPort"
        }
    }
    
    struct Networks: Decodable {
        let bridge: Bridge?
        
        enum CodingKeys: String, CodingKey {
            case bridge = "bridge"
        }
    }
    
    struct Bridge: Decodable {
        let links: [String]?
        let aliases: [String]?
        let macAddress: String?
        let driverOpts: [String: String]?
        let networkID: String?
        let endpointID: String?
        let gateway: String?
        let ipAddress: String?
        let ipPrefixLen: Int?
        let ipv6Gateway: String?
        let globalIPv6Address: String?
        let globalIPv6PrefixLen: Int?
        let dnsNames: [String]?
        
        enum CodingKeys: String, CodingKey {
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
}
