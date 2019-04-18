//
//  UIvewExtension.swift
//  Pods
//
//  Created by Millman YANG on 2017/4/3.
//
//

import Foundation
import UIKit
extension UIView {
    func shadow(opacity: Float, radius: Float, offset: CGSize = CGSize.zero) {
        self.layer.shadowOffset  = offset
        self.layer.shadowColor   = UIColor.black.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowRadius  = CGFloat(radius)
    }
}

var LayoutKey = "AutoLayoutKey"

typealias ConstraintMaker = ((_ maker: LayoutMaker) -> Void)

extension UIView {
    var mLayout: LayoutSetting {
           set {
            objc_setAssociatedObject(self, &LayoutKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        } get {
            if let draw = objc_getAssociatedObject(self, &LayoutKey) as? LayoutSetting {
                return draw
            } else {
                self.mLayout = LayoutSetting(view: self)
                return self.mLayout
            }
        }
    }
}


class LayoutSetting: NSObject {
    internal let view: UIView
    internal let maker:LayoutMaker
    internal init(view: UIView) {
        self.view = view
        self.maker = LayoutMaker(view: self.view)
    }
    
    func constraint(make: ConstraintMaker) {
        make(maker)
        self.maker.activate()
    }
    
    func update(make: ConstraintMaker , duration:TimeInterval) {
        make(maker)
        UIView.animate(withDuration: duration) { 
            self.view.layoutIfNeeded()
        }
    }
    
    func update(make:ConstraintMaker) {
        make(maker)
        self.maker.activate()
    }
    
    func getConstraint(attr:NSLayoutConstraint.Attribute) -> NSLayoutConstraint? {
        return self.maker.constraintMap[attr]
    }
}

class LayoutMaker: NSObject {
    var constraintMap = [NSLayoutConstraint.Attribute : NSLayoutConstraint]()
    internal let view:UIView
    internal init (view:UIView) {
        self.view = view
        self.view.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func set(type: NSLayoutConstraint.Attribute, value: CGFloat) {
        
        if let superV = self.view.superview {
            
            if type == .height || type == .width {
                constraintMap[type] = NSLayoutConstraint(item: self.view, attribute: type, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: value)
            } else {
                constraintMap[type] = NSLayoutConstraint(item: self.view, attribute: type, relatedBy: .equal, toItem: superV, attribute: type, multiplier: 1.0, constant: value)
            }
        }
    }
    
    func activate() {
        var constraint = [NSLayoutConstraint]()
        constraintMap.forEach { (_ , value) in
            constraint.append(value)
        }
        NSLayoutConstraint.activate(constraint)
    }
    
    
}




