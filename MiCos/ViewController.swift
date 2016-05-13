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
    
    @IBOutlet weak var gratitudesLabel: SpringLabel!
    
    @IBOutlet weak var feedTable: UITableView!
    
    @IBOutlet weak var topSpace: NSLayoutConstraint!
    
    @IBOutlet weak var spinny: UIActivityIndicatorView!

    @IBOutlet weak var tabBar: UITabBar!
    
    @IBOutlet weak var pieChartAspect: NSLayoutConstraint!
    
    @IBOutlet weak var tableguideLabel: UILabel!
 
    //let progressIndicatorView = CircularLoaderView(frame: CGRectZero)
    
    var refreshControl:UIRefreshControl?
    
    //keeps track of the last tab the user was on (gratitudes or leaderboard)
    var lastTab: Int = 0
    
    //keeps track of the last angle the graph was at
    var lastAngle: CGFloat = 1
    
    //holds the role of the user (admin or student)
    var userRole: String = "student"
    
    var currentTable: String = "Awards" {
        didSet {
            refresh()
        }
    }
    
    var legacyDivisors: [Int] = []
    var legacyEmojis: [String] = []
    var legacyNames: [String] = []
    var legacyGratitudesTotal: Int = 0
    var legacyGratitudes: [Int] = [] {
        didSet {
            legacyGratitudesTotal = 0
            for grat in legacyGratitudes {
                legacyGratitudesTotal += grat
            }
        }
    }
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
                //animates the feedtable cells
                self.feedTable.reloadSections(sections, withRowAnimation: .Automatic)
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
        
        let chartParams = ["Legacy": newName]
        Flurry.logEvent("Chart Tapped", withParameters: chartParams)
        
      
        
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
        //pieChartView.animate(xAxisDuration: 0.3, yAxisDuration: 0.3)
        
        pieChartView.holeRadiusPercent = 0.70

        pieChartView.descriptionTextColor = UIColor.blackColor()
       // pieChartView.legend.textColor = UIColor.blackColor()
        pieChartView.legend.enabled = false
      //  pieChartView.holeColor = UIColor.whiteColor()
      //  pieChartView.holeColor = UIColor.clearColor()
        pieChartView.transparentCircleRadiusPercent = 0.75
        //pieChartView.dragDecelerationFrictionCoef = 0.99
        //pieChartView.dragDecelerationEnabled = false
        pieChartView.rotationEnabled = false
        
        //self.pieChartView.layoutIfNeeded()
 
        
        //pieChartView.drawSliceTextEnabled = false
      
        
    
    }
  
    
    func setSpring() {
//        self.animatedLogo.animation = "zoomIn"
//        self.animatedLogo.curve = "easeIn"
//        self.animatedLogo.force = 2.5
//        self.animatedLogo.duration = 4
//        self.animatedLogo.rotate = 180
        
        self.legacyName.animation = "zoomIn"
        self.legacyName.curve = "linear"
        self.legacyName.duration = 0.3
        
        self.arcScore.animation = "zoomIn"
        self.arcScore.curve = "linear"
        self.arcScore.duration = 0.3
        
        self.arcPlace.animation = "zoomIn"
        self.arcPlace.curve = "linear"
        self.arcPlace.duration = 0.3
        
        self.bigArcs.animation = "zoomIn"
        self.bigArcs.curve = "linear"
        self.bigArcs.duration = 0.3
        
        self.gratitudesLabel.animation = "zoomIn"
        self.gratitudesLabel.curve = "linear"
        self.gratitudesLabel.duration = 0.3
       
        
        
    }
    func updateMiddle(name: String, score: Float) {
        // puting in a name of "none" and a score of 0 will make this default
        self.pieChartView.bringSubviewToFront(arcScore)
        self.pieChartView.bringSubviewToFront(legacyName)
        
        
        self.setSpring()
        
        let legacyIndex = self.legacyNames.indexOf(name) ?? 0
        let legacyScore = self.legacyScores[legacyIndex]
        let legacyArc = self.legacyArcs[legacyIndex]
        let legacyDivisor = self.legacyDivisors[legacyIndex]
        let legacyGratitude = self.legacyGratitudes[legacyIndex]
       
        
        //list of the rankings to 25
        let rankList = ["1st", "2nd", "3rd", "4th", "5th", "6th", "7th", "8th", "9th", "10th", "11th", "12th", "13th", "14th", "15th", "16th", "17th", "18th", "19th", "20th", "21st", "22nd", "23rd", "24th", "25th"]
        let sortedScores = self.legacyScores.sort()
        
        self.bigArcs.animateTo()
        self.arcPlace.animateTo()
        self.legacyName.animateTo()
        self.gratitudesLabel.animateTo()
        self.arcScore.animateToNext { () -> () in
            if name == "none" && score == 0 {
                self.arcScore.text = (String(format: "%.0f", self.legacyArcsTotal)) + " Global Arcs"
                let currentHighScore = self.legacyScores.maxElement()
                let nameIndex = self.legacyScores.indexOf(currentHighScore!)
                let currentHighName = self.legacyNames[nameIndex!]
                self.bigArcs.text = self.legacyEmojis[nameIndex!]
                self.legacyName.text = currentHighName
                self.arcPlace.text = "CURRENT LEADER:"
                self.gratitudesLabel.text = "\(String(self.legacyGratitudesTotal)) Global Gratitudes"
            } else {
                let rankIndex = sortedScores.indexOf(score)
                let place = rankList[sortedScores.count - rankIndex! - 1] + " Place"
                let first = String(format: "%.0f", legacyArc)
                let second = String(legacyDivisor)
                let third = String(format: "%.1f", legacyScore)
                self.arcPlace.text = place.uppercaseString
                self.arcScore.text = first + " Arcs / " + second + " Members"
                self.legacyName.text = name
                self.bigArcs.text = third
                self.gratitudesLabel.text = "\(String(legacyGratitude)) Gratitudes"
            }
            self.arcScore.hidden = false
            self.legacyName.hidden = false
            self.gratitudesLabel.hidden = false
            self.bigArcs.hidden = false
            self.arcPlace.hidden = false
            
            self.legacyName.animate()
            self.arcScore.animate()
            self.arcPlace.animate()
            self.bigArcs.animate()
            self.gratitudesLabel.animate()
            
        }
    
        
            

        
    }
    
    func refresh() {

        Flurry.logEvent("Refresh")
        
        
        //this spins the graph for funsies
        let randomNum = drand48()
        let newAngle: CGFloat = (360*CGFloat(randomNum))
        let easingOptions: [ChartEasingOption] = [.EaseInBack, .EaseInBounce,.EaseInCirc,.EaseInCubic,.EaseInElastic,.EaseInExpo,.EaseInOutBack,.EaseInOutBounce,.EaseInOutCirc,.EaseInOutCubic,.EaseInElastic,.EaseInExpo,.EaseInOutQuad,.EaseInOutQuart,.EaseInOutQuint,.EaseInOutSine,.EaseInQuad,.EaseInQuart,.EaseInQuint,.EaseInSine,.EaseOutBack,.EaseOutBounce,.EaseOutCirc,.EaseOutCubic,.EaseOutElastic,.EaseOutExpo,.EaseOutQuad,.EaseOutQuart,.EaseOutQuint,.EaseOutSine,.Linear]
        
        self.pieChartView.spin(duration: 0.6, fromAngle: lastAngle, toAngle: newAngle, easingOption: easingOptions[(Int((randomNum + 0.04)*31) - 1)])
        
        
        self.lastAngle = newAngle
        
        if currentTable == "Awards" {
            //hides the label so it doesnt pop up til the rest does
            self.tableguideLabel.hidden = true
            self.pieChartView.bringSubviewToFront(spinny)
            self.spinny.hidden = false
            self.spinny.startAnimating()
           // self.feedTable.userInteractionEnabled = false
            self.arcScore.hidden = true
            self.legacyName.hidden = true
            self.gratitudesLabel.hidden = true
            self.bigArcs.hidden = true
            self.arcPlace.hidden = true
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
            self.currentTable = "Awards"
            self.pieChartView.userInteractionEnabled = true
            self.lastTab = 0

        }
        if item == self.tabBar.items![2] {
            self.feedTable.tableHeaderView!.frame.size.height = 0
            self.currentTable = "Gratitudes"
            self.pieChartView.userInteractionEnabled = false
            self.lastTab = 2
        
        }
        if item == self.tabBar.items![1]{
            if let role = PFUser.currentUser()?["Role"] {
                if role as? String == "F" || role as? String == "E" {
                    Flurry.logEvent("Gratitude Segue")
                    self.performSegueWithIdentifier("gratitudeSegue", sender: self)
                } else {
                    Flurry.logEvent("Award Segue")
                    self.performSegueWithIdentifier("awardSegue", sender: self)
                }
            }
        }
    }
    // Callback when application enters the foreground
    func applicationDidBecomeActiveNotification() {
        self.checkGratitudeNote()
        self.checkGratitudePop()
        self.refresh()
    }
    override func viewDidAppear(animated: Bool) {
        self.checkGratitudeNote()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        feedTable.delegate = self
        feedTable.dataSource = self
        tabBar.delegate = self
        //navigationController?.delegate = self
        self.feedTable.estimatedRowHeight = 150.0
        self.feedTable.rowHeight = UITableViewAutomaticDimension
        
      //  self.navigationController!.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "ChronicleDisp-Bold", size: 20)!]
        
        //does something to the separators
        self.feedTable.separatorColor = UIColor.clearColor()
        
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        // Add observer:
        notificationCenter.addObserver(self, selector:#selector(ViewController.applicationDidBecomeActiveNotification), name:UIApplicationDidBecomeActiveNotification, object:nil)
        
        
     
        //changing award arcs button to award gratitudes if a student is the user
        //also sets the role variable to either admin or student
        if let role = PFUser.currentUser()?["Role"] {
            if role as? String == "F" || role as? String == "E" {
                self.tabBar.items![1].title = "Give Gratitude"
                //self.tabBar.items![2].enabled = true
                self.userRole = "student"
            } else {
                self.userRole = "admin"
                //self.tabBar.items![2].enabled = false
          }
        }

        self.checkGratitudePop()

        //setting up a refresh control
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        self.feedTable.addSubview(refreshControl!)
        
        // set's up the table header view making sure it is as wide as the screen 
        self.feedTable.tableHeaderView = self.pieChartView
        self.feedTable.tableHeaderView!.frame.size.height = view.frame.size.width
      
        
        tabBar.selectedItem = tabBar.items![0]
        self.refresh()
       
    }
    func checkGratitudeNote() {
        
        //only runs to check this if the user is a student
        if userRole == "student" {
            //gets today's date
            let date = NSDate()
            let calendar = NSCalendar.currentCalendar()
            let components = calendar.components([.Day], fromDate: date)
            let today = components.day
            
            
            //grabs the last date stored the last time a gratitude was sent and modifies the
            let query = PFQuery(className:"lastGratitude")
            query.whereKey("user", equalTo: PFUser.currentUser()!)
            query.getFirstObjectInBackgroundWithBlock { (object, error) in
                if error == nil && object != nil {
                    if today != (object!["sent"] as! Int) {
                        self.tabBar.items![1].badgeValue = "!"
                        self.tabBar.items![1].enabled = true
                        
                    } else {
                        self.tabBar.items![1].enabled = false
                        self.tabBar.items![1].badgeValue = "✓"
                    }
                } else {
                    //if it does not exist, this creates a new record of the last gratitude date (0 is never a date)
                    let newObject = PFObject(className: "lastGratitude")
                    newObject["sent"] = 0
                    newObject["user"] = PFUser.currentUser()!
                    newObject.saveInBackground()
                    self.tabBar.items![1].badgeValue = "!"
                    self.tabBar.items![1].enabled = true
                    
                    
                }
                
            }
        }
    }
    
    func checkGratitudePop() {
        
        //only checks for gratitudes if user is a student
        if userRole == "student" {
            //gets today's date
            let date = NSDate()
            let calendar = NSCalendar.currentCalendar()
            let components = calendar.components([.Day], fromDate: date)
            let today = components.day
            
            //grabs the last date stored the last time a gratitude was sent and pops up the sendgratitude view controller if it does not match today
            let query = PFQuery(className:"lastGratitude")
            query.whereKey("user", equalTo: PFUser.currentUser()!)
            query.getFirstObjectInBackgroundWithBlock { (object, error) in
                if error == nil && object != nil {
                    if today != (object!["sent"] as! Int) {
                        self.performSegueWithIdentifier("gratitudeSegue", sender: self)
                    }
                } else {
                    //if it does not exist, this creates a new record of the last gratitude date (0 is never a date)
                    let newObject = PFObject(className: "lastGratitude")
                    newObject["sent"] = 0
                    newObject["user"] = PFUser.currentUser()!
                    newObject.saveInBackground()
                    self.performSegueWithIdentifier("gratitudeSegue", sender: self)
                    
                }
                
            }
            
        }
    }
    
    func queryLegacies() {
        //clears legacy info first
        var Names: [String] = []
        var Emojis: [String] = []
        var Arcs: [Double] = []
        var Scores: [Float] = []
        var Divisors: [Int] = []
        var Gratitudes: [Int] = []
        
        self.legacyArcsTotal = 0
        let legacyQuery = PFQuery(className: "Legacies")
        legacyQuery.orderByDescending("Name")
    
        legacyQuery.findObjectsInBackgroundWithBlock{ (objects: [PFObject]?, error) -> Void in
            if error == nil {
                if let legacies = objects {
                    for legacy in legacies {
                        Emojis.append(legacy["Emoji"] as! String)
                        Arcs.append(legacy["TotalArcs"] as! Double)
                        Names.append(legacy["Name"] as! String)
                        Scores.append((legacy["TotalArcs"] as! Float) / Float(legacy["Divisor"] as? Int ?? 1))
                        Divisors.append(legacy["Divisor"] as? Int ?? 1)
                        Gratitudes.append(legacy["Gratitudes"] as? Int ?? 0)
                        
                    }
                    self.legacyArcs = Arcs
                    self.legacyEmojis = Emojis
                    self.legacyNames = Names
                    self.legacyScores = Scores
                    self.legacyDivisors = Divisors
                    self.legacyGratitudes = Gratitudes
                    
                    
                    
                   
                    
                    
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
        notificationQuery.limit = 100
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
        
        //notificationQuery.whereKey("Sent", equalTo: true)
        notificationQuery.orderByDescending("createdAt")
        notificationQuery.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error) -> Void in
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
            let awardee = notification.objectForKey("Awardee") as! String
            let awarder = notification.objectForKey("Awarder") as! String
            let legacy = notification.objectForKey("Legacy") as! String
            let message = notification.objectForKey("Message") as! String
            let arcs = notification.objectForKey("Arcs") as! Float
            let parseDate = notification.createdAt!! as NSDate
            let date = dateFormatter.stringFromDate(parseDate)
        
            let legacyIndex = self.legacyNames.indexOf(legacy)
            let emoji = self.legacyEmojis[legacyIndex!]
        
        let color = self.colorSet[legacyIndex!]
        if currentTable == "Awards" {
            cell.colorView.backgroundColor = color
            cell.titleLabel.text = ("\(legacy): \(awardee)")
            cell.bodyLabel.text = message
            cell.arcLabel.text = (String(format: "%.0f", arcs))
            cell.awarderLabel.text = "-\(awarder) on \(date)"
            cell.arcTitleLabel.text = "ARCS"
            cell.emojiLabel.text = emoji
        }
        if currentTable == "Gratitudes" {
            cell.bodyLabel.text = message
            cell.arcLabel.text = (String(format: "%.0f", arcs))
            cell.awarderLabel.text = "-\(date)"
            cell.titleLabel.text = "\(awarder):"
            cell.colorView.backgroundColor = UIColor.clearColor()
            cell.arcTitleLabel.text = "ARC"
            cell.emojiLabel.text = ""
            
            
        }
        return cell
        
        
        
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //if the table will be empty, we create a label that says why
        if self.notifications.count == 0 {
          
            let noDataLabel: UILabel = UILabel(frame: CGRectMake(0, 0, self.feedTable.bounds.size.width, self.feedTable.bounds.size.height))
            if currentTable == "Awards" {
            }
            if currentTable == "Gratitudes" {
                if userRole == "admin" {
                    noDataLabel.text = "💔\n" +
                    "Staff are not yet able to send or receive Gratitudes.\n" +
                    "Want to? Submit a suggestion in the Settings menu."
                } else {
                    noDataLabel.text = "💔\n" +
                    "No Gratitudes yet, try giving your own!"
                }
            }
 
            noDataLabel.textColor = UIColor.grayColor()
            noDataLabel.textAlignment = NSTextAlignment.Center
            noDataLabel.numberOfLines = 5
            noDataLabel.adjustsFontSizeToFitWidth = true
        
            
            self.feedTable.backgroundView = noDataLabel
        } else {
            self.feedTable.backgroundView = nil
        }
        
        return self.notifications.count
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //this is coming from the settings or the gratitude screen screen
    @IBAction func closeToViewController(segue:UIStoryboardSegue) {
        
        //logs that the "Later" button was pressed if the segue was from the gratitude view controller
        if let gratitudeTableViewController = segue.sourceViewController as? GratitudeTableViewController {
            
            Flurry.logEvent("Gratitude Later")
        }
        
        self.tabBar.selectedItem = self.tabBar.items![lastTab]
    }
    
    //this is coming from the award arcs screen
    @IBAction func cancelToViewController(segue:UIStoryboardSegue) {
        if let awardArcsViewController = segue.sourceViewController as? AwardArcsViewController{
            Flurry.logEvent("Award Cancel")
        }
        self.tabBar.selectedItem = self.tabBar.items![lastTab]
    }
    
    
    //This one is coming from the gratitude screen
    @IBAction func doneToViewController(segue:UIStoryboardSegue) {
        
        //gets the current day from the phone calendar
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Day], fromDate: date)
        let today = components.day
        
        //saves if the gratitude has been sent or not
        let query = PFQuery(className:"lastGratitude")
        query.getFirstObjectInBackgroundWithBlock { (object, error) in
            if error == nil && object != nil {
                object!["sent"] = today
                object!.saveInBackground()
            } else {
                print (error)
            }
        }
        
        //sets the tab bar to return to the last selected value
        self.tabBar.selectedItem = self.tabBar.items![lastTab]
        
        //sets the ability to award a gratitude to false and removes the badge
        self.tabBar.items![1].enabled = false
        self.tabBar.items![1].badgeValue = "✓"
            
        
        if let gratitudeTableViewController = segue.sourceViewController as? GratitudeTableViewController {
            let passedDone = gratitudeTableViewController.doneButton.enabled
            if passedDone == true {
                let passedText = gratitudeTableViewController.messageText.text
                let passedAwardee = gratitudeTableViewController.person
                
                let userQuery = PFUser.query()
                userQuery?.whereKey("Name", equalTo: passedAwardee!)
                
                userQuery?.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error) -> Void in
                    if error == nil {
                        if let users = objects {
                            for user in users {
                                let notification = PFObject(className: "Notifications")
                                notification["Legacy"] = user["Legacy"] ?? "Admin"
                                notification["Class"] = user["Class"] ?? 9999
                                notification["Message"] = passedText
                                notification["Arcs"] = 1
                                notification["toUser"] = user
                                notification["Awardee"] = user["Name"]
                                let currentUser = PFUser.currentUser()
                                notification["Awarder"] = currentUser?["Name"] as! String
                                notification["fromUser"] = currentUser
                                notification["Notify"] = -1
                                notification.saveInBackgroundWithBlock({ (Bool, error) in
                                    
                                    let gratitudeParams = ["Awardee": passedAwardee!, "Awarder": currentUser?["Name"] as! String, "Message Length": passedText.length]
                                    Flurry.logEvent("Gratitude", withParameters: gratitudeParams as [NSObject : AnyObject])
                                    
                                    //also increments points
                                    let pointsQuery = PFQuery(className: "Legacies")
                                    pointsQuery.whereKey("Name", equalTo: user["Legacy"] as! String)
                                    pointsQuery.limit = 1
                                    pointsQuery.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error) -> Void in
                                        if error == nil{
                                            if let legacies = objects {
                                                for legacy in legacies {
                                                    
                                                    legacy.incrementKey("TotalArcs", byAmount: 1)
                                                    legacy.incrementKey("Gratitudes", byAmount: 1)
                                                    
                                                    legacy.saveInBackgroundWithBlock({ (Bool, error) in
                                                        
                                                       
  
                                                        // creates the text of the notification
                                                        let note = "\(currentUser?["Name"] as! String) sent you a Gratitude 💌"
                                                        
                                                        //sets up variables to be used in sorting notifiations for class or legacy
                                                        let Class = user["Class"] ?? 9999
                                                        let legacy = user["Legacy"] ?? "Admin"
                                                        
                                                        //notify -1 = gratitude, notify 0 = all in class, notify 1 = all in legacy, notify 2 = everyone
                                                        
                                                        PFCloud.callFunctionInBackground("sendNotification", withParameters: ["note" : note, "notify": -1 , "Class": Class!, "legacy": legacy!, "toUser": user.objectId!])   {
                                                            
                                                            (response: AnyObject?, error: NSError?) -> Void in
                                                            if let error = error {
                                                                print (error)
                                                            }
                                                            if let response = response {
                                                                print (response)
                                                            }
                                                        }
                                                        
                                                    })
                                                    
                                                }
                                            }
                                        }
                                    })
                                })
                                
                            }
                        }
                    }
                })
                
            }
            
        }
        
    }
    
    // this one is coming from the award arcs screen
    @IBAction func saveToViewController(segue:UIStoryboardSegue) {
        if let awardArcsViewController = segue.sourceViewController as? AwardArcsViewController{
            //only activates if done button is enabled
            let passedDone = awardArcsViewController.doneButton.enabled
            if passedDone == true {
                
                //getting passed valuse from ArcAwardsViewController
                let passedText = awardArcsViewController.reasonText.text
                let passedArcs = Int(awardArcsViewController.arcLabel.text!)
                let passedNotify = awardArcsViewController.notifyControl.selectedSegmentIndex
                let passedAwardees = awardArcsViewController.awardees
                
                let userQuery = PFUser.query()
                userQuery?.whereKey("Name", containedIn: passedAwardees)
                
                userQuery?.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error) -> Void in
                    if error == nil {
                        if let users = objects {
                            for user in users {
                                let notification = PFObject(className: "Notifications")
                                notification["Legacy"] = user["Legacy"] ?? "Admin"
                                notification["Class"] = user["Class"] ?? 9999
                                notification["Message"] = passedText
                                notification["Arcs"] = passedArcs
                                notification["toUser"] = user
                                notification["Awardee"] = user["Name"]
                                let currentUser = PFUser.currentUser()
                                notification["Awarder"] = currentUser?["Name"] as! String
                                notification["fromUser"] = currentUser
                                notification["Notify"] = passedNotify
                                notification.saveInBackgroundWithBlock({ (Bool, error) in
                                    
                                    //logging flurry event
                                    let awardParams = ["Awardee": user["Name"], "Awarder": currentUser?["Name"] as! String, "Message Length": passedText.length]
                                    Flurry.logEvent("Award", withParameters: awardParams as [NSObject : AnyObject])
                                    
                                    //also increments points
                                    let pointsQuery = PFQuery(className: "Legacies")
                                    pointsQuery.whereKey("Name", equalTo: user["Legacy"] as! String)
                                    pointsQuery.limit = 1
                                    pointsQuery.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error) -> Void in
                                        if error == nil{
                                            if let legacies = objects {
                                                for legacy in legacies {
                                                    
                                                    legacy.incrementKey("TotalArcs", byAmount: passedArcs!)
                                                    
                                                    legacy.saveInBackgroundWithBlock({ (Bool, error) in
                                                        
                                                        //refreshes the view
                                                        self.refresh()
                                                        
                                                        //gets emoji from the looked up legacy
                                                        let emoji = String(legacy["Emoji"]!)
                                                        
                                                        // creates the text of the notification
                                                        let note = "\(emoji) \(passedArcs!) Arcs to \(user["Legacy"])'s \(user["Name"]): \(passedText) -\(currentUser!["Name"])"
                                                        
                                                        //sets up variables to be used in sorting notifiations for class or legacy
                                                        let Class = user["Class"] ?? 9999
                                                        let legacy = user["Legacy"] ?? "Admin"
                                                        
                                                        //notify -1 = gratitude, notify 0 = all in class, notify 1 = all in legacy, notify 2 = everyone
                              
                                                        PFCloud.callFunctionInBackground("sendNotification", withParameters: ["note" : note, "notify": passedNotify, "Class": Class!, "legacy": legacy!, "toUser": user.objectId!])   {
                                                            
                                                                (response: AnyObject?, error: NSError?) -> Void in
                                                            if let error = error {
                                                                print (error)
                                                            }
                                                            if let response = response {
                                                                print (response)
                                                            }
                                                    }
                                                    
                                                    })
                                                    
                                                }
                                            }
                                        }
                                    })
                                })
                                
                            }
                        }
                    }
                })
            }
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

