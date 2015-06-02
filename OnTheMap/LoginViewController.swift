//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Sulaiman Azhar on 5/31/15.
//  Copyright (c) 2015 kazmi. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var debugLabel: UILabel!
    
    var tapRecognizer: UITapGestureRecognizer? = nil
    
    /* to support smaller resolution devices */
    var keyboardAdjusted = false
    var lastKeyboardOffset: CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let placeHolderTextColor: UIColor = UIColor.whiteColor()
        
        emailTextField.attributedPlaceholder = NSAttributedString(string: "Email",
            attributes: [NSForegroundColorAttributeName:placeHolderTextColor])
        emailTextField.delegate = self
        
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password",
            attributes: [NSForegroundColorAttributeName:placeHolderTextColor])
        passwordTextField.delegate = self
        
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap")
        tapRecognizer?.numberOfTapsRequired = 1
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.addKeyboardDismissRecognizer()
        self.subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeKeyboardDismissRecognizer()
        self.unsubscribeToKeyboardNotifications()
    }
    
    //#MARK:- Login
    
    @IBAction func loginButtonAction(sender: AnyObject) {

        debugLabel.text = ""
        self.view.endEditing(true)
        
        if emailTextField.text.isEmpty {
            debugLabel.text = "Email Empty"
        } else if passwordTextField.text.isEmpty {
            debugLabel.text = "Password Empty"
        } else {
            UdacityClient.sharedInstance().authenticateWithCompletionHandler(
                emailTextField.text, password: passwordTextField.text) { (success, errorString) in
                if success {
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("StudentLocationsTabBar")
                            as! UITabBarController
                        self.presentViewController(controller, animated: true, completion: nil)
                        
                    })
                } else {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.debugLabel.text = errorString
                    })
                }
            }
        }
    }
    
    //#MARK:- Text Field Delegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //#MARK:- Keyboard Fixes & Notifications
    
    func addKeyboardDismissRecognizer() {
        self.view.addGestureRecognizer(tapRecognizer!)
    }
    
    func removeKeyboardDismissRecognizer() {
        self.view.removeGestureRecognizer(tapRecognizer!)
    }
    
    func handleSingleTap() {
        self.view.endEditing(true)
    }
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if keyboardAdjusted == false {
            lastKeyboardOffset = getKeyboardHeight(notification) / 2
            self.view.superview?.frame.origin.y = -lastKeyboardOffset
            keyboardAdjusted = true
        }
    }
    
    func keyboardWillHide() {
        if keyboardAdjusted == true {
            self.view.superview?.frame.origin.y = 0
            keyboardAdjusted = false
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }

}
