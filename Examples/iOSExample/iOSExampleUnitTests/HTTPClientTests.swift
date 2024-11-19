import XCTest
import Testcontainers
@testable import iOSExample

final class HTTPClientTests: XCTestCase {
    
    var container: GenericContainer!
    var httpClient: HTTPClient!
    
    override func setUp() async throws {
        container = try GenericContainer(name: "kong/httpbin", port: 80)
        let containerInfo = try await container.start().get()
        
        guard let ports = containerInfo.NetworkSettings.Ports["80/tcp"],
              let hostPort = ports?.first?.HostPort,
              let hostIP = ports?.first?.HostIp
        else {
            throw XCTestError(.failureWhileWaiting, userInfo: ["error": "Unable to resolve container port"])
        }
        
        httpClient = HTTPClient(
            host: "http://\(hostIP)",
            port: Int(hostPort) ?? 80
        )
    }
    
    override func tearDown() async throws {
        try await container.remove().get()
    }
    
    func testGetEndpoint() async throws {
        // Wait for the container to be ready
        try await Task.sleep(for: .seconds(1))
        
        // When
        let response: EchoResponse = try await httpClient.get(endpoint: "/get")
        
        // Then
        XCTAssertFalse(response.headers.isEmpty)
        XCTAssertTrue(response.url.contains("/get"))
        XCTAssertEqual(response.args, [:])
    }
    
    func testInvalidEndpoint() async throws {
        // Wait for the container to be ready
        try await Task.sleep(for: .seconds(1))
        
        do {
            let _: EchoResponse = try await httpClient.get(endpoint: "/invalid")
            XCTFail("Should throw an error")
        } catch {
            XCTAssertTrue(error is HTTPError)
        }
    }
}
