import Foundation

public final class TestContainersHelper {
    
    public class func clean() {
        let server = SimpleProxy()
        try? server.start()
        server.stop()
    }
}

public final class GenericContainer {
    
    static let uuid = UUID().uuidString
    
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
    
    public func start(_ completion: ((Int) -> Void)? = nil) {
        let pullImage = PullImage(name: name)
        let createContainer = CreateContainer(exposedPort: port)
        let startContainer = StartContainer()
        let getContainer = GetContainer(exposedPort: port)
        
        pullImage.completionBlock = {
            createContainer.imageName = pullImage.imageName
        }

        createContainer.completionBlock = { [weak self] in
            guard let self else { return }
            self.id = createContainer.containerId
            startContainer.containerId = createContainer.containerId
            getContainer.containerId = createContainer.containerId
        }

        getContainer.completionBlock = {
            guard let port = getContainer.port,
                  let intPort = Int(port) else {
                fatalError("ContainerPort not found")
            }
            completion?(intPort)
        }
        
        createContainer.addDependency(pullImage)
        startContainer.addDependency(createContainer)
        getContainer.addDependency(startContainer)
        
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        let operations = [pullImage, createContainer, startContainer, getContainer]
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
