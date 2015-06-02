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
    
    var students: [StudentInformation] = [StudentInformation]()
    var annotations: [MKPointAnnotation] = [MKPointAnnotation]()
    
    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()

        /* Create and set the logout button */
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.Plain, target: self, action: "logoutButtonTouchUp")
        
        UdacityClient.sharedInstance().getStudentInformation { students, error in
            if let students = students {
                self.students = students
                
                for student in students {
                    
                    // The lat and long are used to create a CLLocationCoordinates2D instance.
                    let coordinate = CLLocationCoordinate2D(latitude: student.latitude, longitude: student.longitude)
                    
                    // Create the annotation and set its properties
                    var annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate
                    annotation.title = "\(student.firstName) \(student.lastName)"
                    annotation.subtitle = student.mediaURL
                    
                    self.annotations.append(annotation)
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.mapView.addAnnotations(self.annotations)
                    }
                }
                
            } else {
                println(error)
            }
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

}
