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
    
    func isLeaf() -> Bool {
        return true
    }
    
    func icon() -> NSImage {
        return NSImage(named: "NSActionTemplate")!
    }
}
