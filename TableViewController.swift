//
//  TableViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Siddarth Patel on 7/5/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

var colorFlag = false

class TableViewController: UITableViewController {
    
    var usernames = [""]
    var userids = [""]
    var isFollowing = ["":false]
    var refresher: UIRefreshControl!
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    func refresh(){
        
        var query = PFUser.query()
        
        query?.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
            if let users = objects {
                
                self.usernames.removeAll(keepCapacity: true)
                self.userids.removeAll(keepCapacity: true)
                self.isFollowing.removeAll(keepCapacity: true)
                
                for object in users{
                    
                    if let user = object as? PFUser {
                        
                        if user.objectId != PFUser.currentUser()?.objectId{
                            print(user)
                            self.usernames.append(user.username!)
                            self.userids.append(user.objectId!)
                            
                            var query = PFQuery(className: "followers")
                            
                            if PFUser.currentUser() != nil{
                                query.whereKey("follower", equalTo: (PFUser.currentUser()?.objectId)!)
                                query.whereKey("following", equalTo: user.objectId!)
                                
                                query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                                
                                    if let objects = objects{
                                    
                                        print(objects)
                                        if objects.count > 0{
                                        self.isFollowing[user.objectId!] = true
                                    
                                    } else {
                                    
                                        self.isFollowing[user.objectId!] = false
                                    
                                      }
                                    }
                                    if self.isFollowing.count == self.usernames.count{
                                        self.tableView.reloadData()
                                        self.refresher.endRefreshing()
                                    }
                                
                                
                                })
                            }
                        
                        
                        }
                    }
                }
            }
            
        })

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        refresher = UIRefreshControl()
        
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        
        refresher.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        
        self.tableView.addSubview(refresher)
        
        refresh()
    }
    
    
    func displayAlert(title: String, message: String){
        if #available(iOS 8.0, *) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
                self.dismissViewControllerAnimated(true, completion: nil)
            }))
            self.presentViewController(alert, animated: true, completion: nil)
            
            
        } else {
            print("Error creating an alert message!")
        }
        self.view.backgroundColor = UIColor.redColor()
    }
    
        
    @IBAction func logout(sender: AnyObject) {
        
        var errorMessage = "Please try again later"
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0,0,50,50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        
        PFUser.logOutInBackgroundWithBlock { (error) -> Void in
            
            if error == nil{
                self.activityIndicator.stopAnimating()
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                self.displayAlert("Success", message: "Logged out")
                colorFlag = true
            }
            else{
                if let errorString = error!.userInfo["error"] as? String{
                    errorMessage = errorString
                    self.activityIndicator.stopAnimating()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                }
                self.displayAlert("Logout Failed", message: errorMessage)
                
            }
         }
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return usernames.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

        cell.textLabel!.text = usernames[indexPath.row]
        
        if isFollowing[userids[indexPath.row]] == true{
           cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var cell: UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        
        if isFollowing[userids[indexPath.row]] == false{
            
            isFollowing[userids[indexPath.row]] = true
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            var following = PFObject(className: "followers")
            following["following"] = userids[indexPath.row]
            following["follower"] = PFUser.currentUser()?.objectId
            following.saveInBackground()
        }
        else {
           isFollowing[userids[indexPath.row]] = false
           cell.accessoryType = UITableViewCellAccessoryType.None
            var query = PFQuery(className: "followers")
            query.whereKey("follower", equalTo: (PFUser.currentUser()?.objectId)!)
            query.whereKey("following", equalTo: userids[indexPath.row])
            
            query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                
                if let objects = objects{
                    
                    for object in objects{
                        
                        object.deleteInBackground()
                        
                    }
                }
                
            })
        }
    }



}
