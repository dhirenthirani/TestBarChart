//
//  LegendView.swift
//  Charts
//
//  Created by Dhiren Thirani on 25/11/18.
//  Copyright © 2018 Dhiren Thirani. All rights reserved.
//

import UIKit

class LegendView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createLegend(charts: [BarChartDataRenderer]) {
        var y: CGFloat = 10
        for chart in charts {
            let view = UIView(frame: CGRect(x: 10, y: y, width: 30, height: 30))
            view.backgroundColor = chart.barColor
            self.addSubview(view)
            
            let label = UILabel(frame: CGRect(x: view.frame.origin.x + view.frame.size.width + 10, y: y, width: self.frame.width - 20, height: 30))
            label.text = chart.name
            self.addSubview(label)
            
            y = label.frame.origin.y + label.frame.size.height + 10
        }
    }
    
    static func getHeight(charts: [BarChartDataRenderer]) -> CGFloat {
        var y: CGFloat = 10
        y = y + CGFloat((charts.count * (30 + 10)))
        
        return y
    }
}
