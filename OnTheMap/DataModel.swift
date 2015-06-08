//
//  DataModel.swift
//  OnTheMap
//
//  Created by Sulaiman Azhar on 6/9/15.
//  Copyright (c) 2015 kazmi. All rights reserved.
//

import Foundation

class DataModel {
    
    var students: [StudentInformation] = [StudentInformation]()
    
    class func sharedInstance() -> DataModel {
        struct Singleton {
            static var sharedInstance = DataModel()
        }
        
        return Singleton.sharedInstance
    }

}
