//
//  SliderRightViewController.swift
//  MMDrawController
//
//  Created by Millman YANG on 2017/4/3.
//  Copyright © 2017年 CocoaPods. All rights reserved.
//

import UIKit

class SliderRightViewController: UIViewController {
    @IBOutlet weak var tableView:UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension SliderRightViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "RightCell") ,
            let label = cell.viewWithTag(100) as? UIImageView{
            label.image = #imageLiteral(resourceName: "member")
            return cell
        }
        return UITableViewCell()
    }
}
