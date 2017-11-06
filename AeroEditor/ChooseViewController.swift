//
//  ChooseViewController.swift
//  AeroEditor
//
//  Created by Nick Merrill on 8/10/15.
//  Copyright © 2015 Nick Merrill. All rights reserved.
//

import Cocoa

class ChooseViewController: SubMainViewController {
    
    lazy var chooseSplitVC: ChooseSplitViewController = self.storyboard!.instantiateController(withIdentifier: "ChooseSplitViewController") as! ChooseSplitViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addChildViewController(chooseSplitVC)
        self.view.addSubview(chooseSplitVC.view)
        NotificationCenter.default.addObserver(self, selector: #selector(NSWindowDelegate.windowDidResize(_:)), name: NSNotification.Name.NSWindowDidResize, object: self.view.window)
        self.layoutSubviews()
    }
    
    func windowDidResize(_ notification: Notification) {
        self.layoutSubviews()
    }
    
    func layoutSubviews() {
        chooseSplitVC.view.frame = self.view.bounds
    }
}
