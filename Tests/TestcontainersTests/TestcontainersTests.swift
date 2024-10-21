import XCTest
import Logging

@testable import Testcontainers

final class TestContainersTests: XCTestCase {

    var logger: Logger = Logger(label: String(describing: TestContainersTests.self))

    required init(name: String, testClosure: @escaping XCTestCaseClosure) {
        super.init(name: name, testClosure: testClosure)
        logger.logLevel = .info
    }

    override class func tearDown() {
        super.tearDown()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
    }

    func test_start_ThenRemoveContainer_shouldBeSuccess_async_await() async throws {
        var success = false

        do {
            let container = try GenericContainer(name: "redis", port: 6379, logger: logger)
            let response = try await container.start().get()
            logger.info("Container Name: \(response.Name)")
            try await container.remove().get()
            success = true
            XCTAssertEqual(success, true)
        } catch {
            success = false
            XCTAssertEqual(success, true, String(describing: error))
        }
    }

    func test_start_ThenRemoveContainer_shouldBeSuccess() throws {
        let expectation = expectation(description: "test_startThenRemoveContainer_shouldBeSuccess")
        var success = false

        let container = try GenericContainer(name: "redis", port: 6379, logger: logger)
        container
            .start()
            .map { _ in container }
            .flatMap { container in
                container.remove()
            }
            .whenComplete { result in
                switch result {
                case .success:
                    success = true
                    XCTAssertEqual(success, true)
                case let .failure(error):
                    success = false
                    XCTAssertEqual(success, true, String(describing: error))
                }
                expectation.fulfill()
            }

        waitForExpectations(timeout: 120)
    }


    // TODO: Improve the unit tests
    func test_startUsingTag_ThenRemoveContainer_shouldBeSuccess() throws {
        let expectation = expectation(description: "test_startUsingTag_ThenRemoveContainer_shouldBeSuccess")
        var success = false

        // container = GenericContainer(name: "rabbitmq", tag: "3-alpine", port: 6379)
        // let params = ImageParams(name: "redis", tag: "7.2.5", src: nil, repo: nil)
        // container = GenericContainer(image: params, port: 6379)
        let container = try GenericContainer(image: "redis:7.2.5", port: 6379, logger: logger)
        container
            .start()
            .map { _ in container }
            .flatMap { container in
                container.remove()
            }
            .whenComplete { result in
                switch result {
                case .success:
                    success = true
                    XCTAssertEqual(success, true)
                case let .failure(error):
                    success = false
                    XCTAssertEqual(success, true, String(describing: error))
                }
                expectation.fulfill()
            }

        waitForExpectations(timeout: 120)
    }
}
