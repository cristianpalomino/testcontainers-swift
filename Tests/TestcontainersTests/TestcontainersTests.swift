import XCTest
import Combine
@testable import Testcontainers

final class TestContainersTests: XCTestCase {
    
    var container: GenericContainer!
    var cancellables = Set<AnyCancellable>()
    
    override class func tearDown() {
        super.tearDown()
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
    }
    
    func test_startContainer_shouldBeSuccess() throws {
        let expectation = expectation(description: "test_startContainer_shouldBeSuccess")
        var success = false
        
        container = GenericContainer(name: "redis", port: 6379)
        container.start().sink { completion in
            switch completion {
            case .failure:
                success = false
            case .finished:
                XCTAssertEqual(success, true)
                expectation.fulfill()
            }
        } receiveValue: { info in
            success = true
        }.store(in: &cancellables)
        
        waitForExpectations(timeout: 120)
    }
    
    func test_startThenRemoveContainer_shouldBeSuccess() throws {
        let expectation = expectation(description: "test_startThenRemoveContainer_shouldBeSuccess")
        var success = false
        
        container = GenericContainer(name: "redis", port: 6379)
        container
            .start()
            .flatMap { _ in self.container.remove() }
            .sink { completion in
                switch completion {
                case .failure:
                    success = false
                case .finished:
                    XCTAssertEqual(success, true)
                    expectation.fulfill()
                }
            } receiveValue: { info in
                success = true
            }.store(in: &cancellables)
        
        waitForExpectations(timeout: 120)
    }
}
