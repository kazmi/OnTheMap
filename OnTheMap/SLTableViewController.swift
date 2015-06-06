//
//  SLTableViewController.swift
//  OnTheMap
//
//  Created by Sulaiman Azhar on 6/1/15.
//  Copyright (c) 2015 kazmi. All rights reserved.
//

import UIKit

class SLTableViewController: UITableViewController {

    var students: [StudentInformation] = [StudentInformation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Create and set the logout button */
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.Plain, target: self, action: "logoutButtonTouchUp")
        
        /* Create the set the add pin button */
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "pin"), style: UIBarButtonItemStyle.Plain, target: self, action: "informationPostingButtonTouchUp")
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        UdacityClient.sharedInstance().getStudentInformation { students, error in
            if let students = students {
                self.students = students
                dispatch_async(dispatch_get_main_queue()) {
                    self.tableView.reloadData()
                }
            } else {
                println(error)
            }
        }
        
    }
    
    // MARK: - Table View and Data Source Delegates
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.students.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SLTableViewCell") as! UITableViewCell
        let studentInformation = students[indexPath.row]
        
        cell.textLabel?.text = studentInformation.firstName! + " " + studentInformation.lastName!

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        /* show media url in default browser */
        let studentInformation = students[indexPath.row]
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
        
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("InformationPostingViewController")
            as! UIViewController
        self.presentViewController(controller, animated: true, completion: nil)
        
    }

}
