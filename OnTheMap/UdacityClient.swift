//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Sulaiman Azhar on 5/31/15.
//  Copyright (c) 2015 kazmi. All rights reserved.
//

import Foundation
import FBSDKLoginKit


class UdacityClient {
    
    var currentStudent: StudentInformation? = nil
    
    class func sharedInstance() -> UdacityClient {
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        
        return Singleton.sharedInstance
    }
    
    func authenticateWithCompletionHandler(email: String, password: String, completionHandler: (success: Bool, error: NSError?) -> Void) {
    
        self.getAccountKey(email, password: password) { (success, uniqueKey, error) in
            
            if success {
                
                if (self.currentStudent == nil) { self.currentStudent = StudentInformation() }
                
                self.currentStudent?.uniqueKey = uniqueKey
                
                self.getCurrentStudentName() { (success, firstName, lastName, error) in
                    
                    if success {
                        
                        self.currentStudent?.firstName = firstName
                        
                        self.currentStudent?.lastName = lastName
                        
                        self.getCurrentStudentInformation() { (student, error) in
                            
                            if error == nil {
                                
                                self.currentStudent = student
                                
                                completionHandler(success: true, error: nil)
                                
                            } else {
                                
                                completionHandler(success: false, error: error)
                            }
                            
                        }

                    } else {
                        completionHandler(success: success, error: error)
                    }

                }
                
            } else {
                completionHandler(success: success, error: error)
            }
        }
        
        
    }
    
    func authenticateWithCompletionHandler(token: String, completionHandler: (success: Bool, error: NSError?) -> Void) {
        
        self.getAccountKey(token) { (success, uniqueKey, error) in
            
            if success {
                
                if (self.currentStudent == nil) { self.currentStudent = StudentInformation() }
                
                self.currentStudent?.uniqueKey = uniqueKey
                
                self.getCurrentStudentName() { (success, firstName, lastName, error) in
                    
                    if success {
                        
                        self.currentStudent?.firstName = firstName
                        
                        self.currentStudent?.lastName = lastName
                        
                        self.getCurrentStudentInformation() { (student, error) in
                            
                            if error == nil {
                                
                                self.currentStudent = student
                                
                                completionHandler(success: true, error: nil)
                                
                            } else {
                                
                                completionHandler(success: false, error: error)
                            }
                            
                        }
                        
                    } else {
                        completionHandler(success: success, error: error)
                    }
                    
                }
                
            } else {
                completionHandler(success: success, error: error)
            }
        }

    }
    
    func logoutWithCompletionHandler(completionHandler: (success: Bool, error: NSError?) -> Void) {
        
        /* log out from facebook */
        var facebookSession = FBSDKLoginManager()
        facebookSession.logOut()
        FBSDKAccessToken.setCurrentAccessToken(nil)
        
        /* Build the URL */
        let urlString = "https://www.udacity.com/api/session"
        let url = NSURL(string: urlString)!
        
        /* Configure the request */
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "DELETE"
        
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies as! [NSHTTPCookie] {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.addValue(xsrfCookie.value!, forHTTPHeaderField: "X-XSRF-Token")
        }
        
        /* Make the request */
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            if error != nil {
                
                let userInfo: NSDictionary = [
                    NSLocalizedDescriptionKey: error.localizedDescription]
                
                var errorObject = NSError(domain: Error.Domain, code: ErrorTypes.Network.rawValue,
                    userInfo: userInfo as [NSObject : AnyObject])
                
                completionHandler(success: false, error: errorObject)
                
            }
            else {

                /* clear current student */
                self.currentStudent = nil
            
                completionHandler(success: true, error: nil)
            }
        }
        
        /* Start the request */
        task.resume()
    }
    
    // MARK: - Udacity API
    
    func getCurrentStudentName(completionHandler: (success: Bool, firstName: String?, lastName: String?, error: NSError?) -> Void) {
        
        /* Build the URL */
        let urlString = "https://www.udacity.com/api/users/\(self.currentStudent!.uniqueKey!)"
        let url = NSURL(string: urlString)!
        
        /* Configure the request */
        let request = NSMutableURLRequest(URL: url)
        
        /* Make the request */
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                
                let userInfo: NSDictionary = [
                    NSLocalizedDescriptionKey: error.localizedDescription]
                
                var errorObject = NSError(domain: Error.Domain, code: ErrorTypes.Network.rawValue,
                    userInfo: userInfo as [NSObject : AnyObject])
                
                completionHandler(success: false, firstName: nil, lastName: nil, error: errorObject)
                
            }
            else {
                let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
            
                /* Parse the data */
                var parsingError: NSError? = nil
                let parsedJSON = NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments,
                    error: &parsingError) as! NSDictionary
            
                if let user = parsedJSON[JSONResponseKeys.User] as? NSDictionary {
                
                    var firstName = user[JSONResponseKeys.FirstName] as? String
                    var lastName = user[JSONResponseKeys.LastName] as? String
                
                    completionHandler(success: true, firstName: firstName, lastName: lastName, error: nil)
                } else {
                
                    let userInfo: NSDictionary = [
                        NSLocalizedDescriptionKey: "Account not found"]
                    
                    var errorObject = NSError(domain: Error.Domain, code: ErrorTypes.Server.rawValue,
                        userInfo: userInfo as [NSObject : AnyObject])
                    
                    completionHandler(success: false, firstName: nil, lastName: nil, error: errorObject)

                }
            }
            
        }
        
        /* Start the request */
        task.resume()
        
    }
    
    func getAccountKey(token: String, completionHandler: (success: Bool, uniqueKey: String?, error: NSError?) -> Void) {
        
        /* Build the URL */
        let urlString = "https://www.udacity.com/api/session"
        let url = NSURL(string: urlString)!
        
        /* Configure the request */
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var jsonifyError: NSError? = nil
        let jsonBody : [String:AnyObject] = [JSONBodyKeys.FacebookMobile: [JSONBodyKeys.AccessToken: token]]
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(jsonBody, options: nil, error: &jsonifyError)
        
        /* Make the request */
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, respose, error in
            
            if error != nil {
                
                let userInfo: NSDictionary = [
                    NSLocalizedDescriptionKey: error.localizedDescription]
                
                var errorObject = NSError(domain: Error.Domain, code: ErrorTypes.Network.rawValue,
                    userInfo: userInfo as [NSObject : AnyObject])
                
                completionHandler(success: false, uniqueKey: nil, error: errorObject)
                
            } else {
                
                let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
                
                /* Parse the data */
                var parsingError: NSError? = nil
                let parsedJSON = NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments,
                    error: &parsingError) as! NSDictionary
                
                if let account = parsedJSON[JSONResponseKeys.Account] as? NSDictionary {
                    var key = account.valueForKey(JSONResponseKeys.Key) as? String
                    completionHandler(success: true, uniqueKey: key, error: nil)
                } else {
                    if let status = parsedJSON[JSONResponseKeys.Status] as? Int {
                        if status == 403 {
                            let userInfo: NSDictionary = [
                                NSLocalizedDescriptionKey: "Invalid Credentials"]
                            
                            var errorObject = NSError(domain: Error.Domain, code: ErrorTypes.Server.rawValue,
                                userInfo: userInfo as [NSObject : AnyObject])
                            
                            completionHandler(success: false, uniqueKey: nil, error: errorObject)
                        }
                    }
                }
            }
        }
        
        /* Start the request */
        task.resume()
        
    }
    
    func getAccountKey(email: String, password: String, completionHandler: (success: Bool, uniqueKey: String?, error: NSError?) -> Void) {
        
        /* Build the URL */
        let urlString = "https://www.udacity.com/api/session"
        let url = NSURL(string: urlString)!
        
        /* Configure the request */
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var jsonifyError: NSError? = nil
        let jsonBody : [String:AnyObject] = [JSONBodyKeys.Udacity: [JSONBodyKeys.UserName: email, JSONBodyKeys.Password: password]]
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(jsonBody, options: nil, error: &jsonifyError)
        
        /* Make the request */
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, respose, error in
            
            if error != nil {
                let userInfo: NSDictionary = [
                    NSLocalizedDescriptionKey: error.localizedDescription]
                
                var errorObject = NSError(domain: Error.Domain, code: ErrorTypes.Network.rawValue,
                    userInfo: userInfo as [NSObject : AnyObject])

                completionHandler(success: false, uniqueKey: nil, error: errorObject)
            } else {
                
                let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
                
                /* Parse the data */
                var parsingError: NSError? = nil
                let parsedJSON = NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments,
                    error: &parsingError) as! NSDictionary
                
                if let account = parsedJSON[JSONResponseKeys.Account] as? NSDictionary {
                    var key = account.valueForKey(JSONResponseKeys.Key) as? String
                    completionHandler(success: true, uniqueKey: key, error: nil)
                } else {
                    if let status = parsedJSON[JSONResponseKeys.Status] as? Int {
                        
                        if status == 403 {
                            let userInfo: NSDictionary = [
                                NSLocalizedDescriptionKey: "Invalid Credentials"]
                            
                            var errorObject = NSError(domain: Error.Domain, code: ErrorTypes.Server.rawValue,
                                userInfo: userInfo as [NSObject : AnyObject])
                            
                            completionHandler(success: false, uniqueKey: nil, error: errorObject)
                        }
                        
                    }
                }
            }
        }
        
        /* Start the request */
        task.resume()
        
    }
    
    // MARK: - Parse API
    
    func getStudentInformation(skip: Int = 0, completionHandler: (result: [StudentInformation]?, error: NSError?) -> Void) {
        
        /* Parameters */
        let methodParameters = [
            ParameterKeys.Limit: "100",
            ParameterKeys.Skip: "\(skip)",
            ParameterKeys.Order: "-updatedAt"
        ]
        
        /* Build the URL */
        let urlString = "https://api.parse.com/1/classes/StudentLocation" + UdacityClient.escapedParameters(methodParameters)
        let url = NSURL(string: urlString)!
        
        /* Configure the request */
        let request = NSMutableURLRequest(URL: url)
        request.addValue(Constants.AppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.RESTApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        /* Make the request */
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            if error != nil {
                
                let userInfo: NSDictionary = [
                    NSLocalizedDescriptionKey: error.localizedDescription]
                
                var errorObject = NSError(domain: Error.Domain, code: ErrorTypes.Network.rawValue,
                    userInfo: userInfo as [NSObject : AnyObject])
                
                completionHandler(result: nil, error: errorObject)
                
            }
            else {
                
                /* Parse the data */
                var parsingError: NSError? = nil
                let parsedJSON = NSJSONSerialization.JSONObjectWithData(data,
                    options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
                
                /* Use the data */
                if let results = parsedJSON.valueForKey(JSONResponseKeys.Results) as? [[String : AnyObject]] {
                    var students = StudentInformation.studentInformationFromResults(results)
                    completionHandler(result: students, error: nil)
                } else {
                    let userInfo: NSDictionary = [
                        NSLocalizedDescriptionKey: "No students exist"]
                    
                    var errorObject = NSError(domain: Error.Domain, code: ErrorTypes.Server.rawValue,
                        userInfo: userInfo as [NSObject : AnyObject])
                    
                    completionHandler(result: nil, error: errorObject)
                }
            }
        }
        
        /* Start the request */
        task.resume()
        
    }
    
    func getCurrentStudentInformation(completionHandler: (result: StudentInformation?, error: NSError?) -> Void) {
        
        /* Parameters */
        let methodParameters = [
            ParameterKeys.Where: "{\"uniqueKey\":\"\(self.currentStudent!.uniqueKey!)\"}"
        ]
        
        /* Build the URL */
        let urlString = "https://api.parse.com/1/classes/StudentLocation" + UdacityClient.escapedParameters(methodParameters)
        let url = NSURL(string: urlString)!
        
        /* Configure the request */
        let request = NSMutableURLRequest(URL: url)
        request.addValue(Constants.AppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.RESTApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        /* Make the request */
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            
            if error != nil {
                let userInfo: NSDictionary = [
                    NSLocalizedDescriptionKey: error.localizedDescription]
                
                var errorObject = NSError(domain: Error.Domain, code: ErrorTypes.Network.rawValue,
                    userInfo: userInfo as [NSObject : AnyObject])
                
                completionHandler(result: nil, error: errorObject)
            }
            else {
            
                /* Parse the data */
                var parsingError: NSError? = nil
                let parsedJSON = NSJSONSerialization.JSONObjectWithData(data,
                    options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
            
                /* Use the data */
                if let results = parsedJSON.valueForKey(JSONResponseKeys.Results) as? [[String : AnyObject]] {
                    if results.count > 0 {
                        var student = StudentInformation(dictionary: results[0])
                        completionHandler(result: student, error: nil)
                    }
                    else {
                        
                        let userInfo: NSDictionary = [
                            NSLocalizedDescriptionKey: "Student does not exist"]
                        
                        var errorObject = NSError(domain: Error.Domain, code: ErrorTypes.Server.rawValue,
                            userInfo: userInfo as [NSObject : AnyObject])
                        
                        completionHandler(result: nil, error: errorObject)
                        
                    }
                } else {
                    
                    let userInfo: NSDictionary = [
                        NSLocalizedDescriptionKey: "Could not parse Student information"]
                    
                    var errorObject = NSError(domain: Error.Domain, code: ErrorTypes.Server.rawValue,
                        userInfo: userInfo as [NSObject : AnyObject])
                    
                    completionHandler(result: nil, error: errorObject)

                }
            }
            
        }
        
        /* Start the request */
        task.resume()
        
    }
    
    func postStudentInformation(student: StudentInformation, completionHandler: (success: Bool, objectID: String?, error: NSError?) -> Void) {
        
        /* Build the URL */
        let urlString = "https://api.parse.com/1/classes/StudentLocation"
        let url = NSURL(string: urlString)!
        
        /* Configure the request */
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue(Constants.AppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.RESTApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var jsonifyError: NSError? = nil
        let jsonBody : [String:AnyObject] =
        [
            JSONBodyKeys.UniqueKey: student.uniqueKey!,
            JSONBodyKeys.FirstName: student.firstName!,
            JSONBodyKeys.LastName: student.lastName!,
            JSONBodyKeys.MapString: student.mapString!,
            JSONBodyKeys.MediaURL: student.mediaURL!,
            JSONBodyKeys.Latitude: student.latitude!,
            JSONBodyKeys.Longitude: student.longitude!
        ]
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(jsonBody, options: nil, error: &jsonifyError)
        
        /* Make the request */
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                
                let userInfo: NSDictionary = [
                    NSLocalizedDescriptionKey: error.localizedDescription]
                
                var errorObject = NSError(domain: Error.Domain, code: ErrorTypes.Network.rawValue,
                    userInfo: userInfo as [NSObject : AnyObject])
                
                completionHandler(success: false, objectID: nil, error: errorObject)
                
            }
            else {
                /* Parse the data */
                var parsingError: NSError? = nil
                let parsedJSON = NSJSONSerialization.JSONObjectWithData(data,
                    options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
            
                /* Use the data */
                if let objectID = parsedJSON.valueForKey(JSONResponseKeys.ObjectID) as? String {
                    completionHandler(success: true, objectID: objectID, error: nil)
                } else {
                    
                    let userInfo: NSDictionary = [
                        NSLocalizedDescriptionKey: "StudentLocation not created"]
                    
                    var errorObject = NSError(domain: Error.Domain, code: ErrorTypes.Server.rawValue,
                        userInfo: userInfo as [NSObject : AnyObject])
                    
                    completionHandler(success: false, objectID: nil, error: errorObject)
                }
            }
        }
        
        /* Start the request */
        task.resume()
        
    }
    
    func putStudentInformation(student: StudentInformation, completionHandler: (success: Bool, error: NSError?) -> Void) {
        
        /* Build the URL */
        var objectID = student.objectID!
        let urlString = "https://api.parse.com/1/classes/StudentLocation/\(objectID)"
        let url = NSURL(string: urlString)!
        
        /* Configure the request */
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "PUT"
        request.addValue(Constants.AppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.RESTApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var jsonifyError: NSError? = nil
        let jsonBody : [String:AnyObject] =
        [
            JSONBodyKeys.UniqueKey: student.uniqueKey!,
            JSONBodyKeys.FirstName: student.firstName!,
            JSONBodyKeys.LastName: student.lastName!,
            JSONBodyKeys.MapString: student.mapString!,
            JSONBodyKeys.MediaURL: student.mediaURL!,
            JSONBodyKeys.Latitude: student.latitude!,
            JSONBodyKeys.Longitude: student.longitude!
        ]
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(jsonBody, options: nil, error: &jsonifyError)
        
        /* Make the request */
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                
                let userInfo: NSDictionary = [
                    NSLocalizedDescriptionKey: error.localizedDescription]
                
                var errorObject = NSError(domain: Error.Domain, code: ErrorTypes.Network.rawValue,
                    userInfo: userInfo as [NSObject : AnyObject])
                
                completionHandler(success: false, error: errorObject)
            }
            else {
                /* Parse the data */
                var parsingError: NSError? = nil
                let parsedJSON = NSJSONSerialization.JSONObjectWithData(data,
                    options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
            
                /* Use the data */
                if let createdAt = parsedJSON.valueForKey(JSONResponseKeys.UpdatedAt) as? String {
                    completionHandler(success: true, error: nil)
                } else {
                    
                    let userInfo: NSDictionary = [
                        NSLocalizedDescriptionKey: "StudentLocation not updated"]
                    
                    var errorObject = NSError(domain: Error.Domain, code: ErrorTypes.Server.rawValue,
                        userInfo: userInfo as [NSObject : AnyObject])
                    
                    completionHandler(success: false, error: errorObject)
                }
            }
        }
        
        /* Start the request */
        task.resume()

    }
    
    // MARK: - Helper Methods
    
    /* convert a dictionary of parameters to a string for a url */
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + join("&", urlVars)
    }
    
}
