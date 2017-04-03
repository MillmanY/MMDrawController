//
//  CGPointExtension.swift
//  Pods
//
//  Created by Millman YANG on 2017/4/1.
//
//

import UIKit

extension CGPoint {
    
    func distance(point:CGPoint?) -> CGFloat {
        if let p = point {
            let xDist = self.x - p.x
            let yDist = self.y - p.y
            return CGFloat(sqrt( xDist * xDist) + (yDist * yDist) )
        }
        return .greatestFiniteMagnitude
    }
}
