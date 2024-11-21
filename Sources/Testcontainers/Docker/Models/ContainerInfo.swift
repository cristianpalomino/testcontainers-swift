//
//  ContainerInfo.swift
//
//
//  Created by cristian on 6/08/24.
//

import Foundation

public struct ContainerInfo: Decodable {
    public let Id: String
    public let Names: [String]
    public let Image: String
    public let ImageID: String
    public let Command: String
    public let Created: Int
    public let Ports: [Port]
    public let Labels: [String: String]
    public let State: String
    public let Status: String
    public let HostConfig: HostConfig?
    public let NetworkSettings: NetworkSettings
    public let Mounts: [Mount]
}

public extension ContainerInfo {
    
    struct HostConfig: Decodable {
        public let NetworkMode: String
    }
    
    struct Port: Decodable {
        public let IP: String
        public let PrivatePort: Int
        public let PublicPort: Int
        public let `Type`: String
    }
    
    struct NetworkSettings: Decodable {
        public let Networks: [String: NetworkInfo]
    }
    
    struct NetworkInfo: Decodable {
        public let IPAMConfig: String?
        public let Links: String?
        public let Aliases: String?
        public let NetworkID: String
        public let EndpointID: String
        public let Gateway: String
        public let IPAddress: String
        public let IPPrefixLen: Int
        public let IPv6Gateway: String
        public let GlobalIPv6Address: String
        public let GlobalIPv6PrefixLen: Int
        public let MacAddress: String
    }
    
    struct Mount: Decodable {
        public let Name: String?
        public let `Type`: String
        public let Source: String
        public let Destination: String
        public let Driver: String?
        public let Mode: String
        public let RW: Bool
        public let Propagation: String
    }
}
