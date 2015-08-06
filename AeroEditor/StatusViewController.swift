//
//  StatusViewController.swift
//  AeroEditor
//
//  Created by Nick Merrill on 8/4/15.
//  Copyright © 2015 Nick Merrill. All rights reserved.
//

import Cocoa

class StatusViewController: NSViewController, NSOutlineViewDataSource {

    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var tableView: NSOutlineView!
    var videoProcessor: NMVideoProcessor? {
        didSet {
            self.updateProgress()
        }
    }
    var updateProgressTimer: NSTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.allowsColumnReordering = false
        tableView.allowsColumnResizing = false
        tableView.allowsColumnSelection = false
        
        self.updateProgressTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("updateProgress"), userInfo: nil, repeats: true)
    }
    
    func updateProgress() {
        if let processor = self.videoProcessor {
            progressIndicator.doubleValue = processor.operations.progress()
        } else {
            progressIndicator.doubleValue = 1
        }
        self.tableView.reloadData()
    }

    func outlineView(outlineView: NSOutlineView, child index: Int, ofItem item: AnyObject?) -> AnyObject {
        if let processor = videoProcessor {
            if item == nil {
                return processor.operations.allOperations[index]
            }
        }
        return "error"
    }
    
    func outlineView(outlineView: NSOutlineView, isItemExpandable item: AnyObject) -> Bool {
        return false
    }
    
    func outlineView(outlineView: NSOutlineView, numberOfChildrenOfItem item: AnyObject?) -> Int {
        if (item == nil) {
            if let processor = self.videoProcessor {
                return processor.operations.allOperations.count
            } else {
                return 0
            }
        }
        return 0
    }
    
    func outlineView(outlineView: NSOutlineView, objectValueForTableColumn tableColumn: NSTableColumn?, byItem item: AnyObject?) -> AnyObject? {
        if let operationItem = item as? NMInterestingTimeAnalysisOperation {
            switch tableColumn!.identifier {
            case "status":
                if operationItem.failed {
                    return "Failed"
                } else if operationItem.executing {
                    return "Processing"
                } else if operationItem.finished {
                    return "Finished"
                } else if operationItem.ready {
                    return "Queued"
                } else if operationItem.dependencies.count > 0 {
                    return "Queued (Pending Dependencies)"
                } else {
                    return "Unknown"
                }
            case "description":
                return operationItem.name
            default:
                break
            }
        }
        return "not found"
    }
    
}
