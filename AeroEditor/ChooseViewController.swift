//
//  ChooseViewController.swift
//  AeroEditor
//
//  Created by Nick Merrill on 8/10/15.
//  Copyright © 2015 Nick Merrill. All rights reserved.
//

import Cocoa

class ChooseViewController: SubMainViewController {
    
    lazy var chooseSplitVC: ChooseSplitViewController = self.storyboard!.instantiateControllerWithIdentifier("ChooseSplitViewController") as! ChooseSplitViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addChildViewController(chooseSplitVC)
        self.view.addSubview(chooseSplitVC.view)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("windowDidResize:"), name: NSWindowDidResizeNotification, object: self.view.window)
        self.layoutSubviews()
    }
    
    func windowDidResize(notification: NSNotification) {
        self.layoutSubviews()
    }
    
    func layoutSubviews() {
        chooseSplitVC.view.frame = self.view.bounds
    }
}
