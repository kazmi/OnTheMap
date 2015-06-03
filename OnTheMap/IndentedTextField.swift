//
//  IndentedTextField.swift
//  OnTheMap
//
//  Created by Sulaiman Azhar on 5/31/15.
//  Copyright (c) 2015 kazmi. All rights reserved.
//

import UIKit

extension UITextField {
    @IBInspectable var padding_left: CGFloat {
        get {
            return 0
        }
        set (f) {
            layer.sublayerTransform = CATransform3DMakeTranslation(f, 0, 0)
        }
    }
    
    @IBInspectable var padding_top: CGFloat {
        get {
            return 0
        }
        set (f) {
            layer.sublayerTransform = CATransform3DMakeTranslation(0, f, 0)
        }
    }
}
