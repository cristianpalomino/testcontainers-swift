import Foundation
import Logging
import NIO

public final class RyukService {
    
    public let sessionId: String
    private let logger: Logger
    private var container: GenericContainer?
    private static var isStarted = false
    private var containerInfo: ContainerInspectInfo?
    
    init(logger: Logger, sessionId: String = UUID().uuidString) {
        self.logger = logger
        self.sessionId = sessionId
    }

    func start() -> EventLoopFuture<Void>? {
        guard !Self.isStarted, !isRyukDisabled() else {
            if isRyukDisabled() {
                logger.warning("""
                ********************************************************************************
                Ryuk has been disabled. This can cause unexpected behavior in your environment.
                ********************************************************************************
                """)
            }
            return nil
        }
        
        do {
            let config = ContainerConfig(
                image: "testcontainers/ryuk:0.5.1",
                labels: [
                    "org.testcontainers.ryuk": "true",
                    "org.testcontainers.sessionId": sessionId
                ],
                hostConfig: HostConfig(
                    binds: ["/var/run/docker.sock:/var/run/docker.sock"],
                    privileged: true,
                    autoRemove: true
                )
            )
            
            container = try GenericContainer(
                image: DockerImageName(name: "testcontainers/ryuk", tag: "0.5.1"),
                configuration: config,
                logger: logger
            )
            
            Self.isStarted = true
            
            return container?.start().map { info in
                self.containerInfo = info
                self.logger.info("🧹 Started Ryuk container")
            }
        } catch {
            logger.error("Failed to start Ryuk container: \(error)")
            return nil
        }
    }
    
    private func isRyukDisabled() -> Bool {
        ProcessInfo.processInfo.environment["TESTCONTAINERS_RYUK_DISABLED"] == "true"
    }
}

public extension RyukService {
    func getContainerInfo() -> ContainerInspectInfo? {
        containerInfo
    }

    func remove() -> EventLoopFuture<Void> {
        return container?
            .stop() 
            .flatMap { _ in
                self.container?.remove()
        }.map { _ in
            self.logger.info("🧹 Removed Ryuk container")
                self.containerInfo = nil
                self.container = nil
        }
    }
}
