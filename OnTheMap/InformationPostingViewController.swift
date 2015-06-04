//
//  InformationPostingViewController.swift
//  OnTheMap
//
//  Created by Sulaiman Azhar on 6/3/15.
//  Copyright (c) 2015 kazmi. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class InformationPostingViewController: UIViewController {
    
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var findButton: UIButton!
    
    @IBOutlet weak var linkTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var submitButton: UIButton!
    
    var geocoder: CLGeocoder!
    var studyingLocation: CLLocation? = nil
    
    var tapRecognizer: UITapGestureRecognizer? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        geocoder = CLGeocoder()
        
        locationTextField.attributedPlaceholder = NSAttributedString(string: "Enter Your Location Here",
            attributes: [NSForegroundColorAttributeName:UIColor.whiteColor()])
        
        linkTextField.attributedPlaceholder = NSAttributedString(string: "Enter a link to Share Here",
            attributes: [NSForegroundColorAttributeName:UIColor.whiteColor()])

        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap")
        tapRecognizer?.numberOfTapsRequired = 1
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        addKeyboardDismissRecognizer()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardDismissRecognizer()
    }
    
    @IBAction func cancelInformationPosting(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func findOnTheMap(sender: AnyObject) {
        geocoder.geocodeAddressString(locationTextField.text,
            completionHandler: { (placemarks:[AnyObject]!, error: NSError!) -> Void in
                
            if error == nil && placemarks.count > 0 {
                let placemark = placemarks[0] as! CLPlacemark
                self.studyingLocation = placemark.location
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.cancelButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
                    self.questionLabel.hidden = true
                    self.locationTextField.hidden = true
                    self.findButton.hidden = true
                    self.linkTextField.hidden = false
                    self.mapView.hidden = false
                    self.submitButton.hidden = false
                })
                
            }
         })
    }
    
    @IBAction func postInformation(sender: AnyObject) {
        
    }
    
    
    //#MARK:- Keyboard Fixes & Notifications
    
    func addKeyboardDismissRecognizer() {
        view.addGestureRecognizer(tapRecognizer!)
    }
    
    func removeKeyboardDismissRecognizer() {
        view.removeGestureRecognizer(tapRecognizer!)
    }
    
    func handleSingleTap() {
        view.endEditing(true)
    }
    

}
