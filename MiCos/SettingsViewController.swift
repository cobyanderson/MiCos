//
//  SettingsViewController.swift
//  MiCos
//
//  Created by Samuel Coby Anderson on 3/6/16.
//  Copyright © 2016 Samuel Coby Anderson. All rights reserved.
//

import UIKit
import Parse

class SettingsViewController: UITableViewController {
    
    @IBOutlet weak var logOut: UITableViewCell!
    
    @IBOutlet weak var submitBug: UITableViewCell!
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print (indexPath.section)
        if indexPath.section == 0 {
            PFUser.logOutInBackgroundWithBlock { (NSError) -> Void in
                let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
                delegate.presentLogInView()

            }
        }
        else {
            UIApplication.sharedApplication().openURL(NSURL(string: "https://docs.google.com/forms/d/18oztRy7QhVYUCmxCGQrsklhjS8X89r32vU_9lWbKP0A/viewform")!)
            
        }
        
    }

   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
