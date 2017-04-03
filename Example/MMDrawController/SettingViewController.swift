//
//  SettingViewController.swift
//  MMDrawController
//
//  Created by Millman YANG on 2017/4/3.
//  Copyright © 2017年 CocoaPods. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showLeftAction() {
        if let drawer = self.drawer() ,
            let manager = drawer.getManager(direction: .left){
            let value = !manager.isShow
            drawer.showLeftSlider(isShow: value)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
