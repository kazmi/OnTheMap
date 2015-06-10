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

class InformationPostingViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var linkButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var findButton: UIButton!
    
    @IBOutlet weak var linkTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var submitButton: UIButton!
    
    var activityIndicator: UIActivityIndicatorView!
    
    var alertController: UIAlertController!
    
    var geocoder: CLGeocoder!
    var studyingLocation: CLLocation? = nil
    
    var tapRecognizer: UITapGestureRecognizer? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
        activityIndicator.center = self.view.center
        self.view.addSubview(activityIndicator)
        
        geocoder = CLGeocoder()
        
        locationTextField.attributedPlaceholder = NSAttributedString(string: "Enter Your Location Here",
            attributes: [NSForegroundColorAttributeName:UIColor.whiteColor()])
        locationTextField.tintColor = UIColor.whiteColor()
        
        linkTextField.attributedPlaceholder = NSAttributedString(string: "Enter a link to Share Here",
            attributes: [NSForegroundColorAttributeName:UIColor.whiteColor()])
        linkTextField.tintColor = UIColor.whiteColor()

        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap")
        tapRecognizer?.numberOfTapsRequired = 1
        
        if let currentStudent = UdacityClient.sharedInstance().currentStudent {
            
            if let mapString = currentStudent.mapString {
                self.locationTextField.text = mapString
            }
            
            if let mediaURL = currentStudent.mediaURL {
                self.linkTextField.text = currentStudent.mediaURL!
            }
            
        }
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
    
    @IBAction func browseLink(sender: AnyObject) {
        let app = UIApplication.sharedApplication()
        app.openURL(NSURL(string: linkTextField.text)!)
    }
    
    @IBAction func findOnTheMap(sender: AnyObject) {
        
        activityIndicator.startAnimating()
        self.view.alpha = 0.5
        
        geocoder.geocodeAddressString(locationTextField.text,
            completionHandler: { (placemarks:[AnyObject]!, error: NSError!) -> Void in
                
            dispatch_async(dispatch_get_main_queue(), {
                self.view.alpha = 1.0
                self.activityIndicator.stopAnimating()
            })
                
            if error == nil && placemarks.count > 0 {
                
                let placemark = placemarks[0] as! CLPlacemark
                
                self.studyingLocation = placemark.location
                
                var annotation = MKPointAnnotation()
                annotation.coordinate = placemark.location.coordinate
                
                var region = MKCoordinateRegion()
                region.center = placemark.location.coordinate
                
                /* The app zooms the map into an appropriate region based 
                   on the available information */

                if let thoroughfare = placemark.thoroughfare {
                    region.span.latitudeDelta = 0.2
                    region.span.longitudeDelta = 0.2
                } else if let locality = placemark.locality {
                    region.span.latitudeDelta = 0.5
                    region.span.longitudeDelta = 0.5
                } else {
                    region.span.latitudeDelta = 12.0
                    region.span.longitudeDelta = 12.0
                }

                dispatch_async(dispatch_get_main_queue(), {
                    
                    self.cancelButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
                    self.questionLabel.hidden = true
                    self.locationTextField.hidden = true
                    self.findButton.hidden = true
                    self.linkTextField.hidden = false
                    self.mapView.hidden = false
                    self.submitButton.hidden = false
                    self.linkButton.hidden = false
                    
                    // pass the region to mapview and show annotation
                    self.mapView.addAnnotation(annotation)
                    self.mapView.setRegion(region, animated: true)
                    self.mapView.regionThatFits(region)

                })
                
            } else {
                
                let alertController = UIAlertController(title: nil, message: "The geocoding operation could not be completed.", preferredStyle: .Alert)
                
                let okAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                }
                
                alertController.addAction(okAction)
                
                self.presentViewController(alertController, animated: true, completion: nil)
                
            }
                
         })
    }
    
    func postInformationLogic() {
        var studentInfo: [String : AnyObject] = [:]
        studentInfo["objectId"] = UdacityClient.sharedInstance().currentStudent?.objectID
        studentInfo["uniqueKey"] = UdacityClient.sharedInstance().currentStudent?.uniqueKey!
        studentInfo["mapString"] = self.locationTextField.text
        studentInfo["mediaURL"] = self.linkTextField.text
        studentInfo["latitude"] = self.studyingLocation?.coordinate.latitude
        studentInfo["longitude"] = self.studyingLocation?.coordinate.longitude
        studentInfo["firstName"] = UdacityClient.sharedInstance().currentStudent?.firstName!
        studentInfo["lastName"] = UdacityClient.sharedInstance().currentStudent?.lastName!
        var student = StudentInformation(dictionary: studentInfo)
        
        if let objectID = UdacityClient.sharedInstance().currentStudent?.objectID {
            
            UdacityClient.sharedInstance().putStudentInformation(student) { (success, error) in
                
                if success {
                    
                    UdacityClient.sharedInstance().currentStudent = student
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.dismissViewControllerAnimated(true, completion: nil)
                    })
                }
                else {
                    
                    self.displayErrorMessage(error!)
                    
                }
                
            }
            
        } else {
            
            UdacityClient.sharedInstance().postStudentInformation(student) { (success, objectID, error) in
                
                if success {
                    
                    UdacityClient.sharedInstance().currentStudent = student
                    UdacityClient.sharedInstance().currentStudent?.objectID = objectID!
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.dismissViewControllerAnimated(true, completion: nil)
                    })
                }
                else {
                    
                    self.displayErrorMessage(error!)
                    
                }
                
            }
            
        }
    }
    
    func displayErrorMessage(errorString: String) {
        
        self.alertController = UIAlertController(title: nil, message: errorString, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default) { (action) in }
        
        let retryAction = UIAlertAction(title: "Retry", style: .Default) { (action) in
            dispatch_async(dispatch_get_main_queue(), {
                self.postInformationLogic()
            })
        }
        
        self.alertController.addAction(okAction)
        self.alertController.addAction(retryAction)
        
        dispatch_async(dispatch_get_main_queue(), {
            self.presentViewController(self.alertController, animated: true, completion: nil)
        })
        
    }
    
    @IBAction func postInformation(sender: AnyObject) {
        postInformationLogic()
    }
    
    //#MARK: - Textfield Delegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if(textField == linkTextField && textField.text == "") {
            textField.text = "http://"
        }
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
