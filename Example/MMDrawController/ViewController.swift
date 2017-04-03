//
//  ViewController.swift
//  MMDrawController
//
//  Created by millmanyang@gmail.com on 03/30/2017.
//  Copyright (c) 2017 millmanyang@gmail.com. All rights reserved.
//

import UIKit
import MMDrawController
class ViewController: MMDrawerViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Init by storyboard identifier
        super.setMainWith(identifier: "Home")
        super.setLeftWith(identifier: "Member", mode: .rearWidthRate(r: 0.6))
        //Init by Code
        let story = UIStoryboard.init(name: "Main", bundle: nil)
        let right = story.instantiateViewController(withIdentifier: "SliderRight")
//        super.set(right: right, mode: .rearWidth(w: 100))
        
        super.setRightWith(identifier: "Member", mode: .rearWidthRate(r: 0.6))

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

