//
//  SignUpViewController.swift
//  Itinerary
//
//  Created by Daniel Ku on 7/14/16.
//  Copyright © 2016 djku. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class SignUpViewController: UIViewController {
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPassField: UITextField!
    let ref = FIRDatabase.database().reference()

    override func viewDidLoad() {
        super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)

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
    
    @IBAction func createAccountButton(sender: AnyObject) {
        if nameField.text == nil{
            let alertcontroller = UIAlertController(title: "You need to enter in a name", message: "", preferredStyle: .Alert)
            alertcontroller.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: nil))
            self.presentViewController(alertcontroller, animated: true, completion: nil)
            return
        }
        
        if emailField.text == nil{
            let alertcontroller = UIAlertController(title: "You need to enter in an email", message: "", preferredStyle: .Alert)
            alertcontroller.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: nil))
            self.presentViewController(alertcontroller, animated: true, completion: nil)
            return
        }
        
        if passwordField.text == nil{
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
            // ...
            if error != nil{
                print(error)
                return
            }
            
            let userID = user!.uid
            let name = self.nameField.text!
            let email = self.emailField.text!
            
            let user = ["uid": userID,
                        "name": name,
                        "email": email]
            
            self.ref.child("Users").child(userID).setValue(user)


            
            print("Created")
        }
        
    }


}
