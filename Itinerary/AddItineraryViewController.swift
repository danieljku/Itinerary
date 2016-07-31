//
//  AddItineraryViewController.swift
//  Itinerary
//
//  Created by Daniel Ku on 7/18/16.
//  Copyright © 2016 djku. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

class AddItineraryViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var imageScrollView: UIScrollView!
    @IBOutlet weak var itineraryTitleText: UITextField!
    @IBOutlet weak var cityText: UITextField!
    @IBOutlet weak var durationText: UITextField!
    @IBOutlet weak var roughCostText: UITextField!
    @IBOutlet weak var categorySegControl: UISegmentedControl!
    @IBOutlet weak var summaryTextView: UITextView!
    let ref = FIRDatabase.database().reference()
    let itineraryID = NSUUID().UUIDString
    let imagePicker = UIImagePickerController()
    var imageArray = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SignUpViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    @IBAction func cancelButton(sender: AnyObject) {
        let mainStoryBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let homeViewController: UIViewController = mainStoryBoard.instantiateViewControllerWithIdentifier("TabBarController")
        self.presentViewController(homeViewController, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let itineraryInfoViewController = segue.destinationViewController as! ItineraryInfoViewController
        if segue.identifier == "ItineraryInfo"{
            itineraryInfoViewController.userID = itineraryID
            itineraryInfoViewController.myImages = imageArray
            itineraryInfoViewController.prevLocation = "AddItineraryViewController"
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        var selectedImage: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage{
            selectedImage = editedImage
        }else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            selectedImage = originalImage
        }
        if let image = selectedImage{
            imageArray.append(image)
            
            let imageWidth:CGFloat = 120
            let imageHeight:CGFloat = 120
            var xPosition:CGFloat = 0
            var scrollViewSize:CGFloat=0
            
            
            for image in self.imageArray {
                let myImageView:UIImageView = UIImageView()
                myImageView.image = image
                
                myImageView.frame.size.width = imageWidth
                myImageView.frame.size.height = imageHeight
                myImageView.frame.origin.x = xPosition
                myImageView.frame.origin.y = 10
                
                
                self.imageScrollView.addSubview(myImageView)
                xPosition += imageWidth + 10
                scrollViewSize += imageWidth + 10
            }
            self.imageScrollView.contentSize = CGSize(width: scrollViewSize, height: imageHeight)
        }
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func addImage(sender: AnyObject) {
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func createItineraryButton(sender: AnyObject) {
        var category = "Friends"
        
        if(categorySegControl.selectedSegmentIndex == 0){
            category = "Tourist"
        }else if(categorySegControl.selectedSegmentIndex == 1){
            category = "Couple"
        }else if(categorySegControl.selectedSegmentIndex == 2){
            category = "Friends"
        }else if(categorySegControl.selectedSegmentIndex == 3){
            category = "Family"
        }else{
            let alertController = UIAlertController(title: "Choose a category!", message: "", preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: nil))
            presentViewController(alertController, animated: true, completion: nil)
            return
        }
        
        let userID = FIRAuth.auth()?.currentUser?.uid
        
        let itinerary = ["Title": itineraryTitleText.text,
                         "City": cityText.text,
                         "Duration": durationText.text,
                         "Cost": roughCostText.text,
                         "Category": category,
                         "Summary": summaryTextView.text,
                         "UserID": userID
                         ]
        
        var i = 0
        var imageURLArray = [String]()

        while i < imageArray.count{
            let imageName = NSUUID().UUIDString
            let storageRef = FIRStorage.storage().reference().child("\(imageName)")
            let uploadData = UIImagePNGRepresentation(imageArray[i])
            
            storageRef.putData(uploadData!, metadata: nil, completion: { (metadata, error) in
                if error != nil{
                    print(error)
                    return
                }
                    if let photoImageURL = metadata?.downloadURL()?.absoluteString{
                        imageURLArray.append(photoImageURL)
                    }
            
                if imageURLArray.count == self.imageArray.count {
                    var j = 0
                    while(j < imageURLArray.count){
                         self.ref.child("Photos").child(self.itineraryID).child("\(j)").updateChildValues(["image": imageURLArray[j]])
                        j += 1
                    }
                }
            })
            i += 1
        }
        
        ref.child("Itineraries").child(itineraryID).setValue(itinerary)
        ref.child("Users").child(userID!).child("MyItineraries").updateChildValues([itineraryID: itineraryTitleText.text!])
    }
    
}
