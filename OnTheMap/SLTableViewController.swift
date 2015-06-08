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
        
        /* Create and set the logout button */
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.Plain, target: self, action: "logoutButtonTouchUp")
        
        /* Create the set the add pin button */
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "pin"), style: UIBarButtonItemStyle.Plain, target: self, action: "informationPostingButtonTouchUp")
        
        if (DataModel.sharedInstance().students.count == 0) {
            println("populating data")
            UdacityClient.sharedInstance().getStudentInformation { students, error in
                if let students = students {
                    DataModel.sharedInstance().students = students
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.tableView.reloadData()
                    }
                    
                } else {
                    
                    let alertController = UIAlertController(title: nil, message: error,
                        preferredStyle: .Alert)
                    
                    let okAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                    }
                    alertController.addAction(okAction)
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                }
            }
            
        } else {
            self.tableView.reloadData()
        }
        
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
