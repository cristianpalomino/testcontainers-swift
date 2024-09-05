//
//  DockerImageNameTests.swift
//
//
//  Created by cristian on 5/09/24.
//

import XCTest
@testable import Testcontainers

final class DockerImageNameTests: XCTestCase {
    
    override class func tearDown() {
        super.tearDown()
    }
    
    func testInitWithValidImageString() throws {
        let imageString = "nginx:latest"
        let dockerImageName = try DockerImageName(image: imageString)
        
        XCTAssertEqual(dockerImageName.name, "nginx")
        XCTAssertEqual(dockerImageName.tag, "latest")
    }
    
    func testInitWithInvalidImageString() {
        let imageString = "nginx-latest"
        
        XCTAssertThrowsError(try DockerImageName(image: imageString)) { error in
            XCTAssertEqual(error as? String, "Unable to retrieve nginx-latest, use the next format <name>:<tag>")
        }
    }
    
    func testInitWithNameAndTag() {
        let name = "nginx"
        let tag = "latest"
        let dockerImageName = DockerImageName(name: name, tag: tag)
        
        XCTAssertEqual(dockerImageName.name, name)
        XCTAssertEqual(dockerImageName.tag, tag)
    }
    
    func testInitWithEmptyImageString() {
        let imageString = ""
        
        XCTAssertThrowsError(try DockerImageName(image: imageString)) { error in
            XCTAssertEqual(error as? String, "Unable to retrieve , use the next format <name>:<tag>")
        }
    }
    
    func testInitWithMultipleColons() {
        let imageString = "nginx:latest:extra"
        
        XCTAssertThrowsError(try DockerImageName(image: imageString)) { error in
            XCTAssertEqual(error as? String, "Unable to retrieve nginx:latest:extra, use the next format <name>:<tag>")
        }
    }
}
