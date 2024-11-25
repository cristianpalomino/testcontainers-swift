import Foundation
import Logging
import NIO

public protocol SideContainer {
    var sessionId: UUID { get }
    var name: String { get }
    var configuration: ContainerConfig { get }
    var info: ContainerInspectInfo? { get }
    var container: DockerContainerOperations? { get }

    func start() -> EventLoopFuture<Void>
    func remove() -> EventLoopFuture<Void>
}

public final class RyukSideContainer: SideContainer {

    private let docker: DockerOperations
    private let logger: Logger
    public let sessionId: UUID

    public var name: String {
        return "\(configuration.Image)-\(sessionId.uuidString)"
    }

    public var container: DockerContainerOperations?
    public var info: ContainerInspectInfo?
    public var configuration: ContainerConfig {
        ContainerConfig(
            image: "testcontainers/ryuk:0.5.1",
            labels: [
                "org.testcontainers.ryuk": "true",
                "org.testcontainers.sessionId": sessionId.uuidString
            ]
        )
    }

    init(docker: DockerOperations, logger: Logger, sessionId: UUID = UUID()) {
        self.docker = docker
        self.logger = logger
        self.sessionId = sessionId
    }

    public func start() -> EventLoopFuture<Void> {
        return docker.create(container: configuration).flatMap { container in
            self.container = container
            return container.start().flatMap { _ in
                self.logger.info("🚀 Starting \(self.name) container...")
                return container.inspect().map { info in
                    self.logger.info("🔍 Inspected \(self.name) container")
                    self.info = info
                }
            }
        }
    }

    public func remove() -> EventLoopFuture<Void> {
        guard let container = container else {
            return docker.client.eventLoop.makeFailedFuture("Container not found")
        }

        return container.stop().flatMap { _ in
            self.logger.info("📦 Stopping \(self.name) container...")
            return container.remove().map { _ in
                self.logger.info("🧹 Removed \(self.name) container")
            }
        }
    }
}
