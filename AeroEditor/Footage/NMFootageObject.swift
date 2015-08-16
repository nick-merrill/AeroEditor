//
//  NMFootageObject.swift
//  AeroEditor
//
//  Created by Nick Merrill on 8/15/15.
//  Copyright © 2015 Nick Merrill. All rights reserved.
//

import Cocoa

class NMFootageObject: NSObject {
    var title: String = ""
    var children = [NMFootageObject]()
    
    override var description: String {
        var ret = "\(self.className): \(title)"
        if children.count > 0 {
            ret += " [children: "
            for child in children {
                ret += child.description
            }
            ret += "]"
        }
        return ret
    }
    
    func isLeaf() -> Bool {
        return true
    }
    
    func icon() -> NSImage {
        return NSImage(named: "NSActionTemplate")!
    }
}
