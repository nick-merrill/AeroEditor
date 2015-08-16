//
//  MainViewController.swift
//  AeroEditor
//
//  Created by Nick Merrill on 8/10/15.
//  Copyright © 2015 Nick Merrill. All rights reserved.
//

import Cocoa

class MainViewController: NSTabViewController {
    
//    lazy var footageAngles = [NMFootageAngle]()
    @IBOutlet var footageController: NSTreeController!
    var footage = [NMFootageObject]()
//    lazy var footageAnglesController: NSTreeController = {
//        let tree = NSTreeController()
//        let treeRoot = [
//            "title": "Camera Angles",
//            "isLeaf": false,
//        ]
//        tree.addObject(treeRoot)
//        return tree
//    }()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}
