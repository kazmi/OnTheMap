//
//  SLMapViewController.swift
//  OnTheMap
//
//  Created by Sulaiman Azhar on 6/2/15.
//  Copyright (c) 2015 kazmi. All rights reserved.
//

import UIKit
import MapKit

class SLMapViewController: UIViewController {
    
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
