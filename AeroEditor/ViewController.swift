//
//  ViewController.swift
//  AeroEditor
//
//  Created by Nick Merrill on 7/29/15.
//  Copyright (c) 2015 Nick Merrill. All rights reserved.
//

import Cocoa
import AVKit
import AVFoundation

class ViewController: NSViewController {
    
    @IBOutlet weak var fileDisplay: NSTextField!
    @IBOutlet weak var playerView: AVPlayerView!
    
    lazy var detailWindowCtrl: DetailWindowController = self.storyboard!.instantiateControllerWithIdentifier("DetailWindowController") as! DetailWindowController
    
    var videoURLs = [NSURL]()
    var activeProcessor:NMVideoProcessor?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    
    // Allows user to choose which video files to process
    @IBAction func addFiles(sender: AnyObject) {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = true
        openPanel.runModal()
        self.videoURLs += openPanel.URLs
        self.updateFileDisplay()
    }
    @IBAction func clearFiles(sender: AnyObject) {
        self.videoURLs.removeAll(keepCapacity: false)
        self.updateFileDisplay()
    }
    
    func updateFileDisplay() {
        let str:NSMutableString = ""
        for url in self.videoURLs {
            str.appendString("• ")
            str.appendString(url.lastPathComponent!)
            str.appendString("\n")
        }
        self.fileDisplay.stringValue = str as String
    }

    // Begins processing video files
    @IBAction func process(sender: AnyObject) {
        let processor = NMVideoProcessor(forFiles: self.videoURLs)
        self.activeProcessor = processor
        
        processor.analyzeInterestingTimes()
        processor.sortInterestingTimes()
        processor.insertFootageFromInterestingTimes()
        
        // Set preview video to monitor composition
        let playerItem = AVPlayerItem(asset: processor.composition)
        self.playerView.player = AVPlayer(playerItem: playerItem)
    }
    
    @IBAction func showInterestingFootage(sender: AnyObject) {
        detailWindowCtrl.showWindow(self)
    }
    
//    @IBAction func previewImageFrame(sender: AnyObject) {
//        if let processor = self.activeProcessor {
//            processor.getPreviewFrame({
//                image in
//                print("about to show frame")
//                self.previewImageView.image = NSImage(CGImage: image, size: self.previewImageView.frame.size)
//            })
//        }
//    }
}

