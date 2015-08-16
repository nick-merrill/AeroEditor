//
//  ChooseOutlineViewController.swift
//  AeroEditor
//
//  Created by Nick Merrill on 8/11/15.
//  Copyright © 2015 Nick Merrill. All rights reserved.
//

import Cocoa

class ChooseOutlineViewController: SubMainViewController, NSOutlineViewDelegate {

    @IBOutlet weak var outlineView: NSOutlineView!
    lazy var footageController: NSTreeController = self.mainVC!.footageController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        outlineView.bind("content", toObject: footageController, withKeyPath: "self.arrangedObjects", options: nil)
        outlineView.bind("selectionIndexPaths", toObject: footageController, withKeyPath: "self.selectionIndexPaths", options: nil)
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("[view(==200)]", options: [], metrics: nil, views: ["view": self.view]))
    }
    
    @IBAction func addAngle(sender: AnyObject) {
        footageController.add(self)
    }
    
    @IBAction func addAsset(sender: AnyObject) {
        footageController.addChild(self)
    }
    
    @IBAction func remove(sender: AnyObject) {
        footageController.remove(self)
    }
    
    func outlineView(outlineView: NSOutlineView, isItemExpandable item: AnyObject) -> Bool {
        return true
    }
    
    func outlineView(outlineView: NSOutlineView, viewForTableColumn tableColumn: NSTableColumn?, item: AnyObject) -> NSView? {
        let view = outlineView.makeViewWithIdentifier("DataCell", owner: self) as! NSTableCellView
        return view
    }
    
    func outlineViewSelectionDidChange(notification: NSNotification) {
        if let selectedAngle = footageController.selectedObjects.first {
            NSNotificationCenter.defaultCenter().postNotificationName("ChooseOutlineViewSelectionChanged", object: self, userInfo: ["selectedAngle": selectedAngle])
        }
    }
    
    @IBAction func footageObjectEdited(sender: AnyObject) {
//        print(footageController.content)
    }
}
