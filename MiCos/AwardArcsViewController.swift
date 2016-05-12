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
    
    @IBOutlet weak var doneButton: UIButton!
    
    @IBOutlet weak var textCountLabel: UILabel!
    
    var notifications: [PFObject]? = []
    var points: [PFObject]? = []
    
    var awardees: [String] = [] {
        didSet {
            var nameString = ""
            for awardee in awardees {
                nameString = nameString + "\(awardee)  "
            }
            awardeeLabel.text? = nameString
            if textLength > 20  {
                self.doneButton.enabled = true
                self.doneButton.alpha = 1.0
            }
        }
    }
    var textLength: Int = 0 {
        didSet {
            self.textCountLabel.text = "Need \(String(20 - textLength))"
            self.textCountLabel.textColor = UIColor.redColor()
            if textLength >= 20  {
                self.textCountLabel.textColor = UIColor.greenColor()
                self.textCountLabel.text = ""
                if awardees.count > 0 {
                    self.doneButton.enabled = true
                    self.doneButton.alpha = 1.0
                }
            } else {
                self.doneButton.enabled = false
                self.doneButton.alpha = 0.3
                
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
        
            
            //makes sure doen button is enabled before saving
               
        
    }

    
    @IBAction func sliderValueChanged(sender: AnyObject) {
        arcLabel.text = (String(format: "%.0f", arcSlider.value))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.reasonText.delegate = self
        
        //triggers the did set method of text length
        self.textLength = 0
        
        //gets rid of separators
        self.tableView.separatorColor = UIColor.groupTableViewBackgroundColor()
        
        // disables the done button
        self.doneButton.enabled = false
        self.doneButton.alpha = 0.3
       
        // sets arc max and min give values for different people
        print (PFUser.currentUser()!)
        if let arcMax = PFUser.currentUser()!["MaxArcs"] {
            if let arcMin = PFUser.currentUser()!["MinArcs"] {
                self.arcSlider.maximumValue = arcMax as! Float
                self.arcSlider.minimumValue = arcMin as! Float
                arcLabel.text = String(Int(arcMin as! Float))
                
            }
        }
//        if let role = PFUser.currentUser()!["Role"] as? String {
//            if role == "E" {
//                self.notifyControl.removeSegmentAtIndex(2 , animated: false)
//            }
//        }
    
        //sets the segment control's default
        self.notifyControl.selectedSegmentIndex = 2
        
        //makes sure back button does not have previous title
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
        
        
    }
    @IBAction func unwindWithSelectedAwardees(segue: UIStoryboardSegue) {
        if let chooseAwardeeViewController = segue.sourceViewController as?
            ChooseAwardeeViewController,
            passedUsers = chooseAwardeeViewController.selectedAwardees{
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
