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

class ProfileViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    let ref = FIRDatabase.database().reference()
    var userPhotosID = [String]()
    var myItineraryArray = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        ref.child("Users").child((FIRAuth.auth()?.currentUser?.uid)!).child("MyItineraries").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            var snaps = [String]()
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshots {
                    snaps.append((snap.value!["imageID"] as? String)!)
                }
                self.myItineraryArray = snaps
                let range = NSMakeRange(0, self.collectionView.numberOfSections())
                let sections = NSIndexSet(indexesInRange: range)
                self.collectionView.reloadSections(sections)
            }
            
        })
        
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
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "AddItinerary"{
            //Segue to add itinerary view controller
            print("Creating new itienrary")
        }else if let indexPath = collectionView.indexPathForCell((sender as? UICollectionViewCell)!){
            if segue.identifier == "ItineraryInfo" {
                let itineraryInfoViewController = segue.destinationViewController as? ItineraryInfoViewController
                itineraryInfoViewController?.itineraryID = myItineraryArray[indexPath.row]
                itineraryInfoViewController?.prevLocation = "ProfileViewController"
            }
        }
        
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return myItineraryArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ItineraryCell", forIndexPath: indexPath) as! ProfileItineraryCollectionViewCell
        let row = indexPath.row
        
        ref.child("Users").child((FIRAuth.auth()?.currentUser?.uid)!).child("MyItineraries").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            let itineraryID = snapshot.childSnapshotForPath(String(row)).value!["imageID"] as? String
            self.userPhotosID.append(itineraryID!)
        
            self.ref.child("Photos").child(self.userPhotosID[row]).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                if let profileImageURL = snapshot.childSnapshotForPath(String(0)).value!["image"] as? String{
                    let url = NSURL(string: profileImageURL)
                    let imageData = NSData(contentsOfURL: url!)
                    let image  = UIImage(data: imageData!)
                    cell.itineraryImage.image = image
                }
            })
        })

        
        return cell
    }

    
    @IBAction func logoutButton(sender: AnyObject) {
        try! FIRAuth.auth()!.signOut()
        
        FBSDKAccessToken.setCurrentAccessToken(nil)
        
        let mainStoryBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let homeViewController: UIViewController = mainStoryBoard.instantiateViewControllerWithIdentifier("LoginScreen")
        self.presentViewController(homeViewController, animated: true, completion: nil)
    }
}
