//
//  PasswordResetViewController.swift
//  Itinerary
//
//  Created by Daniel Ku on 7/14/16.
//  Copyright © 2016 djku. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class PasswordResetViewController: UIViewController {
    @IBOutlet weak var emailField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sendResetButton(sender: AnyObject) {
        let email = emailField.text!
        
        FIRAuth.auth()?.sendPasswordResetWithEmail(email) { error in
            if let error = error {
                // An error happened.
                print(error)
                return
            } else {
                // Password reset email sent.
                print("password reset sent!")
            }
        }
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
