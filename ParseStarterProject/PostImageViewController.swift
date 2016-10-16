//
//  PostImageViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Siddarth Patel on 7/6/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class PostImageViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {
    
    var activityIndicator = UIActivityIndicatorView()

    @IBOutlet var imageToPost: UIImageView!
    
    @IBOutlet var message: UITextField!
    
    var isPosted = false
    
    func displayAlert(title: String, message: String){
        if #available(iOS 8.0, *) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
          
            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alert.addAction(defaultAction)
            presentViewController(alert,animated: true, completion: nil)
            /*alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
            }))
            presentViewController(alert, animated: true, completion: nil)*/
            
        } else {
            print("Error creating an alert message!")
        }
    }
    
    @IBAction func addImage(sender: AnyObject) {
        var image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        image.allowsEditing = false
        
        self.presentViewController(image, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.dismissViewControllerAnimated(true, completion: nil)
        imageToPost.image = image
        isPosted = true
    }
    
    @IBAction func shareImage(sender: AnyObject) {
        
        if isPosted == true{
            isPosted = false
            var errorMessage = "Please try again later"
            activityIndicator = UIActivityIndicatorView(frame: self.view.frame)
            activityIndicator.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            
            var post = PFObject(className: "Post")
            
            post["message"] = message.text
            
            post["userId"] = PFUser.currentUser()?.objectId
            
            let imageData = UIImageJPEGRepresentation(imageToPost.image!,1.0)
            
            let imageFile = PFFile(name: "image.png", data: imageData!)
            
            post["imageFile"] = imageFile
            
            post.saveInBackgroundWithBlock { (success, error) -> Void in
                
                self.activityIndicator.stopAnimating()
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                
                if error == nil{
                    
                    print("image posted on parse")
                    self.imageToPost.image = UIImage(named: "MAN BLANK.jpg")
                    self.message.text = ""
                    self.displayAlert("Image Posted!", message: "Image has been posted")
                }
                else{
                    
                    if let errorString = error!.userInfo["error"] as? String{
                        errorMessage = errorString
                    }
                    self.displayAlert("Failed posting image", message: errorMessage)
                    
                }
            }
        } else{
            
            self.displayAlert("Failed posting image", message: "Please select an image")
        
        }
        
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.lightGrayColor()
        self.message.delegate = self

        // Do any additional setup after loading the view.
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
  
    func textFieldShouldReturn(textField : UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
