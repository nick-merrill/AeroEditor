//
//  NMVideoProcessor.swift
//  AeroEditor
//
//  Created by Nick Merrill on 7/29/15.
//  Copyright (c) 2015 Nick Merrill. All rights reserved.
//

import Cocoa
import AVFoundation
import QuartzCore
import CoreImage

let VIDEO_TIME_SCALE:Int32 = 10

// Used to indicate time ranges of varying levels of interesting footage.
class NMInterestingTimeRange: NSObject {
    var timeRange: CMTimeRange
    var score: Float
    
    init(start: Int64, duration: Int64, score: Float) {
        self.timeRange = CMTimeRangeMake(CMTimeMake(start, VIDEO_TIME_SCALE), CMTimeMake(duration, VIDEO_TIME_SCALE))
        self.score = score
    }
}


class NMPixel: NSObject {
    // These values are stored as floats on the interval [0, 1)
    let alpha: Float
    let red: Float
    let green: Float
    let blue: Float
    
    init(alpha: UInt8, red: UInt8, green: UInt8, blue: UInt8) {
        self.alpha = Float(alpha) / 256.0
        self.red = Float(red) / 256.0
        self.green = Float(green) / 256.0
        self.blue = Float(blue) / 256.0
    }
    
    func differenceScore(pixel2: NMPixel) -> Float {
        return (abs(self.alpha - pixel2.alpha) +
            abs(self.red - pixel2.red) +
            abs(self.green - pixel2.green) +
            abs(self.blue - pixel2.blue)) / 4.0
    }
    
    func intensity() -> Float {
        return (red + green + blue) / 3.0
    }
}


class NMImageAnalyzer: NSObject {
    let BYTES_PER_PIXEL = 4

    let imageData: UnsafePointer<UInt8>
    let pixelsWide: Int
    let pixelsHigh: Int

    var intensityHistogram: [Int]
    
    override var description: String {
        return "Size: \(self.pixelsWide)x\(self.pixelsHigh)\n" +
            "Intensity Histogram: \(self.intensityHistogram)"
    }
    
    init(image: CGImage) {
        let bitmapContext = NMImageAnalyzer.bitmapContext(image)
        let uncastedData = CGBitmapContextGetData(bitmapContext)
        self.imageData = UnsafePointer<UInt8>(uncastedData)
        self.pixelsWide = CGImageGetWidth(image)
        self.pixelsHigh = CGImageGetHeight(image)
        
        // Create histogram
        let HISTOGRAM_NUM_BUCKETS = 30
        let HISTOGRAM_SKIP_PIXELS = 4
        var intensityHistogramBuckets = [Float?](count: HISTOGRAM_NUM_BUCKETS, repeatedValue: nil)
        for var i in 0..<HISTOGRAM_NUM_BUCKETS {
            intensityHistogramBuckets[i] = Float(i) / Float(HISTOGRAM_NUM_BUCKETS)
        }
        self.intensityHistogram = [Int](count: HISTOGRAM_NUM_BUCKETS, repeatedValue: 0)
        for var i = 0; i < self.pixelsHigh; i += HISTOGRAM_SKIP_PIXELS {
            for var j = 0; j < self.pixelsWide; j += HISTOGRAM_SKIP_PIXELS {
                let pixel = self.pixelFromImageData(self.imageData, x: i, y: j)
                let intensity = pixel.intensity()
                var bucketIndex = 0
                while bucketIndex < HISTOGRAM_NUM_BUCKETS - 1 {
                    if intensityHistogramBuckets[bucketIndex + 1] > intensity {
                        break
                    }
                    bucketIndex++
                }
                // Increment the appropriate bucket
                self.intensityHistogram[bucketIndex]++
            }
        }
        
        // Create average pixel value grid
        let GRID_WIDTH = 4
        let GRID_HEIGHT = 3
        let widthPerGridPanel = self.pixelsWide / GRID_WIDTH
        let heightPerGridPanel = self.pixelsHigh / GRID_HEIGHT
        for var i in 0..<GRID_WIDTH {
            for var j in 0..<GRID_HEIGHT {
                // Calculate average pixel color within grid panel (i, j)
                let widthOffset = i * widthPerGridPanel
                let heightOffset = j * heightPerGridPanel
                
            }
        }
    }
    
    // From https://gist.github.com/jokester/948616a1b881451796d6
    private class func bitmapContext(img: CGImage) -> CGContextRef {
        // Get image width, height
        let pixelsWide = CGImageGetWidth(img)
        let pixelsHigh = CGImageGetHeight(img)
        
        // Declare the number of bytes per row. Each pixel in the bitmap in this
        // example is represented by 4 bytes; 8 bits each of red, green, blue, and
        // alpha.
        let bitmapBytesPerRow = pixelsWide * 4
        let bitmapByteCount = bitmapBytesPerRow * Int(pixelsHigh)
        
        // Use the generic RGB color space.
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        // Allocate memory for image data. This is the destination in memory
        // where any drawing to the bitmap context will be rendered.
        let bitmapData = malloc(bitmapByteCount)
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedFirst.rawValue)
        
        // Create the bitmap context. We want pre-multiplied ARGB, 8-bits
        // per component. Regardless of what the source image format is
        // (CMYK, Grayscale, and so on) it will be converted over to the format
        // specified here by CGBitmapContextCreate.
        let context = CGBitmapContextCreate(bitmapData, pixelsWide, pixelsHigh, 8, bitmapBytesPerRow, colorSpace, bitmapInfo.rawValue)!
        
        // draw the image onto the context
        let rect = CGRect(x: 0, y: 0, width: pixelsWide, height: pixelsHigh)
        CGContextDrawImage(context, rect, img)
        
        return context
    }
    
    private func pixelFromImageData(imageData: UnsafePointer<UInt8>, x: Int, y: Int) -> NMPixel {
        assert(0 <= x && x < self.pixelsWide)
        assert(0 <= y && y < self.pixelsHigh)
        let offset = 4 * (y * self.pixelsWide + x)
        return NMPixel(
            alpha: self.imageData[offset + 0],
            red: self.imageData[offset + 1],
            green: self.imageData[offset + 2],
            blue: self.imageData[offset + 3])
    }
}


enum NMVideoFrameError: ErrorType {
    case InvalidFrame
}


class NMVideoFrame: NSObject {
    var image: CGImage? = nil
    var asset: AVAsset? = nil
    var time: CMTime? = nil
    
    init(asset: AVAsset, time: CMTime) throws {
        super.init()
        self.asset = asset
        self.time = time
        if let image = NMVideoFrame.getImageFromAsset(asset, time: time) {
            self.image = image
        } else {
            throw NMVideoFrameError.InvalidFrame
        }
    }
    
    class func getImageFromAsset(asset: AVAsset, time: CMTime) -> CGImage? {
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        var actualTime = kCMTimeZero
        do {
            return try imageGenerator.copyCGImageAtTime(time, actualTime: &actualTime)
        } catch {
            print("Error grabbing image at time", time)
            return nil
        }
    }
    
    func imageAnalyzer() -> NMImageAnalyzer {
        return NMImageAnalyzer(image: self.image!)
    }
    
    func differenceScoreByHistogram(frame2: NMVideoFrame) -> Float {
        let hist1 = self.imageAnalyzer()
        let hist2 = frame2.imageAnalyzer()
        print(hist1)
        print(hist2)
        return 42
    }

}


class NMVideoProcessor: NSObject {
    
    init (forFiles fileURLs:[NSURL]) {
        self.fileURLs = fileURLs
        for url in self.fileURLs {
            self.assets.append(AVAsset(URL: url))
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
        print("finding interesting times")

        if let asset = self.primaryAsset {
            // experiment::
            do {
                let frame1 = try NMVideoFrame(asset: asset, time: CMTimeMake(0, VIDEO_TIME_SCALE))
                let frame2 = try NMVideoFrame(asset: asset, time: CMTimeMake(10, VIDEO_TIME_SCALE))
                let diff = frame1.differenceScoreByHistogram(frame2)
                print(diff)
            } catch {
                print("Error initializing NMVideoFrame")
            }
        }

        self.interestingTimes = []  // TODO

//        self.interestingTimes = [
//            NMInterestingTimeRange(start: 200, duration: 50, score: 40.5),
//            NMInterestingTimeRange(start: 500, duration: 20, score: 100),
//        ]
    }
    
    func insertFootageFromInterestingTimes() {
        if (self.primaryAsset == nil) {
            print("No primary asset to work with")
            return
        }
        if (self.compositionTrackVideo == nil) {
            print("No composition track initialized yet")
            return
        }
        for time in self.interestingTimes {
            do {
                try self.compositionTrackVideo!.insertTimeRange(time.timeRange, ofTrack: self.primaryAsset!.tracksWithMediaType(AVMediaTypeVideo)[0], atTime: self.currentCompositionTime)
                self.currentCompositionTime = CMTimeAdd(self.currentCompositionTime, time.timeRange.duration)
            } catch {
                print("Error inserting footage")
            }
        }
    }
    
    func getPreviewFrame(completionHandler: (CGImage)->Void) {
        let imageGenerator = AVAssetImageGenerator(asset: self.composition)
        
        var actualTime = kCMTimeZero
        do {
            let image = try imageGenerator.copyCGImageAtTime(self.previewTime, actualTime: &actualTime)
            completionHandler(image)
            self.previewTime = CMTimeAdd(self.previewTime, CMTimeMake(1, 1))
        } catch {
            print("Error generating preview image")
        }
    }
}
