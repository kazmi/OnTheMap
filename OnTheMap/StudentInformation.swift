//
//  StudentInformation.swift
//  OnTheMap
//
//  Created by Sulaiman Azhar on 6/1/15.
//  Copyright (c) 2015 kazmi. All rights reserved.
//

import Foundation
import MapKit

struct StudentInformation {
    var firstName: String
    var lastName: String
    var mediaURL: String
    var latitude: CLLocationDegrees
    var longitude: CLLocationDegrees
    
    /* Construct a StudentInformation from a dictionary */
    init(dictionary: [String : AnyObject]) {
        firstName = dictionary["firstName"] as! String
        lastName = dictionary["lastName"] as! String
        mediaURL = dictionary["mediaURL"] as! String
        latitude = CLLocationDegrees(dictionary["latitude"] as! Double)
        longitude = CLLocationDegrees(dictionary["longitude"] as! Double)
        
    }
    
    /* Helper: Given an array of dictionaries, convert them to an array of StudentInformation objects */
    static func studentInformationFromResults(results: [[String : AnyObject]]) -> [StudentInformation] {
        
        var students = [StudentInformation]()
        
        for result in results {
            students.append(StudentInformation(dictionary: result))
        }
        
        return students
    }
}
