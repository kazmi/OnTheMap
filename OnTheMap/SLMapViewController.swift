//
//  SLMapViewController.swift
//  OnTheMap
//
//  Created by Sulaiman Azhar on 6/2/15.
//  Copyright (c) 2015 kazmi. All rights reserved.
//

import UIKit
import MapKit

class SLMapViewController: UIViewController, MKMapViewDelegate {
    
    var annotations: [MKPointAnnotation] = [MKPointAnnotation]()
    
    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateMap", name: "studentDataUpdated", object: nil)

        /* Create and set the logout button */
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.Plain, target: self, action: "logoutButtonTouchUp")
        
        /* Create the set the add pin button */
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "pin"), style: UIBarButtonItemStyle.Plain, target: self, action: "informationPostingButtonTouchUp")
        
        if (DataModel.sharedInstance().students.count == 0) {
            
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
                    
                }
            }
            
        } else {
    
            updateMap()
    
        }
        
    }
    
    func updateMap() {
        
        self.generateAnnotations()
        self.mapView.addAnnotations(self.annotations)

    }
    
    func generateAnnotations() {
        
        for student in DataModel.sharedInstance().students {
            
            // The lat and long are used to create a CLLocationCoordinates2D instance.
            let coordinate = CLLocationCoordinate2D(latitude: student.latitude!, longitude: student.longitude!)
            
            // Create the annotation and set its properties
            var annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(student.firstName!) \(student.lastName!)"
            annotation.subtitle = student.mediaURL
            
            self.annotations.append(annotation)
            
        }
        
    }
    
    // MARK: - Map View Delegate
    
    /*
    
    The MKMapViewDelegate protocol implementation is based on the PinSample app,
    (https://s3.amazonaws.com/content.udacity-data.com/courses/ud421/PinSample.zip.)
    
    */
    
    // Create a view with a "right callout accessory view".
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinColor = .Red
            pinView!.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIButton
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotation.
    func mapView(mapView: MKMapView!, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == annotationView.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            app.openURL(NSURL(string: annotationView.annotation.subtitle!)!)
        }
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
        }
        else {
            
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("InformationPostingViewController")
                as! UIViewController
            self.presentViewController(controller, animated: true, completion: nil)
        }
        
    }

}
