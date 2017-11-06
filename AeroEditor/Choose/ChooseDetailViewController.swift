//
//  ChooseDetailViewController.swift
//  AeroEditor
//
//  Created by Nick Merrill on 8/11/15.
//  Copyright © 2015 Nick Merrill. All rights reserved.
//

import Cocoa

class ChooseDetailViewController: SubMainViewController {

    var angle: NMFootageAngle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(ChooseDetailViewController.updateSelection(_:)), name: NSNotification.Name(rawValue: "ChooseOutlineViewSelectionChanged"), object: nil)
    }
    
    func updateSelection(_ notification: Notification) {
        angle = notification.userInfo?["selectedAngle"] as? NMFootageAngle
    }
}
