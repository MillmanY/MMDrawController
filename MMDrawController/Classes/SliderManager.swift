//
//  SliderManager.swift
//  Pods
//
//  Created by Millman YANG on 2017/3/31.
//
//

import UIKit

public enum SliderLocation {
    case left
    case right
    case none
}

public class SliderManager: NSObject {
    
    unowned let drawer:MMDrawerViewController
    var showChangeBlock:((Bool)->Void)?
    public var isShow = false {
        didSet {
            let constraint = self.shiftConstraint()
            switch self.location {
            case .left:
                if isSliderFront() {
                    constraint?.constant = (isShow) ? 0 : -shiftWidth
                } else if !isSliderFront() {
                    constraint?.constant = (isShow) ? shiftWidth : 0
                }
            case .right:
                if isSliderFront()  {
                    constraint?.constant = (isShow) ? 0 : shiftWidth
                } else {
                    constraint?.constant = (isShow) ? -shiftWidth : 0
                }
            default:break
            }
            showChangeBlock?(isShow)
        }
    }
    var animateDuration = 0.15
    var lastPoint:CGPoint = .zero
    var location:SliderLocation = .none
    
    lazy var sliderPan:UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(SliderManager.panAction(pan:)))
        return pan
    }()
    
    public private(set) var slider:UIViewController? {
        willSet {
            slider?.view.removeGestureRecognizer(sliderPan)
            slider?.removeFromParentViewController()
            slider?.view.removeFromSuperview()
            newValue?.view.isHidden = true
        }
    }
    
    var shiftWidth: CGFloat = 0.0
    var mode:SliderMode = .none {
        didSet{
            guard let sliderV = self.slider?.view else {
                return
            }
            
            if self.isSliderFront() {
                self.drawer.view.bringSubview(toFront: sliderV)
                self.slider?.view.shadow(opacity: 0.4, radius: 5.0)
                sliderPan.isEnabled = true
            } else {
                self.drawer.view.sendSubview(toBack: sliderV)
                self.slider?.view.shadow(opacity: 0.0, radius: 0.0)
                sliderPan.isEnabled = false
            }
            let drawerSize = drawer.view.frame.size
            self.setShiftWidth(drawSize: drawerSize)
        }
    }
    
    internal init(drawer:MMDrawerViewController) {
        self.drawer = drawer
        super.init()
    }

    func addSlider(slider:UIViewController ,
                   location:SliderLocation ,
                   mode:SliderMode) {
        self.slider = slider
        drawer.view.addSubview(slider.view)
        self.location = location
        self.mode = mode
        self.setSliderLayout()
        drawer.addChildViewController(slider)
//        slider.beginAppearanceTransition(true, animated: true)
//        slider.didMove(toParentViewController: drawer)
//        slider.endAppearanceTransition()

        slider.view.addGestureRecognizer(sliderPan)
    }
    
    func show(isShow:Bool) {
        self.isShow = isShow
        self.slider?.beginAppearanceTransition(isShow, animated: true)
        if isShow {
            self.slider?.view.isHidden = !isShow
        }
        
        UIView.animate(withDuration: animateDuration, animations: { 
            self.drawer.view.layoutIfNeeded()
        }) { (finish) in
            self.slider?.endAppearanceTransition()
            
            if !isShow {
                self.slider?.view.isHidden = !isShow
            }
        }
   }
    
    fileprivate func setSliderLayout() {
        slider?.view.mLayout.constraint { (make) in
            make.set(type: .top, value: 0.0)
            make.set(type: .bottom, value: 0.0)
            make.set(type: .width, value: shiftWidth)
            
            switch self.location {
            case .left:
                if isSliderFront() {
                    make.set(type: .leading, value: -shiftWidth)
                } else {
                    make.set(type: .leading, value: 0)
                }
            case .right:
                if isSliderFront() {
                    make.set(type: .trailing, value: shiftWidth)
                } else {
                    make.set(type: .trailing, value: 0)
                }
            default: break
            }
        }
    }
    
    fileprivate func isSliderFront() -> Bool {
        switch self.mode {
        case .frontWidth(_) , .frontWidthRate(_):
            return true
        default:
            return false
        }
    }
    
    fileprivate func setShiftWidth(drawSize:CGSize) {
        let mainW = drawSize.width
        
        switch mode {
        case .frontWidth(let w):
            shiftWidth = w
        case .frontWidthRate(let r):
            shiftWidth = mainW * r
        case .rearWidth(let w):
            shiftWidth = w
        case .rearWidthRate(let r):
            shiftWidth = mainW * r
        default: break
        }
    }
    
    func viewRotation(size:CGSize) {
        self.setShiftWidth(drawSize: size)
        self.slider?.view.mLayout.update(make: { (make) in
            make.constraintMap[.width]?.constant = shiftWidth
        })
        // prevent layout Error
        let show = self.isShow
        self.isShow = show
    }
}

extension SliderManager {
    @objc func panAction(pan:UIPanGestureRecognizer) {
        if let view = pan.view {
            switch pan.state {
            case .began:
                slider?.view.isHidden = false
                lastPoint = pan.translation(in: view)
            case .changed:
                let current = pan.translation(in: view)
                self.setViewLocate(currentPoint: current, lastPoint: lastPoint)
                lastPoint = current
            case .cancelled , .ended :
                let vel = pan.velocity(in: view)
                
                self.setViewFrameEnd(velocity: vel)
                lastPoint = .zero
            default:
                break
            }
        }
    }
    
    func setViewLocate(currentPoint:CGPoint , lastPoint:CGPoint) {
        
        if let constraint = self.shiftConstraint(){
            let shift = currentPoint.x - lastPoint.x
            var will = constraint.constant + shift
            
            switch self.location {
            case .left:
                if isSliderFront() {
                    if will >= 0 {
                        will = 0
                    }
                } else if !isSliderFront() {
                    if will <= 0 {
                        will = 0
                    } else if will >= shiftWidth {
                        will = shiftWidth
                    }
                }
            case .right:
                if !isSliderFront()  {
                    if will >= 0 {
                        will = 0
                    } else if will <= -shiftWidth {
                        will = -shiftWidth
                    }
                } else if isSliderFront() {
                    if will <= 0 {
                        will = 0
                    } else if will >= shiftWidth {
                        will = shiftWidth
                    }
                }
            default:break
            }
            constraint.constant = will
        }
    }

    func setViewFrameEnd(velocity: CGPoint) {
        var isShow = false
        
        switch self.location {
        case .left:
            isShow =  velocity.x > 0
        case .right:
            isShow =  velocity.x < 0

        default:
            break
        }
        self.show(isShow: isShow)
    }
    
    func shiftConstraint() -> NSLayoutConstraint? {
        if let sliderView = self.slider?.view {
            let mainView = self.drawer.containerView
            let shiftView = self.isSliderFront() ? sliderView : mainView
        
            switch self.location {
            case .left:
                return shiftView.mLayout.getConstraint(attr: .leading)
                
            case .right:
                if isSliderFront() {
                    return shiftView.mLayout.getConstraint(attr: .trailing)
                } else {
                    return shiftView.mLayout.getConstraint(attr: .leading)
                }
            default:break
                
            }
        }
        return nil
    }
}

