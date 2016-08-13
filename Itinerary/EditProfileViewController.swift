//
//  EditProfileViewController.swift
//  Itinerary
//
//  Created by Daniel Ku on 8/4/16.
//  Copyright © 2016 djku. All rights reserved.
//

import UIKit
import Firebase

class EditProfileViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    //@IBOutlet weak var currentPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var confirmNewPasswordTextField: UITextField!

    let ref = FIRDatabase.database().reference()
    let user = FIRAuth.auth()?.currentUser
    let imagePicker = UIImagePickerController()
    var name = ""
    var email = ""
    var photo = UIImage()
    var photoFlag = false
    var passwordFlag = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SignUpViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SignUpViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SignUpViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        profilePhoto.image = photo
        profilePhoto.layer.borderWidth = 1
        profilePhoto.layer.masksToBounds = false
        profilePhoto.layer.borderColor = UIColor.blackColor().CGColor
        profilePhoto.layer.cornerRadius = profilePhoto.frame.height/2
        profilePhoto.clipsToBounds = true
        
        nameTextField.text = name
        emailTextField.text = email
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            if view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
            else {
                
            }
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            if view.frame.origin.y != 0 {
                self.view.frame.origin.y += keyboardSize.height
            }
            else {
                
            }
        }
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        var selectedImage: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage{
            selectedImage = editedImage
        }else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            selectedImage = originalImage
        }
        
        if let image = selectedImage{
            profilePhoto.image = image
        }
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    
    @IBAction func saveChangesButton(sender: AnyObject) {
        if photoFlag == true{
            let imageName = "\(name)/\(NSUUID().UUIDString)"
            let storageRef = FIRStorage.storage().reference().child("\(imageName)")
            let uploadData = UIImagePNGRepresentation(self.profilePhoto.image!)
            
            storageRef.putData(uploadData!, metadata: nil, completion: { (metadata, error) in
                if error != nil{
                    print(error)
                    return
                }
                if let photoImageURL = metadata?.downloadURL()?.absoluteString{
                    self.ref.child("Users").updateChildValues(["photoURL": photoImageURL])
                }
            })
        }
        
        if newPasswordTextField.text != "" || confirmNewPasswordTextField.text != ""{
            if newPasswordTextField.text != confirmNewPasswordTextField.text{
                let alertcontroller = UIAlertController(title: "Passwords do not match!", message: "", preferredStyle: .Alert)
                alertcontroller.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: nil))
                presentViewController(alertcontroller, animated: true, completion: nil)
                return
            }else{
                let newPassword = newPasswordTextField.text
                user?.updatePassword(newPassword!) { error in
                    if let error = error {
                        print(error)
                        return
                    } else {
                        // Password updated.
                        print("Password Updated")
                    }
                }
            }
        }
        if emailTextField.text != ""{
            user?.updateEmail(emailTextField.text!) { error in
                if let error = error {
                    print(error)
                    return
                } else {
                    // Email updated.
                    self.ref.child("Users").updateChildValues(["email": self.email])
                    print("Email Updated")
                }
            }
        }
        if nameTextField.text != ""{
            ref.child("Users").updateChildValues(["name": name])
        }
    }
    
    @IBAction func changeProfilePhotoButton(sender: AnyObject) {
        photoFlag = true
        presentViewController(imagePicker, animated: true, completion: nil)
    }

}
