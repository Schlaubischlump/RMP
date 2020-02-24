//
//  ResultViewController.swift
//  RMP
//
//  Created by David Klopp on 02.01.20.
//  Copyright © 2020 David Klopp. All rights reserved.
//

import Foundation
import UIKit

class ResultViewController: UIViewController {
    @IBOutlet var chartView: RadarChartView!

    fileprivate var chartValues : [Int] = []
    fileprivate var chartLabels : [String] = []

    var chartData: [BasicNeed:Int] = [:] {
        didSet {
            chartLabels = []
            chartValues = []
            for need in BasicNeed.asArray {
                chartLabels.append(need.rawValue.localized())
                chartValues.append((chartData[need] ?? 0)+3)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let color = UIColor(red:0.282, green:0.541, blue:0.867, alpha:0.50)
        let backgroundColor = UIColor(red:0.851, green:0.851, blue:0.941, alpha:1.00)
        let xAxisColor = UIColor(red:0.396, green:0.769, blue:0.914, alpha:1.00)
        let yAxisColor = UIColor(red:0.596, green:0.863, blue:0.945, alpha:1.50)
        let fontColor = UIColor(red:0.259, green:0.365, blue:0.565, alpha:1.00)

        chartView.data = chartValues
        chartView.labelTexts = chartLabels
        chartView.numberOfVertexes = chartLabels.count
        chartView.numberTicks = 6
        chartView.style = RadarChartStyle(color: color,
                                          backgroundColor: backgroundColor,
                                          xAxis: RadarChartStyle.Axis(
                                            colors: [xAxisColor],
                                            widths: [0.5, 0.5, 2.0, 0.5, 0.5]),
                                          yAxis: RadarChartStyle.Axis(
                                            colors: [yAxisColor],
                                            widths: [0.5]),
                                          label: RadarChartStyle.Label(fontName: "Helvetica",
                                                                       fontColor: fontColor,
                                                                       fontSize: 11,
                                                                       lineSpacing: 0,
                                                                       letterSpacing: 0,
                                                                       margin: 10)
        )
        chartView.option = RadarChartOption(shouldPlot: true, animated: false, duration: 0)
    }

    override func viewDidLayoutSubviews() {
        chartView.prepareForDrawChart()
        chartView.setNeedsLayout()
    }
}
