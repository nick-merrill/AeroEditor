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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("updateSelection:"), name: "ChooseOutlineViewSelectionChanged", object: nil)
    }
    
    func updateSelection(notification: NSNotification) {
        angle = notification.userInfo?["selectedAngle"] as? NMFootageAngle
    }
}
