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
    
    func test_startDockerImage_shouldBeSuccess() throws {
        let expectation = expectation(description: "test_startDockerImage_shouldBeSuccess")
        container = GenericContainer(name: "mendhak/http-https-echo", port: 8080)
        container.start().sink { completion in
            print(completion)
        } receiveValue: { info in
            expectation.fulfill()
        }.store(in: &cancellables)
        
        waitForExpectations(timeout: 120)
    }
}
