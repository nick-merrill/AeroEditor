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
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


let VIDEO_TIME_SCALE:Int32 = 100
let COMPARE_DISTANCE: Int64 = 25

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
    // These values are stored as floats on the interval [0, 1]
    let alpha: Float
    let red: Float
    let green: Float
    let blue: Float
    
    override var description: String {
        return "(\(self.red256()), \(self.green256()), \(self.blue256()))"
    }
    
    init(alphaF: Float, redF: Float, greenF: Float, blueF: Float) {
        self.alpha = alphaF
        self.red = redF
        self.green = greenF
        self.blue = blueF
    }
    
    convenience init(alpha: UInt8, red: UInt8, green: UInt8, blue: UInt8) {
        self.init(
            alphaF: Float(alpha) / 255.0,
            redF: Float(red) / 255.0,
            greenF: Float(green) / 255.0,
            blueF: Float(blue) / 255.0)
    }

    
    func differenceScore(_ pixel2: NMPixel) -> Float {
        let alphaDiff = abs(self.alpha - pixel2.alpha)
        let redDiff = abs(self.red - pixel2.red)
        let greenDiff = abs(self.green - pixel2.green)
        let blueDiff = abs(self.blue - pixel2.blue)
        let sumDiff = alphaDiff + redDiff + greenDiff + blueDiff
        return sumDiff / 4.0
    }
    
    func intensity() -> Float {
        return (red + green + blue) / 3.0
    }
    
    func red256() -> UInt8 {
        return UInt8(self.red * 255)
    }
    
    func green256() -> UInt8 {
        return UInt8(self.green * 255)
    }
    
    func blue256() -> UInt8 {
        return UInt8(self.blue * 255)
    }
}


let BYTES_PER_PIXEL = 4
let HISTOGRAM_NUM_BUCKETS = 30
let HISTOGRAM_SKIP_PIXELS = 10
let GRID_WIDTH = 17
let GRID_HEIGHT = 10
let GRID_SKIP_PIXELS = HISTOGRAM_SKIP_PIXELS

class NMImageAnalyzer: NSObject {
    var bitmapData: UnsafeMutableRawPointer
    var imageData: UnsafePointer<UInt8>
    let pixelsWide: Int
    let pixelsHigh: Int

    var intensityHistogram: [Int] = [Int]()
    var averageGrid: [[NMPixel?]] = []  // 2D array in the form [y, x]
    
    override var description: String {
        return "Size: \(self.pixelsWide)x\(self.pixelsHigh)\n" +
            "Intensity Histogram: \(self.intensityHistogram)\n" +
            "Color Grid: \(self.averageGrid)"
    }
    
    init(image: CGImage) {
        let bitmapContext = NMImageAnalyzer.bitmapContext(image)
        self.bitmapData = bitmapContext.bitmapData
        let uncastedData = (bitmapContext.context).data
        self.imageData = UnsafePointer<UInt8>(uncastedData)
        self.pixelsWide = image.width
        self.pixelsHigh = image.height
        super.init()
        
        // Create histogram
//        self.generateHistogram()
        
        // Create average pixel value grid
        self.generateAverageGrid()
    }
    
    deinit {
        free(self.bitmapData)
    }
    
    fileprivate func generateHistogram() {
        var intensityHistogramBuckets = [Float?](repeating: nil, count: HISTOGRAM_NUM_BUCKETS)
        for let i in 0..<HISTOGRAM_NUM_BUCKETS {
            intensityHistogramBuckets[i] = Float(i) / Float(HISTOGRAM_NUM_BUCKETS)
        }
        self.intensityHistogram = [Int](repeating: 0, count: HISTOGRAM_NUM_BUCKETS)
        for var y = 0; y < self.pixelsHigh; y += HISTOGRAM_SKIP_PIXELS {
            for var x = 0; x < self.pixelsWide; x += HISTOGRAM_SKIP_PIXELS {
                let pixel = self.pixelAt(x: x, y: y)
                let intensity = pixel.intensity()
                var bucketIndex = 0
                while bucketIndex < HISTOGRAM_NUM_BUCKETS - 1 {
                    if intensityHistogramBuckets[bucketIndex + 1] > intensity {
                        break
                    }
                    bucketIndex += 1
                }
                // Increment the appropriate bucket
                self.intensityHistogram[bucketIndex] += 1
            }
        }
    }
    
    fileprivate func generateAverageGrid() {
        let widthPerGridPanel = self.pixelsWide / GRID_WIDTH
        let heightPerGridPanel = self.pixelsHigh / GRID_HEIGHT
        self.averageGrid = Array<[NMPixel?]>(repeating: [NMPixel?](), count: GRID_HEIGHT)
        for let n in 0..<GRID_HEIGHT {
            self.averageGrid[n] = [NMPixel?](repeating: nil, count: GRID_WIDTH)
            for let m in 0..<GRID_WIDTH {
                // Calculate average pixel color within grid panel (m, n)
                let widthOffset = m * widthPerGridPanel
                let heightOffset = n * heightPerGridPanel
                var alphaSum: Float = 0
                var redSum: Float = 0
                var greenSum: Float = 0
                var blueSum: Float = 0
                //                var intensitySum: Float = 0
                var count: Int = 0
                for var y = heightOffset; y < heightOffset + heightPerGridPanel; y += GRID_SKIP_PIXELS {
                    for var x = widthOffset; x < widthOffset + widthPerGridPanel; x += GRID_SKIP_PIXELS {
                        let pixel = self.pixelAt(x: x, y: y)
                        alphaSum += pixel.alpha
                        redSum += pixel.red
                        greenSum += pixel.green
                        blueSum += pixel.blue
                        //                        intensitySum += pixel.intensity()
                        count += 1
                    }
                }
                let countF = Float(count)
                let averagePixel = NMPixel(
                    alphaF: alphaSum / countF,
                    redF: redSum / countF,
                    greenF: greenSum / countF,
                    blueF: blueSum / countF)
                self.averageGrid[n][m] = averagePixel
            }
        }
    }
    
    // From https://gist.github.com/jokester/948616a1b881451796d6
    fileprivate class func bitmapContext(_ img: CGImage) -> (context: CGContext, bitmapData: UnsafeMutableRawPointer) {
        // Get image width, height
        let pixelsWide = img.width
        let pixelsHigh = img.height
        
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
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)
        
        // Create the bitmap context. We want pre-multiplied ARGB, 8-bits
        // per component. Regardless of what the source image format is
        // (CMYK, Grayscale, and so on) it will be converted over to the format
        // specified here by CGBitmapContextCreate.
        let context = CGContext(data: bitmapData, width: pixelsWide, height: pixelsHigh, bitsPerComponent: 8, bytesPerRow: bitmapBytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!
                
        // draw the image onto the context
        let rect = CGRect(x: 0, y: 0, width: pixelsWide, height: pixelsHigh)
        context.draw(img, in: rect)
        
        return (context, bitmapData!)
    }
    
    fileprivate func pixelAt(x: Int, y: Int) -> NMPixel {
        assert(0 <= x && x < self.pixelsWide)
        assert(0 <= y && y < self.pixelsHigh)
        let offset = 4 * (y * self.pixelsWide + x)
        return NMPixel(
            alpha: self.imageData[offset + 0],
            red: self.imageData[offset + 1],
            green: self.imageData[offset + 2],
            blue: self.imageData[offset + 3])
    }
    
    // Compares each color grid panel and returns average difference between all panels
    func differenceScoreByColorGrid(_ analyzer2: NMImageAnalyzer) -> Float {
        var differenceSum: Float = 0
        for let n in 0..<GRID_HEIGHT {
            for let m in 0..<GRID_WIDTH {
                let pixel1 = self.averageGrid[n][m]!
                let pixel2 = analyzer2.averageGrid[n][m]!
                let difference: Float = pixel1.differenceScore(pixel2)
                differenceSum += difference
            }
        }
        return differenceSum / Float(GRID_HEIGHT * GRID_WIDTH)
    }
}


enum NMVideoFrameError: Error {
    case invalidFrame
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
            throw NMVideoFrameError.invalidFrame
        }
    }
    
    class func getImageFromAsset(_ asset: AVAsset, time: CMTime) -> CGImage? {
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        var actualTime = kCMTimeZero
        do {
            return try imageGenerator.copyCGImage(at: time, actualTime: &actualTime)
        } catch {
            print("Error grabbing image at time", time)
            return nil
        }
    }
    
    func imageAnalyzer() -> NMImageAnalyzer {
        return NMImageAnalyzer(image: self.image!)
    }
    
    func differenceScore(_ frame2: NMVideoFrame) -> Float {
        let analyzer1 = self.imageAnalyzer()
        let analyzer2 = frame2.imageAnalyzer()
        return analyzer1.differenceScoreByColorGrid(analyzer2)
    }
}


class NMInterestingTimeAnalysisOperation: NMOperation {
    let videoProcessor: NMVideoProcessor
    let asset: AVAsset
    let time1: CMTime
    let time2: CMTime
    
    init(fromAsset asset: AVAsset, time1: CMTime, time2: CMTime, videoProcessor: NMVideoProcessor) {
        self.videoProcessor = videoProcessor
        self.asset = asset
        self.time1 = time1
        self.time2 = time2
    }
    
    override func main() {
        if self.isCancelled {
            return
        }
        
        do {
            let frame1 = try NMVideoFrame(asset: asset, time: time1)
            
            if self.isCancelled {
                return
            }
            
            let frame2 = try NMVideoFrame(asset: asset, time: time2)
            
            if self.isCancelled {
                return
            }
            
            let diff = frame1.differenceScore(frame2)
            
            if self.isCancelled {
                return
            }
            
            self.videoProcessor.interestingTimes.append(NMInterestingTimeRange(start: frame1.time!.value, duration: frame2.time!.value - frame1.time!.value, score: diff))
//            print("Analyzed Time: \(frame1.time!.seconds)s \t Score: \(diff)")
        } catch {
            print("Error processing \(self.name)")
            self.failed = true
        }
    }
}


class NMVideoProcessorOperations {
    var allOperations = [Operation]()
    
    lazy var interestingTimeAnalysisQueue: NMOperationQueue = {
        let queue = NMOperationQueue()
        queue.name = "interesting time analysis queue"
        queue.qualityOfService = QualityOfService.utility
        queue.addOperationCallback = { (op: Operation) -> Void in
            self.allOperations.append(op)
        }
        return queue
        }()
    
    func progress() -> Double {
        let operationsComplete = self.interestingTimeAnalysisQueue.operationsComplete.count
        let operationsInProgress = self.interestingTimeAnalysisQueue.operations.count
        let operationsTotal = operationsInProgress + operationsComplete
        if operationsTotal == 0 {
            return 1
        }
        return Double(operationsComplete) / Double(operationsTotal)
    }
    
    func cancelAllOperations() {
        self.interestingTimeAnalysisQueue.cancelAllOperations()
    }
}


class NMVideoProcessor: NSObject {
    
    init (forFiles fileURLs:[URL]) {
        super.init()
        
        self.fileURLs = fileURLs
        for url in self.fileURLs {
            self.assets.append(AVAsset(url: url))
        }
        if (self.assets.count > 0) {
            self.primaryAsset = self.assets[0]
        }
        
        self.reset()
        
        // Creates main video track for composition
        self.compositionTrackVideo = self.composition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: 0)
    }
    
    var completionHandler: ((Void) -> Void)?
    
    var operations = NMVideoProcessorOperations()
    
    var fileURLs = [URL]()
    var assets = [AVAsset]()
    var primaryAsset:AVAsset?
    var previewTime = kCMTimeZero
    
    var interestingTimes = [NMInterestingTimeRange]()
    
    var composition: AVMutableComposition = AVMutableComposition()
    var compositionTrackVideo:AVMutableCompositionTrack? = nil
    var currentCompositionTime: CMTime = kCMTimeZero
    
    func beginProcessing() {
        self.operations.interestingTimeAnalysisQueue.onFinalOperationCompleted = {
            print("sorting and inserting")
            DispatchQueue.main.async(execute: { () -> Void in
                self.sortInterestingTimes()
                self.insertFootageFromInterestingTimes()
                self.completionHandler?()
            })
            self.operations.interestingTimeAnalysisQueue.onFinalOperationCompleted = nil
        }
        
        DispatchQueue.main.async { () -> Void in
            self.analyzeInterestingTimes()
        }
    }
    
    func reset() {
        self.operations.cancelAllOperations()
        
        self.composition = AVMutableComposition()
        self.compositionTrackVideo = nil
        self.currentCompositionTime = kCMTimeZero
    }
    

    
    // Finds "interesting" times in all asset video tracks.
    fileprivate func analyzeInterestingTimes() {
        print("finding interesting times")

        if let asset = self.primaryAsset {
            let assetDuration = Int64(asset.duration.seconds * Double(VIDEO_TIME_SCALE))
            for var t: Int64 = 0; t < assetDuration; t += COMPARE_DISTANCE {
                let time1 = CMTimeMake(t, VIDEO_TIME_SCALE)
                let time2 = CMTimeMake(t + COMPARE_DISTANCE, VIDEO_TIME_SCALE)
                let op = NMInterestingTimeAnalysisOperation(fromAsset: asset, time1: time1, time2: time2, videoProcessor: self)
                op.name = "interesting time analysis for times \(time1.seconds)s and \(time2.seconds)s"
                self.operations.interestingTimeAnalysisQueue.addOperation(op)
            }
        }
    }
    
    fileprivate func sortInterestingTimes() {
        print("sorting interesting times")
        
//        self.interestingTimes.sortInPlace({ $0.score > $1.score })
        self.interestingTimes.sort(by: { $0.timeRange.start.seconds < $1.timeRange.start.seconds })
    }
    
    fileprivate func insertFootageFromInterestingTimes() {
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
                try self.compositionTrackVideo!.insertTimeRange(time.timeRange, of: self.primaryAsset!.tracks(withMediaType: AVMediaTypeVideo)[0], at: self.currentCompositionTime)
                self.currentCompositionTime = CMTimeAdd(self.currentCompositionTime, time.timeRange.duration)
            } catch {
                print("Error inserting footage")
            }
        }
    }
    
//    func getPreviewFrame(completionHandler: (CGImage)->Void) {
//        let imageGenerator = AVAssetImageGenerator(asset: self.composition)
//        
//        var actualTime = kCMTimeZero
//        do {
//            let image = try imageGenerator.copyCGImageAtTime(self.previewTime, actualTime: &actualTime)
//            completionHandler(image)
//            self.previewTime = CMTimeAdd(self.previewTime, CMTimeMake(1, 1))
//        } catch {
//            print("Error generating preview image")
//        }
//    }
}
