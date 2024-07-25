//
//  OperationsTests.swift
//
//
//  Created by cristian on 18/07/24.
//

import XCTest
@testable import Testcontainers

final class OperationsTests: XCTestCase {
    
    static let proxy = SimpleProxy()
    
    override class func setUp() {
        super.setUp()
        try? proxy.start()
    }
    
    override class func tearDown() {
        proxy.stop()
        super.tearDown()
    }
    
    func test_listImages() {
        let expectation = expectation(description: "test_listImages")
        let operation = ListImages()
        operation.completionBlock = {
            print(operation.images)
            expectation.fulfill()
        }
        let queue = OperationQueue()
        queue.addOperations([operation], waitUntilFinished: false)
        waitForExpectations(timeout: 30)
    }
    
    func test_listContainers() {
        let expectation = expectation(description: "test_listContainers")
        let operation = ListContainers()
        operation.completionBlock = {
            print(operation.containers)
            expectation.fulfill()
        }
        let queue = OperationQueue()
        queue.addOperations([operation], waitUntilFinished: false)
        waitForExpectations(timeout: 30)
    }
    
    func test_removeAllContainers() {
        let expectation = expectation(description: "test_removeAllContainers")
        
        let listContainers = ListContainers()
        listContainers.completionBlock = {
            let containerIds = listContainers.containers?.compactMap { $0.id } ?? []
            let removeContainersOperations = containerIds.compactMap {
                let operation = RemoveContainer(containerId: $0)
                operation.addDependency(listContainers)
                return operation
            }
            
            let queue = OperationQueue()
            queue.addOperations(removeContainersOperations, waitUntilFinished: false)
        }
        
        let queue = OperationQueue()
        queue.addOperations([listContainers], waitUntilFinished: false)
        waitForExpectations(timeout: 30)
    }
}
