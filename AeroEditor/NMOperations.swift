//
//  NMOperations.swift
//  AeroEditor
//
//  Created by Nick Merrill on 8/5/15.
//  Copyright © 2015 Nick Merrill. All rights reserved.
//

import Cocoa


class NMOperation: Operation {
    var failed = false
    
    func statusDescription() -> String {
        if self.failed {
            return "Failed"
        } else if self.isExecuting {
            return "Processing"
        } else if self.isFinished {
            return "Finished"
        } else if self.isReady {
            return "Queued"
        } else if self.dependencies.count > 0 {
            return "Queued (Pending Dependencies)"
        } else {
            return "Unknown"
        }
    }
}


class NMOperationQueue: OperationQueue {
    override init() {
        super.init()
        //        self.maxConcurrentOperationCount = 2  // FIXME: for testing only
    }
    
    lazy var operationsComplete = [Operation]()
    
    var onFinalOperationCompleted: ((Void) -> Void)?
    var addOperationCallback: ((Operation) -> Void)?
    
    // Ensure operation is appended to completed operations array on completion
    override func addOperation(_ op: Operation) {
        op.completionBlock = {
            if let presetCompletionBlock = op.completionBlock {
                presetCompletionBlock()
            }
            self.operationsComplete.append(op)
            if self.operations.count == 0 {
                self.onFinalOperationCompleted?()
            }
        }
        super.addOperation(op)
        self.addOperationCallback?(op)
    }
}
