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
    
    internal let drawer:MMDrawerViewController
    public var isShow = false
    var animateDuration = 0.3
    var lastPoint:CGPoint = .zero
    var location:SliderLocation = .none
    
    lazy var sliderPan:UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(SliderManager.panAction(pan:)))
        return pan
    }()
    
    var slider:UIViewController? {
        willSet {
            slider?.view.removeGestureRecognizer(sliderPan)
            slider?.removeFromParentViewController()
            slider?.view.removeFromSuperview()
            newValue?.view.isHidden = true
        }
    }
    
    var mode:SliderMode = .none {
        didSet{
            switch mode {
            case .frontWidth(_), .frontWidthRate(_):
                slider?.view.shadow(opacity: 0.4, radius: 5.0)
                sliderPan.isEnabled = true
            default:
                slider?.view.shadow(opacity: 0.0, radius: 0.0)
                sliderPan.isEnabled = false
            }
            switch oldValue {
            case .none:
                break
            default:
                self.show(isShow: false)

            }
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
        self.location = location
        self.mode = mode
        
        drawer.view.addSubview(slider.view)
        drawer.addChildViewController(slider)
        slider.view.addGestureRecognizer(sliderPan)
    }
    
    func show(isShow:Bool) {
        self.isShow = isShow
        self.slider?.beginAppearanceTransition(isShow, animated: true)
        if isShow {
            self.slider?.view.isHidden = !isShow
        }
        
        UIView.animate(withDuration: animateDuration, animations: {
            self.resetFrame()
        }, completion: { (finish) in
            self.slider?.endAppearanceTransition()
            
            if !isShow {
                self.slider?.view.isHidden = !isShow
            }
        })
   }
    
    func resetFrame() {
        let drawerFrame = drawer.view.frame
        let mainW = drawerFrame.width
    
        if let view = self.slider?.view {
            switch mode {
            case .frontWidth(let w):
                self.front(sliderView: view, width: w)
            case .frontWidthRate(let r):
                let fixW = mainW * r
                self.front(sliderView: view, width: fixW)
            case .rearWidth(let w):
                self.rear(sliderView: view, width: w)
            case .rearWidthRate(let r):
                let fix = mainW * r
                self.rear(sliderView: view, width: fix)
            default: break
            }
        }
    }

    func isSliderFront() -> Bool {
        switch self.mode {
        case .frontWidth(_) , .frontWidthRate(_):
            return true
        default:
            return false
        }
    }
}

extension SliderManager {
    func panAction(pan:UIPanGestureRecognizer) {
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
        
        if let sliderView = self.slider?.view {
            let mainView = self.drawer.containerView 
            let mainFrame = mainView.frame
            let shiftView = self.isSliderFront() ? sliderView : mainView

            switch self.location {
            case .left:
                let shift = currentPoint.x - lastPoint.x
                let will = shiftView.frame.origin.x + shift
                
                if isSliderFront() && will <= 0 {
                    shiftView.frame.origin.x = will
                } else if !isSliderFront() && will >= 0 && will <= sliderView.frame.width{
                    shiftView.frame.origin.x = will
                }
            case .right:
                let shift = currentPoint.x - lastPoint.x                
                let will = shiftView.frame.origin.x + shift
                
                if  isSliderFront() && will >= mainFrame.width - sliderView.frame.width {
                    shiftView.frame.origin.x = will
                } else if !isSliderFront() && will >= -sliderView.frame.width &&  will <= 0 {
                    shiftView.frame.origin.x = will
                }
            default:
                break
            }
        }
    }

    func setViewFrameEnd(velocity:CGPoint) {
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
}

// Front
extension SliderManager {
    
    fileprivate func front(sliderView:UIView,
                           width:CGFloat) {
        let mainW = drawer.view.bounds.width
        let mainH = drawer.view.bounds.height
        
        var frame = CGRect(x: 0, y: 0, width: width, height: mainH)
        drawer.view.bringSubview(toFront: sliderView)
        
        switch self.location {
        case .left:
            frame.origin.x = self.isShow ? 0 : -frame.width
        case .right:
            frame.origin.x = self.isShow ? mainW - frame.width : mainW
        default: break
        }
        sliderView.frame = frame
    }
}

// Rear
extension SliderManager {
    fileprivate func rear(sliderView:UIView ,
                          width:CGFloat) {
        let mainW = drawer.view.bounds.width
        let mainH = drawer.view.bounds.height
        var frame = CGRect(x: 0, y: 0, width: width, height: mainH)
        drawer.view.sendSubview(toBack: sliderView)
        
        switch self.location {
        case .right:
            frame.origin.x = mainW-width
        default: break
        }
        sliderView.frame = frame
        self.fixMainFrameWith(slider: sliderView)
    }
    
    fileprivate func fixMainFrameWith(slider:UIView) {
        let mainView = drawer.containerView
        var frame = mainView.frame
        
        switch self.location {
        case .left:
            frame.origin.x = (self.isShow) ? slider.frame.width : 0
        case .right:
            frame.origin.x = (self.isShow) ? -slider.frame.width  : 0
        default:
            break
        }
        mainView.frame = frame
    }
}
