//
//  ItinerarySearchViewController.swift
//  Itinerary
//
//  Created by Daniel Ku on 7/19/16.
//  Copyright © 2016 djku. All rights reserved.
//

import UIKit
import Firebase
import Alamofire
import AlamofireImage

class ItinerarySearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    let ref = FIRDatabase.database().reference()
    var itineraryArray = [FIRDataSnapshot]()
    var searchActive = false
    var filtered = [FIRDataSnapshot]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        searchBar.scopeButtonTitles = ["All", "Tourist", "Couple", "Friends", "Families"]
        searchBar.tintColor = UIColor(red:0.37, green:0.88, blue:0.70, alpha:1.0)
        
        tableView.rowHeight = UIScreen.mainScreen().bounds.size.width
        
        searchBar.setScopeBarButtonTitleTextAttributes([NSForegroundColorAttributeName : UIColor.whiteColor()], forState: .Normal)
        searchBar.setScopeBarButtonTitleTextAttributes([NSForegroundColorAttributeName : UIColor.whiteColor()], forState: .Selected)
        
        ref.child("Itineraries").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            var snaps = [FIRDataSnapshot]()
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshots {
                    snaps.append(snap)
                }
                self.itineraryArray = snaps
                let range = NSMakeRange(0, self.tableView.numberOfSections)
                let sections = NSIndexSet(indexesInRange: range)
                self.tableView.reloadSections(sections, withRowAnimation: .Fade)
            }
            
        })
    }

    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filtered = itineraryArray.filter { snap in
            let categoryMatch = (snap.value!["Category"] as? String == scope)
            return categoryMatch && (snap.value!["City"] as? String)!.lowercaseString.containsString(searchText.lowercaseString)
        }
        
        tableView.reloadData()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        filtered = itineraryArray.filter({ (text) -> Bool in
            let tmp = text.value!["City"] as? String
            let range = tmp!.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
            return range != nil
        })
        if(filtered.count == 0){
            searchActive = false;
        } else {
            searchActive = true;
        }
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            if identifier == "ItineraryInfo" {
                let indexPath = tableView.indexPathForSelectedRow!
                let itineraryInfoViewController = segue.destinationViewController as! ItineraryInfoViewController
                itineraryInfoViewController.itineraryID = self.itineraryArray[indexPath.row].key
                itineraryInfoViewController.prevLocation = "ItinerarySearchViewController"
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(searchActive) {
            return filtered.count
        }
        return itineraryArray.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("itineraryTableViewCell", forIndexPath: indexPath) as! ItinerarySearchTableViewCell
        
//        cell.layer.borderWidth = 0.5
//        cell.layer.borderColor = UIColor.grayColor().CGColor

        
        let row = indexPath.row
        var itineraryID = itineraryArray[row]
        
        if(searchActive){
            itineraryID = filtered[row]
        }else{
            itineraryID = itineraryArray[row]
        }
        self.ref.child("Itineraries").child(itineraryID.key).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            cell.titleLabel.text = snapshot.value!["Title"] as? String
            cell.cityLabel.text = snapshot.value!["City"] as? String
            cell.costLabel.text = "$\(String(format: "%.2f",((100.00 * (Double)((snapshot.value!["Cost"] as? String)!)!))/100.00))"
            cell.categoryLabel.text = snapshot.value!["Category"] as? String
            
            cell.titleLabel.font = UIFont.boldSystemFontOfSize(20.0)
            
            self.ref.child("Photos").child(itineraryID.key).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                if let profileImageURL = snapshot.childSnapshotForPath(String(0)).value!["image"] as? String{
                    Alamofire.request(.GET, profileImageURL).response { (request, response, data, error) in
                        cell.itineraryImage.image = UIImage(data: data!)

                    }
                }
            })
        })
        return cell
    }

}
