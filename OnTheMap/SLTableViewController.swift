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
        
    }
    
    // MARK: - Logout
    
    func logoutButtonTouchUp() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
