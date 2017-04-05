# MMDrawController

[![CI Status](http://img.shields.io/travis/millmanyang@gmail.com/MMDrawController.svg?style=flat)](https://travis-ci.org/millmanyang@gmail.com/MMDrawController)
[![Version](https://img.shields.io/cocoapods/v/MMDrawController.svg?style=flat)](http://cocoapods.org/pods/MMDrawController)
[![License](https://img.shields.io/cocoapods/l/MMDrawController.svg?style=flat)](http://cocoapods.org/pods/MMDrawController)
[![Platform](https://img.shields.io/cocoapods/p/MMDrawController.svg?style=flat)](http://cocoapods.org/pods/MMDrawController)

## Demo
landscape

![demo](https://github.com/MillmanY/MMDrawController/blob/master/demoFIle/landscape.gif)

portrait
    
![demo](https://github.com/MillmanY/MMDrawController/blob/master/demoFIle/portrait.gif)


## Requirements
   
    iOS 8.0+
    Xcode 8.0+
    Swift 3.0+    
## Use
1.Inherit your controller with MMDrawController
    
    class ViewController: MMDrawerViewController {
    }
    
3.Set main view controller
            
     super.setMainWith(identifier: "Home")

2.Set slider view controller
 
     // Init by storyboard identifier
     super.setLeftWith(identifier: "Member", mode: .frontWidthRate(r: 0.6))
     //Init by Code
     let story = UIStoryboard.init(name: "Main", bundle: nil)
     let right = story.instantiateViewController(withIdentifier: "SliderRight")
     super.set(right: right, mode: .rearWidth(w: 100))

3.Control MMDrawerController on your main or slider controller

     if let drawer = self.drawer() {
         drawer.showLeftSlider(isShow: true)
     }

## Installation

MMDrawController is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "MMDrawController"
```

## Author

millmanyang@gmail.com

## License

MMDrawController is available under the MIT license. See the LICENSE file for more info.
