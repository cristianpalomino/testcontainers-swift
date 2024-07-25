import XCTest
import Testcontainers
@testable import RedisClientApp

final class RedisClientTests: XCTestCase {
    
    func test_runApp() throws {
        let expectation = expectation(description: "test_runApp")
        
        let container = try GenericContainer(name: "redis", port: 6379)
        container.create {
            container.start { port in
                let redisConfig = RedisConfig(host: "localhost", port: port)
                let app = try? RedisClientApp(redisConfig: redisConfig)
                try app?.run()
                defer { app?.shutdown() }
            }
        }
        waitForExpectations(timeout: 10000)
    }
}
