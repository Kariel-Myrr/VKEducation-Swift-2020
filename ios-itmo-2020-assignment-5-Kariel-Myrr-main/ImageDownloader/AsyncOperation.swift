//
//  AsyncOperation.swift
//  ImageDownloader
//
//  Created by Kariel Myrr on 27.12.2020.
//

import Foundation
import Combine

class AsyncOperation: Operation, Cancellable {
    enum State : String {
        case ready = "isReady"
        case executing = "isExecuting"
        case finished = "isFinished"
    }
    
    var state = State.ready {
        willSet {
            willChangeValue(forKey: state.rawValue)
            willChangeValue(forKey: newValue.rawValue)
        }
        didSet {
            didChangeValue(forKey: state.rawValue)
            didChangeValue(forKey: oldValue.rawValue)
        }
    }
    
    override var isAsynchronous: Bool { true }
    
    override var isReady: Bool {
        return super.isReady && state == .ready
    }
    
    override var isExecuting: Bool {
        return state == .executing
    }
    
    override var isFinished: Bool {
        return state == .finished
    }
    
    
    override func start() {
        if isCancelled {
            state = .finished
        } else {
            main()
            state = .executing
        }
    }
    
    override func cancel() {
        super.cancel()
        state = .finished
    }
}
