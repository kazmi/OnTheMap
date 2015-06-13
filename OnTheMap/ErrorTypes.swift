//
//  ErrorTypes.swift
//  OnTheMap
//
//  Created by Sulaiman Azhar on 6/13/15.
//  Copyright (c) 2015 kazmi. All rights reserved.
//

import Foundation

enum ErrorTypes: Int {
    
    case Client  = 0
    case Network = 1
    case Server  = 2
    
    static func localizedDescription(errorType: ErrorTypes) -> String {
        
        switch errorType {
        case .Client:
            return "Client Error"
        case .Network:
            return "Network Error"
        case .Server:
            return "Server Error"
        default:
            return "Unknown Error"
        }
        
    }
}
