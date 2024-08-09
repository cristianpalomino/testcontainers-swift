//
//  ContainerConfig.swift
//
//
//  Created by cristian on 24/07/24.
//

import Foundation

extension ContainerConfig {
    
    static func build(image name: String, exposed port: Int) -> ContainerConfig {
        let portBinding = PortBinding(hostPort: "0")
        let portBindings = ["\(port)/tcp": [portBinding]]
        return ContainerConfig(
            image: name,
            labels: ["org.testcontainers.lang": "swift",
                     "org.testcontainers": "true",
                     "org.testcontainers.version": "0.0.1"],
            hostConfig: .init(portBindings: portBindings, capAdd: ["NET_ADMIN"])
        )
    }
}

public struct ContainerConfig: Codable {
    public var Hostname: String?
    public var Domainname: String?
    public var User: String?
    public var AttachStdin: Bool?
    public var AttachStdout: Bool?
    public var AttachStderr: Bool?
    public var Tty: Bool?
    public var OpenStdin: Bool?
    public var StdinOnce: Bool?
    public var Env: [String]?
    public var Cmd: [String]?
    public var Entrypoint: String?
    public var Image: String
    public var Labels: [String: String]?
    public var Volumes: [String: Volume]?
    public var WorkingDir: String?
    public var NetworkDisabled: Bool?
    public var MacAddress: String?
    public var ExposedPorts: [String: ExposedPort]?
    public var StopSignal: String?
    public var StopTimeout: Int?
    public var HostConfig: HostConfig?
    public var NetworkingConfig: NetworkingConfig?
    
    public init(hostname: String? = nil, domainname: String? = nil, user: String? = nil, attachStdin: Bool? = nil, attachStdout: Bool? = nil, attachStderr: Bool? = nil, tty: Bool? = nil, openStdin: Bool? = nil, stdinOnce: Bool? = nil, env: [String]? = nil, cmd: [String]? = nil, entrypoint: String? = nil, image: String, labels: [String : String]? = nil, volumes: [String : Volume]? = nil, workingDir: String? = nil, networkDisabled: Bool? = nil, macAddress: String? = nil, exposedPorts: [String : ExposedPort]? = nil, stopSignal: String? = nil, stopTimeout: Int? = nil, hostConfig: HostConfig? = nil, networkingConfig: NetworkingConfig? = nil) {
        self.Hostname = hostname
        self.Domainname = domainname
        self.User = user
        self.AttachStdin = attachStdin
        self.AttachStdout = attachStdout
        self.AttachStderr = attachStderr
        self.Tty = tty
        self.OpenStdin = openStdin
        self.StdinOnce = stdinOnce
        self.Env = env
        self.Cmd = cmd
        self.Entrypoint = entrypoint
        self.Image = image
        self.Labels = labels
        self.Volumes = volumes
        self.WorkingDir = workingDir
        self.NetworkDisabled = networkDisabled
        self.MacAddress = macAddress
        self.ExposedPorts = exposedPorts
        self.StopSignal = stopSignal
        self.StopTimeout = stopTimeout
        self.HostConfig = hostConfig
        self.NetworkingConfig = networkingConfig
    }
}

public struct Volume: Codable {}

public struct ExposedPort: Codable {}

public struct HostConfig: Codable {
    public var Binds: [String]?
    public var Links: [String]?
    public var Memory: Int?
    public var MemorySwap: Int?
    public var MemoryReservation: Int?
    public var NanoCpus: Int?
    public var CpuPercent: Int?
    public var CpuShares: Int?
    public var CpuPeriod: Int?
    public var CpuRealtimePeriod: Int?
    public var CpuRealtimeRuntime: Int?
    public var CpuQuota: Int?
    public var CpusetCpus: String?
    public var CpusetMems: String?
    public var MaximumIOps: Int?
    public var MaximumIOBps: Int?
    public var BlkioWeight: Int?
    public var BlkioWeightDevice: [BlkioWeightDevice]?
    public var BlkioDeviceReadBps: [BlkioDeviceReadBps]?
    public var BlkioDeviceReadIOps: [BlkioDeviceReadIOps]?
    public var BlkioDeviceWriteBps: [BlkioDeviceWriteBps]?
    public var BlkioDeviceWriteIOps: [BlkioDeviceWriteIOps]?
    public var DeviceRequests: [DeviceRequest]?
    public var MemorySwappiness: Int?
    public var OomKillDisable: Bool?
    public var OomScoreAdj: Int?
    public var PidMode: String?
    public var PidsLimit: Int?
    public var PortBindings: [String: [PortBinding]]?
    public var PublishAllPorts: Bool?
    public var Privileged: Bool?
    public var ReadonlyRootfs: Bool?
    public var Dns: [String]?
    public var DnsOptions: [String]?
    public var DnsSearch: [String]?
    public var VolumesFrom: [String]?
    public var CapAdd: [String]?
    public var CapDrop: [String]?
    public var GroupAdd: [String]?
    public var RestartPolicy: RestartPolicy?
    public var AutoRemove: Bool?
    public var NetworkMode: String?
    public var Devices: [Device]?
    public var Ulimits: [Ulimit]?
    public var LogConfig: LogConfig?
    public var SecurityOpt: [String]?
    public var StorageOpt: [String: String]?
    public var CgroupParent: String?
    public var VolumeDriver: String?
    public var ShmSize: Int?
    
    public init(binds: [String]? = nil, links: [String]? = nil, memory: Int? = nil, memorySwap: Int? = nil, memoryReservation: Int? = nil, nanoCpus: Int? = nil, cpuPercent: Int? = nil, cpuShares: Int? = nil, cpuPeriod: Int? = nil, cpuRealtimePeriod: Int? = nil, cpuRealtimeRuntime: Int? = nil, cpuQuota: Int? = nil, cpusetCpus: String? = nil, cpusetMems: String? = nil, maximumIOps: Int? = nil, maximumIOBps: Int? = nil, blkioWeight: Int? = nil, blkioWeightDevice: [BlkioWeightDevice]? = nil, blkioDeviceReadBps: [BlkioDeviceReadBps]? = nil, blkioDeviceReadIOps: [BlkioDeviceReadIOps]? = nil, blkioDeviceWriteBps: [BlkioDeviceWriteBps]? = nil, blkioDeviceWriteIOps: [BlkioDeviceWriteIOps]? = nil, deviceRequests: [DeviceRequest]? = nil, memorySwappiness: Int? = nil, oomKillDisable: Bool? = nil, oomScoreAdj: Int? = nil, pidMode: String? = nil, pidsLimit: Int? = nil, portBindings: [String : [PortBinding]]? = nil, publishAllPorts: Bool? = nil, privileged: Bool? = nil, readonlyRootfs: Bool? = nil, dns: [String]? = nil, dnsOptions: [String]? = nil, dnsSearch: [String]? = nil, volumesFrom: [String]? = nil, capAdd: [String]? = nil, capDrop: [String]? = nil, groupAdd: [String]? = nil, restartPolicy: RestartPolicy? = nil, autoRemove: Bool? = nil, networkMode: String? = nil, devices: [Device]? = nil, ulimits: [Ulimit]? = nil, logConfig: LogConfig? = nil, securityOpt: [String]? = nil, storageOpt: [String : String]? = nil, cgroupParent: String? = nil, volumeDriver: String? = nil, shmSize: Int? = nil) {
        self.Binds = binds
        self.Links = links
        self.Memory = memory
        self.MemorySwap = memorySwap
        self.MemoryReservation = memoryReservation
        self.NanoCpus = nanoCpus
        self.CpuPercent = cpuPercent
        self.CpuShares = cpuShares
        self.CpuPeriod = cpuPeriod
        self.CpuRealtimePeriod = cpuRealtimePeriod
        self.CpuRealtimeRuntime = cpuRealtimeRuntime
        self.CpuQuota = cpuQuota
        self.CpusetCpus = cpusetCpus
        self.CpusetMems = cpusetMems
        self.MaximumIOps = maximumIOps
        self.MaximumIOBps = maximumIOBps
        self.BlkioWeight = blkioWeight
        self.BlkioWeightDevice = blkioWeightDevice
        self.BlkioDeviceReadBps = blkioDeviceReadBps
        self.BlkioDeviceReadIOps = blkioDeviceReadIOps
        self.BlkioDeviceWriteBps = blkioDeviceWriteBps
        self.BlkioDeviceWriteIOps = blkioDeviceWriteIOps
        self.DeviceRequests = deviceRequests
        self.MemorySwappiness = memorySwappiness
        self.OomKillDisable = oomKillDisable
        self.OomScoreAdj = oomScoreAdj
        self.PidMode = pidMode
        self.PidsLimit = pidsLimit
        self.PortBindings = portBindings
        self.PublishAllPorts = publishAllPorts
        self.Privileged = privileged
        self.ReadonlyRootfs = readonlyRootfs
        self.Dns = dns
        self.DnsOptions = dnsOptions
        self.DnsSearch = dnsSearch
        self.VolumesFrom = volumesFrom
        self.CapAdd = capAdd
        self.CapDrop = capDrop
        self.GroupAdd = groupAdd
        self.RestartPolicy = restartPolicy
        self.AutoRemove = autoRemove
        self.NetworkMode = networkMode
        self.Devices = devices
        self.Ulimits = ulimits
        self.LogConfig = logConfig
        self.SecurityOpt = securityOpt
        self.StorageOpt = storageOpt
        self.CgroupParent = cgroupParent
        self.VolumeDriver = volumeDriver
        self.ShmSize = shmSize
    }
}

public struct BlkioWeightDevice: Codable {}

public struct BlkioDeviceReadBps: Codable {}

public struct BlkioDeviceReadIOps: Codable {}

public struct BlkioDeviceWriteBps: Codable {}

public struct BlkioDeviceWriteIOps: Codable {}

public struct DeviceRequest: Codable {
    public var Driver: String?
    public var Count: Int?
    public var DeviceIDs: [String]?
    public var Capabilities: [[String]]?
    public var Options: [String: String]?
    
    public init(driver: String? = nil, count: Int? = nil, deviceIDs: [String]? = nil, capabilities: [[String]]? = nil, options: [String : String]? = nil) {
        self.Driver = driver
        self.Count = count
        self.DeviceIDs = deviceIDs
        self.Capabilities = capabilities
        self.Options = options
    }
}

public struct PortBinding: Codable {
    public var HostPort: String?
    
    public init(hostPort: String? = nil) {
        self.HostPort = hostPort
    }
}

public struct RestartPolicy: Codable {
    public var Name: String?
    public var MaximumRetryCount: Int?
    
    public init(name: String? = nil, maximumRetryCount: Int? = nil) {
        self.Name = name
        self.MaximumRetryCount = maximumRetryCount
    }
}

public struct Device: Codable {}

public struct Ulimit: Codable {}

public struct LogConfig: Codable {
    public var `Type`: String?
    public var Config: [String: String]?
    
    public init(type: String? = nil, config: [String : String]? = nil) {
        self.Type = type
        self.Config = config
    }
}

public struct NetworkingConfig: Codable {
    public var EndpointsConfig: [String: EndpointConfig]?
    
    public init(endpointsConfig: [String : EndpointConfig]? = nil) {
        self.EndpointsConfig = endpointsConfig
    }
}

public struct EndpointConfig: Codable {
    public var IpamConfig: IPAMConfig?
    public var Links: [String]?
    public var Aliases: [String]?
    
    public init(ipamConfig: IPAMConfig? = nil, links: [String]? = nil, aliases: [String]? = nil) {
        self.IpamConfig = ipamConfig
        self.Links = links
        self.Aliases = aliases
    }
}

public struct IPAMConfig: Codable {
    public var Ipv4Address: String?
    public var Ipv6Address: String?
    public var LinkLocalIPs: [String]?
    
    public init(ipv4Address: String? = nil, ipv6Address: String? = nil, linkLocalIPs: [String]? = nil) {
        self.Ipv4Address = ipv4Address
        self.Ipv6Address = ipv6Address
        self.LinkLocalIPs = linkLocalIPs
    }
}

