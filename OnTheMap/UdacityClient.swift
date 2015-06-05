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
    
    var uniqueKey: String?
    var name: String?
    
    class func sharedInstance() -> UdacityClient {
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        
        return Singleton.sharedInstance
    }
    
    func authenticateWithCompletionHandler(email: String, password: String, completionHandler: (success: Bool, errorString: String?) -> Void) {
    
        self.getAccountKey(email, password: password) { (success, uniqueKey, errorString) in
            
            if success {
                
                self.uniqueKey = uniqueKey
                
                self.getCurrentStudentName() { (success, name, errorString) in
                    
                    self.name = name
                
                    completionHandler(success: success, errorString: errorString)

                }
                
            } else {
                completionHandler(success: success, errorString: errorString)
            }
        }
        
        
    }
    
    func authenticateWithCompletionHandler(token: String, completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        self.getAccountKey(token) { (success, uniqueKey, errorString) in
            
            if success {
                
                self.uniqueKey = uniqueKey
                
                self.getCurrentStudentName() { (success, name, errorString) in
                    
                    self.name = name
                    
                    completionHandler(success: success, errorString: errorString)
                    
                }
                
            } else {
                completionHandler(success: success, errorString: errorString)
            }
        }

    }
    
    func logoutWithCompletionHandler(completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        /* log out from facebook */
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
        let task = session.dataTaskWithRequest(request) { data, response, downloadError in
            
            if downloadError != nil {
                completionHandler(success: false, errorString: downloadError.description)
            }
            
            completionHandler(success: true, errorString: nil)
        }
        
        /* Start the request */
        task.resume()
    }
    
    // MARK: - Udacity API
    
    func getCurrentStudentName(completionHandler: (success: Bool, name: String?, errorString: String?) -> Void) {
        
        /* Build the URL */
        let urlString = "https://www.udacity.com/api/users/\(self.uniqueKey!)"
        let url = NSURL(string: urlString)!
        
        /* Configure the request */
        let request = NSMutableURLRequest(URL: url)
        
        /* Make the request */
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                completionHandler(success: false, name: nil, errorString: "Request Timed Out")
            }
            
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
            
            /* Parse the data */
            var parsingError: NSError? = nil
            let parsedJSON = NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments,
                error: &parsingError) as! NSDictionary
            
            if let user = parsedJSON["user"] as? NSDictionary {
                
                var firstName = user["first_name"] as? String
                var lastName = user["last_name"] as? String
                var name = firstName! + " " + lastName!
                
                completionHandler(success: true, name: name, errorString: nil)
            } else {
                
                completionHandler(success: false, name: nil, errorString: "Account not found")
            }
            
        }
        
        /* Start the request */
        task.resume()
        
    }
    
    func getAccountKey(token: String, completionHandler: (success: Bool, uniqueKey: String?, errorString: String?) -> Void) {
        
        /* Build the URL */
        let urlString = "https://www.udacity.com/api/session"
        let url = NSURL(string: urlString)!
        
        /* Configure the request */
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var jsonifyError: NSError? = nil
        let jsonBody : [String:AnyObject] = ["facebook_mobile": ["access_token": token]]
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(jsonBody, options: nil, error: &jsonifyError)
        
        /* Make the request */
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, respose, downloadError in
            
            if let error = downloadError {
                completionHandler(success: false, uniqueKey: nil, errorString: "Request Timed Out")
            } else {
                
                let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
                
                /* Parse the data */
                var parsingError: NSError? = nil
                let parsedJSON = NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments,
                    error: &parsingError) as! NSDictionary
                
                if let account = parsedJSON["account"] as? NSDictionary {
                    var key = account.valueForKey("key") as? String
                    completionHandler(success: true, uniqueKey: key, errorString: nil)
                } else {
                    if let status = parsedJSON["status"] as? Int {
                        if status == 403 {
                            completionHandler(success: false, uniqueKey: nil, errorString: "Invalid Credentials")
                        }
                    }
                }
            }
        }
        
        /* Start the request */
        task.resume()
        
    }
    
    func getAccountKey(email: String, password: String, completionHandler: (success: Bool, uniqueKey: String?, errorString: String?) -> Void) {
        
        /* Build the URL */
        let urlString = "https://www.udacity.com/api/session"
        let url = NSURL(string: urlString)!
        
        /* Configure the request */
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var jsonifyError: NSError? = nil
        let jsonBody : [String:AnyObject] = ["udacity": ["username": email, "password": password]]
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(jsonBody, options: nil, error: &jsonifyError)
        
        /* Make the request */
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, respose, downloadError in
            
            if let error = downloadError {
                completionHandler(success: false, uniqueKey: nil, errorString: "Request Timed Out")
            } else {
                
                let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
                
                /* Parse the data */
                var parsingError: NSError? = nil
                let parsedJSON = NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments,
                    error: &parsingError) as! NSDictionary
                
                if let account = parsedJSON["account"] as? NSDictionary {
                    var key = account.valueForKey("key") as? String
                    completionHandler(success: true, uniqueKey: key, errorString: nil)
                } else {
                    if let status = parsedJSON["status"] as? Int {
                        if status == 403 {
                            completionHandler(success: false, uniqueKey: nil, errorString: "Invalid Credentials")
                        }
                    }
                }
            }
        }
        
        /* Start the request */
        task.resume()
        
    }
    
    // MARK: - Parse API
    
    func getStudentInformation(completionHandler: (result: [StudentInformation]?, error: NSError?) -> Void) {
        
        /* Build the URL */
        let urlString = "https://api.parse.com/1/classes/StudentLocation"
        let url = NSURL(string: urlString)!
        
        /* Configure the request */
        let request = NSMutableURLRequest(URL: url)
        request.addValue("ENTER_APP_ID_HERE", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("ENTER_REST_API_KEY_HERE", forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        /* Make the request */
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, downloadError in
            
            if downloadError != nil {
                completionHandler(result: nil, error: downloadError)
            }
            
            /* Parse the data */
            var parsingError: NSError? = nil
            let parsedJSON = NSJSONSerialization.JSONObjectWithData(data,
                options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
            
            /* Use the data */
            if let results = parsedJSON.valueForKey("results") as? [[String : AnyObject]] {
                var students = StudentInformation.studentInformationFromResults(results)
                completionHandler(result: students, error: nil)
            } else {
                completionHandler(result: nil, error: NSError(domain: "student information parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getStudentInformation"]))
            }
            
        }
        
        /* Start the request */
        task.resume()
        
    }
    
}
