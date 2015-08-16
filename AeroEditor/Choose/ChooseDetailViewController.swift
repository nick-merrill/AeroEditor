//
//  ChooseDetailViewController.swift
//  AeroEditor
//
//  Created by Nick Merrill on 8/11/15.
//  Copyright © 2015 Nick Merrill. All rights reserved.
//

import Cocoa

class ChooseDetailViewController: SubMainViewController, NSTextFieldDelegate {

    @IBOutlet weak var angleNameTextField: NSTextField!
    var angle: NMFootageAngle? {
        didSet {
            if let angle = angle {
                angleNameTextField.stringValue = angle.title
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("updateSelection:"), name: "ChooseOutlineViewSelectionChanged", object: nil)
    }
    
    func updateSelection(notification: NSNotification) {
        angle = notification.userInfo?["selectedAngle"] as? NMFootageAngle
    }
    
    override func controlTextDidChange(obj: NSNotification) {
        if obj.userInfo?["NSFieldEditor"] as? NSTextField == angleNameTextField {
            print("yes")
        }
        
        super.controlTextDidChange(obj)
    }
}
