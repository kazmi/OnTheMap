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
    var objectID: String? = nil
    var uniqueKey: String? = nil
    var mapString: String? = nil
    var mediaURL: String? = nil
    var latitude: CLLocationDegrees? = nil
    var longitude: CLLocationDegrees? = nil
    var firstName: String? = nil
    var lastName: String? = nil
    
    /* Construct a StudentInformation from a dictionary */
    init(dictionary: [String : AnyObject]) {
        
        if let objectID = dictionary["objectId"] as? String {
            self.objectID = objectID
        }
        
        if let uniqueKey = dictionary["uniqueKey"] as? String {
            self.uniqueKey = uniqueKey
        }
        
        if let firstName = dictionary["firstName"] as? String {
            self.firstName = firstName
        }
        
        if let lastName = dictionary["lastName"] as? String {
            self.lastName = lastName
        }
        
        if let mapString = dictionary["mapString"] as? String {
            self.mapString = mapString
        }
        
        if let mediaURL = dictionary["mediaURL"] as? String {
            self.mediaURL = mediaURL
        }
        
        if let latitude = dictionary["latitude"] as? Double {
            self.latitude = latitude
        }
        
        if let longitude = dictionary["longitude"] as? Double {
            self.longitude = longitude
        }
        
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
