//
//  NMFootageAngle.swift
//  AeroEditor
//
//  Created by Nick Merrill on 8/10/15.
//  Copyright © 2015 Nick Merrill. All rights reserved.
//

import Cocoa

class NMFootageAngle: NMFootageObject {
    override init() {
        super.init()
        title = "Unnamed Angle"
    }
    
    override func isLeaf() -> Bool {
        return false
    }
    
    override func icon() -> NSImage {
        return NSImage(named: "NSFolderTemplate")!
    }
}
