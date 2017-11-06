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
    lazy var updateProgressTimer: Timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(StatusViewController.updateProgress), userInfo: nil, repeats: true)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.allowsColumnReordering = false
        tableView.allowsColumnResizing = false
        tableView.allowsColumnSelection = false
        
        self.updateProgressTimer.fire()
    }
    
    func updateProgress() {
        if let processor = self.videoProcessor {
            progressIndicator.doubleValue = processor.operations.progress()
        } else {
            progressIndicator.doubleValue = 1
        }
        self.tableView.reloadData()
    }

    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if let processor = videoProcessor {
            if item == nil {
                return processor.operations.allOperations[index]
            }
        }
        return "error"
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return false
    }
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if (item == nil) {
            if let processor = self.videoProcessor {
                return processor.operations.allOperations.count
            } else {
                return 0
            }
        }
        return 0
    }
    
    func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
        if let operationItem = item as? NMInterestingTimeAnalysisOperation {
            switch tableColumn!.identifier {
            case "status":
                return operationItem.statusDescription()
            case "description":
                return operationItem.name
            default:
                break
            }
        }
        return "not found"
    }
    
}
