//
//  NMFootageTreeController.swift
//  AeroEditor
//
//  Created by Nick Merrill on 8/16/15.
//  Copyright © 2015 Nick Merrill. All rights reserved.
//

import Cocoa

class NMFootageTreeController: NSTreeController {
    override func add(sender: AnyObject?) {
        if !canAdd {
            return
        }
        if self.selectionIndexPath?.length > 1 {
            self.addObject(NMFootageAsset())
        } else {
            self.addObject(NMFootageAngle())
        }
    }
    
    override func addChild(sender: AnyObject?) {
        if !canAddChild {
            return
        }
        let length = selectionIndexPath!.length
        var indexes = [Int](count: length + 1, repeatedValue: 0)
        selectionIndexPath!.getIndexes(&indexes)
        indexes[length] = 0
        let newIndexPath = NSIndexPath(indexes: indexes, length: indexes.count)
        self.insertObject(NMFootageAsset(), atArrangedObjectIndexPath: newIndexPath)
    }
    
    override var canAddChild: Bool {
        return selectionIndexPath == nil || selectionIndexPath!.length <= 1
    }
}
