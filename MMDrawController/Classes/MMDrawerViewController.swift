//
//  MMDrawerViewController.swift
//  Pods
//
//  Created by Millman YANG on 2017/3/30.
//
//

import UIKit

// only check segue are (main/segue) ,
public class DrawerSegue: UIStoryboardSegue {
    override public func perform() {}
}

public enum SliderMode {
    case frontWidth(w:CGFloat)
    case frontWidthRate(r:CGFloat)

    case rearWidth(w:CGFloat)
    case rearWidthRate(r:CGFloat)
    case none
}

public enum ShowMode {
    case left
    case right
    case main
}

struct SegueParams {
    var type:String
    var params:Any?
}

open class MMDrawerViewController: UIViewController  {
    var containerView = UIView()
    var sliderMap = [SliderLocation:SliderManager]()
    var currentManager:SliderManager?
    
    override open func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let s = segue as? DrawerSegue ,
           let p = sender as? SegueParams {
            switch p.type {
            case "main":
                self.set(main: s.destination)
            case "left":
                if let slideMode = p.params as? SliderMode {
                    self.set(left: s.destination, mode: slideMode)
                }
            case "right":
                if let slideMode = p.params as? SliderMode {
                    self.set(right: s.destination, mode: slideMode)
                }
            default:
              break
            }
        }
    }
    
    public var main:UIViewController? {
        willSet {
            main?.removeFromParentViewController()
            main?.view.removeFromSuperview()
        } didSet {
            if let new = main {                
                new.view.shadow(opacity: 0.4, radius: 5.0)
                new.view.addGestureRecognizer(mainPan)
                
                containerView.addSubview(new.view)
                self.view.layoutIfNeeded()
                self.addChildViewController(new)
            }
        }
    }
    
    lazy var mainPan:UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(MMDrawerViewController.panAction(pan:)))
        return pan
    }()

    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let m = main {
            m.view.frame = containerView.bounds
            
            var isRearShow = false
            sliderMap.forEach({
                if !isRearShow {
                    $0.value.resetFrame()
                }

                if $0.value.isShow && !$0.value.isSliderFront() {
                    isRearShow = true
                }
            })
            
            if !isRearShow {
                containerView.frame = self.view.bounds
            }
        }
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(containerView)
    }
    
    public func set(left:UIViewController, mode:SliderMode) {
        sliderMap[.left] = SliderManager(drawer:self)
        sliderMap[.left]?.addSlider(slider: left, location: .left, mode: mode)
        self.view.layoutSubviews()
    }
    
    public func set(right:UIViewController , mode:SliderMode) {
        sliderMap[.right] = SliderManager(drawer: self)
        sliderMap[.right]?.addSlider(slider: right, location: .right, mode: mode)
        self.view.layoutSubviews()
    }
    
    public func setLeft(mode:SliderMode) {
        sliderMap[.left]?.mode = mode
        self.view.layoutSubviews()
    }
    
    public func setRight(mode:SliderMode) {
        sliderMap[.right]?.mode = mode
        self.view.layoutSubviews()
    }
    
    public func set(main:UIViewController) {
        self.main = main
        self.view.layoutSubviews()
    }
    
    public func showLeftSlider(isShow:Bool) {
        sliderMap[.left]?.show(isShow: isShow)
    }
    
    public func showRightSlider(isShow:Bool) {
        sliderMap[.right]?.show(isShow: isShow)
    }
    
    public func getManager(direction:SliderLocation) -> SliderManager? {
        return sliderMap[direction]
    }
    
    public func setMainWith(identifier:String) {
        self.performSegue(withIdentifier: identifier, sender: SegueParams(type: "main", params: nil))
    }
    
    public func setLeftWith(identifier:String , mode:SliderMode) {
        self.performSegue(withIdentifier: identifier, sender: SegueParams(type: "left", params: mode))
    }
    
    public func setRightWith(identifier:String , mode:SliderMode) {
        self.performSegue(withIdentifier: identifier, sender: SegueParams(type: "right", params: mode))
    }
}

extension MMDrawerViewController {
    func panAction(pan:UIPanGestureRecognizer) {
        switch pan.state {
        case .began:
            currentManager = self.searchCurrentManagerWith(pan: pan)
            currentManager?.panAction(pan: pan)
        case .changed:
            currentManager?.panAction(pan: pan)
        case .cancelled , .ended :
            currentManager?.panAction(pan: pan)
            currentManager = nil
        default:
            break
        }
    }
    
    fileprivate func searchCurrentManagerWith(pan:UIPanGestureRecognizer) -> SliderManager? {
        var manager:SliderManager?
        let rect = self.view.bounds.insetBy(dx: 40, dy: 40)
        let first = pan.location(in: pan.view)
        //Edge
        if !rect.contains(first) {
            let vel = pan.velocity(in: pan.view)
            let isVertical = fabs(vel.x) < fabs(vel.y)
            
            sliderMap.forEach({ (_ , value) in
                
                if let s = manager?.slider?.view {
                    
                    let pre = first.distance(point: s.center)
                    let current = first.distance(point: value.slider?.view.center)
                    
                    if current < pre {
                        manager = value
                    }
                } else {
                    manager = value
                }
            })
            
        } else {
            manager = nil
        }
        return manager
    }
}
