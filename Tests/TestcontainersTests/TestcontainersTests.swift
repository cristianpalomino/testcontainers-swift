import XCTest
@testable import Testcontainers

final class TestContainersTests: XCTestCase {

    var container: GenericContainer!

    override class func tearDown() {
        super.tearDown()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
    }

    func test_start_ThenRemoveContainer_shouldBeSuccess_async_await() async throws {
        var success = false
        do {
            container = try GenericContainer(name: "redis", port: 6379)
            let response = try await container.start().get()
            print(response.Name)
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

        container = try GenericContainer(name: "redis", port: 6379)
        container
            .start()
            .map { _ in self.container }
            .flatMap { container in
                container.remove()
            }
            .whenComplete { result in
                switch result {
                case let .success(response):
                    print(response)
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
        container = try GenericContainer(image: "redis:7.2.5", port: 6379)
        container
            .start()
            .map { _ in self.container }
            .flatMap { container in
                container.remove()
            }
            .whenComplete { result in
                switch result {
                case let .success(response):
                    print(response)
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
