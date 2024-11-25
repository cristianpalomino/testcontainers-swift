import XCTest
import Logging
@testable import Testcontainers

final class RyukSideContainerTests: XCTestCase {
    private var logger: Logger!
    private var container: GenericContainer!
    private var secondContainer: GenericContainer?

    override func setUp() {
        super.setUp()
        logger = Logger(label: "org.testcontainers.ryuk.tests")
    }

    override func tearDown() async throws {
        try await container.remove().get()
        try await secondContainer?.remove().get()
        try await super.tearDown()
    }

    func test_ryukStart_whenFirstTime_shouldStartContainer() async throws {
        // Given
        container = try GenericContainer(name: "redis", port: 6379, logger: logger)

        // When
        _ = try await container.start().get()

        // Then
        let ryukSideContainer: RyukSideContainer? = container.getSideContainer()

        XCTAssertNotNil(ryukSideContainer)
        XCTAssertEqual(ryukSideContainer?.configuration.Labels?["org.testcontainers.ryuk"], "true")
        XCTAssertEqual(
            ryukSideContainer?.configuration.Labels?["org.testcontainers.sessionId"],
            container.getSideContainers().first?.sessionId.uuidString
        )
    }

    func test_ryukStart_withTwoInstances_shouldRunSeparately() async throws {
        // Given
        container = try GenericContainer(name: "redis", port: 6379, logger: logger)
        secondContainer = try GenericContainer(name: "redis", port: 6380, logger: logger)

        // When - Start both containers
        _ = try await container.start().get()
        _ = try await secondContainer?.start().get()

        // Then
        let firstRyukInfo: RyukSideContainer? = container.getSideContainer()
        let secondRyukInfo: RyukSideContainer? = secondContainer?.getSideContainer()

        XCTAssertNotNil(firstRyukInfo, "First Ryuk container should be running")
        XCTAssertNotNil(secondRyukInfo, "Second Ryuk container should be running")
        XCTAssertNotEqual(firstRyukInfo?.sessionId, secondRyukInfo?.sessionId, "Ryuk containers should have different IDs")
    }

    // func test_ryukStart_whenDisabled_shouldReturnNil() async throws {
    //     // Given
    //     setenv("TESTCONTAINERS_RYUK_DISABLED", "true", 1)
    //     defer { unsetenv("TESTCONTAINERS_RYUK_DISABLED") }

    //     container = try GenericContainer(name: "redis", port: 6379, logger: logger)

    //     // When
    //     _ = try await container.start().get()

    //     // Then
    //     XCTAssertNil(
    //         container.ryukService.getContainerInfo(),
    //         "Ryuk container should not be created when disabled"
    //     )
    // }

    func test_ryukContainer_shouldHaveCorrectConfiguration() async throws {
        // Given
        container = try GenericContainer(name: "redis", port: 6379, logger: logger)

        // When
        _ = try await container.start().get()

        // Then
        let ryukSideContainer: RyukSideContainer? = container.getSideContainer()

        // Verify container configuration
        XCTAssertEqual(ryukSideContainer?.configuration.Image, "testcontainers/ryuk:0.5.1")

        // Verify Ryuk labels
        XCTAssertEqual(ryukSideContainer?.configuration.Labels?["org.testcontainers.ryuk"], "true")
        XCTAssertEqual(
            ryukSideContainer?.configuration.Labels?["org.testcontainers.sessionId"],
            container.getSideContainers().first?.sessionId.uuidString
        )
    }
}
