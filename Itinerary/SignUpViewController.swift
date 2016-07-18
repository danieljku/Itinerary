//
//  SignUpViewController.swift
//  Itinerary
//
//  Created by Daniel Ku on 7/14/16.
//  Copyright © 2016 djku. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

class SignUpViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPassField: UITextField!
    let ref = FIRDatabase.database().reference()
    let imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SignUpViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        imagePicker.delegate = self
        imagePicker.allowsEditing = true

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    @IBAction func addImageButton(sender: AnyObject) {
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    //Create account button is clicked
    @IBAction func createAccountButton(sender: AnyObject) {
        if nameField.text == ""{
            let alertcontroller = UIAlertController(title: "You need to enter in a name", message: "", preferredStyle: .Alert)
            alertcontroller.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: nil))
            self.presentViewController(alertcontroller, animated: true, completion: nil)
            return
        }
        
        if emailField.text == ""{
            let alertcontroller = UIAlertController(title: "You need to enter in an email", message: "", preferredStyle: .Alert)
            alertcontroller.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: nil))
            self.presentViewController(alertcontroller, animated: true, completion: nil)
            return
        }
        
        if passwordField.text == ""{
            let alertcontroller = UIAlertController(title: "You didn't enter in a password", message: "", preferredStyle: .Alert)
            alertcontroller.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: nil))
            return
        }
        
        if passwordField.text != confirmPassField.text{
            let alertcontroller = UIAlertController(title: "Password doesn't match", message: "", preferredStyle: .Alert)
            alertcontroller.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: nil))
            self.presentViewController(alertcontroller, animated: true, completion: nil)
            return
        }
        FIRAuth.auth()?.createUserWithEmail(emailField.text!, password: passwordField.text!) { (user, error) in
            if error != nil{
                print(error)
                return
            }
            let imageName = NSUUID().UUIDString
            let storageRef = FIRStorage.storage().reference().child("\(imageName)")
            let uploadData = UIImagePNGRepresentation(self.profilePhoto.image!)
            
            storageRef.putData(uploadData!, metadata: nil, completion: { (metadata, error) in
                if error != nil{
                    print(error)
                    return
                }
                if let photoImageURL = metadata?.downloadURL()?.absoluteString{
                    let userID = user!.uid
                    let name = self.nameField.text!
                    let email = self.emailField.text!
                    
                    let user = ["uid": userID,
                        "name": name,
                        "email": email,
                        "photoURL": photoImageURL]
                    self.storeData(userID, user: user)
                }
            })
        }
        
    }
    func storeData(userID: String, user: [String: AnyObject]){
        self.ref.child("Users").child(userID).setValue(user)
        
        FIRAuth.auth()?.addAuthStateDidChangeListener { auth, user in
            if user != nil {
                // User is signed in.
                let mainStoryBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let homeViewController: UIViewController = mainStoryBoard.instantiateViewControllerWithIdentifier("HomeView")
                self.presentViewController(homeViewController, animated: true, completion: nil)
            }
        }
    }


}
