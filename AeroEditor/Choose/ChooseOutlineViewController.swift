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
        
        outlineView.bind("content", to: footageController, withKeyPath: "self.arrangedObjects", options: nil)
        outlineView.bind("selectionIndexPaths", to: footageController, withKeyPath: "self.selectionIndexPaths", options: nil)
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "[view(==200)]", options: [], metrics: nil, views: ["view": self.view]))
    }
    
    @IBAction func addAngle(_ sender: AnyObject) {
        footageController.add(self)
    }
    
    @IBAction func addAsset(_ sender: AnyObject) {
        footageController.addChild(self)
    }
    
    @IBAction func remove(_ sender: AnyObject) {
        footageController.remove(self)
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: AnyObject) -> Bool {
        return true
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        let view = outlineView.make(withIdentifier: "DataCell", owner: self) as! NSTableCellView
        return view
    }
    
    func outlineViewSelectionDidChange(_ notification: Notification) {
        if let selectedAngle = footageController.selectedObjects.first {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "ChooseOutlineViewSelectionChanged"), object: self, userInfo: ["selectedAngle": selectedAngle])
        }
    }
    
    @IBAction func footageObjectEdited(_ sender: AnyObject) {
//        print(footageController.content)
    }
}
