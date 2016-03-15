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
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    @IBOutlet weak var textCountLabel: UILabel!
    
    var person: String? = "" {
        didSet {
            self.personLabel.text = person
            if textLength > 50  {
                self.doneButton.enabled = true
            }
        }
    }
    var textLength: Int = 0 {
        didSet {
            self.textCountLabel.text = "\(String(textLength))/50"
            self.textCountLabel.textColor = UIColor.redColor()
            if textLength > 50  {
                self.textCountLabel.textColor = UIColor.greenColor()
                if person != "" {
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

    override func viewDidLoad() {
        super.viewDidLoad()
        self.messageText.delegate = self
        
        self.textLength = 0
        
        self.doneButton.enabled = false
      
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
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
        
        let userQuery = PFUser.query()
        userQuery?.whereKey("Name", equalTo: person!)
        
        userQuery?.findObjectsInBackgroundWithBlock({ (objects: [AnyObject]?, error) -> Void in
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
                    PFUser.currentUser()!["DailyGratitude"] = true
                    notification.saveInBackground()
                    PFUser.currentUser()?.saveInBackground()
                    //fix this to not be like this
                }
            }
        })
        
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
