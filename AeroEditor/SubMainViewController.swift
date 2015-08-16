//
//  SubMainViewController.swift
//  AeroEditor
//
//  Created by Nick Merrill on 8/11/15.
//  Copyright © 2015 Nick Merrill. All rights reserved.
//

import Cocoa

// Helps automatically define the MainViewController
// Used for other subclasses of NSViewController
func getMainViewController(myViewController: NSViewController) -> MainViewController {
    if let mainVC = getMainViewControllerFromParentViewController(myViewController) {
        return mainVC
    }
    assert(false)
}

func getMainViewControllerFromParentViewController(viewController: NSViewController?) -> MainViewController? {
    if viewController == nil {
        return nil
    }
    var mainVC: MainViewController?
    switch viewController {
    case is MainViewController:
        mainVC = viewController as? MainViewController
    case is SubMainViewController:
        let parentVC = viewController as? SubMainViewController
        mainVC = parentVC?.mainVC
    case is SubMainSplitViewController:
        let parentVC = viewController as? SubMainSplitViewController
        mainVC = parentVC?.mainVC
    default:
        break
    }
    if mainVC != nil {
        return mainVC!
    }
    return getMainViewControllerFromParentViewController(viewController?.parentViewController)
}


class SubMainViewController: NSViewController {
    var mainVC: MainViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainVC = getMainViewController(self)
    }
}


class SubMainSplitViewController: NSSplitViewController {
    var mainVC: MainViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainVC = getMainViewController(self)
    }
}
