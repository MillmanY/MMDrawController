//
//  SliderViewController.swift
//  MMDrawController
//
//  Created by Millman YANG on 2017/3/30.
//  Copyright © 2017年 CocoaPods. All rights reserved.
//

import UIKit
import MMDrawController

let titleArr = ["Main","Setting"]

class SliderViewController: UIViewController {
    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var imgAvater:UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.setup()
    }

    func setup() {
        self.imgAvater.clipsToBounds = true
        self.imgAvater.layer.cornerRadius = imgAvater.frame.height/2
    }
}

extension SliderViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let d = self.drawer() {
            let story = UIStoryboard.init(name: "Main", bundle: nil)
            if let main = story.instantiateViewController(withIdentifier: "MainVC") as? UINavigationController ,
               let first = main.viewControllers.first {
                if indexPath.row == 0 {
                    first.view.backgroundColor = UIColor.red
                } else {
                    first.view.backgroundColor = UIColor.blue
                }
                d.set(main: main)
            }
        }
    }
}

extension SliderViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "TitleCell") ,
           let label = cell.viewWithTag(100) as? UILabel{
            label.text = titleArr[indexPath.row]
            return cell
        }
        return UITableViewCell()
    }
}
