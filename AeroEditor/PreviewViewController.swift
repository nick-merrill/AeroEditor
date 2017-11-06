//
//  PreviewViewController.swift
//  AeroEditor
//
//  Created by Nick Merrill on 8/7/15.
//  Copyright © 2015 Nick Merrill. All rights reserved.
//

import Cocoa
import AVKit
import AVFoundation

class PreviewViewController: NSViewController, CPTBarPlotDataSource, CPTBarPlotDelegate, CPTPlotSpaceDelegate {

    @IBOutlet weak var playerView: AVPlayerView!
    
    // Graph
    @IBOutlet weak var graphHostingView: CPTGraphHostingView!
    lazy var graph: CPTGraph = self.configureGraph()
    lazy var barPlot: CPTBarPlot = self.configurePlot()
    
    var videoProcessor: NMVideoProcessor? {
        didSet {
            if let processor = videoProcessor {
                loadAsset(processor.composition)
            }
            reloadGraph()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        graph.backgroundColor = CPTColor.black().cgColor
        barPlot.backgroundColor = CPTColor.green().cgColor
    }
    
    func loadAsset(_ asset: AVAsset) {
        let playerItem = AVPlayerItem(asset: asset)
        playerView.player = AVPlayer(playerItem: playerItem)
    }
    
    func reset() {
        self.playerView.player = nil
    }
    
    func reloadGraph() {
        graph.reloadData()
        graph.defaultPlotSpace?.scale(toFit: graph.allPlots())
    }
    
    func configureGraph() -> CPTGraph {
        let graph = CPTXYGraph(frame: graphHostingView.bounds, xScaleType: CPTScaleType.dateTime, yScaleType: CPTScaleType.linear)
        graph.plotAreaFrame?.masksToBorder = false
        graphHostingView.hostedGraph = graph
//        graph.applyTheme(CPTTheme(named: kCPTPlainBlackTheme))
        
        let plotSpace = graph.defaultPlotSpace as! CPTXYPlotSpace
        plotSpace.xRange = CPTPlotRange(locationDecimal: CPTDecimalFromFloat(0), lengthDecimal: CPTDecimalFromFloat(1))
        plotSpace.yRange = CPTPlotRange(locationDecimal: CPTDecimalFromFloat(0), lengthDecimal: CPTDecimalFromFloat(0.2))
        plotSpace.delegate = self
//        plotSpace.setScaleType(CPTScaleType.Category, forCoordinate: CPTCoordinate.X)
//        graph.addPlotSpace(plotSpace)
        
        graph.paddingBottom = 0
        graph.paddingTop = 0
        graph.paddingLeft = 0
        graph.paddingRight = 0
        
        return graph
    }
    
    func configurePlot() -> CPTBarPlot {
        let barPlot = CPTBarPlot(frame: self.graph.bounds)
        barPlot.dataSource = self
        barPlot.delegate = self as! CALayerDelegate
        barPlot.barsAreHorizontal = false
        
        let barLineStyle = CPTMutableLineStyle()
        barLineStyle.lineColor = CPTColor.lightGray()
        barLineStyle.lineWidth = 0
        
        barPlot.barWidth = 1
        barPlot.barOffset = 0
        barPlot.lineStyle = barLineStyle
        
        graph.add(barPlot, to: graph.defaultPlotSpace)
        return barPlot
    }
    
    func numberOfRecords(for plot: CPTPlot) -> UInt {
        if let processor = videoProcessor {
            return UInt(processor.interestingTimes.count)
        }
        return 0
    }
    
    func number(for plot: CPTPlot, field fieldEnum: UInt, record idx: UInt) -> AnyObject? {
        if Int(fieldEnum) == CPTBarPlotField.barTip.rawValue {
            return videoProcessor?.interestingTimes[Int(idx)].score as AnyObject
        }
        return NSDecimalNumber(value: idx as UInt)
    }
    
    func barFill(for barPlot: CPTBarPlot, record idx: UInt) -> CPTFill? {
        return CPTFill(color: CPTColor.red())
    }
    
//    func dataLabelForPlot(plot: CPTPlot, recordIndex idx: UInt) -> CPTLayer? {
//        let t: NMInterestingTimeRange = self.videoProcessor!.interestingTimes[Int(idx)]
////        let scoreStr = String(format: "%.2f", t.score)
//        return CPTTextLayer(text: "\(t.timeRange.start.seconds)")
//    }
    
    func barPlot(_ plot: CPTBarPlot, barWasSelectedAtRecord idx: UInt) {
        print("Selected \(idx)")
        if let processor = videoProcessor {
            let start: CMTime = processor.interestingTimes[Int(idx)].timeRange.start
            playerView.player?.seek(to: start)
            playerView.player?.play()
        }
    }
    
    // Don't allow vertical scrolling
    func plotSpace(_ space: CPTPlotSpace, willDisplaceBy proposedDisplacementVector: CGPoint) -> CGPoint {
        return CGPoint(x: proposedDisplacementVector.x, y: 0)
    }
}
