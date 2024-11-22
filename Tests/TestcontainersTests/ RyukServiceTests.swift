import XCTest
import Logging
@testable import Testcontainers

final class RyukServiceTests: XCTestCase {
    private var logger: Logger!
    private var container: GenericContainer!

    override func setUp() {
        super.setUp()
        logger = Logger(label: "org.testcontainers.ryuk.tests")
    }
    
    override func tearDown() async throws {
        try await container.remove().get()
        try await super.tearDown() 
    }
    
    func test_ryukStart_whenFirstTime_shouldStartContainer() async throws {
        // Given
        container = try GenericContainer(name: "redis", port: 6379, logger: logger)
        
        // When
        _ = try await container.start().get()
           
        // Then
        let containerInfo = try XCTUnwrap(container.ryukService.getContainerInfo())

        XCTAssertEqual(containerInfo.Config.Labels["org.testcontainers.ryuk"], "true")
        XCTAssertEqual(
            containerInfo.Config.Labels["org.testcontainers.sessionId"],
            container.ryukService.sessionId
        )
    }
    
    func test_ryukStart_whenAlreadyStarted_shouldReturnNil() async throws {
        // Given
        container = try GenericContainer(name: "redis", port: 6379, logger: logger)
        
        // When - First start
        _ = try await container.start().get()
        let firstRyukInfo = try XCTUnwrap(container.ryukService.getContainerInfo())
        
        // When - Second start with same container
        let secondStart = container.ryukService.start()
        
        // Then
        XCTAssertNil(secondStart, "Second start should return nil as Ryuk is already running")
        
        let secondRyukInfo = container.ryukService.getContainerInfo()
        XCTAssertEqual(firstRyukInfo.Id, secondRyukInfo?.Id)
    }
    
    func test_ryukStart_whenDisabled_shouldReturnNil() async throws {
        // Given
        setenv("TESTCONTAINERS_RYUK_DISABLED", "true", 1)
        defer { unsetenv("TESTCONTAINERS_RYUK_DISABLED") }
        
        container = try GenericContainer(name: "redis", port: 6379, logger: logger)
        
        // When
        _ = try await container.start().get()
        
        // Then
        XCTAssertNil(
            container.ryukService.getContainerInfo(),
            "Ryuk container should not be created when disabled"
        )
    }
    
    func test_ryukContainer_shouldHaveCorrectConfiguration() async throws {
        // Given
        container = try GenericContainer(name: "redis", port: 6379, logger: logger)
        
        // When
        _ = try await container.start().get()
        
        // Then
        let containerInfo = try XCTUnwrap(container.ryukService.getContainerInfo())
        
        // Verify container configuration
        XCTAssertEqual(containerInfo.Config.Image, "testcontainers/ryuk:0.5.1")
        XCTAssertTrue(containerInfo.HostConfig?.Privileged ?? false)
        XCTAssertTrue(containerInfo.HostConfig?.AutoRemove ?? false)
        XCTAssertEqual(
            containerInfo.HostConfig?.Binds,
            ["/var/run/docker.sock:/var/run/docker.sock"]
        )
        
        // Verify Ryuk labels
        XCTAssertEqual(containerInfo.Config.Labels["org.testcontainers.ryuk"], "true")
        XCTAssertEqual(
            containerInfo.Config.Labels["org.testcontainers.sessionId"],
            container.ryukService.sessionId
        )
    }
}
