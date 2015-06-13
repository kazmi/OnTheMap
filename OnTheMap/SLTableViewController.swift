//
//  SLTableViewController.swift
//  OnTheMap
//
//  Created by Sulaiman Azhar on 6/1/15.
//  Copyright (c) 2015 kazmi. All rights reserved.
//

import UIKit

class SLTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateTable", name: "studentDataUpdated", object: nil)
        
        /* Create and set the logout button */
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.Plain, target: self, action: "logoutButtonTouchUp")
        
        /* Create and set the add pin and reload button */
        self.navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: UIImage(named: "reload"), style: UIBarButtonItemStyle.Plain, target: self, action: "loadData"),
            UIBarButtonItem(image: UIImage(named: "pin"), style: UIBarButtonItemStyle.Plain, target: self, action: "informationPostingButtonTouchUp")
        ]
        
        if (DataModel.sharedInstance().students.count == 0) {
            
            loadData()
            
        } else {
            
            updateTable()
            
        }
        
    }
    
    func updateTable() {
        self.tableView.reloadData()
    }
    
    // MARK: - Table View and Data Source Delegates
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataModel.sharedInstance().students.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SLTableViewCell") as! UITableViewCell
        let studentInformation = DataModel.sharedInstance().students[indexPath.row]
        
        cell.textLabel?.text = studentInformation.firstName! + " " + studentInformation.lastName!

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        /* show media url in default browser */
        let studentInformation = DataModel.sharedInstance().students[indexPath.row]
        let link = NSURL(string: studentInformation.mediaURL!)!
        UIApplication.sharedApplication().openURL(link)
    }
    
    // MARK: - Logout
    
    func logoutButtonTouchUp() {

        UdacityClient.sharedInstance().logoutWithCompletionHandler() { (success, errorString) in
            if success {
                dispatch_async(dispatch_get_main_queue(), {
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
            }
        }
    }
    
    // MARK: - Navigation Bar Buttons
    
    func loadData() {
        
        DataModel.sharedInstance().students.removeAll(keepCapacity: true)
        
        var serialQueue = dispatch_queue_create("com.udacity.onthemap.api", DISPATCH_QUEUE_SERIAL)
        
        var skips = [0, 100]
        for skip in skips {
            dispatch_sync( serialQueue ) {
                
                UdacityClient.sharedInstance().getStudentInformation (skip: skip) { students, error in
                    if let students = students {
                        DataModel.sharedInstance().students.extend(students)
                        
                        if students.count > 0 {
                            dispatch_async(dispatch_get_main_queue()) {
                                NSNotificationCenter.defaultCenter().postNotificationName("studentDataUpdated", object: nil)
                            }
                        }
                        
                    } else {
                        
                        let title: String =  ErrorTypes.localizedDescription(ErrorTypes(rawValue: error!.code)!)
                        let alertController = UIAlertController(title: title, message: error!.localizedDescription,
                            preferredStyle: .Alert)
                        
                        let okAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                        }
                        alertController.addAction(okAction)
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            self.presentViewController(alertController, animated: true, completion: nil)
                        }
                    }
                }
            }
        }
        
    }
    
    func informationPostingButtonTouchUp() {
        
        if UdacityClient.sharedInstance().currentStudent?.objectID != nil {
            let message = "You have already posted a Student Location. Would you like to Overwrite Your Current Location?"
            let alertController = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
            
            let overwriteAction = UIAlertAction(title: "Overwrite", style: .Default) { (action) in
                
                let controller = self.storyboard!.instantiateViewControllerWithIdentifier("InformationPostingViewController")
                    as! UIViewController
                self.presentViewController(controller, animated: true, completion: nil)
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
                
            }
            
            alertController.addAction(cancelAction)
            alertController.addAction(overwriteAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
        } else {
            
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("InformationPostingViewController")
                as! UIViewController
            self.presentViewController(controller, animated: true, completion: nil)
        }
        
    }

}
