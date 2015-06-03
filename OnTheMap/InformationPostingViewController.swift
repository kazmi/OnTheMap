//
//  InformationPostingViewController.swift
//  OnTheMap
//
//  Created by Sulaiman Azhar on 6/3/15.
//  Copyright (c) 2015 kazmi. All rights reserved.
//

import UIKit

class InformationPostingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func cancelInformationPosting(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    

}
