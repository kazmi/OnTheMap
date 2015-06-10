//
//  Constants.swift
//  OnTheMap
//
//  Created by Sulaiman Azhar on 6/10/15.
//  Copyright (c) 2015 kazmi. All rights reserved.
//

import Foundation

extension UdacityClient {
    
    // MARK: - Constants
    struct Constants {
        
        static let AppID: String = "ENTER_APP_ID_HERE"
        static let RESTApiKey : String = "ENTER_REST_API_KEY_HERE"
        
    }
    
    // MARK: - Parameter Keys
    struct ParameterKeys {
        
        static let Limit = "limit"
        static let Skip = "skip"
        static let Order = "order"
        static let Where = "where"
        
    }
    
    // MARK: - JSON Body Keys
    struct JSONBodyKeys {
        
        static let FacebookMobile = "facebook_mobile"
        static let AccessToken = "access_token"
        
        static let Udacity = "udacity"
        static let UserName = "username"
        static let Password = "password"
        
        static let UniqueKey = "uniqueKey"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let MapString = "mapString"
        static let MediaURL = "mediaURL"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        
    }
    
    // MARK: - JSON Response Keys
    struct JSONResponseKeys {
        
        static let User = "user"
        static let FirstName = "first_name"
        static let LastName = "last_name"
        static let Account = "account"
        static let Key = "key"
        static let Status = "status"
        static let Results = "results"
        static let ObjectID = "objectId"
        static let UpdatedAt = "updatedAt"
        
    }

    
}