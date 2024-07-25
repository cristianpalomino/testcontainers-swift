import Foundation

public final class TestContainersHelper {
    
    public class func clean() {
        let server = SimpleProxy()
        try? server.start()
        server.stop()
    }
}

public final class GenericContainer {
    
    var id: String?
    let name: String
    let port: Int
    
    private let server = SimpleProxy()
    
    public init(
        name: String,
        port: Int
    ) throws {
        self.name = name
        self.port = port
        try server.start()
    }
    
    deinit {
        server.stop()
    }
    
    public func create(_ completion: (() -> Void)? = nil) {
        let pullImage = PullImage(name: name)
        
        let createContainer = CreateContainer(port: port)
        createContainer.completionBlock = { [weak self] in
            guard let self else { return }
            self.id = createContainer.containerId
            completion?()
        }
        
        createContainer.addDependency(pullImage)
        let queue = OperationQueue()
        let operations = [pullImage, createContainer]
        queue.addOperations(operations, waitUntilFinished: false)
    }
    
    public func start(_ completion: ((Int) -> Void)? = nil) {
        guard let id = id else { return }
        let startContainer = StartContainer(containerId: id)
        
        let getContainer = GetContainer(containerId: id, port: port)
        getContainer.completionBlock = {
            guard let hostPort = getContainer.containerPort, let intPort = Int(hostPort) else {
                fatalError("ContainerPort not found...!")
            }
            completion?(intPort)
        }
        
        getContainer.addDependency(startContainer)
        let queue = OperationQueue()
        let operations = [startContainer, getContainer]
        queue.addOperations(operations, waitUntilFinished: false)
    }
    
    public func stop(_ completion: (() -> Void)? = nil) {
        guard let id = id else { return }
        let stopContainer = StopContainer(containerId: id)
        stopContainer.completionBlock = { completion?() }
        let queue = OperationQueue()
        queue.addOperations([stopContainer], waitUntilFinished: false)
    }
    
    public func clean(_ completion: (() -> Void)? = nil) {
        guard let id = id else { return }
        let stopContainer = StopContainer(containerId: id)
        let removeContainer = RemoveContainer(containerId: id)
        removeContainer.completionBlock = { completion?() }
        removeContainer.addDependency(stopContainer)
        let queue = OperationQueue()
        let operations = [stopContainer, removeContainer]
        queue.addOperations(operations, waitUntilFinished: false)
    }
}
