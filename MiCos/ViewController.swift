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



class ViewController: UIViewController, ChartViewDelegate, UITableViewDelegate, UITableViewDataSource, UITabBarDelegate {
    

    @IBOutlet weak var pieChartView: PieChartView!
   
    @IBOutlet weak var legacyName: SpringLabel!
   
    //@IBOutlet weak var animatedLogo: SpringImageView!
    @IBOutlet weak var bigArcs: SpringLabel!
    
    @IBOutlet weak var arcScore: SpringLabel!

    @IBOutlet weak var arcPlace: SpringLabel!
    
    @IBOutlet weak var feedTable: UITableView!
    
    @IBOutlet weak var awardArcsButton: UIBarButtonItem!
    
    @IBOutlet weak var topSpace: NSLayoutConstraint!
    
    @IBOutlet weak var spinny: UIActivityIndicatorView!

    @IBOutlet weak var tabBar: UITabBar!
    
    @IBOutlet weak var pieChartAspect: NSLayoutConstraint!
    
    @IBOutlet weak var tableguideLabel: UILabel!
 
    //let progressIndicatorView = CircularLoaderView(frame: CGRectZero)
    
    var refreshControl:UIRefreshControl?
    
    var oneTimePass = false
    // allows the app time to save the fact that a user has just completed their daily gratitude
    
    var currentTable: String = "Awards" {
        didSet {
            refresh()
        }
    }
    
    var legacyDivisors: [Int] = []
    var legacyEmojis: [String] = []
    var legacyNames: [String] = []
    var legacyArcsTotal: Double = 0
    var legacyArcs: [Double] = [] {
        didSet {
            //gets total arc amount each time legacy arcs is updated
            if legacyArcs.count > 0 {
                self.spinny.stopAnimating()
                self.tableguideLabel.hidden = false
                legacyArcsTotal = 0
                for amount in legacyArcs {
                    legacyArcsTotal += amount
                }
            }
        }
    }
    var legacyScores: [Float] = []
    
    //var feed: [[String]] = []
    var notifications: [AnyObject] = [] {
        didSet {
            //self.feedTable.reloadData()
            
                let range = NSMakeRange(0, self.feedTable.numberOfSections)
                let sections = NSIndexSet(indexesInRange: range)
                self.feedTable.reloadSections(sections, withRowAnimation: .Middle)
                self.refreshControl?.endRefreshing()
            
        }
    }
    
    let colorSet =
    [   UIColor.brownColor(),
        UIColor(red: 0.102, green: 0.7373, blue: 0.6118, alpha: 1.0), //1
        UIColor(red: 0.0863, green: 0.6275, blue: 0.5216, alpha: 1.0),
        UIColor(red: 0.1804, green: 0.8, blue: 0.4431, alpha: 1.0),
        UIColor(red: 0.1529, green: 0.6824, blue: 0.3765, alpha: 1.0),
        
        UIColor(red: 0.1608, green: 0.702, blue: 0.7255, alpha: 1.0),
        UIColor(red: 0.2039, green: 0.5961, blue: 0.8588, alpha: 1.0),
        UIColor(red: 0.1, green: 0.2784, blue: 0.7784, alpha: 1.0),
        UIColor(red: 0.2324, green: 0.1, blue: 0.798, alpha: 1.0),
        UIColor(red: 0.5824, green: 0.1, blue: 0.898, alpha: 1.0),
        
        UIColor(red: 0.6078, green: 0.349, blue: 0.7137, alpha: 1.0),
        UIColor(red: 0.5569, green: 0.2667, blue: 0.6784, alpha: 1.0),
        UIColor(red: 0.2039, green: 0.2863, blue: 0.3686, alpha: 1.0),
        UIColor(red: 0.1725, green: 0.2431, blue: 0.3137, alpha: 1.0),
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
        queryNotifications(newName)
        
      
        
    }
    func chartValueNothingSelected(chartView: ChartViewBase) {
        queryNotifications("none")
        self.updateMiddle("none", score: 0)
       
        
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
        
        pieChartView.noDataTextDescription = " "
        pieChartView.noDataText = " "
        pieChartView.data = chartData
       // pieChartView.backgroundColor = UIColor.clearColor()
        pieChartView.descriptionText = ""
       // pieChartView.animate(xAxisDuration: 5.0, yAxisDuration: 4.0)
        
        pieChartView.holeRadiusPercent = 0.70

        pieChartView.descriptionTextColor = UIColor.blackColor()
       // pieChartView.legend.textColor = UIColor.blackColor()
        pieChartView.legend.enabled = false
      //  pieChartView.holeColor = UIColor.whiteColor()
      //  pieChartView.holeColor = UIColor.clearColor()
        pieChartView.transparentCircleRadiusPercent = 0.75
        pieChartView.dragDecelerationFrictionCoef = 0
        
        //self.pieChartView.layoutIfNeeded()
 
        
        //pieChartView.drawSliceTextEnabled = false
      
        
    
    }
  
    
    func setSpring() {
//        self.animatedLogo.animation = "zoomIn"
//        self.animatedLogo.curve = "easeIn"
//        self.animatedLogo.force = 2.5
//        self.animatedLogo.duration = 4
//        self.animatedLogo.rotate = 180
        
        self.legacyName.animation = "fadeIn"
        self.legacyName.curve = "linear"
        self.legacyName.duration = 0.3
        
        self.arcScore.animation = "fadeIn"
        self.arcScore.curve = "linear"
        self.arcScore.duration = 0.3
        
        self.arcPlace.animation = "fadeIn"
        self.arcPlace.curve = "linear"
        self.arcPlace.duration = 0.3
        
        self.bigArcs.animation = "fadeIn"
        self.bigArcs.curve = "linear"
        self.bigArcs.duration = 0.3
       
        
        
    }
    func updateMiddle(name: String, score: Float) {
        // puting in a name of "none" and a score of 0 will make this default
        self.pieChartView.bringSubviewToFront(arcScore)
        self.pieChartView.bringSubviewToFront(legacyName)
        self.arcScore.hidden = false
        self.legacyName.hidden = false
        
        self.setSpring()
        
        let legacyIndex = self.legacyNames.indexOf(name) ?? 0
        let legacyScore = self.legacyScores[legacyIndex]
        let legacyArc = self.legacyArcs[legacyIndex]
        let legacyDivisor = self.legacyDivisors[legacyIndex]
        
        //list of the rankings to 25
        let rankList = ["1st", "2nd", "3rd", "4th", "5th", "6th", "7th", "8th", "9th", "10th", "11th", "12th", "13th", "14th", "15th", "16th", "17th", "18th", "19th", "20th", "21st", "22nd", "23rd", "24th", "25th"]
        let sortedScores = self.legacyScores.sort()
        
        self.bigArcs.animateTo()
        self.arcPlace.animateTo()
        self.legacyName.animateTo()
        self.arcScore.animateToNext { () -> () in
            if name == "none" && score == 0 {
                self.arcScore.text = (String(format: "%.1f", self.legacyArcsTotal)) + " Shared Arcs"
                let currentHighScore = self.legacyScores.maxElement()
                let nameIndex = self.legacyScores.indexOf(currentHighScore!)
                let currentHighName = self.legacyNames[nameIndex!]
                self.bigArcs.text = ""
                self.legacyName.text = currentHighName
                self.arcPlace.text = "Current Leader:"
            } else {
                let rankIndex = sortedScores.indexOf(score)
                let place = rankList[sortedScores.count - rankIndex! - 1] + " Place"
                let first = String(format: "%.1f", legacyArc)
                let second = String(legacyDivisor)
                let third = String(format: "%.1f", legacyScore)
                self.arcPlace.text = place
                self.arcScore.text = first + " Arcs / " + second + " Members"
                self.legacyName.text = name
                self.bigArcs.text = third
            }
            self.legacyName.animate()
            self.arcScore.animate()
            self.arcPlace.animate()
            self.bigArcs.animate()
            
        }
    
        
            

        
    }
    
    func refresh() {
        if currentTable == "Awards" {
            //hides the label so it doesnt pop up til the rest does
            self.tableguideLabel.hidden = true
            self.pieChartView.bringSubviewToFront(spinny)
            self.spinny.hidden = false
            self.spinny.startAnimating()
           // self.feedTable.userInteractionEnabled = false
            self.arcScore.hidden = true
            self.legacyName.hidden = true
          //  self.animatedLogo.image = UIImage(named: "logo")
            self.setSpring()
           // self.animatedLogo.animate()
            
            queryLegacies()
            queryNotifications("none")
        }
        if currentTable == "Gratitudes" {
            queryNotifications("gratitudes")
        }
    

    }
    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        if item == self.tabBar.items![0] {
           self.feedTable.tableHeaderView!.frame.size.height = view.frame.size.width
//            header.setNeedsLayout()
//            header.layoutIfNeeded()
//            let height = header.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
//            header.frame.size.height = height
//            feedTable.tableHeaderView = header
//            self.arcPlace.layoutIfNeeded()
//            self.arcScore.layoutIfNeeded()
//            self.legacyName.layoutIfNeeded()
            self.currentTable = "Awards"
            self.pieChartView.userInteractionEnabled = true
    
            
           
        }
        if item == self.tabBar.items![1] {
           self.feedTable.tableHeaderView!.frame.size.height = 0
            self.currentTable = "Gratitudes"
            self.pieChartView.userInteractionEnabled = false
          
            
            
            
        
        }
    }
    override func viewDidAppear(animated: Bool) {
        PFUser.currentUser()!.fetchInBackgroundWithBlock { (user: PFObject?, error) -> Void in
            if error == nil {
                
                if self.oneTimePass == false {
                    if let currentUser = user {
                        
                        if let sent = currentUser["DailyGratitude"] as? Bool { // if daily grat var exists
                            if let role = currentUser["Role"] as? String {
                                if role != "A" && role != "B" && role != "C" && role != "D" {
                                    if sent == false {
                                        self.performSegueWithIdentifier("gratitudeSegue", sender: self)
                                    }
                                }
                            }
                            
                        } else { // if the daily gratititude variable does not exist, check the role
                            if let role = currentUser["Role"] as? String {
                                if role != "A" && role != "B" && role != "C" && role != "D" {
                                    self.performSegueWithIdentifier("gratitudeSegue", sender: self)
                                    
                                }
                            }
                        }
                    }
                }
                self.oneTimePass = false
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        feedTable.delegate = self
        feedTable.dataSource = self
        tabBar.delegate = self
        self.feedTable.estimatedRowHeight = 150.0
        self.feedTable.rowHeight = UITableViewAutomaticDimension
        
        
            
        //fading + button if student
        if let role = PFUser.currentUser()?["Role"] {
            if role as? String == "F" {
                self.awardArcsButton.enabled = false
                self.awardArcsButton.
            }
        }
        else {
            self.awardArcsButton.enabled = false
        }
        //setting up a refresh control
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        self.feedTable.addSubview(refreshControl!)
        
        // set's up the table header view making sure it is as wide as the screen 
        self.feedTable.tableHeaderView = self.pieChartView
        self.feedTable.tableHeaderView!.frame.size.height = view.frame.size.width
      
        
        tabBar.selectedItem = tabBar.items![0]
        self.refresh()
      
        
//        var screen = UIScreen.mainScreen().bounds
//        var screenWidth = screen.size.width
//        var screenHeight = screen.size.height
      
       
        

        //pieChartView.addSubview(self.progressIndicatorView)
       
       // progressIndicatorView.frame = pieChartView.bounds
        //progressIndicatorView.autoresizingMask = [UIViewAutoresizing.FlexibleHeight, UIViewAutoresizing.FlexibleWidth]
        //self.progressIndicatorView.progress = CGFloat(0.5)/CGFloat(1.0)
        
        
    
    }
    func queryLegacies() {
        //clears legacy info first
        var Names: [String] = []
        var Emojis: [String] = []
        var Arcs: [Double] = []
        var Scores: [Float] = []
        var Divisors: [Int] = []
        
        self.legacyArcsTotal = 0
        let legacyQuery = PFQuery(className: "Legacies")
        legacyQuery.orderByDescending("Name")
        legacyQuery.findObjectsInBackgroundWithBlock{ (objects: [AnyObject]?, error) -> Void in
            if error == nil {
                if let legacies = objects {
                    for legacy in legacies {
                        Emojis.append(legacy["Emoji"] as! String)
                        Arcs.append(legacy["TotalArcs"] as! Double)
                        Names.append(legacy["Name"] as! String)
                        Scores.append((legacy["TotalArcs"] as! Float) / Float(legacy["Divisor"] as? Int ?? 1))
                        Divisors.append(legacy["Divisor"] as? Int ?? 1)
                      
                    }
                    self.legacyArcs = Arcs
                    self.legacyEmojis = Emojis
                    self.legacyNames = Names
                    self.legacyScores = Scores
                    self.legacyDivisors = Divisors
                    
                    
                   
                    
                    
                   // self.progressIndicatorView.progress = CGFloat(1.0)/CGFloat(1.0)
                    
                    //converts the legacy scores (which are floats) to doubles
                    let legacyScoresAsDoubles = self.legacyScores.map {Double($0)}
                    self.setChart(self.legacyEmojis, values: legacyScoresAsDoubles)
                    self.setSpring()
                    //self.progressIndicatorView.reveal()
                    //self.legacyName.text = ""
                    //self.view.bringSubviewToFront(self.legacyName)
                    
                       // self.pieChartView.holeColor = self.colorSet[5]
                        //self.pieChartView.layer.mask = nil
                   // return true
                       // self.pieChartView.b
                  //      self.animatedLogo.animateTo()
                        self.updateMiddle("none", score: 0)
                    
                        
                    
                    
                }
            }
        }
    }
    func queryNotifications(selectedLegacy: String) {
        let notificationQuery = PFQuery(className: "Notifications")
        notificationQuery.orderByDescending("createdAt")
        notificationQuery.limit = 50
        if selectedLegacy == "gratitudes" {
            notificationQuery.whereKey("Awardee", equalTo: PFUser.currentUser()!["Name"]!)
            notificationQuery.whereKey("Notify", equalTo: -1)
        }
        else if selectedLegacy == "none" {
            notificationQuery.whereKey("Notify", notEqualTo: -1)
            self.tableguideLabel.text = "All Awards"
        }
        else {
            notificationQuery.whereKey("Legacy", equalTo: selectedLegacy)
            notificationQuery.whereKey("Notify", notEqualTo: -1)
            self.tableguideLabel.text = "Awards for \(selectedLegacy)"
        }
        
        notificationQuery.whereKey("Sent", equalTo: true)
        notificationQuery.orderByDescending("createdAt")
        notificationQuery.findObjectsInBackgroundWithBlock { (objects: [AnyObject]?, error) -> Void in
            if error == nil {
                if let notifications = objects {
                    self.notifications = notifications
                    self.feedTable.layoutIfNeeded()
                    self.pieChartView.layoutIfNeeded()
                    
                }
            }
        }
    }
//    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//         if (indexPath.section == -1 && indexPath.row == 0) {
//            if self.currentTable == "Gratitudes" {
//                return 0
//            }
//        }
//        return 50
//    }


    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        if indexPath.row == 0 {
//            
//        }
//        else {
//            
//        }
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEE, MMM d"
        
        let cell = self.feedTable.dequeueReusableCellWithIdentifier("feedCell") as! FeedTableViewCell
            let notification = self.notifications[indexPath.row]
            let awardee = notification["Awardee"] as! String
            let awarder = notification["Awarder"] as! String
            let legacy = notification["Legacy"] as! String
            let message = notification["Message"] as! String
            let arcs = notification["Arcs"] as! Float
            let parseDate = notification.createdAt!! as NSDate
            let date = dateFormatter.stringFromDate(parseDate)
        
            let legacyIndex = self.legacyNames.indexOf(legacy)
            let emoji = self.legacyEmojis[legacyIndex!]
        
        let color = self.colorSet[legacyIndex!]
        if currentTable == "Awards" {
            cell.colorView.backgroundColor = color
            cell.titleLabel.text = "\(emoji) \(legacy): \(awardee)"
            cell.bodyLabel.text = message
            cell.arcLabel.text = (String(format: "%.0f", arcs))
            cell.awarderLabel.text = "-\(awarder) on \(date)"
            cell.arcTitleLabel.text = "Arcs"
        }
        if currentTable == "Gratitudes" {
            cell.bodyLabel.text = message
            cell.arcLabel.text = (String(format: "%.0f", arcs))
            cell.awarderLabel.text = "-\(date)"
            cell.titleLabel.text = "From \(awarder):"
            cell.colorView.backgroundColor = UIColor.clearColor()
            cell.arcTitleLabel.text = "Arc"
            
            
        }
        return cell
        
        
        
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.notifications.count
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
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeToViewController(segue:UIStoryboardSegue) {
    }
    
    @IBAction func cancelToViewController(segue:UIStoryboardSegue) {
    }
    
    @IBAction func doneToViewController(segue:UIStoryboardSegue) {
        self.oneTimePass = true
    }
    
    
    @IBAction func saveToViewController(segue:UIStoryboardSegue) {
        if let awardArcsViewController = segue.sourceViewController as? AwardArcsViewController {
           // if let award = awardArcsViewController.award {
                //save it here
          //  }
            // some good stuff for animating table views
//            let indexPath = NSIndexPath(forRow: players.count-1, inSection: 0)
//            tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            
            
        }
        
    }
    //Changing Status Bar
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        
        //LightContent
        return UIStatusBarStyle.LightContent
        
        //Default
        //return UIStatusBarStyle.Default
        
    }


}

