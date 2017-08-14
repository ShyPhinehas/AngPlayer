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

4.Use Delegate

		public func angPlayerCallback(loadStart player: AngPlayer){
    	    self.addSpinner()
    	}
        
    	public func angPlayerCallback(loadFinshied player: AngPlayer, isLoadSuccess: Bool, error: Error?){
        self.removeSpinner()
        if isLoadSuccess{
            self.angPlayer.play()
        }else{
            print("load error : \(String(describing: error?.localizedDescription))")
        }
    	}
        
    	public func angPlayerCallback(player: AngPlayer, statusPlayer: AVPlayerStatus, error: Error?){}
        
    	public func angPlayerCallback(player: AngPlayer, statusItemPlayer: AVPlayerItemStatus, error: Error?){}
        
    	public func angPlayerCallback(player: AngPlayer, loadedTimeRanges: [CMTimeRange]){
        	//set loaded range value to loaded Slide
        	/*
            	let durationTotal = loadedTimeRanges.reduce(0) { (actual, range) -> Double in
                	return actual + range.end.seconds
            	}
            	let dur2 = Float(durationTotal)
            	loadedPlaySlider?.value = dur2
         	*/
    	}
        
    	public func angPlayerCallback(player: AngPlayer, duration: Double){
        	//set play slide maxValue and load slile maxValue
        	/*
            	playSlider?.maximumValue = Float(duration)
            	loadedPlaySlider?.maximumValue = Float(duration)
         	*/
    	}
        
    	public func angPlayerCallback(player: AngPlayer, currentTime: Double){
        	//edit slide value by changing currentTime
        	//playSlider?.value = Float(currentTime)
    	}
        
    	public func angPlayerCallback(player: AngPlayer, rate: Float){
        	if rate == 0.0 {
            	//change play buton state to pause
        	}else{
            	//change play buton state to play
        	}
    	}
    	public func angPlayerCallback(player: AngPlayer, isLikelyKeepUp: Bool){
        	if isLikelyKeepUp{
            	self.removeSpinner()
        	}else{
            	self.addSpinner()
        	}
 	   }
    
    	public func angPlayerCallback(playerFinished player: AngPlayer){}
        
    	public func angPlayerCallback(pangestureLocation touchLocation: CGPoint, valueLength: CGPoint){
        	self.angPlayer.changeVolumeByGesture(by: touchLocation)
    	}

## Author

skyphinehas@hanmail.net, montelia@naver.com

## License

AngPlayer is available under the MIT license. See the LICENSE file for more info.
