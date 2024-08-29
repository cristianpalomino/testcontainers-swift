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
    
    func test_startContainer_shouldBeSuccess_async_await() async throws {
        var success = false
        do {
            container = GenericContainer(name: "redis", port: 6379)
            let response = try await container.start().get()
            print(response.Name)
            success = true
            XCTAssertEqual(success, true)
        } catch {
            success = false
            XCTAssertEqual(success, true, error.localizedDescription)
        }
    }
    
    func test_startThenRemoveContainer_shouldBeSuccess_async_await() async throws {
        var success = false
        do {
            container = GenericContainer(name: "redis", port: 6379)
            let response = try await container.start().get()
            print(response.Name)
            try await container.remove().get()
            success = true
            XCTAssertEqual(success, true)
        } catch {
            success = false
            XCTAssertEqual(success, true, error.localizedDescription)
        }
    }

    func test_startContainer_shouldBeSuccess() throws {
        let expectation = expectation(description: "test_startContainer_shouldBeSuccess")
        var success = false
        
        container = GenericContainer(name: "redis", port: 6379)
        container.start().whenComplete { result in
            switch result {
            case let .success(response):
                print(response.Name)
                success = true
                XCTAssertEqual(success, true)
            case let .failure(error):
                success = false
                XCTAssertEqual(success, true, error.localizedDescription)
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 120)
    }
    
    func test_startThenRemoveContainer_shouldBeSuccess() throws {
        let expectation = expectation(description: "test_startThenRemoveContainer_shouldBeSuccess")
        var success = false
        
        container = GenericContainer(name: "redis", port: 6379)
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
                    XCTAssertEqual(success, true, error.localizedDescription)
                }
                expectation.fulfill()
            }
        
        waitForExpectations(timeout: 120)
    }
}
