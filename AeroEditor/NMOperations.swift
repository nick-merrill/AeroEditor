//
//  NMOperations.swift
//  AeroEditor
//
//  Created by Nick Merrill on 8/5/15.
//  Copyright © 2015 Nick Merrill. All rights reserved.
//

import Cocoa


class NMOperation: NSOperation {
    var failed = false
    
    func statusDescription() -> String {
        if self.failed {
            return "Failed"
        } else if self.executing {
            return "Processing"
        } else if self.finished {
            return "Finished"
        } else if self.ready {
            return "Queued"
        } else if self.dependencies.count > 0 {
            return "Queued (Pending Dependencies)"
        } else {
            return "Unknown"
        }
    }
}


class NMOperationQueue: NSOperationQueue {
    override init() {
        super.init()
        //        self.maxConcurrentOperationCount = 2  // FIXME: for testing only
    }
    
    lazy var operationsComplete = [NSOperation]()
    
    var onFinalOperationCompleted: (Void -> Void)?
    var addOperationCallback: (NSOperation -> Void)?
    
    // Ensure operation is appended to completed operations array on completion
    override func addOperation(op: NSOperation) {
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