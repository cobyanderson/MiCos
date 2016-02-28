//
//  AwardArcsViewController.swift
//  MiCos
//
//  Created by Samuel Coby Anderson on 2/27/16.
//  Copyright © 2016 Samuel Coby Anderson. All rights reserved.
//

import UIKit
import Parse

class Award {
    var awardee: PFUser?
    var awarder: PFUser?
    var reason: String?
    var arcAmount: Float?
}

class AwardArcsViewController: UITableViewController {

    @IBOutlet weak var arcSlider: UISlider!
    
    @IBOutlet weak var awardeeLabel: UILabel!
    
    @IBOutlet weak var reasonText: UITextView!
    
    @IBOutlet weak var arcLabel: UILabel!
    
    
    var award: Award?
    
    var awardees: [String] = [] {
        didSet {
            var nameString = ""
            for awardee in awardees {
                nameString = nameString + "\(awardee)  "
            }
            awardeeLabel.text? = nameString
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        reasonText.endEditing(true)
        if segue.identifier ==  "SaveAward" {
            award = Award()
            award?.reason = reasonText.text
            award?.arcAmount = arcSlider.value
        }
        
   }

    
    @IBAction func sliderValueChanged(sender: AnyObject) {
        arcLabel.text = String(Int(arcSlider.value))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        arcSlider.maximumValue = 50
        arcSlider.minimumValue = 1
        
        //makes sure back button does not have previous title
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
        
        
        //sets up a tap gesture to dismiss keyboard
        
        
        
        
        
        

    
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    @IBAction func unwindWithSelectedAwardees(segue: UIStoryboardSegue) {
        if let ChooseAwardeeViewController = segue.sourceViewController as? ChooseAwardeeViewController,
            passedUsers = ChooseAwardeeViewController.selectedAwardees{
            awardees = passedUsers
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
