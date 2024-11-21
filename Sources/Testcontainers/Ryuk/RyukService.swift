import Foundation
import Logging
import NIO

public final class RyukService {
    private let logger: Logger
    private let sessionId: String
    private var container: GenericContainer?
    private static var isStarted = false
    
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
            return container?.start().map { _ in
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
