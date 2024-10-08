import XCTest
import Testcontainers
@testable import RedisClientApp

final class RedisClientTests: XCTestCase {
    
    var container: GenericContainer!
    var app: RedisClientApp!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        container = try GenericContainer(name: "redis", port: 6379)
    }
    
    override func tearDownWithError() throws {
        container = nil
        app.shutdown()
        try super.tearDownWithError()
    }
    
    func test_runApp() throws {
        let expectation = expectation(description: "test_runApp")
        container.start { port in
            do {
                let redisConfig = RedisConfig(host: "localhost", port: port)
                self.app = try RedisClientApp(redisConfig: redisConfig)
                try self.app.run()
            } catch {
                XCTFail("Failed to run app: \(error)")
            }
        }
        waitForExpectations(timeout: 10000)
    }
}
