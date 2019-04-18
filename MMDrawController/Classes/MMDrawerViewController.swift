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
    case frontWidth(w: CGFloat)
    case frontWidthRate(r: CGFloat)
    
    case rearWidth(w: CGFloat)
    case rearWidthRate(r: CGFloat)
    case none
}

public enum ShowMode {
    case left
    case right
    case main
}
public typealias ConfigBlock = ((_ vc: UIViewController) -> Void)?
struct SegueParams {
    var type: String
    var params: Any?
    var config: ConfigBlock
}

open class MMDrawerViewController: UIViewController  {
    var statusBarHidden = false {
        didSet {
            self.setNeedsStatusBarAppearanceUpdate()
            //            UIApplication.shared.statusBarView?.isHidden = true
        }
    }
    open override var prefersStatusBarHidden: Bool {
        return statusBarHidden
    }
    
    public var isShowMask = false {
        didSet {
            self.maskView.isHidden = !isShowMask
        }
    }
    
    fileprivate lazy var maskView: UIView = {
        let v = UIView()
        v.isHidden = true
        v.alpha = 0.0
        v.backgroundColor = UIColor.black.withAlphaComponent(0.15)
        return v
    }()
    lazy var containerView: UIView = {
        let v = UIView()
        self.view.addSubview(v)
        
        v.mLayout.constraint { (maker) in
            maker.set(type: .leading, value: 0)
            maker.set(type: .top, value: 0)
            maker.set(type: .bottom, value: 0)
            maker.set(type: .width, value: self.view.frame.width)
        }
        return v
    }()
    
    public private(set) var sliderMap = [SliderLocation:SliderManager]()
    var currentManager:SliderManager?
    
    override open func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let s = segue as? DrawerSegue,
            let p = sender as? SegueParams {
            
            if let config = p.config {
                config(segue.destination)
            }
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
    
    public var main: UIViewController? {
        willSet {
            main?.removeFromParent()
            main?.didMove(toParent: nil)
            main?.view.removeFromSuperview()
            main?.view.subviews.forEach({ $0.removeFromSuperview() })
            main?.endAppearanceTransition()
        } didSet {
            if let new = main {
                new.view.shadow(opacity: 0.4, radius: 5.0)
                new.view.addGestureRecognizer(mainPan)
                new.view.translatesAutoresizingMaskIntoConstraints = false
                containerView.insertSubview(new.view, belowSubview: maskView)
                new.view.mLayout.constraint { (maker) in
                    maker.set(type: .leading, value: 0)
                    maker.set(type: .top, value: 0)
                    maker.set(type: .bottom, value: 0)
                    maker.set(type: .trailing, value: 0)
                }
                self.view.layoutIfNeeded()
                self.addChild(new)
            }
        }
    }
    
     lazy var maskPan: UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(MMDrawerViewController.panAction(pan:)))
        return pan
    }()
    lazy var mainPan: UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(MMDrawerViewController.panAction(pan:)))
        return pan
    }()
    
    public var draggable: Bool = true {
        didSet{
            mainPan.isEnabled = draggable
            sliderMap.forEach { $0.1.sliderPan.isEnabled = draggable }
        }
    }
    
    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        self.containerView.mLayout.update { (make) in
            make.constraintMap[.width]?.constant = size.width
        }
        
        sliderMap.forEach { (_ ,value) in
            value.viewRotation(size: size)
        }
    }
    
    public func set(left: UIViewController, mode: SliderMode) {
        
        sliderMap[.left] = SliderManager(drawer:self)
        sliderMap[.left]?.showChangeBlock = { [weak self] _ in
            self?.checkShowResult()
        }
        sliderMap[.left]?.addSlider(slider: left, location: .left, mode: mode)
        self.view.layoutIfNeeded()
    }
    
    public func set(right: UIViewController , mode: SliderMode) {
        sliderMap[.right] = SliderManager(drawer: self)
        sliderMap[.right]?.addSlider(slider: right, location: .right, mode: mode)
        sliderMap[.right]?.showChangeBlock = { [weak self] _ in
            self?.checkShowResult()
        }
        
        self.view.layoutIfNeeded()
    }
    
    public func setLeft(mode: SliderMode) {
        sliderMap[.left]?.mode = mode
        self.view.layoutIfNeeded()
    }
    
    public func setRight(mode: SliderMode) {
        sliderMap[.right]?.mode = mode
        self.view.layoutIfNeeded()
    }
    
    public func set(main: UIViewController) {
        self.main = main
        self.view.layoutIfNeeded()
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
    
    public func setMainWith(identifier: String) {
        self.setController(identifier: identifier, params: SegueParams(type: "main", params: nil, config: nil))
    }
    
    public func setMain(identifier: String, config: ConfigBlock) {
        self.setController(identifier: identifier, params: SegueParams(type: "main", params: nil, config: config))
    }
    
    public func setLeftWith(identifier:String, mode: SliderMode) {
        self.setController(identifier: identifier, params: SegueParams(type: "left", params: mode, config: nil))
    }
    
    public func setLeft(identifier:String, mode: SliderMode, config: ConfigBlock) {
        self.setController(identifier: identifier, params: SegueParams(type: "left", params: mode, config: config))
    }
    
    public func setRightWith(identifier: String, mode: SliderMode) {
        self.setController(identifier: identifier, params: SegueParams(type: "right", params: mode, config: nil))
    }
    
    public func setRightWith(identifier: String, mode: SliderMode, config: ConfigBlock) {
        self.setController(identifier: identifier, params: SegueParams(type: "right", params: mode, config: config))
    }
    
    fileprivate func setController(identifier: String, params: SegueParams ) {
        self.performSegue(withIdentifier: identifier, sender: params)
    }
    
    fileprivate func checkShowResult() {
        var isShow = false
        sliderMap.forEach {
            if $0.value.isShow {
                isShow = true
            }
        }
        UIView.animate(withDuration: 0.15) { [weak self] in
            self?.maskView.alpha = (isShow) ? 1.0 : 0.0
        }
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if touches.first?.view == maskView {
            sliderMap.forEach {
                $0.value.show(isShow: false)
            }
        }
    }
}

extension MMDrawerViewController {
    @objc func panAction(pan:UIPanGestureRecognizer) {
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
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        containerView.addSubview(maskView)
        maskView.mLayout.constraint { (maker) in
            maker.set(type: .leading, value: 0)
            maker.set(type: .trailing, value: 0)
            maker.set(type: .top, value: 0)
            maker.set(type: .bottom, value: 0)
        }
        maskView.addGestureRecognizer(maskPan)

    }
}

