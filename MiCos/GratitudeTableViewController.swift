//
//  GratitudeTableViewController.swift
//  MiCos
//
//  Created by Samuel Coby Anderson on 3/9/16.
//  Copyright © 2016 Samuel Coby Anderson. All rights reserved.
//

import UIKit
import Parse

class GratitudeTableViewController: UITableViewController, UITextViewDelegate {
   
    @IBOutlet weak var personLabel: UILabel!
    
    @IBOutlet weak var messageText: UITextView!
    
    @IBOutlet weak var doneButton: UIButton!
    
    @IBOutlet weak var textCountLabel: UILabel!
    
    var person: String? = "" {
        didSet {
            self.personLabel.text = person
            if textLength > 50  {
                self.doneButton.enabled = true
                self.doneButton.alpha = 0.4
            }
        }
    }
    var textLength: Int = 0 {
        didSet {
            self.textCountLabel.text = "Need \(String(50 - textLength))"
            self.textCountLabel.textColor = UIColor.redColor()
            if textLength >= 50  {
                self.textCountLabel.textColor = UIColor.greenColor()
                self.textCountLabel.text = ""
                if person != "" {
                    self.doneButton.enabled = true
                    self.doneButton.alpha = 1.0
                }
            } else {
                self.doneButton.enabled = false
                self.doneButton.alpha = 0.4
                
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

    override func viewDidLoad() {
        super.viewDidLoad()
        self.messageText.delegate = self
        
        self.textLength = 0
        
        self.doneButton.enabled = false
        self.doneButton.alpha = 0.4
      
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
        
        //gets rid of separators
        self.tableView.separatorColor = UIColor.groupTableViewBackgroundColor()
        
        //creates reminders to send gratitudes
        createReminders()
        
    }
    func createReminders() {
        
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        
        
        let today = NSDate()
        print (today)
        let calendar = NSCalendar.currentCalendar()
        calendar.timeZone = NSTimeZone.localTimeZone()
        let components = calendar.components([.Day, .Month, .Year, .Hour, .TimeZone], fromDate: today)
        let hoursTill = 15 - components.hour
        let secondsTill: NSTimeInterval = Double(hoursTill)*3600
        var pushTime = today.dateByAddingTimeInterval(secondsTill)
        var message = "Feeling Thankful? Don't forget to send your daily Gratitude!"
        
        //sets up five local notifications to remind people to send their daily gratitudes
        for i in 1...5 {
            
            //add a day to the time
            pushTime = pushTime.dateByAddingTimeInterval(86400)
        
            let notification = UILocalNotification()
            notification.alertBody = message
            notification.fireDate = pushTime
            notification.soundName = "velvet alert 07 descending.mp3"
            notification.applicationIconBadgeNumber = 1
            UIApplication.sharedApplication().scheduleLocalNotification(notification)
            
            switch i {
            case 1:
                message = "Someone do something nice or unexpected for you today? Show them your thanks with a Gratitude!"
            case 2:
                message = "Taking just a few moments to reflect on what we are thankful for each day builds whole individuals and strong communities, want to send a Gratitude? "
            case 3:
                message = "You haven't sent a Gratitude in a few days, it only takes a few seconds of your time to make someone else's day."
            case 4:
                message = "It seems these notifications aren't working, I'll stop reminding you to send your daily Gratitude."
            default:
                message = "Feeling Thankful? Don't forget to send your daily Gratitude!"
            }
            
        }
        
    }

    @IBAction func unwindWithSelectedPerson(segue: UIStoryboardSegue) {
        if let ChoosePersonViewController = segue.sourceViewController as?
            ChoosePersonViewController,
            passedUser = ChoosePersonViewController.selectedPerson{
                person = passedUser
        }
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        messageText.endEditing(true)
        
        // makes sure the done button is enabled, meaning the 
        if doneButton.enabled == true {
            let userQuery = PFUser.query()
            userQuery?.whereKey("Name", equalTo: person!)
            
            userQuery?.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error) -> Void in
                if error == nil {
                    if let user = objects?[0] {
                        let notification = PFObject(className: "Notifications")
                        notification["Legacy"] = user["Legacy"]
                        notification["Message"] = self.messageText.text
                        notification["Arcs"] = 1.0
                        notification["toUser"] = user
                        notification["Awardee"] = user["Name"]
                        let currentUser = PFUser.currentUser()
                        notification["Awarder"] = currentUser?["Name"] as! String
                        notification["fromUser"] = currentUser
                        notification["Sent"] = false
                        notification["Notify"] = -1
//                        PFUser.currentUser()!["DailyGratitude"] = true
//                        notification.saveInBackground()
//                        PFUser.currentUser()?.saveInBackground()
//                        //fix this to not be like this
                    }
                }
            })
            
        }
    }
    

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        
        //LightContent
        return UIStatusBarStyle.LightContent
        
        //Default
        //return UIStatusBarStyle.Default
        
    }

}
