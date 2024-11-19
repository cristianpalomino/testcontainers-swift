//
//  ContainerInspectInfo.swift
//
//
//  Created by cristian on 7/08/24.
//

import Foundation

public struct ContainerInspectInfo: Decodable {
    public let Id: String
    public let Created: String
    public let Path: String
    public let Args: [String]
    public let State: State
    public let Image: String
    public let ResolvConfPath: String
    public let HostnamePath: String
    public let HostsPath: String
    public let LogPath: String
    public let Name: String
    public let RestartCount: Int
    public let Driver: String
    public let Platform: String
    public let MountLabel: String
    public let ProcessLabel: String
    public let AppArmorProfile: String
    public let ExecIDs: String?
    public let HostConfig: HostConfig
    public let GraphDriver: GraphDriver
    public let Mounts: [Mount]
    public let Config: Config
    public let NetworkSettings: NetworkSettings
}

public extension ContainerInspectInfo {
    
    struct State: Decodable {
        public let Status: String
        public let Running: Bool
        public let Paused: Bool
        public let Restarting: Bool
        public let OOMKilled: Bool
        public let Dead: Bool
        public let Pid: Int
        public let ExitCode: Int
        public let Error: String
        public let StartedAt: String
        public let FinishedAt: String
    }
    
    struct HostConfig: Decodable {
        public let Binds: [String]?
        public let ContainerIDFile: String
        public let LogConfig: LogConfig
        public let NetworkMode: String
        public let PortBindings: [String: [PortBinding]]
        public let RestartPolicy: RestartPolicy
        public let AutoRemove: Bool
        public let VolumeDriver: String
        public let VolumesFrom: [String]?
        public let ConsoleSize: [Int]
        public let CapAdd: [String]
        public let CapDrop: [String]?
        public let CgroupnsMode: String
        public let Dns: [String]?
        public let DnsOptions: [String]?
        public let DnsSearch: [String]?
        public let ExtraHosts: [String]?
        public let GroupAdd: [String]?
        public let IpcMode: String
        public let Cgroup: String
        public let Links: [String]?
        public let OomScoreAdj: Int
        public let PidMode: String
        public let Privileged: Bool
        public let PublishAllPorts: Bool
        public let ReadonlyRootfs: Bool
        public let SecurityOpt: [String]?
        public let UTSMode: String
        public let UsernsMode: String
        public let ShmSize: Int
        public let Runtime: String
        public let Isolation: String
        public let CpuShares: Int
        public let Memory: Int
        public let NanoCpus: Int
        public let CgroupParent: String
        public let BlkioWeight: Int
        public let BlkioWeightDevice: [String]?
        public let BlkioDeviceReadBps: [String]?
        public let BlkioDeviceWriteBps: [String]?
        public let BlkioDeviceReadIOps: [String]?
        public let BlkioDeviceWriteIOps: [String]?
        public let CpuPeriod: Int
        public let CpuQuota: Int
        public let CpuRealtimePeriod: Int
        public let CpuRealtimeRuntime: Int
        public let CpusetCpus: String
        public let CpusetMems: String
        public let Devices: [String]?
        public let DeviceCgroupRules: [String]?
        public let DeviceRequests: [String]?
        public let MemoryReservation: Int
        public let MemorySwap: Int
        public let MemorySwappiness: Int?
        public let OomKillDisable: Bool?
        public let PidsLimit: Int?
        public let Ulimits: [String]?
        public let CpuCount: Int
        public let CpuPercent: Int
        public let IOMaximumIOps: Int
        public let IOMaximumBandwidth: Int
        public let MaskedPaths: [String]
        public let ReadonlyPaths: [String]
    }
    
    struct LogConfig: Decodable {
        let `Type`: String
        public let Config: [String: String]
    }
    
    struct PortBinding: Decodable {
        public let HostIp: String
        public let HostPort: String
    }
    
    struct RestartPolicy: Decodable {
        public let Name: String
        public let MaximumRetryCount: Int
    }
    
    struct GraphDriver: Decodable {
        public let Data: GraphDriverData?
        public let Name: String
    }
    
    struct GraphDriverData: Decodable {
        public let LowerDir: String
        public let MergedDir: String
        public let UpperDir: String
        public let WorkDir: String
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
    
    struct Config: Decodable {
        public let Hostname: String
        public let Domainname: String
        public let User: String
        public let AttachStdin: Bool
        public let AttachStdout: Bool
        public let AttachStderr: Bool
        public let ExposedPorts: [String: [String: String]]
        public let Tty: Bool
        public let OpenStdin: Bool
        public let StdinOnce: Bool
        public let Env: [String]
        public let Cmd: [String]?
        public let Image: String
//        public let Volumes: [String: String]?
        public let WorkingDir: String
        public let Entrypoint: [String]?
        public let OnBuild: [String]?
        public let Labels: [String: String]
    }
    
    struct NetworkSettings: Decodable {
        public let Bridge: String
        public let SandboxID: String
        public let SandboxKey: String
        public let Ports: [String: [PortBinding]?]
        public let HairpinMode: Bool
        public let LinkLocalIPv6Address: String
        public let LinkLocalIPv6PrefixLen: Int
        public let SecondaryIPAddresses: [String]?
        public let SecondaryIPv6Addresses: [String]?
        public let EndpointID: String
        public let Gateway: String
        public let GlobalIPv6Address: String
        public let GlobalIPv6PrefixLen: Int
        public let IPAddress: String
        public let IPPrefixLen: Int
        public let IPv6Gateway: String
        public let MacAddress: String
        public let Networks: [String: Network]
    }
    
    struct Network: Decodable {
        public let IPAMConfig: String?
        public let Links: String?
        public let Aliases: String?
        public let MacAddress: String
        public let DriverOpts: String?
        public let NetworkID: String
        public let EndpointID: String
        public let Gateway: String
        public let IPAddress: String
        public let IPPrefixLen: Int
        public let IPv6Gateway: String
        public let GlobalIPv6Address: String
        public let GlobalIPv6PrefixLen: Int
        public let DNSNames: [String]?
    }
}
