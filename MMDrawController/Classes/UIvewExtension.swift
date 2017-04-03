//
//  UIvewExtension.swift
//  Pods
//
//  Created by Millman YANG on 2017/4/3.
//
//

import Foundation

extension UIView {
    func shadow(opacity:Float , radius:Float) {
        self.layer.shadowColor   = UIColor.black.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowRadius  = CGFloat(radius)
    }
}
