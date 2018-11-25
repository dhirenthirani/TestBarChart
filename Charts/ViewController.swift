//
//  ViewController.swift
//  Charts
//
//  Created by Dhiren Thirani on 24/11/18.
//  Copyright © 2018 Dhiren Thirani. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.navigationItem.title = "Bar Chart"
        
        let barchart = BarChart(frame: CGRect(x: 0, y: 100, width: self.view.frame.width, height: self.view.frame.size.height - 200))
        barchart.dataSource = self
        barchart.drawGraph()
        self.view.addSubview(barchart)
    }
}

extension ViewController: BarChartDataSource {
    func getXAxisDataForBarChart() -> NSMutableArray {
        let array: NSMutableArray = NSMutableArray()
        for i in 0...20 {
            array.add("\(2000 + i)")
        }
        return array
    }
    
    func numberOfBarsToBePlotted() -> Int {
        return 2
    }
    
    func colorForBarChart(for barNumber: Int) -> UIColor {
        return UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1.0)
    }
    
    func widthForBarChart(for barNumber: Int) -> Double {
        return 30
    }
    
    func nameForBarChart(for barNumber: Int) -> String {
        return "Data\(barNumber)"
    }
    
    func yValueForBarChart(for barNumber: Int) -> [Double] {
        var array = [Double]()
        for _ in 0...20 {
            array.append(Double(Int.random(in: 0..<200)))
        }
        return array
    }
}
