//
//  ViewController.swift
//  AngPlayer
//
//  Created by skyphinehas@hanmail.net on 08/04/2017.
//  Copyright (c) 2017 skyphinehas@hanmail.net. All rights reserved.
//

import UIKit
import AVFoundation

/**
 1. file in Resaurce
 angPlayer.url = FileLocation.bundle.url(filePath: "001.mp4")
 
 2. web
 angPlayer.url = URL(string: "http://www.littlefox.net/app/api/m3u8/MDAwMDcwNDQ1MDA4MTAxMjAxNjAyMDIxNDA3MzQ5OTY0NTAyMDE3MTQzOHwzNzE0MTAzOHw1MjU5OTM5OXxXfDY0MCoxMTM2fGtvfEtSfDR8MTg")
 
 3. files
 let urls : [URL?] = [
 URL(string: "https://bitdash-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8"),
 URL(string: "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8"),
 URL(string: "https://mnmedias.api.telequebec.tv/m3u8/29880.m3u8"),
 FileLocation.bundle.url(filePath: "001.mp4"),
 ]
 angPlayer.urls = urls
 */

open class AngPlayerVC: UIViewController, AngPlayerViewDelegate {

    var angPlayer: AngPlayer!
    var spinner : UIActivityIndicatorView?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        angPlayer = AngPlayer(frame: UIScreen.main.bounds)
        angPlayer.delegate = self
        self.view.addSubview(angPlayer)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
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

    @IBAction func nextBtnCallback(_ sender: Any) {
        angPlayer.next()
    }
    
    @IBAction func prevBtnCallback(_ sender: Any) {
        angPlayer.prev()
    }
}

extension AngPlayerVC{
    
    public func addSpinner(isPreventouch: Bool = false) {
        removeSpinner()
        self.view.isUserInteractionEnabled = !isPreventouch
        spinner = UIActivityIndicatorView(frame: UIScreen.main.bounds)
        spinner?.activityIndicatorViewStyle = .white
        spinner?.startAnimating()
        self.view.addSubview(spinner!)
    }
    
    public func removeSpinner() {
        spinner?.stopAnimating()
        spinner?.removeFromSuperview()
        spinner = nil
    }
}
