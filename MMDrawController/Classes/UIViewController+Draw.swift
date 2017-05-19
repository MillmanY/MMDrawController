//
//  UIViewExtension.swift
//  Pods
//
//  Created by Millman YANG on 2017/4/2.
//
//

import UIKit

public extension UIViewController {
    
    public func drawer() -> MMDrawerViewController? {
        return self.findDrawer(controller: self)
    }
    
    private func findDrawer(controller: UIViewController?) -> MMDrawerViewController? {

        if let p = controller?.parent {
         
            if let parent = p as? MMDrawerViewController {
                return parent
            } else {
                return self.findDrawer(controller: p)
            }
        }
        return nil
    }


}




