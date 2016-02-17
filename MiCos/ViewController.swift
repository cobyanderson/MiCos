//
//  ViewController.swift
//  MiCos
//
//  Created by Samuel Coby Anderson on 8/28/15.
//  Copyright (c) 2015 Samuel Coby Anderson. All rights reserved.
//

import UIKit
import Parse
import Charts

class ViewController: UIViewController {

    @IBOutlet weak var pieChartView: PieChartView!
    
    func setChart(dataPoints: [String], values: [Double]) {
        pieChartView.noDataText = "No Arcs have been awarded yet..."
        
        var dataEntries: [ChartDataEntry] = []
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(value: values[i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = PieChartDataSet(yVals: dataEntries, label: "Legacies")
        chartDataSet.colors = ChartColorTemplates.liberty()
        let chartData = PieChartData(xVals: dataPoints, dataSet: chartDataSet)
        pieChartView.data = chartData
        
        pieChartView.descriptionText = ""
        pieChartView.backgroundColor = UIColor.grayColor()
        pieChartView.animate(xAxisDuration: 4.0, yAxisDuration: 4.0)
        
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let legacies = ["Civic", "Eureka", "Liberty", "Field", "Mason", "Pier", "Gate", "Union", "Vista", "Reserve", "Hunter", "Pyramid", "Laurel", "Octagon", "Plaza", "Mission", "Ocean", "North", "Tower", "Cable", "Chronicle", "Circuit", "Legion", "Labyrinth", "Lands"]
        let arcs = [41.0, 44.0, 48.0, 51.0, 52.0, 53.0, 54.0, 59.0, 60.0, 61.0, 62.0, 64.0, 66.0, 70.0, 73.0, 79.0, 80.0, 81.0, 86.0, 92.0, 94.0, 95.0, 97.0, 98.0, 99.0]
        setChart(legacies, values: arcs)
        
      
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

