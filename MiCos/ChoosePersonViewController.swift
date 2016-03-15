//
//  ChoosePersonViewController.swift
//  MiCos
//
//  Created by Samuel Coby Anderson on 3/9/16.
//  Copyright © 2016 Samuel Coby Anderson. All rights reserved.
//
import Parse
import UIKit

class ChoosePersonViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var personSearchBar: UISearchBar!
    
    @IBOutlet weak var personTableView: UITableView!

    @IBOutlet weak var bottomSpace: NSLayoutConstraint!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var foundPeople: [PFUser]?
    
    var selectedPerson: String? = ""
    
    var query: PFQuery? {
        didSet {
            activityIndicator.startAnimating()
            oldValue?.cancel()
        }
    }
    
    func findPeople(completionBlock:PFArrayResultBlock) -> PFQuery {
        let searchText = self.personSearchBar?.text ?? ""
        let userQuery = PFUser.query()
        if let awardersLegacy = PFUser.currentUser()?["Legacy"] as? String {
            userQuery?.whereKey("Legacy", notEqualTo: awardersLegacy)
        }
        userQuery?.whereKey("Name", matchesRegex: searchText, modifiers: "i")
        userQuery?.whereKey("username", notEqualTo: PFUser.currentUser()!.username!)
        userQuery?.whereKey("Role", containedIn: ["F","E"])
        userQuery?.orderByAscending("Legacy")
        userQuery?.findObjectsInBackgroundWithBlock(completionBlock)
        
        return userQuery!
        
    }
    func searchUpdateList(results: [AnyObject]?, error: NSError?) {
        let awardees = results as? [PFObject] ?? []
        self.foundPeople = awardees.map({ (awardee) -> PFUser in
            return awardee as! PFUser
        })
        
        self.activityIndicator.stopAnimating()
        self.personTableView.reloadData()
        
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()
        self.personTableView.delegate = self
        self.personTableView.dataSource = self
        self.personSearchBar.delegate = self
        
        //register to check if the keyboard pops up
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "keyboardShown:", name: UIKeyboardDidShowNotification, object: nil)
        
        query = findPeople(searchUpdateList)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.foundPeople?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: PersonTableViewCell =
        self.personTableView.dequeueReusableCellWithIdentifier("personCell") as! PersonTableViewCell!
        
        let foundPerson = foundPeople![indexPath.row]
        cell.nameLabel.text = foundPerson["Name"] as? String ?? "error"
        cell.emailLabel.text = foundPerson["Legacy"] as? String ?? "error"
        
        return cell
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "saveSelectedPerson" {
            if let cell = sender as? PersonTableViewCell {
                let indexPath = personTableView.indexPathForCell(cell)
                if let index = indexPath?.row {
                    self.selectedPerson = foundPeople![indexPath!.row]["Name"] as! String
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        self.selectedPerson = foundPeople![indexPath.row]["Name"] as! String
    }
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        personSearchBar.setShowsCancelButton(true, animated: true)
    }
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text = ""
        searchBar.setShowsCancelButton(false, animated: true)
        query = findPeople(searchUpdateList)
        bottomSpace.constant = 0
        
    }
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        query = findPeople(searchUpdateList)
    }
    func keyboardShown(notification: NSNotification) {
        let info  = notification.userInfo!
        let value: AnyObject = info[UIKeyboardFrameEndUserInfoKey]!
        
        let rawFrame = value.CGRectValue
        let keyboardFrame = view.convertRect(rawFrame, fromView: nil)
        
        bottomSpace.constant = keyboardFrame.height
        
    }
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        
        //LightContent
        return UIStatusBarStyle.LightContent
        
        //Default
        //return UIStatusBarStyle.Default
        
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
