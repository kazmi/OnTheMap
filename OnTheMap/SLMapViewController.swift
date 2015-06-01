//
//  SLMapViewController.swift
//  OnTheMap
//
//  Created by Sulaiman Azhar on 6/2/15.
//  Copyright (c) 2015 kazmi. All rights reserved.
//

import UIKit

class SLMapViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        /* Create and set the logout button */
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.Plain, target: self, action: "logoutButtonTouchUp")
        
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

}
