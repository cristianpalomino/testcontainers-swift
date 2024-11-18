//
//  iOSExampleUITests.swift
//  iOSExampleUITests
//
//  Created by cristian on 16/11/24.
//

import XCTest
import Testcontainers
@testable import iOSExample

final class iOSExampleUITests: XCTestCase {

    var container: GenericContainer!
    var app: XCUIApplication!
    var expectedHost: String!

    override func setUp() async throws {
        container = try GenericContainer(name: "kong/httpbin", port: 80)
        let containerInfo = try await container.start().get()

        guard let ports = containerInfo.NetworkSettings.Ports["80/tcp"],
              let hostPort = ports?.first?.HostPort
        else {
            throw XCTestError(.failureWhileWaiting, userInfo: ["error": "Unable to resolve container port"])
        }

        // Store expected host for validation
        expectedHost = "http://localhost:\(hostPort)"

        // Setup app with launch arguments
        app = XCUIApplication()
        app.launchArguments = ["UI_TEST"]
        app.launchEnvironment = [
            "HOST": "http://localhost",
            "PORT": hostPort
        ]
        app.launch()
    }

    override func tearDown() async throws {
        try await container.remove().get()
    }

    @MainActor
    func testHostInformation() throws {
        // Wait for the host information to appear
        let hostText = app.staticTexts[expectedHost]
        XCTAssertTrue(hostText.waitForExistence(timeout: 5))

        // Verify host section exists and shows correct information
        let hostSection = app.collectionViews.staticTexts["Host Information"]
        XCTAssertTrue(hostSection.exists)
        XCTAssertTrue(hostText.exists)
    }

    @MainActor
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
