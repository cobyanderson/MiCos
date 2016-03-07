//
//  ChooseAwardeeViewController.swift
//  MiCos
//
//  Created by Samuel Coby Anderson on 2/27/16.
//  Copyright © 2016 Samuel Coby Anderson. All rights reserved.
//

import UIKit
import Parse

class ChooseAwardeeViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var bottomSpace: NSLayoutConstraint!

    @IBOutlet weak var awardeeTableView: UITableView!
    
    @IBOutlet weak var chooseAwardeeSearchBar: UISearchBar!
    
    var foundAwardees: [PFUser]?
    
    var selectedAwardees: [String]? = []
    
    var query: PFQuery? {
        didSet {
            oldValue?.cancel()
        }
    }
    
    func findAwardees(completionBlock:PFArrayResultBlock) -> PFQuery {
        let searchText = self.chooseAwardeeSearchBar?.text ?? ""
        let userQuery = PFUser.query()
        if let awardersLegacy = PFUser.currentUser()?["Legacy"] as? String {
            userQuery?.whereKey("Legacy", notEqualTo: awardersLegacy)
        }
        userQuery?.whereKey("Name", matchesRegex: searchText, modifiers: "i")
        userQuery?.whereKey("username", notEqualTo: PFUser.currentUser()!.username!)
        userQuery?.whereKey("Role", containedIn: ["F","E"])
        userQuery?.findObjectsInBackgroundWithBlock(completionBlock)
        
        return userQuery!
        
    }
    func searchUpdateList(results: [AnyObject]?, error: NSError?) {
        let awardees = results as? [PFObject] ?? []
        self.foundAwardees = awardees.map({ (awardee) -> PFUser in
            return awardee as! PFUser
        })
       
        self.awardeeTableView.reloadData()
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.awardeeTableView.delegate = self
        self.awardeeTableView.dataSource = self
        self.chooseAwardeeSearchBar.delegate = self
        
        query = findAwardees(searchUpdateList)
        
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
    }



    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.foundAwardees?.count ?? 0
    }

   func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell: AwardeeTableViewCell = self.awardeeTableView.dequeueReusableCellWithIdentifier("awardeeCell") as! AwardeeTableViewCell!
    
        let foundAwardee = foundAwardees![indexPath.row]
        //cell.legacyLabel.text = foundAwardee["Emoji"] as? String ?? "error"
        cell.nameLabel.text = foundAwardee["Name"] as? String ?? "error"
        cell.emailLabel.text = foundAwardee["Legacy"] as? String ?? "error"

        if selectedAwardees!.contains(foundAwardees![indexPath.row].objectId!) {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
    

        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell: AwardeeTableViewCell = (awardeeTableView.cellForRowAtIndexPath(indexPath) as? AwardeeTableViewCell)!
        
        if selectedAwardees!.contains(foundAwardees![indexPath.row]["Name"] as! String) == false {
             selectedAwardees!.append(foundAwardees![indexPath.row]["Name"] as! String)
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        }
        else {
            selectedAwardees!.removeAtIndex(selectedAwardees!.indexOf(foundAwardees![indexPath.row]["Name"] as! String)!)
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
        awardeeTableView.deselectRowAtIndexPath(indexPath, animated: true)
        print (selectedAwardees)
    }
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if selectedAwardees!.contains(foundAwardees![indexPath.row]["Name"] as! String) {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        bottomSpace.constant = 216
        chooseAwardeeSearchBar.setShowsCancelButton(true, animated: true)
    }
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text = ""
        searchBar.setShowsCancelButton(false, animated: true)
        query = findAwardees(searchUpdateList)
        bottomSpace.constant = 0
        
        
    }
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        query = findAwardees(searchUpdateList)
    }
  

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
extension PFUser{

}
public func ==(lhs: PFUser, rhs: PFUser) -> Bool {
    return lhs.objectId == rhs.objectId
}



