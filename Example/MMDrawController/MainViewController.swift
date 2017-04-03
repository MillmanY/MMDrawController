//
//  MainViewController.swift
//  MMDrawController
//
//  Created by Millman YANG on 2017/3/30.
//  Copyright © 2017年 CocoaPods. All rights reserved.
//

import UIKit
import MMDrawController
class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func showLeftAction() {
        if let drawer = self.drawer() ,
            let manager = drawer.getManager(direction: .left){
            let value = !manager.isShow
            drawer.showLeftSlider(isShow: value)
        }
    }
    
    @IBAction func showRightAction() {
        if let drawer = self.drawer() ,
           let manager = drawer.getManager(direction: .right){
            let value = !manager.isShow
            drawer.showRightSlider(isShow: value)
        }
    }
}
