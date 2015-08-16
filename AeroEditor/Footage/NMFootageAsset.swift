//
//  NMFootageTrack.swift
//  AeroEditor
//
//  Created by Nick Merrill on 8/15/15.
//  Copyright © 2015 Nick Merrill. All rights reserved.
//

import Cocoa
import AVFoundation

class NMFootageAsset: NMFootageObject {
    var asset: AVAsset?
    
    override init() {
        super.init()
        title = "Unnamed Asset"
    }
}
