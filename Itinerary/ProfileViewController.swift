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
import AlamofireImage
import Alamofire

class ProfileViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var statusTextView: UITextView!
    @IBOutlet weak var myItineraryLabel: UILabel!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    var email = ""
    let ref = FIRDatabase.database().reference()
    var userPhotosID = [String]()
    var myItineraryArray = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        myItineraryLabel.font = UIFont.boldSystemFontOfSize(17.0)
        nameLabel.font = UIFont.boldSystemFontOfSize(17.0)
        
        let leftAndRightPaddings: CGFloat = 6.0
        let numberOfItemsPerRow: CGFloat = 3.0

        let bounds = UIScreen.mainScreen().bounds
        let width = (bounds.size.width - leftAndRightPaddings)/numberOfItemsPerRow
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSizeMake(width, width)

        
        
        //Will implement in the future
        editButton.enabled = false
        
        profileImageView.layer.borderWidth = 0
        profileImageView.layer.masksToBounds = false
        profileImageView.layer.cornerRadius = profileImageView.frame.height/2
        profileImageView.clipsToBounds = true

        ref.child("Users").child((FIRAuth.auth()?.currentUser?.uid)!).child("MyItineraries").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            var snaps = [String]()
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshots {
                    snaps.append((snap.value!["itineraryID"] as? String)!)
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
            let name = snapshot.value!["name"] as? String
            self.email = (snapshot.value!["email"] as? String)!
            self.nameLabel.text = name
            self.statusTextView.text = "Hello " + self.nameLabel.text! + " welcome to myItinerary. Add your bio or status by going to the edit tab!"
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
        }else if segue.identifier == "EditProfile"{
            let editProfileViewController = segue.destinationViewController as? EditProfileViewController
            editProfileViewController?.name = nameLabel.text!
            editProfileViewController?.email = email
            editProfileViewController?.photo = profileImageView.image!
            print("Editing Profile")
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
            let itineraryID = snapshot.childSnapshotForPath(String(row)).value!["itineraryID"] as? String
            self.userPhotosID.append(itineraryID!)
        
            self.ref.child("Photos").child(self.userPhotosID[row]).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                if let profileImageURL = snapshot.childSnapshotForPath(String(0)).value!["image"] as? String{
                    Alamofire.request(.GET, profileImageURL).response { (request, response, data, error) in
                        cell.itineraryImage.image = UIImage(data: data!, scale:1)
                    }
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
