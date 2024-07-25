//
//  File.swift
//  
//
//  Created by cristian on 16/07/24.
//

import Foundation

class AsyncOperation: Operation {

    private let lockQueue = DispatchQueue(label: "com.testcontainers.async", attributes: .concurrent)
    private var _isExecuting: Bool = false
    private var _isFinished: Bool = false
    
    override var isAsynchronous: Bool {
        return true
    }
    
    override var isExecuting: Bool {
        get { return lockQueue.sync { _isExecuting } }
        set {
            willChangeValue(forKey: "isExecuting")
            lockQueue.sync(flags: .barrier) { _isExecuting = newValue }
            didChangeValue(forKey: "isExecuting")
        }
    }
    
    override var isFinished: Bool {
        get { return lockQueue.sync { _isFinished } }
        set {
            willChangeValue(forKey: "isFinished")
            lockQueue.sync(flags: .barrier) { _isFinished = newValue }
            didChangeValue(forKey: "isFinished")
        }
    }
    
    override func start() {
        if isCancelled {
            finish()
            return
        }
        
        isExecuting = true
        main()
    }
    
    func finish() {
        isExecuting = false
        isFinished = true
    }
}
