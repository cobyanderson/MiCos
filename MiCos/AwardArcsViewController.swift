//
//  AwardArcsViewController.swift
//  MiCos
//
//  Created by Samuel Coby Anderson on 2/27/16.
//  Copyright © 2016 Samuel Coby Anderson. All rights reserved.
//

import UIKit
import Parse


class AwardArcsViewController: UITableViewController, UITextViewDelegate{

    @IBOutlet weak var arcSlider: UISlider!
    
    @IBOutlet weak var awardeeLabel: UILabel!
    
    @IBOutlet weak var reasonText: UITextView!
    
    @IBOutlet weak var arcLabel: UILabel!
    
    @IBOutlet weak var notifyControl: UISegmentedControl!
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    @IBOutlet weak var textCountLabel: UILabel!
    

    
    var awardees: [String] = [] {
        didSet {
            var nameString = ""
            for awardee in awardees {
                nameString = nameString + "\(awardee)  "
            }
            awardeeLabel.text? = nameString
            if textLength > 20  {
                self.doneButton.enabled = true
            }
        }
    }
    var textLength: Int = 0 {
        didSet {
            self.textCountLabel.text = "\(String(textLength))/20"
            self.textCountLabel.textColor = UIColor.redColor()
            if textLength > 20  {
                self.textCountLabel.textColor = UIColor.greenColor()
                if awardees.count > 0 {
                    self.doneButton.enabled = true
                }
            } else {
                self.doneButton.enabled = false
                
            }
        }
    }
    func textViewDidChange(textView: UITextView) {
        self.textLength = textView.text.length
    }
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        reasonText.endEditing(true)
        if segue.identifier ==  "SaveAward" {
         
            
            let userQuery = PFUser.query()
            userQuery?.whereKey("Name", containedIn: awardees)
            
            userQuery?.findObjectsInBackgroundWithBlock({ (objects: [AnyObject]?, error) -> Void in
                if error == nil {
                    if let users = objects {
                        for user in users {
                            let notification = PFObject(className: "Notifications")
                            notification["Legacy"] = user["Legacy"]
                            notification["Message"] = self.reasonText.text
                            notification["Arcs"] = self.arcSlider.value
                            notification["toUser"] = user
                            notification["Awardee"] = user["Name"]
                            let currentUser = PFUser.currentUser()
                            notification["Awarder"] = currentUser?["Name"] as! String
                            notification["fromUser"] = currentUser
                            notification["Sent"] = false
                            notification["Notify"] = self.notifyControl.selectedSegmentIndex
                            notification.saveInBackground()
//                            let pointsQuery = PFQuery(className: "Legacies")
//                            pointsQuery.whereKey("Name", equalTo: user["Legacy"] as! String)
//                            pointsQuery.limit = 1
//                            pointsQuery.findObjectsInBackgroundWithBlock({ (objects: [AnyObject]?, error) -> Void in
//                                if error == nil{
//                                    if let points = objects {
//                                        for point in points {
//                                            point.incrementKey("TotalArcs", byAmount: self.arcSlider.value)
//                                            point.saveInBackground()
//                                        }
//                                    }
//                                }
//                            })
                            
                        }
                    }
                }
            })
        
        }
    }

    
    @IBAction func sliderValueChanged(sender: AnyObject) {
        arcLabel.text = (String(format: "%.0f", arcSlider.value))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.reasonText.delegate = self
        
        //triggers the did set method of text length
        self.textLength = 0
        
        // disables the done button
        self.doneButton.enabled = false
       
        // sets arc max and min give values for different people
        print (PFUser.currentUser()!)
        if let arcMax = PFUser.currentUser()!["MaxArcs"] {
            if let arcMin = PFUser.currentUser()!["MinArcs"] {
                self.arcSlider.maximumValue = arcMax as! Float
                self.arcSlider.minimumValue = arcMin as! Float
                arcLabel.text = String(Int(arcMin as! Float))
            }
        }
        if let role = PFUser.currentUser()!["Role"] as? String {
            if role == "E" {
                self.notifyControl.removeSegmentAtIndex(2 , animated: false)
            }
        }
    
        //sets the segment control's default
        self.notifyControl.selectedSegmentIndex = 1
        
        //makes sure back button does not have previous title
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
        
        
        //sets up a tap gesture to dismiss keyboard
        
        
        
        
        
        

    
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    @IBAction func unwindWithSelectedAwardees(segue: UIStoryboardSegue) {
        if let ChooseAwardeeViewController = segue.sourceViewController as?
            ChooseAwardeeViewController,
            passedUsers = ChooseAwardeeViewController.selectedAwardees{
            awardees = passedUsers
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        
        //LightContent
        return UIStatusBarStyle.LightContent
        
        //Default
        //return UIStatusBarStyle.Default
        
    }

}
