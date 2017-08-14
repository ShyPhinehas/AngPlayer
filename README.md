# AngPlayer

[![CI Status](http://img.shields.io/travis/skyphinehas@hanmail.net/AngPlayer.svg?style=flat)](https://travis-ci.org/skyphinehas@hanmail.net/AngPlayer)
[![Version](https://img.shields.io/cocoapods/v/AngPlayer.svg?style=flat)](http://cocoapods.org/pods/AngPlayer)
[![License](https://img.shields.io/cocoapods/l/AngPlayer.svg?style=flat)](http://cocoapods.org/pods/AngPlayer)
[![Platform](https://img.shields.io/cocoapods/p/AngPlayer.svg?style=flat)](http://cocoapods.org/pods/AngPlayer)

##  Play your video more easly##



## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements
ios 8.0~
## Installation

AngPlayer is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "AngPlayer"
```

## useage

1. Make Player ViewController

		class PlayerVC: AngPlayerVC {
	
		}

2. Make Player

		var angPlayer: AngPlayer!
		override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        	super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        	angPlayer = AngPlayer(frame: UIScreen.main.bounds)
        	self.view.addSubview(angPlayer)
 		}
 
3. Link Url 
 
 	file in Resaurce 
        	 angPlayer.url = FileLocation.bundle.url(filePath: "001.mp4")
         
    web 
    	     angPlayer.url = URL(string: "http://<>")
         
    files
        	 let urls : [URL?] = [
                     URL(string: "https://<>.m3u8"),
                     URL(string: "https://<>.m3u8"),
                     URL(string: "https://<>0.m3u8"),
                     FileLocation.bundle.url(filePath: "001.mp4"),
         	]
         	angPlayer.urls = urls



## Author

skyphinehas@hanmail.net, montelia@naver.com

## License

AngPlayer is available under the MIT license. See the LICENSE file for more info.
