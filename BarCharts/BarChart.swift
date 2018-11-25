//
//  BarChart.swift
//  Charts
//
//  Created by Dhiren Thirani on 24/11/18.
//  Copyright © 2018 Dhiren Thirani. All rights reserved.
//

import UIKit

protocol BarChartDataSource: NSObjectProtocol {
    func getXAxisDataForBarChart() -> NSMutableArray
    func numberOfBarsToBePlotted() -> Int
    func colorForBarChart(for barNumber: Int) -> UIColor
    func widthForBarChart(for barNumber: Int) -> Double
    func nameForBarChart(for barNumber: Int) -> String
    func yValueForBarChart(for barNumber: Int) -> [Double]
}

private class BarChartDataRenderer: NSObject {
    var barColor: UIColor?
    var barWidth: Double?
    var yAxisData: [Double]?
    var name: String?
}

class BarChart: UIView {
    var dataSource: BarChartDataSource?
    
    private let FONT = UIFont.systemFont(ofSize: 12)
    private let FONT_SIZE: CGFloat = 12
    private let TEXT_COLOR = UIColor.black

    private let PADDING_20: Double = 20
    private let PADDING_10: Double = 10
    
    private var maxYValue: Double = 0.0
    private var minYValue: Double = 0.0
    
    private var stepX: Double = 0.0
    private var stepY: Double = 0.0
    
    private var xOffset: Double = 0.0
    
    private var xAxisArray: NSMutableArray = NSMutableArray()
    private var chartData: [BarChartDataRenderer] = [BarChartDataRenderer]()
    
    private var scrollView: CustomScrollView?
    private var graphView: UIView?
    
    private var touchedLayer: CAShapeLayer?
    private var dataShapeLayer: CAShapeLayer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getDataFromDataSource() {
        self.xAxisArray = self.dataSource?.getXAxisDataForBarChart() ?? NSMutableArray()
        
        var barWidth: Double = 0.0
        
        let numberOfBarToBePlotted = self.dataSource?.numberOfBarsToBePlotted() ?? 0
        for i in 0..<numberOfBarToBePlotted {
            let chart: BarChartDataRenderer = BarChartDataRenderer()
            chart.barColor = self.dataSource?.colorForBarChart(for: i)
            chart.barWidth = self.dataSource?.widthForBarChart(for: i)
            chart.yAxisData = self.dataSource?.yValueForBarChart(for: i)
            chart.name = self.dataSource?.nameForBarChart(for: i)
            
            barWidth += chart.barWidth ?? 0.0
            
            
            let min = chart.yAxisData?.min() ?? 0.0
            let max = chart.yAxisData?.max() ?? 0.0
            
            if max > maxYValue {
                maxYValue = max
            }
            
            if min < minYValue {
                minYValue = min
            }
            
            chartData.append(chart)
        }
        
        stepX = barWidth + PADDING_20
    }
    
    
    func drawGraph() {
        self.getDataFromDataSource()
        
        let width: Double = Double(self.frame.width)
        let height: Double = Double(self.frame.height)
        
        self.scrollView = CustomScrollView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        self.scrollView?.showsVerticalScrollIndicator = false
        self.scrollView?.showsHorizontalScrollIndicator = false
        self.scrollView?.isUserInteractionEnabled = true
        self.scrollView?.alwaysBounceVertical = false
        self.scrollView?.delegate = self
        
        let string = NSString(string: "\(round(maxYValue))")
        let maxTextSize = string.size(withAttributes: [NSAttributedString.Key.font : self.FONT])
        xOffset = Double(maxTextSize.width) + PADDING_20

        let graphWidth = (Double(self.xAxisArray.count) * stepX) + xOffset
        
        self.graphView = UIView(frame: CGRect(x: 0.0, y: PADDING_20, width: graphWidth, height: height - 3*PADDING_20))
        self.graphView?.isUserInteractionEnabled = true
        
        createXAxisLine()
        createYAxisLine()
        createBarGraph()
        
        
        self.graphView?.setNeedsDisplay()
        self.addSubview(self.graphView!)
        self.scrollView?.addSubview(self.graphView!)
        self.scrollView?.setNeedsDisplay()

        self.addSubview(self.scrollView!)

        self.scrollView?.contentSize = CGSize(width: graphWidth + width, height: Double(height))
        self.setNeedsDisplay()
    }
    
    private func createXAxisLine() {
        var i: Int = 0
        for value in self.xAxisArray {
            let x = (Double(i) * stepX) + xOffset
            
            let startPoint = CGPoint(x: x, y: 0)
            let endPoint = CGPoint(x: x, y: Double(self.graphView?.frame.height ?? 0))
            
            drawLineForGrid(startPoint: startPoint, endPoint: endPoint, text: "\(value)", textFrame: CGRect(x: x, y: Double(self.graphView?.frame.height ?? 0) + PADDING_10, width: stepX, height: 20))
            
            i = i + 1
        }
        
        if i == self.xAxisArray.count {
            let x = (Double(i) * stepX) + xOffset
            
            let startPoint = CGPoint(x: x, y: 0)
            let endPoint = CGPoint(x: x, y: Double(self.graphView?.frame.height ?? 0))

            drawLineForGrid(startPoint: startPoint, endPoint: endPoint, text: "", textFrame: CGRect.zero)
        }
    }
    
    private func createYAxisLine() {
        let grindCount: Int = 5
        
        let diff = maxYValue - minYValue
        
        self.stepY = Double(self.graphView?.frame.height ?? 0.0) / diff
        
        let step = diff/Double(grindCount)
        
        for i in 0...grindCount {
            let y = (Double(i) * step) * stepY
            let value = (Double(i) * step) + minYValue
            
            let x = xOffset
            let startPoint = CGPoint(x: x, y: Double(self.graphView?.frame.height ?? 0) - y)
            let endPoint = CGPoint(x: Double(self.graphView?.frame.width ?? 0), y: Double(self.graphView?.frame.height ?? 0) - y)
            
            drawLineForGrid(startPoint: startPoint, endPoint: endPoint, text: "\(round(value))", textFrame: CGRect(x: 0, y: Double(self.graphView?.frame.height ?? 0) - y - 10, width: xOffset, height: 20))
        }
    }
    
    private func createBarGraph(){
        var totalBarWidth: Double = PADDING_10
        for chart in chartData {
            let barWidth: Double = chart.barWidth ?? 0.0
            var i: Double = 0.0
            for value in chart.yAxisData! {
                let x: Double = (i * stepX) + xOffset
                let y: Double = value * stepY
                
                let startPoint = CGPoint(x: x + totalBarWidth + barWidth, y: Double(self.graphView?.frame.height ?? 0.0) - y)
                let endPoint = CGPoint(x: x + totalBarWidth, y: Double(self.graphView?.frame.height ?? 0.0))
                
                let layer = CAShapeLayer()
                layer.path = drawBarPath(startPoint: startPoint, endPoint: endPoint).cgPath
                layer.strokeColor = chart.barColor?.cgColor
                layer.fillColor = chart.barColor?.cgColor
                layer.fillRule = .evenOdd
                layer.opacity = 0.7
                layer.lineWidth = 0.5
                layer.shadowColor = UIColor.clear.cgColor
                layer.shadowRadius = 0
                layer.shadowOpacity = 0
                layer.setValue(value, forKey: "data")
                self.graphView?.layer.addSublayer(layer)
                
                i = i + 1.0
            }
            
            totalBarWidth = totalBarWidth + barWidth
        }
    }
    
    private func drawLineForGrid(startPoint: CGPoint, endPoint: CGPoint, text: String, textFrame: CGRect, shouldDraw: Bool = true) {
        if shouldDraw {
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = drawPath(startPoint: startPoint, endPoint: endPoint).cgPath
            shapeLayer.strokeColor = UIColor.black.cgColor
            shapeLayer.lineWidth = 1
            self.graphView?.layer.addSublayer(shapeLayer)
        }
        
        let textLayer = CATextLayer()
        textLayer.font = self.FONT as CFTypeRef
        textLayer.fontSize = self.FONT_SIZE
        textLayer.frame = textFrame
        textLayer.string = text
        textLayer.alignmentMode = .center
        textLayer.foregroundColor = self.TEXT_COLOR.cgColor
        textLayer.shouldRasterize = true
        textLayer.rasterizationScale = UIScreen.main.scale
        textLayer.contentsScale = UIScreen.main.scale
        self.graphView?.layer.addSublayer(textLayer)
    }
    
    private func drawPath(startPoint: CGPoint, endPoint: CGPoint) -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: startPoint)
        path.addLine(to: endPoint)
        path.close()
        path.stroke()
        
        return path
    }
    
    private func drawBarPath(startPoint: CGPoint, endPoint: CGPoint) -> UIBezierPath {
        let path = UIBezierPath(rect: CGRect(x: startPoint.x, y: startPoint.y, width: endPoint.x - startPoint.x, height: endPoint.y - startPoint.y))
        
        path.close()
        path.stroke()
        
        return path
    }
}

extension BarChart: UIScrollViewDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let point: CGPoint = touches.first?.location(in: self.graphView) ?? CGPoint.zero
        
        if self.graphView?.frame.contains(point) ?? false {
            let layers = self.graphView?.layer.hitTest(point)
            for layer in (layers?.sublayers)! {
                if layer.isMember(of: CAShapeLayer.self) {
                    let shapeLayer = (layer as! CAShapeLayer)
                    if shapeLayer.path?.contains(point) ?? false {
                        shapeLayer.opacity = 1
                        shapeLayer.shadowRadius = 10
                        shapeLayer.shadowColor = UIColor.black.cgColor
                        shapeLayer.shadowOpacity = 1
                        
                        touchedLayer = shapeLayer
                        
                        let data = touchedLayer?.value(forKey: "data") as? Double ?? 0.0
                    
                        self.showMarker(data: "\(round(data))")
                    }
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let layer = touchedLayer {
            layer.opacity = 0.7
            layer.shadowRadius = 0
            layer.shadowColor = UIColor.clear.cgColor
            layer.shadowOpacity = 0
        }
        dataShapeLayer?.removeFromSuperlayer()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let layer = touchedLayer {
            layer.opacity = 0.7
            layer.shadowRadius = 0
            layer.shadowColor = UIColor.clear.cgColor
            layer.shadowOpacity = 0
        }
        dataShapeLayer?.removeFromSuperlayer()
    }
    
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        if let layer = touchedLayer {
//            layer.opacity = 0.7
//            layer.shadowRadius = 0
//            layer.shadowColor = UIColor.clear.cgColor
//            layer.shadowOpacity = 0
//        }
//        dataShapeLayer?.removeFromSuperlayer()
//    }
//
    func showMarker(data: String) {
        let rect = touchedLayer?.path?.boundingBox
        
        let string = NSString(string: data)
        let size = string.size(withAttributes: [NSAttributedString.Key.font : self.FONT])
        
        let path = UIBezierPath(roundedRect: CGRect(x: Double(rect?.origin.x ?? 0), y: (Double(rect?.origin.y ?? 0) - Double(size.height)), width:Double(size.width) + 2*PADDING_10, height: Double(size.height)), cornerRadius: 3)
        path.close()
        path.stroke()
        
        dataShapeLayer = CAShapeLayer()
        dataShapeLayer?.path = path.cgPath
        dataShapeLayer?.strokeColor = UIColor.white.cgColor
        dataShapeLayer?.backgroundColor = UIColor.white.cgColor
        dataShapeLayer?.fillColor = UIColor.white.cgColor
        dataShapeLayer?.fillRule = .evenOdd
        dataShapeLayer?.lineWidth = 3
        dataShapeLayer?.shadowColor = UIColor.black.cgColor
        dataShapeLayer?.shadowRadius = 5
        dataShapeLayer?.shadowOpacity = 1
        
        let textLayer = CATextLayer()
        textLayer.font = self.FONT as CFTypeRef
        textLayer.fontSize = self.FONT_SIZE
        textLayer.frame = path.cgPath.boundingBox
        textLayer.string = data
        textLayer.alignmentMode = .center
        textLayer.backgroundColor = UIColor.clear.cgColor
        textLayer.foregroundColor = self.TEXT_COLOR.cgColor
        textLayer.shouldRasterize = true
        textLayer.rasterizationScale = UIScreen.main.scale
        textLayer.contentsScale = UIScreen.main.scale
        dataShapeLayer!.addSublayer(textLayer)
        
        self.graphView?.layer.addSublayer(dataShapeLayer!)
    }
}
