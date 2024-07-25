//
//  ContainerConfig.swift
//
//
//  Created by cristian on 24/07/24.
//

import Foundation

public struct ContainerConfig: Codable {
    public var hostname: String?
    public var domainname: String?
    public var user: String?
    public var attachStdin: Bool?
    public var attachStdout: Bool?
    public var attachStderr: Bool?
    public var tty: Bool?
    public var openStdin: Bool?
    public var stdinOnce: Bool?
    public var env: [String]?
    public var cmd: [String]?
    public var entrypoint: String?
    public var image: String?
    public var labels: [String: String]?
    public var volumes: [String: Volume]?
    public var workingDir: String?
    public var networkDisabled: Bool?
    public var macAddress: String?
    public var exposedPorts: [String: ExposedPort]?
    public var stopSignal: String?
    public var stopTimeout: Int?
    public var hostConfig: HostConfig?
    public var networkingConfig: NetworkingConfig?
    
    public init(hostname: String? = nil, domainname: String? = nil, user: String? = nil, attachStdin: Bool? = nil, attachStdout: Bool? = nil, attachStderr: Bool? = nil, tty: Bool? = nil, openStdin: Bool? = nil, stdinOnce: Bool? = nil, env: [String]? = nil, cmd: [String]? = nil, entrypoint: String? = nil, image: String? = nil, labels: [String : String]? = nil, volumes: [String : Volume]? = nil, workingDir: String? = nil, networkDisabled: Bool? = nil, macAddress: String? = nil, exposedPorts: [String : ExposedPort]? = nil, stopSignal: String? = nil, stopTimeout: Int? = nil, hostConfig: HostConfig? = nil, networkingConfig: NetworkingConfig? = nil) {
        self.hostname = hostname
        self.domainname = domainname
        self.user = user
        self.attachStdin = attachStdin
        self.attachStdout = attachStdout
        self.attachStderr = attachStderr
        self.tty = tty
        self.openStdin = openStdin
        self.stdinOnce = stdinOnce
        self.env = env
        self.cmd = cmd
        self.entrypoint = entrypoint
        self.image = image
        self.labels = labels
        self.volumes = volumes
        self.workingDir = workingDir
        self.networkDisabled = networkDisabled
        self.macAddress = macAddress
        self.exposedPorts = exposedPorts
        self.stopSignal = stopSignal
        self.stopTimeout = stopTimeout
        self.hostConfig = hostConfig
        self.networkingConfig = networkingConfig
    }
}

public struct Volume: Codable {}

public struct ExposedPort: Codable {}

public struct HostConfig: Codable {
    public var binds: [String]?
    public var links: [String]?
    public var memory: Int?
    public var memorySwap: Int?
    public var memoryReservation: Int?
    public var nanoCpus: Int?
    public var cpuPercent: Int?
    public var cpuShares: Int?
    public var cpuPeriod: Int?
    public var cpuRealtimePeriod: Int?
    public var cpuRealtimeRuntime: Int?
    public var cpuQuota: Int?
    public var cpusetCpus: String?
    public var cpusetMems: String?
    public var maximumIOps: Int?
    public var maximumIOBps: Int?
    public var blkioWeight: Int?
    public var blkioWeightDevice: [BlkioWeightDevice]?
    public var blkioDeviceReadBps: [BlkioDeviceReadBps]?
    public var blkioDeviceReadIOps: [BlkioDeviceReadIOps]?
    public var blkioDeviceWriteBps: [BlkioDeviceWriteBps]?
    public var blkioDeviceWriteIOps: [BlkioDeviceWriteIOps]?
    public var deviceRequests: [DeviceRequest]?
    public var memorySwappiness: Int?
    public var oomKillDisable: Bool?
    public var oomScoreAdj: Int?
    public var pidMode: String?
    public var pidsLimit: Int?
    public var portBindings: [String: [PortBinding]]?
    public var publishAllPorts: Bool?
    public var privileged: Bool?
    public var readonlyRootfs: Bool?
    public var dns: [String]?
    public var dnsOptions: [String]?
    public var dnsSearch: [String]?
    public var volumesFrom: [String]?
    public var capAdd: [String]?
    public var capDrop: [String]?
    public var groupAdd: [String]?
    public var restartPolicy: RestartPolicy?
    public var autoRemove: Bool?
    public var networkMode: String?
    public var devices: [Device]?
    public var ulimits: [Ulimit]?
    public var logConfig: LogConfig?
    public var securityOpt: [String]?
    public var storageOpt: [String: String]?
    public var cgroupParent: String?
    public var volumeDriver: String?
    public var shmSize: Int?
    
    public init(binds: [String]? = nil, links: [String]? = nil, memory: Int? = nil, memorySwap: Int? = nil, memoryReservation: Int? = nil, nanoCpus: Int? = nil, cpuPercent: Int? = nil, cpuShares: Int? = nil, cpuPeriod: Int? = nil, cpuRealtimePeriod: Int? = nil, cpuRealtimeRuntime: Int? = nil, cpuQuota: Int? = nil, cpusetCpus: String? = nil, cpusetMems: String? = nil, maximumIOps: Int? = nil, maximumIOBps: Int? = nil, blkioWeight: Int? = nil, blkioWeightDevice: [BlkioWeightDevice]? = nil, blkioDeviceReadBps: [BlkioDeviceReadBps]? = nil, blkioDeviceReadIOps: [BlkioDeviceReadIOps]? = nil, blkioDeviceWriteBps: [BlkioDeviceWriteBps]? = nil, blkioDeviceWriteIOps: [BlkioDeviceWriteIOps]? = nil, deviceRequests: [DeviceRequest]? = nil, memorySwappiness: Int? = nil, oomKillDisable: Bool? = nil, oomScoreAdj: Int? = nil, pidMode: String? = nil, pidsLimit: Int? = nil, portBindings: [String : [PortBinding]]? = nil, publishAllPorts: Bool? = nil, privileged: Bool? = nil, readonlyRootfs: Bool? = nil, dns: [String]? = nil, dnsOptions: [String]? = nil, dnsSearch: [String]? = nil, volumesFrom: [String]? = nil, capAdd: [String]? = nil, capDrop: [String]? = nil, groupAdd: [String]? = nil, restartPolicy: RestartPolicy? = nil, autoRemove: Bool? = nil, networkMode: String? = nil, devices: [Device]? = nil, ulimits: [Ulimit]? = nil, logConfig: LogConfig? = nil, securityOpt: [String]? = nil, storageOpt: [String : String]? = nil, cgroupParent: String? = nil, volumeDriver: String? = nil, shmSize: Int? = nil) {
        self.binds = binds
        self.links = links
        self.memory = memory
        self.memorySwap = memorySwap
        self.memoryReservation = memoryReservation
        self.nanoCpus = nanoCpus
        self.cpuPercent = cpuPercent
        self.cpuShares = cpuShares
        self.cpuPeriod = cpuPeriod
        self.cpuRealtimePeriod = cpuRealtimePeriod
        self.cpuRealtimeRuntime = cpuRealtimeRuntime
        self.cpuQuota = cpuQuota
        self.cpusetCpus = cpusetCpus
        self.cpusetMems = cpusetMems
        self.maximumIOps = maximumIOps
        self.maximumIOBps = maximumIOBps
        self.blkioWeight = blkioWeight
        self.blkioWeightDevice = blkioWeightDevice
        self.blkioDeviceReadBps = blkioDeviceReadBps
        self.blkioDeviceReadIOps = blkioDeviceReadIOps
        self.blkioDeviceWriteBps = blkioDeviceWriteBps
        self.blkioDeviceWriteIOps = blkioDeviceWriteIOps
        self.deviceRequests = deviceRequests
        self.memorySwappiness = memorySwappiness
        self.oomKillDisable = oomKillDisable
        self.oomScoreAdj = oomScoreAdj
        self.pidMode = pidMode
        self.pidsLimit = pidsLimit
        self.portBindings = portBindings
        self.publishAllPorts = publishAllPorts
        self.privileged = privileged
        self.readonlyRootfs = readonlyRootfs
        self.dns = dns
        self.dnsOptions = dnsOptions
        self.dnsSearch = dnsSearch
        self.volumesFrom = volumesFrom
        self.capAdd = capAdd
        self.capDrop = capDrop
        self.groupAdd = groupAdd
        self.restartPolicy = restartPolicy
        self.autoRemove = autoRemove
        self.networkMode = networkMode
        self.devices = devices
        self.ulimits = ulimits
        self.logConfig = logConfig
        self.securityOpt = securityOpt
        self.storageOpt = storageOpt
        self.cgroupParent = cgroupParent
        self.volumeDriver = volumeDriver
        self.shmSize = shmSize
    }
}

public struct BlkioWeightDevice: Codable {}

public struct BlkioDeviceReadBps: Codable {}

public struct BlkioDeviceReadIOps: Codable {}

public struct BlkioDeviceWriteBps: Codable {}

public struct BlkioDeviceWriteIOps: Codable {}

public struct DeviceRequest: Codable {
    public var driver: String?
    public var count: Int?
    public var deviceIDs: [String]?
    public var capabilities: [[String]]?
    public var options: [String: String]?
    
    public init(driver: String? = nil, count: Int? = nil, deviceIDs: [String]? = nil, capabilities: [[String]]? = nil, options: [String : String]? = nil) {
        self.driver = driver
        self.count = count
        self.deviceIDs = deviceIDs
        self.capabilities = capabilities
        self.options = options
    }
}

public struct PortBinding: Codable {
    public var hostPort: String?
    
    public init(hostPort: String? = nil) {
        self.hostPort = hostPort
    }
}

public struct RestartPolicy: Codable {
    public var name: String?
    public var maximumRetryCount: Int?
    
    public init(name: String? = nil, maximumRetryCount: Int? = nil) {
        self.name = name
        self.maximumRetryCount = maximumRetryCount
    }
}

public struct Device: Codable {}

public struct Ulimit: Codable {}

public struct LogConfig: Codable {
    public var type: String?
    public var config: [String: String]?
    
    public init(type: String? = nil, config: [String : String]? = nil) {
        self.type = type
        self.config = config
    }
}

public struct NetworkingConfig: Codable {
    public var endpointsConfig: [String: EndpointConfig]?
    
    public init(endpointsConfig: [String : EndpointConfig]? = nil) {
        self.endpointsConfig = endpointsConfig
    }
}

public struct EndpointConfig: Codable {
    public var ipamConfig: IPAMConfig?
    public var links: [String]?
    public var aliases: [String]?
    
    public init(ipamConfig: IPAMConfig? = nil, links: [String]? = nil, aliases: [String]? = nil) {
        self.ipamConfig = ipamConfig
        self.links = links
        self.aliases = aliases
    }
}

public struct IPAMConfig: Codable {
    public var ipv4Address: String?
    public var ipv6Address: String?
    public var linkLocalIPs: [String]?
    
    public init(ipv4Address: String? = nil, ipv6Address: String? = nil, linkLocalIPs: [String]? = nil) {
        self.ipv4Address = ipv4Address
        self.ipv6Address = ipv6Address
        self.linkLocalIPs = linkLocalIPs
    }
}
