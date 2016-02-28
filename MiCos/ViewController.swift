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

class ViewController: UIViewController, ChartViewDelegate, UITableViewDelegate {
    

    @IBOutlet weak var pieChartView: PieChartView!
   
    @IBOutlet weak var legacyName: SpringLabel!
   
    @IBOutlet weak var animatedLogo: SpringImageView!
    
    @IBOutlet weak var arcScore: SpringLabel!

    @IBOutlet weak var arcPlace: SpringLabel!
    
    @IBOutlet weak var feedTable: UITableView!
    
    let progressIndicatorView = CircularLoaderView(frame: CGRectZero)
    
    var legacyEmojis: [String] = []
    var legacyNames: [String] = []
    var legacyArcs: [Double] = []
    var legacyScores: [Float] = []
    
    let colorSet =
    [   UIColor.brownColor(),
        UIColor(red: 0.102, green: 0.7373, blue: 0.6118, alpha: 1.0), //1
        UIColor(red: 0.0863, green: 0.6275, blue: 0.5216, alpha: 1.0),
        UIColor(red: 0.1804, green: 0.8, blue: 0.4431, alpha: 1.0),
        UIColor(red: 0.1529, green: 0.6824, blue: 0.3765, alpha: 1.0),
        
        UIColor(red: 0.1608, green: 0.502, blue: 0.7255, alpha: 1.0),
        UIColor(red: 0.2039, green: 0.5961, blue: 0.8588, alpha: 1.0),
        UIColor(red: 0.6078, green: 0.349, blue: 0.7137, alpha: 1.0),
        UIColor(red: 0.5569, green: 0.2667, blue: 0.6784, alpha: 1.0),
        UIColor(red: 0.2039, green: 0.2863, blue: 0.3686, alpha: 1.0),
        
        UIColor(red: 0.1725, green: 0.2431, blue: 0.3137, alpha: 1.0),
        UIColor.darkGrayColor(),
        UIColor(red: 0.498, green: 0.549, blue: 0.5529, alpha: 1.0),
        UIColor(red: 0.5843, green: 0.6471, blue: 0.651, alpha: 1.0),
        UIColor(red: 0.7412, green: 0.7647, blue: 0.7804, alpha: 1.0),
        
        UIColor(red: 0.9255, green: 0.9412, blue: 0.9451, alpha: 1.0),
        UIColor(red: 0.9851, green: 0.9686, blue: 0.5588, alpha: 1.0),
        UIColor(red: 0.9851, green: 0.8686, blue: 0.1588, alpha: 1.0),
        UIColor(red: 0.9451, green: 0.7686, blue: 0.0588, alpha: 1.0),
        UIColor(red: 0.9529, green: 0.6118, blue: 0.0706, alpha: 1.0),
        
        UIColor(red: 0.902, green: 0.4941, blue: 0.1333, alpha: 1.0),
        UIColor(red: 0.9859, green: 0.298, blue: 0.2353, alpha: 1.0),
        UIColor(red: 0.9059, green: 0.298, blue: 0.2353, alpha: 1.0),
        UIColor(red: 0.7529, green: 0.2235, blue: 0.1686, alpha: 1.0) ,
        UIColor(red: 0.8275, green: 0.3294, blue: 0, alpha: 1.0),
        
    ]
 
    func chartValueSelected(chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: ChartHighlight) {
        let newName = self.legacyNames[entry.xIndex]
        let newScore = self.legacyScores[entry.xIndex]
        updateMiddle(newName, score: newScore)
        
    }
    func chartValueNothingSelected(chartView: ChartViewBase) {
        print ("meh")
    }
    func chartTranslated(chartView: ChartViewBase, dX: CGFloat, dY: CGFloat) {
        print ("pease")
    }

    
    func setChart(dataPoints: [String], values: [Double]) {
        
        pieChartView.delegate = self
        
        pieChartView.noDataText = "chart error"
        
        var dataEntries: [ChartDataEntry] = []
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(value: values[i], xIndex: i)
            dataEntries.append(dataEntry)
          
        }
        
        let chartDataSet = PieChartDataSet(yVals: dataEntries, label: "Legacies")
        chartDataSet.drawValuesEnabled = false
        chartDataSet.colors = self.colorSet
        
        let chartData = PieChartData(xVals: dataPoints, dataSet: chartDataSet)
        
        pieChartView.data = chartData
        pieChartView.backgroundColor = UIColor.clearColor()
        pieChartView.descriptionText = ""
        pieChartView.animate(xAxisDuration: 0.5, yAxisDuration: 4.0)
        
        pieChartView.holeRadiusPercent = 0.70

        pieChartView.descriptionTextColor = UIColor.blackColor()
       // pieChartView.legend.textColor = UIColor.blackColor()
        pieChartView.legend.enabled = false
      //  pieChartView.holeColor = UIColor.whiteColor()
        pieChartView.holeColor = UIColor.whiteColor()
        pieChartView.transparentCircleRadiusPercent = 0.75
        pieChartView.dragDecelerationFrictionCoef = 0

        //pieChartView.drawSliceTextEnabled = false
      
        
        
    }
  
    
    func setSpring() {
        self.animatedLogo.animation = "zoomIn"
        self.animatedLogo.curve = "easeIn"
        self.animatedLogo.force = 2.5
        self.animatedLogo.duration = 4
        self.animatedLogo.rotate = 0.5
        
        self.legacyName.animation = "fadeIn"
        self.legacyName.curve = "linear"
        self.legacyName.duration = 0.3
        
        self.arcScore.animation = "fadeIn"
        self.arcScore.curve = "linear"
        self.arcScore.duration = 0.3
        
        self.arcPlace.animation = "fadeIn"
        self.arcPlace.curve = "linear"
        self.arcPlace.duration = 0.3
        
        
    }
    func updateMiddle(name: String, score: Float) {
        self.pieChartView.bringSubviewToFront(arcScore)
        self.pieChartView.bringSubviewToFront(legacyName)
        self.arcScore.hidden = false
        self.legacyName.hidden = false
        
        self.setSpring()
        
        //find the ranking
        let sortedScores = self.legacyScores.sort()
        let rankIndex = sortedScores.indexOf(score)
        
        var place = ""
        if (sortedScores.count - rankIndex!)  == 1 {
            place = "1st Place"
        }
        else if (sortedScores.count - rankIndex!)  == 2 {
            place = "2nd Place"
        }
        else if (sortedScores.count - rankIndex!)  == 3 {
            place = "3rd Place"
        }
        else {
            place = String(sortedScores.count - rankIndex!) + "th Place"
        }
        
        
        self.arcPlace.animateTo()
        self.legacyName.animateTo()
        self.arcScore.animateToNext { () -> () in
            self.arcScore.text = String(score) + " Arcs"
            self.legacyName.text = name
            self.arcPlace.text = String(place)
            self.legacyName.animate()
            self.arcScore.animate()
            self.arcPlace.animate()
        }
    
        
            
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        feedTable.delegate = self
        
        
        self.arcScore.hidden = true
        self.legacyName.hidden = true
            
        self.animatedLogo.image = UIImage(named: "logo")
        
        pieChartView.addSubview(self.progressIndicatorView)
       
        progressIndicatorView.frame = pieChartView.bounds
        progressIndicatorView.autoresizingMask = [UIViewAutoresizing.FlexibleHeight, UIViewAutoresizing.FlexibleWidth]
        //self.progressIndicatorView.progress = CGFloat(0.5)/CGFloat(1.0)
        
        
        
        
        let legacyQuery = PFQuery(className: "Legacies")
        legacyQuery.orderByDescending("Name")
        legacyQuery.findObjectsInBackgroundWithBlock{ (objects: [AnyObject]?, error) -> Void in
            if error == nil {
                if let legacies = objects {
                    for legacy in legacies {
                        self.legacyEmojis.append(legacy["Emoji"] as! String)
                        self.legacyArcs.append(legacy["TotalArcs"] as! Double)
                        self.legacyNames.append(legacy["Name"] as! String)
                        self.legacyScores.append(legacy["TotalArcs"] as! Float)
                    }
                    let currentHighScore = self.legacyScores.maxElement()
                    let nameIndex = self.legacyScores.indexOf(currentHighScore!)
                    let currentHighName = self.legacyNames[nameIndex!]
                    
                    
                   // self.progressIndicatorView.progress = CGFloat(1.0)/CGFloat(1.0)
                    self.setChart(self.legacyEmojis, values: self.legacyArcs)
                    self.setSpring()
                    self.progressIndicatorView.reveal()
                    //self.legacyName.text = ""
                    //self.view.bringSubviewToFront(self.legacyName)
                    
                    self.animatedLogo.animateNext({ () -> () in
                       // self.pieChartView.holeColor = self.colorSet[5]
                        self.pieChartView.layer.mask = nil
                        self.animatedLogo.animateTo()
                        self.updateMiddle(currentHighName, score: currentHighScore!)
                    })
                }
            }
       
            
        }
    
//        let legacyEmojis = ["🏛", "💡", "🔔","⚾️","👁","🦀", "☀️", "❤️", "🌳","💰","🕯", "🔺","👑","🐙","🌐", "⛪", "🌊", "🕛", "🎨", "🚃", "📰", "⚡️", "🗡", "🏵", "⌛️"]
//        let legacyNames = ["Civic", "Eureka", "Liberty", "Field", "Mason", "Pier", "Gate", "Union", "Vista", "Reserve", "Hunter", "Pyramid", "Laurel", "Octagon", "Plaza", "Mission", "Ocean", "North", "Tower", "Cable", "Chronicle", "Circuit", "Legion", "Labyrinth", "Lands"]
//        let arcs = [61.3, 65.0, 41.0, 144.0, 86.4, 92.0,  97.0, 98.0, 99.0, 48.0, 51.9, 152.0, 53.0, 54.6, 59.0, 60.0,  64.6, 166.0, 70.0, 94.0, 95.2,73.0, 179.0, 80.5, 81.0]
        
        
//        for index in 0...(legacyEmojis.count - 1) {
//            var legacy = PFObject(className: "Legacies")
//            legacy["Name"] = legacyNames[index]
//            legacy["Emoji"] =  legacyEmojis[index]
//            legacy["TotalArcs"] = arcs[index]
//            legacy["Color"] = self.colorSet[index]
//            legacy.saveInBackgroundWithBlock({ (Bool, error) -> Void in
//            
//                print ("yay")
//            })
//        }

      
        
      
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func cancelToViewController(segue:UIStoryboardSegue) {
    }
    
    @IBAction func saveToViewController(segue:UIStoryboardSegue) {
        if let awardArcsViewController = segue.sourceViewController as? AwardArcsViewController {
            if let award = awardArcsViewController.award {
                //save it here
            }
            // some good stuff for animating table views
//            let indexPath = NSIndexPath(forRow: players.count-1, inSection: 0)
//            tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            
            
        }
        
    }


}

