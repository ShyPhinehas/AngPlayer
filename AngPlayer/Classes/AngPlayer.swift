//
//  TPlayer.swift
//  FoxPlayer
//
//  Created by littlefox on 2017. 7. 17..
//  Copyright © 2017년 LittleFox. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

public protocol AngPlayerViewDelegate: class {
    func angPlayerCallback(loadStart player: AngPlayer)
    func angPlayerCallback(loadFinshied player: AngPlayer, isLoadSuccess: Bool, error: Error?)
    func angPlayerCallback(player: AngPlayer, statusPlayer: AVPlayer.Status, error: Error?)
    func angPlayerCallback(player: AngPlayer, statusItemPlayer: AVPlayerItem.Status, error: Error?)
    func angPlayerCallback(player: AngPlayer, loadedTimeRanges: [CMTimeRange])
    func angPlayerCallback(player: AngPlayer, duration: Double)
    func angPlayerCallback(player: AngPlayer, currentTime: Double)
    func angPlayerCallback(player: AngPlayer, rate: Float)
    func angPlayerCallback(player: AngPlayer, isLikelyKeepUp: Bool)
    func angPlayerCallback(playerFinished player: AngPlayer)
    func angPlayerCallback(pangestureLocation touchLocation: CGPoint, valueLength: CGPoint)
}

public enum FileLocation {
    case bundle
    case cache_folder
    case document_folder
    
    public func url(filePath: String) -> URL?{
        if self == .bundle{
            let sepPath = filePath.components(separatedBy: ".")
            if sepPath.count > 1{
                if let path = Bundle.main.path(forResource: sepPath[0], ofType: sepPath[1]){
                    return URL(fileURLWithPath: path)
                }
            }
        }else{
            let folerType : FileManager.SearchPathDirectory = (self == .cache_folder) ? .cachesDirectory : .documentDirectory
            if let baseURL = FileManager.default.urls(for: folerType, in: .userDomainMask).first{
                return baseURL.appendingPathComponent(filePath)
            }
        }
        return nil
    }
}

public enum AngPlayerViewFillMode {
    case resizeAspect
    case resizeAspectFill
    case resize
    
    init?(videoGravity: AVLayerVideoGravity){
        switch videoGravity {
        case .resizeAspect:
            self = .resizeAspect
        case .resizeAspectFill:
            self = .resizeAspectFill
        case .resize:
            self = .resize
        default:
            return nil
        }
    }
    
    var AVLayerVideoGravity: AVLayerVideoGravity {
        get {
            switch self {
            case .resizeAspect:
                return .resizeAspect
            case .resizeAspectFill:
                return .resizeAspectFill
            case .resize:
                return .resize
            }
        }
    }
}

public class AngPlayer: UIView {
    
    private var statusContext = true
    private var statusItemContext = true
    private var statusKeepUpContext = true
    private var loadedContext = true
    private var durationContext = true
    private var currentTimeContext = true
    private var rateContext = true
    private var playerItemContext = true
    
    private let tPlayerTracksKey = "tracks"
    private let tPlayerPlayableKey = "playable"
    private let tPlayerDurationKey = "duration"
    private let tPlayerRateKey = "rate"
    private let tCurrentItemKey = "currentItem"
    
    private let tPlayerStatusKey = "status"
    private let tPlayerEmptyBufferKey = "playbackBufferEmpty"
    private let tPlaybackBufferFullKey = "playbackBufferFull"
    private let tPlayerKeepUpKey = "playbackLikelyToKeepUp"
    private let tLoadedTimeRangesKey = "loadedTimeRanges"
    
    fileprivate var beginPoint: CGPoint?
    fileprivate var beginVolume: Float?
    lazy fileprivate var _MPVolumeSlider: UISlider? = {
        return MPVolumeView().subviews.filter{NSStringFromClass($0.classForCoder) == "MPVolumeSlider"}.first as? UISlider
    }()
    
    var playerLayer: AVPlayerLayer {
        get {
            return self.layer as! AVPlayerLayer
        }
    }
    
    override public class var layerClass: Swift.AnyClass {
        get {
            return AVPlayerLayer.self
        }
    }
    
    private var timeObserverToken: AnyObject?
    private weak var lastPlayerTimeObserve: AVPlayer?
    
    //MARK: - Public Variables
    public weak var delegate: AngPlayerViewDelegate?
    
    fileprivate var player: AVPlayer? {
        get {
            return playerLayer.player
        }
        
        set {
            playerLayer.player = newValue
        }
    }
    
    
    public var fillMode: AngPlayerViewFillMode! {
        didSet {
            playerLayer.videoGravity = fillMode.AVLayerVideoGravity
        }
    }
    
    public var maximumDuration: TimeInterval? {
        get {
            if let playerItem = self.player?.currentItem {
                return CMTimeGetSeconds(playerItem.duration)
            }
            return nil
        }
    }
    
    public var currentTime: Double {
        get {
            guard let player = player else {
                return 0
            }
            return CMTimeGetSeconds(player.currentTime())
        }
        set {
            guard let timescale = player?.currentItem?.duration.timescale else {
                return
            }
            let newTime = CMTimeMakeWithSeconds(newValue, timescale)
            player!.seek(to: newTime,toleranceBefore: kCMTimeZero,toleranceAfter: kCMTimeZero)
        }
    }
    
    public var interval = CMTimeMake(1, 60) {
        didSet {
            if rate != 0 {
                addCurrentTimeObserver()
            }
        }
    }
    
    public var rate: Float {
        get {
            guard let player = player else {
                return 0
            }
            return player.rate
        }
        set {
            if newValue == 0 {
                removeCurrentTimeObserver()
            } else if rate == 0 && newValue != 0 {
                addCurrentTimeObserver()
            }
            
            player?.rate = newValue
        }
    }
    
    public func availableDuration() -> CMTimeRange {
        let range = self.player?.currentItem?.loadedTimeRanges.first
        if let range = range {
            return range.timeRangeValue
        }
        return kCMTimeRangeZero
    }
    
    public var url: URL? {
        didSet {
            guard let url = url else {
                return
            }
            self.preparePlayer(url: url)
        }
    }
    
    public var urls: [URL?]! {
        didSet {
            guard let _ = urls?.first else {
                return
            }
            self.currentUrlNumber = 0
        }
    }
    
    public var currentUrlNumber : Int = 0 {
        didSet{
            if let _ = urls {
                if self.currentUrlNumber < 0 {
                    self.currentUrlNumber = 0
                }else if self.currentUrlNumber >= self.urls.count{
                    self.self.currentUrlNumber = self.urls.count - 1
                }
                
                self.url = urls[self.currentUrlNumber]
                
            }else{
                print("there is no urls")
            }
        }
    }
    
    public var isPrevAndNextBtnStatusInfo : (isPrevBtnEnable: Bool, isNextBtnEnable : Bool) {
        get{
            if let _ = urls{
                return (currentUrlNumber != 0, currentUrlNumber != urls.count - 1)
            }else{
                return (false, false)
            }
        }
    }
    
    public func preparePlayer(url: URL) {
        
        self.delegate?.angPlayerCallback(loadStart: self)
        
        resetPlayer()
        
        let asset = AVURLAsset(url: url)
        let requestKeys : [String] = [tPlayerTracksKey,tPlayerPlayableKey,tPlayerDurationKey]
        asset.loadValuesAsynchronously(forKeys: requestKeys) {
            DispatchQueue.main.async {
                for key in requestKeys{
                    var error: NSError?
                    let status = asset.statusOfValue(forKey: key, error: &error)
                    if status == .failed {
                        self.delegate?.angPlayerCallback(loadFinshied: self, isLoadSuccess: false, error: error)
                        return
                    }
                    
                    if asset.isPlayable == false{
                        self.delegate?.angPlayerCallback(loadFinshied: self, isLoadSuccess: false, error: error)
                        return
                    }
                }
                
                self.player = AVPlayer(playerItem: AVPlayerItem(asset:asset))
                self.addObserversPlayer(avPlayer: self.player!)
                self.addObserversVideoItem(playerItem: self.player!.currentItem!)
                self.delegate?.angPlayerCallback(loadFinshied: self, isLoadSuccess: true, error: nil)
            }
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initPlayer()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initPlayer()
    }
    
    deinit {
        delegate = nil
        resetPlayer()
    }
    
    private func initPlayer(){
        self.backgroundColor = UIColor.clear
        soundEnableAtBibrationOff()
        self.fillMode = .resizeAspect
    }
    
    private func soundEnableAtBibrationOff(){
        do{try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)}catch{}
    }
    
    private func addObserversPlayer(avPlayer: AVPlayer) {
        avPlayer.addObserver(self, forKeyPath: tPlayerStatusKey, options: [.new], context: &statusContext)
        avPlayer.addObserver(self, forKeyPath: tPlayerRateKey, options: [.new], context: &rateContext)
        avPlayer.addObserver(self, forKeyPath: tCurrentItemKey, options: [.old,.new], context: &playerItemContext)
    }
    
    private func removeObserversPlayer(avPlayer: AVPlayer) {
        
        avPlayer.removeObserver(self, forKeyPath: tPlayerStatusKey, context: &statusContext)
        avPlayer.removeObserver(self, forKeyPath: tPlayerRateKey, context: &rateContext)
        avPlayer.removeObserver(self, forKeyPath: tCurrentItemKey, context: &playerItemContext)
        
        if let timeObserverToken = timeObserverToken {
            avPlayer.removeTimeObserver(timeObserverToken)
        }
    }
    private func addObserversVideoItem(playerItem: AVPlayerItem) {
        playerItem.addObserver(self, forKeyPath: tLoadedTimeRangesKey, options: [], context: &loadedContext)
        playerItem.addObserver(self, forKeyPath: tPlayerDurationKey, options: [], context: &durationContext)
        playerItem.addObserver(self, forKeyPath: tPlayerStatusKey, options: [], context: &statusItemContext)
        playerItem.addObserver(self, forKeyPath: tPlayerKeepUpKey, options: [.new,.old], context: &statusKeepUpContext)
        NotificationCenter.default.addObserver(self, selector: #selector(AngPlayer.playerItemDidPlayToEndTime(aNotification:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
    }
    private func removeObserversVideoItem(playerItem: AVPlayerItem) {
        
        playerItem.removeObserver(self, forKeyPath: tLoadedTimeRangesKey, context: &loadedContext)
        playerItem.removeObserver(self, forKeyPath: tPlayerDurationKey, context: &durationContext)
        playerItem.removeObserver(self, forKeyPath: tPlayerStatusKey, context: &statusItemContext)
        playerItem.removeObserver(self, forKeyPath: tPlayerKeepUpKey, context: &statusKeepUpContext)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
    }
    
    private func removeCurrentTimeObserver() {
        
        if let timeObserverToken = self.timeObserverToken {
            lastPlayerTimeObserve?.removeTimeObserver(timeObserverToken)
        }
        timeObserverToken = nil
    }
    
    private func addCurrentTimeObserver() {
        removeCurrentTimeObserver()
        lastPlayerTimeObserve = player
        self.timeObserverToken = player?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { [weak self] time-> Void in
            if let mySelf = self {
                self?.delegate?.angPlayerCallback(player: mySelf, currentTime: mySelf.currentTime)
            }
            } as AnyObject?
    }
    
    @objc private func playerItemDidPlayToEndTime(aNotification: NSNotification) {
        self.delegate?.angPlayerCallback(playerFinished: self)
    }
    
    public func play() {
        rate = 1
    }
    
    public func pause() {
        rate = 0
    }
    
    public func stop() {
        currentTime = 0
        pause()
    }
    
    public func next(){
        guard let _ = urls else{
            return
        }
        currentUrlNumber += 1
    }
    
    public func prev(){
        guard let _ = urls else{
            return
        }
        currentUrlNumber -= 1
    }
    
    public func playFromBeginning() {
        self.player?.seek(to: kCMTimeZero)
        self.player?.play()
    }
    
    private func resetPlayer() {
        guard let player = player else {
            return
        }
        player.pause()
        
        removeObserversPlayer(avPlayer: player)
        
        if let playerItem = player.currentItem {
            removeObserversVideoItem(playerItem: playerItem)
        }
        
        self.player = nil
        
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if context == &statusContext {
            
            guard let avPlayer = player else {
                super.observeValue(forKeyPath: keyPath, of: object, change: change , context: context)
                return
            }
            self.delegate?.angPlayerCallback(player: self, statusPlayer: avPlayer.status, error: avPlayer.error)
            
        } else if context == &loadedContext {
            
            let playerItem = player?.currentItem
            
            guard let times = playerItem?.loadedTimeRanges else {
                return
            }
            
            let values = times.map({ $0.timeRangeValue})
            self.delegate?.angPlayerCallback(player: self, loadedTimeRanges: values)
            
        } else if context == &durationContext{
            
            if let currentItem = player?.currentItem {
                self.delegate?.angPlayerCallback(player: self, duration: currentItem.duration.seconds)
            }
            
        } else if context == &statusItemContext{
            //status of item has changed
            if let currentItem = player?.currentItem {
                self.delegate?.angPlayerCallback(player: self, statusItemPlayer: currentItem.status, error: currentItem.error)
            }
            
        } else if context == &rateContext{
            guard let newRateNumber = (change?[NSKeyValueChangeKey.newKey] as? NSNumber) else{
                return
            }
            let newRate = newRateNumber.floatValue
            if newRate == 0 {
                removeCurrentTimeObserver()
            } else {
                addCurrentTimeObserver()
            }
            
            self.delegate?.angPlayerCallback(player: self, rate: newRate)
            
        }else if context == &statusKeepUpContext{
            
            guard let newIsKeppupValue = (change?[NSKeyValueChangeKey.newKey] as? Bool) else{
                return
            }
            
            self.delegate?.angPlayerCallback(player: self, isLikelyKeepUp: newIsKeppupValue)
            
        } else if context == &playerItemContext{
            guard let oldItem = (change?[NSKeyValueChangeKey.oldKey] as? AVPlayerItem) else{
                return
            }
            removeObserversVideoItem(playerItem: oldItem)
            guard let newItem = (change?[NSKeyValueChangeKey.newKey] as? AVPlayerItem) else{
                return
            }
            addObserversVideoItem(playerItem: newItem)
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change , context: context)
        }
    }
}

extension AngPlayer : UIGestureRecognizerDelegate {
    
    public func addPanGesture() {
        let panGesture: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(AngPlayer.handlePanGestureRecognizer(_:)))
        self.addGestureRecognizer(panGesture)
    }
    
    @objc private func handlePanGestureRecognizer(_ gestureRecognizer : UIPanGestureRecognizer) {
        let touchLocation = gestureRecognizer.location(in: self)
        if let _ = beginPoint {
            self.delegate?.angPlayerCallback(pangestureLocation: touchLocation, valueLength: CGPoint(x: (beginPoint!.x-touchLocation.x)/1000, y: (beginPoint!.y-touchLocation.y)/1000))
        }
    }
    
    public func changeVolumeByGesture(by touchLocation: CGPoint) {
        
        if let _ = beginPoint, let _ = beginVolume {
            let c: CGPoint = beginPoint!
            let a1: CGPoint = CGPoint(x: beginPoint!.x + 5, y: beginPoint!.y)
            let a2: CGPoint = touchLocation
            
            let angleRadian : CGFloat = atan((a2.y - c.y)/(a2.x - c.x)) - atan((a1.y - c.y)/(a1.x - c.x))
            let angleRadianToDegree : CGFloat = angleRadian * (180/CGFloat(Double.pi))
            
            let limitedDegree : CGFloat = 75
            
            if abs(angleRadianToDegree) > limitedDegree {
                
                let volume : Float = {
                    let v = beginVolume! - Float(touchLocation.y - beginPoint!.y)/1000
                    if v > 1 {return 1}
                    if v < 0 {return 0}
                    return v
                }()
                
                _MPVolumeSlider?.setValue(volume, animated: false)
            }
        }
    }
    
    public override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        beginPoint = (gestureRecognizer as? UIPanGestureRecognizer)?.location(in: self)
        beginVolume = _MPVolumeSlider?.value
        return true
    }
}

public extension AngPlayer {
    func screenshot() throws -> UIImage? {
        guard let time = player?.currentItem?.currentTime() else {
            return nil
        }
        return try screenshotCMTime(cmTime: time)?.0
    }
    
    func screenshotTime(time: Double? = nil) throws -> (UIImage, photoTime: CMTime)?{
        guard let timescale = player?.currentItem?.duration.timescale else {
            return nil
        }
        
        let timeToPicture: CMTime
        if let time = time {
            timeToPicture = CMTimeMakeWithSeconds(time, timescale)
        } else if let time = player?.currentItem?.currentTime() {
            timeToPicture = time
        } else {
            return nil
        }
        return try screenshotCMTime(cmTime: timeToPicture)
    }
    
    private func screenshotCMTime(cmTime: CMTime) throws -> (UIImage,photoTime: CMTime)? {
        guard let player = player , let asset = player.currentItem?.asset else {
            return nil
        }
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        var timePicture = kCMTimeZero
        imageGenerator.appliesPreferredTrackTransform = true
        imageGenerator.requestedTimeToleranceAfter = kCMTimeZero
        imageGenerator.requestedTimeToleranceBefore = kCMTimeZero
        
        let ref = try imageGenerator.copyCGImage(at: cmTime, actualTime: &timePicture)
        let viewImage: UIImage = UIImage(cgImage: ref)
        return (viewImage, timePicture)
    }
}


