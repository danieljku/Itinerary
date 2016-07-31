//
//  TabBarViewController.swift
//  Itinerary
//
//  Created by Daniel Ku on 7/29/16.
//  Copyright © 2016 djku. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {
    var tabBarIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if tabBarIndex == 0{
            self.selectedIndex = 0
        }else{
            self.selectedIndex = 1
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
