//
//  NMFootageTreeController.swift
//  AeroEditor
//
//  Created by Nick Merrill on 8/16/15.
//  Copyright © 2015 Nick Merrill. All rights reserved.
//

import Cocoa
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class NMFootageTreeController: NSTreeController {
    override func add(_ sender: Any?) {
        if !canAdd {
            return
        }
        if self.selectionIndexPath?.count > 1 {
            self.addObject(NMFootageAsset())
        } else {
            self.addObject(NMFootageAngle())
        }
    }
    
    override func addChild(_ sender: Any?) {
        if !canAddChild {
            return
        }
        let length = selectionIndexPath!.count
        var indexes = [Int](repeating: 0, count: length + 1)
        (selectionIndexPath! as NSIndexPath).getIndexes(&indexes)
        indexes[length] = 0
        let newIndexPath = NSIndexPath(indexes: indexes, length: indexes.count) as IndexPath
        self.insert(NMFootageAsset(), atArrangedObjectIndexPath: newIndexPath)
    }
    
    override var canAddChild: Bool {
        return selectionIndexPath == nil || selectionIndexPath!.count <= 1
    }
}
