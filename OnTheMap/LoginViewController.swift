//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Sulaiman Azhar on 5/31/15.
//  Copyright (c) 2015 kazmi. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class LoginViewController: UIViewController, UITextFieldDelegate, FBSDKLoginButtonDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var logginButton: UIButton!
    @IBOutlet weak var facebookLoginButton: FBSDKLoginButton!
    @IBOutlet weak var debugLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIImageView!
    
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var errorViewTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var retryButton: UIButton!
    
    var tapRecognizer: UITapGestureRecognizer? = nil
    
    /* to support smaller resolution devices */
    var keyboardAdjusted = false
    var lastKeyboardOffset: CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        errorViewTopConstraint.constant += errorView.frame.size.height
        
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
        
        self.view.endEditing(true)
        
        if emailTextField.text.isEmpty {
            self.showErrorView("Client Error: Email Empty")
        } else if passwordTextField.text.isEmpty {
            self.showErrorView("Client Error: Password Empty")
        } else {
            
            startLoginAnimation()
            
            UdacityClient.sharedInstance().authenticateWithCompletionHandler(
                emailTextField.text, password: passwordTextField.text) { (success, errorString) in
                    
                dispatch_async(dispatch_get_main_queue(), {
                    self.stopLoginAnimation()
                })

                if success {
                    self.completeLogin()
                } else {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.showErrorView(errorString!)
                    })
                }
            }
        }
    }
    
    //#MARK: Facebook Login
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {

        if((FBSDKAccessToken.currentAccessToken()) != nil) {
            
            dispatch_async(dispatch_get_main_queue(), {
                self.startLoginAnimation()
            })
            
            let token = FBSDKAccessToken.currentAccessToken().tokenString
            
            UdacityClient.sharedInstance().authenticateWithCompletionHandler(token) { (success, errorString ) in
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.stopLoginAnimation()
                })
                
                if success {
                    self.completeLogin()
                } else {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.showErrorView(errorString!)
                    })
                }
            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        
    }
    
    func completeLogin() {
        dispatch_async(dispatch_get_main_queue(), {
            
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("StudentLocationsTabBar")
                as! UITabBarController
            self.presentViewController(controller, animated: true, completion: nil)
            
        })
    }
    
    func startLoginAnimation() {
        
        UIView.animateWithDuration(1.0, animations: {
            self.emailTextField.alpha = 0.5
            self.passwordTextField.alpha = 0.5
            self.logginButton.alpha = 0.5
        })
        
        self.logginButton.enabled = false
        self.facebookLoginButton.enabled = false
        activityIndicator.hidden = false
        
        // The full rotation animation was implemented after following
        // this http://mathewsanders.com/animations-in-swift-part-two/
        
        UIView.animateKeyframesWithDuration(5.0, delay: 0.0,
            options: UIViewKeyframeAnimationOptions.Repeat, animations: {
                
                let fullRotation = CGFloat(M_PI * 2)
                
                UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 1/3, animations: {
                    self.activityIndicator.transform = CGAffineTransformMakeRotation(1/3 * fullRotation)
                })
                UIView.addKeyframeWithRelativeStartTime(1/3, relativeDuration: 1/3, animations: {
                    self.activityIndicator.transform = CGAffineTransformMakeRotation(2/3 * fullRotation)
                })
                UIView.addKeyframeWithRelativeStartTime(2/3, relativeDuration: 1/3, animations: {
                    self.activityIndicator.transform = CGAffineTransformMakeRotation(3/3 * fullRotation)
                })
                
            }, completion: nil)
        
    }
    
    func stopLoginAnimation() {
        
        UIView.animateWithDuration(1.0, animations: {
            self.emailTextField.alpha = 1.0
            self.passwordTextField.alpha = 1.0
            self.logginButton.alpha = 1.0
        })
        
        self.activityIndicator.hidden = true
        self.logginButton.enabled = true
        self.facebookLoginButton.enabled = true
        
    }

    //#MARK:- Error View
    
    func showErrorView(errorString: String, showRetry: Bool = false) {
        
        errorMessageLabel.text = errorString
        retryButton.hidden = !showRetry
        
        self.errorViewTopConstraint.constant = 8
        self.errorView.setNeedsUpdateConstraints()
        
        UIView.animateWithDuration(1.0,
            delay: 0.0, usingSpringWithDamping: 0.5,
            initialSpringVelocity: 1.0,
            options: UIViewAnimationOptions.CurveEaseInOut,
            animations: {
                self.errorView.layoutIfNeeded()
            },
            completion: nil)

    }
    
    @IBAction func okButton(sender: AnyObject) {
        
        self.errorViewTopConstraint.constant += errorView.frame.size.height
        self.errorView.setNeedsUpdateConstraints()
        
        UIView.animateWithDuration(1.0, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.errorView.layoutIfNeeded()
            }, completion: nil)
    }
    
    //#MARK:- Sign Up
    
    @IBAction func signupButtonAction(sender: AnyObject) {
        let app = UIApplication.sharedApplication()
        app.openURL(NSURL(string: "https://www.udacity.com/account/auth#!/signin")!)
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
