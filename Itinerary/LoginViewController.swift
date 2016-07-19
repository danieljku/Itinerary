//
//  ViewController.swift
//  Itinerary
//
//  Created by Daniel Ku on 7/12/16.
//  Copyright © 2016 djku. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import FBSDKLoginKit


class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    var fbLoginSuccess = false
    @IBOutlet weak var loginButton: FBSDKLoginButton!
    @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        activitySpinner.hidden = true
        
        FIRAuth.auth()?.addAuthStateDidChangeListener { auth, user in
            if user != nil {
                // User is signed in.
                let mainStoryBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let homeViewController: UIViewController = mainStoryBoard.instantiateViewControllerWithIdentifier("TabBarController")
                    UIApplication.sharedApplication().delegate?.window!?.rootViewController = homeViewController
            } else {
                // No user is signed in.
                self.loginButton.readPermissions = ["public_profile", "email", "user_friends"]
                self.loginButton.delegate = self
            }
        }
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    @IBAction func signInButton(sender: AnyObject) {
        FIRAuth.auth()?.signInWithEmail(emailField.text!, password: passwordField.text!) { (user, error) in
            if error != nil{
                print(error)
                return
            }
            let mainStoryBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let homeViewController: UIViewController = mainStoryBoard.instantiateViewControllerWithIdentifier("HomeView")
            self.presentViewController(homeViewController, animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError?) {
        
        activitySpinner.hidden = false
        activitySpinner.startAnimating()
        
        
        if let error = error {
            print(error.localizedDescription)
            return
        }else if result.isCancelled{
            //return to screen
        }else{
            let ref = FIRDatabase.database().reference()
            let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
            FIRAuth.auth()?.signInWithCredential(credential) { (user, error) in
                if error != nil{
                    print(error)
                    return
                }
                let storageRef = FIRStorage.storage().reference()
                let profilePic = FBSDKGraphRequest(graphPath: "me/picture", parameters: ["height": 240, "width": "240", "redirect": false], HTTPMethod: "GET")
                profilePic.startWithCompletionHandler({(connection, result, error) -> Void in
                    if error != nil{
                        print(error)
                    }
                    let dictionary = result as? NSDictionary
                    let data = dictionary?.objectForKey("data")
                    let urlPic = (data?.objectForKey("url"))! as! String
                    
                    if let imageData = NSData(contentsOfURL: NSURL(string: urlPic)!){
                        let profilePicRef = storageRef.child(user!.uid)
                        let uploadTask = profilePicRef.putData(imageData, metadata: nil){ metadata, error in
                            if error != nil{
                                print(error)
                                return
                            }
                        }
                    }
                    if let user = FIRAuth.auth()?.currentUser {
                        let photoUrl = urlPic
                        let name = user.displayName!
                        let email = user.email!
                        let userID = user.uid;
                        
                        let fbUser = ["uid": userID,
                            "name": name,
                            "email": email,
                            "photoURL": photoUrl]
                        
                        ref.child("Users").child(userID).setValue(fbUser)
                        
                    } else {
                        // No user is signed in.
                    }
                })
                
            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!){
        print("User logged out")
    }


}

