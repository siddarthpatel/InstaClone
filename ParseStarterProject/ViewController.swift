/**
* Copyright (c) 2015-present, Parse, LLC.
* All rights reserved.
*
* This source code is licensed under the BSD-style license found in the
* LICENSE file in the root directory of this source tree. An additional grant
* of patent rights can be found in the PATENTS file in the same directory.
*/

import UIKit
import Parse

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate{
    
    var signupActive = true
    
    var flag: Int = 1
    
    @IBOutlet var mainTitle: UILabel!
    
    @IBOutlet var subTitle: UILabel!
    
    @IBOutlet var username: UITextField!
    
    @IBOutlet var password: UITextField!
    
    @IBOutlet var signupButton: UIButton!
    
    @IBOutlet var registeredLabel: UILabel!
    
    @IBOutlet var loginButton: UIButton!
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    func displayAlert(title: String, message: String){
        if #available(iOS 8.0, *) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
            }))
            self.presentViewController(alert, animated: true, completion: nil)
    
            } else {
                print("Error creating an alert message!")
            }
            self.view.backgroundColor = UIColor.yellowColor()
    }
    
    @IBAction func signUp(sender: AnyObject) {
        var errorMessage = "Please try again later"
        if username.text == "" || password.text == ""{
            
            displayAlert("Error", message: "Please enter a username and password")
        
        } else {
              self.view.backgroundColor = UIColor.lightGrayColor()
              activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0,0,50,50))
              activityIndicator.center = self.view.center
              activityIndicator.hidesWhenStopped = true
              activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
              view.addSubview(activityIndicator)
              activityIndicator.startAnimating()
              UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            
            if signupActive == true{
              var user = PFUser()
              user.username = username.text
              user.password = password.text
              
              user.signUpInBackgroundWithBlock({ (success, error) -> Void in
                
                self.activityIndicator.stopAnimating()
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                
                if error == nil {
                    // signUp success
                    self.performSegueWithIdentifier("login", sender: self)
                
                }else{
                    
                    if let errorString = error!.userInfo["error"] as? String{
                        errorMessage = errorString
                    }
                    self.displayAlert("Failed SignUp", message: errorMessage)
                    
                }
                
              })
            }
            
            else{
            
                PFUser.logInWithUsernameInBackground(username.text!, password: password.text!, block: { (user, error) -> Void in
                    
                    self.activityIndicator.stopAnimating()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    
                    if user != nil{
                       //logged in
                        self.performSegueWithIdentifier("login", sender: self)
                    }
                    else{
                        
                        if let errorString = error!.userInfo["error"] as? String{
                            errorMessage = errorString
                        }
                        self.displayAlert("Failed Login", message: errorMessage)
                        //self.view.backgroundColor = UIColor.yellowColor()
                    }
                })
            
            
            
            
            }
            
            
            
         }
     }
    
    @IBAction func login(sender: AnyObject) {
        
        if signupActive == true{
            
            signupButton.setTitle("Login", forState: UIControlState.Normal)
            
            registeredLabel.text = "Not registered?"
            
            loginButton.setTitle("Sign Up", forState: UIControlState.Normal)
            
            signupActive = false
        } else {
        
            signupButton.setTitle("Sign Up", forState: UIControlState.Normal)
            
            registeredLabel.text = "Already a member?"
            
            loginButton.setTitle("Login", forState: UIControlState.Normal)
            
            signupActive = true
        
         }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.yellowColor()
        self.username.delegate = self
        self.password.delegate = self
       
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField : UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    override func viewDidLayoutSubviews() {
        
        if flag == 1{
            //mainTitle.center = CGPointMake(mainTitle.center.x , mainTitle.center.y - 3200)
       
            subTitle.alpha = 0
            username.alpha = 0
            password.alpha = 0
            signupButton.alpha = 0
            registeredLabel.alpha = 0
            loginButton.alpha = 0
        }
      
    }
    
    override func viewDidAppear(animated: Bool) {
        
        /*UIView.animateWithDuration(1) { () -> Void in
            
            self.mainTitle.center = CGPointMake(self.mainTitle.center.x , self.mainTitle.center.y + 3200)
            //self.mainTitle.alpha = 1
        }*/
        UIView.animateWithDuration(7) { () -> Void in
                
                self.subTitle.alpha = 1
                self.username.alpha = 1
                self.password.alpha = 1
                self.signupButton.alpha = 1
                self.registeredLabel.alpha = 1
                self.loginButton.alpha = 1
                
        }
        flag = flag + 1
        
        if PFUser.currentUser() != nil {
        
            self.performSegueWithIdentifier("login", sender: self)
            
        }
        if colorFlag == true{
            self.view.backgroundColor = UIColor.yellowColor()
        
        }
       

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
