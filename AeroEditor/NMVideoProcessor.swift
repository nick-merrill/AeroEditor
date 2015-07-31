//
//  NMVideoProcessor.swift
//  AeroEditor
//
//  Created by Nick Merrill on 7/29/15.
//  Copyright (c) 2015 Nick Merrill. All rights reserved.
//

import Cocoa
import AVFoundation

let VIDEO_TIME_SCALE:Int32 = 10

// Used to indicate time ranges of varying levels of interesting footage.
class NMInterestingTimeRange: NSObject {
    let timeRange: CMTimeRange
    let score: Float
    
    init(start: Int64, duration: Int64, score: Float) {
        self.timeRange = CMTimeRangeMake(CMTimeMake(start, VIDEO_TIME_SCALE), CMTimeMake(duration, VIDEO_TIME_SCALE))
        self.score = score
    }
}


class NMVideoProcessor: NSObject {
    
    init (forFiles fileURLs:[NSURL]) {
        self.fileURLs = fileURLs
        for url in self.fileURLs {
            self.assets.append(AVAsset.assetWithURL(url) as! AVAsset)
        }
        if (self.assets.count > 0) {
            self.primaryAsset = self.assets[0]
        }
        
        // Creates main video track for composition
        self.compositionTrackVideo = self.composition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: 0)
    }
    
    var fileURLs = [NSURL]()
    var assets = [AVAsset]()
    var primaryAsset:AVAsset?
    var previewTime = kCMTimeZero
    
    var interestingTimes = [NMInterestingTimeRange]()
    
    var composition = AVMutableComposition()
    var compositionTrackVideo:AVMutableCompositionTrack?
    var currentCompositionTime = kCMTimeZero
    
    // Finds "interesting" times in all asset video tracks.
    func identifyInterestingTimes() {
        println("finding interesting times")
        self.interestingTimes = [
            NMInterestingTimeRange(start: 200, duration: 50, score: 40.5),
            NMInterestingTimeRange(start: 500, duration: 20, score: 100),
        ]
    }
    
    func insertFootageFromInterestingTimes() {
        var error: NSError?
        if (self.primaryAsset == nil) {
            println("No primary asset to work with")
            return
        }
        if (self.compositionTrackVideo == nil) {
            println("No composition track initialized yet")
            return
        }
        for time in self.interestingTimes {
            self.compositionTrackVideo!.insertTimeRange(time.timeRange, ofTrack: self.primaryAsset!.tracksWithMediaType(AVMediaTypeVideo)[0] as! AVAssetTrack, atTime: self.currentCompositionTime, error: &error)
            if (error != nil) {
                println("Error inserting footage", error!.description)
                return
            }
            self.currentCompositionTime = CMTimeAdd(self.currentCompositionTime, time.timeRange.duration)
        }
    }
    
    func getPreviewFrame(completionHandler: (CGImage)->Void) {
        let imageGenerator = AVAssetImageGenerator(asset: self.composition)
        let timeValue = NSValue(CMTime: self.previewTime)
        
        var error: NSError?
        var actualTime = kCMTimeZero
        let image = imageGenerator.copyCGImageAtTime(self.previewTime, actualTime: &actualTime, error: &error)
        if (error != nil) {
            println("Error generating preview image:", error!.description)
            return
        }
        completionHandler(image)
        self.previewTime = CMTimeAdd(self.previewTime, CMTimeMake(1, 1))
    }
}
