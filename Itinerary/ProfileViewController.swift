//
//  View2.swift
//  Itinerary
//
//  Created by Daniel Ku on 7/13/16.
//  Copyright © 2016 djku. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import FBSDKLoginKit

class ProfileViewController: UIViewController {
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let ref = FIRDatabase.database().reference()
        
        let userID = FIRAuth.auth()?.currentUser?.uid
        ref.child("Users").child(userID!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            // Get user value
            self.nameLabel.text = snapshot.value!["name"] as? String
            self.emailLabel.text = snapshot.value!["email"] as? String
            if let profileImageURL = snapshot.value!["photoURL"] as? String{
                let url = NSURL(string: profileImageURL)
                let imageData = NSData(contentsOfURL: url!)
                self.profileImageView.image = UIImage(data: imageData!)
            }
        })
    }

    @IBAction func logoutButton(sender: AnyObject) {
        try! FIRAuth.auth()!.signOut()
        
        FBSDKAccessToken.setCurrentAccessToken(nil)
        
        let mainStoryBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let homeViewController: UIViewController = mainStoryBoard.instantiateViewControllerWithIdentifier("LoginScreen")
        self.presentViewController(homeViewController, animated: true, completion: nil)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
