import XCTest
@testable import Testcontainers

final class TestContainersTests: XCTestCase {
    
    var container: GenericContainer!
    
    override class func tearDown() {
        TestContainersHelper.clean()
        super.tearDown()
    }
    
    override func tearDownWithError() throws {
        container = nil
        try super.tearDownWithError()
    }
    
    func test_startDockerImage_shouldBeSuccess() throws {
        let expectation = expectation(description: "test_startDockerImage_shouldBeSuccess")
        container = try GenericContainer(name: "mendhak/http-https-echo", port: 8080)
        container.start { host in
            XCTAssertNotNil(host)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 60)
    }
    
    func test_stopDockerImage_shouldBeSuccess() throws {
        let expectation = expectation(description: "test_stopDockerImage_shouldBeSuccess")
        container = try GenericContainer(name: "redis", port: 6379)
        container.start { _ in
            self.container.stop {
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 60)
    }
    
    func test_removeDockerImage_shouldBeSuccess() throws {
        let expectation = expectation(description: "test_removeDockerImage_shouldBeSuccess")
        container = try GenericContainer(name: "redis", port: 6379)
        container.start { _ in
            self.container.clean {
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 60)
    }
}
