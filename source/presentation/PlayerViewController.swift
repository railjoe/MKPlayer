//
//  PlayerViewController.swift
//  PlayerKit
//
//  Created by Jovan Stojanov on 24.4.23..
//

import UIKit
import AVFoundation

#if canImport(GoogleInteractiveMediaAds)
import GoogleInteractiveMediaAds
#endif

class PlayerViewController: UIViewController, PlayerDelegate {
    var contentPlayhead: IMAAVPlayerContentPlayhead?
    
    @IBOutlet weak var liveView: UIView!
    @IBOutlet weak var liveLbl: UILabel!
    @IBOutlet weak var playButton: UIButton!
    
    var adContainerView: UIView?
    @IBOutlet weak var overlayView: UIView!
    
    @IBOutlet weak var controlsView: UIView!
    @IBOutlet weak var progressLbl: UILabel!
    @IBOutlet weak var volumeBtn: UIButton!
    @IBOutlet weak var fullscreenButton: UIButton!
    @IBOutlet weak var airplayButton: UIButton!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private let avplayer = AVPlayer()
    private let player: RegularPlayer
    private weak var containerView: UIView?
    private weak var controller: UIViewController?
    private var config: MKConfig
    private var alertWindow: UIWindow?
    var autoplay = true
    var isStream = false
    var timer: Timer?
    var stackedEvents = [PlayerEvent.EventType.video_percent_25, PlayerEvent.EventType.video_percent_50, PlayerEvent.EventType.video_percent_75, PlayerEvent.EventType.video_percent_95]
    private let repository: EventRepository = DefaultEventRepository(dataTransferService: DefaultDataTransferService(with: DefaultNetworkService(config: ApiDataNetworkConfig(baseURL: URL(string: "https://moa.mediaoutcast.com/")!), logger: DefaultNetworkErrorLogger())))
    
    private var started = false
    
#if canImport(GoogleInteractiveMediaAds)
    var adsLoader: IMAAdsLoader?
    var adsManager: IMAAdsManager?
#endif
    
    init(config: MKConfig, containerView: UIView, controller: UIViewController){
        self.config = config
        self.containerView = containerView
        self.controller = controller
        self.player = RegularPlayer(player: avplayer, seekTolerance: nil)
        super.init(nibName: "PlayerViewController", bundle: Bundle(for: Self.self))
        fireEvent(PlayerEvent.EventType.initalize)
        addToContainer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator .animate { [weak self] context in
            if self?.presentingViewController == nil {
                let statusBarOrientation = UIApplication.shared.statusBarOrientation
                if statusBarOrientation.isLandscape {
                    
#if canImport(GoogleInteractiveMediaAds)
                    if(self?.adsManager?.adPlaybackInfo.isPlaying == false) {
                        self?.enterFullscreen()
                    }
#else
                    self?.enterFullscreen()
#endif
                }
            }
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addPlayerToView()
        player.delegate = self
        if let url = URL(string: config.url ?? "") {
            player.set(AVURLAsset(url: url))
        }
        if config.mute {
            player.volume = 0
        }
        autoplay = config.autoplay
        
        
#if canImport(GoogleInteractiveMediaAds)
        if config.adTag != nil {
            overlayView.alpha = 1.0
            controlsView.alpha = 0
            slider.alpha = 0
            contentPlayhead = IMAAVPlayerContentPlayhead(avPlayer: avplayer)
            setUpAdsLoader()
        } else {
            toggleOverlay(action: .show)
        }
#else
        toggleOverlay(action: .show)
#endif
    }
    
    func hideContentPlayer() {
        overlayView.isHidden = true
        player.view.isHidden = true
    }
    
    func showContentPlayer() {
        controlsView.alpha = 1.0
        slider.alpha = 1.0
        overlayView.isHidden = false
        player.view.isHidden = false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        return .allButUpsideDown
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if presentingViewController != nil {
            fullscreenButton.isSelected = true
        } else {
            fullscreenButton.isSelected = false
        }
    }
    
    func start(){
        started = true
#if canImport(GoogleInteractiveMediaAds)
        if let adTag = config.adTag{
            requestAds(adTag: adTag)
        } else {
            controlsView.alpha = 1.0
            player.play()
            fireEvent(PlayerEvent.EventType.start)
        }
#else
        player.play()
        fireEvent(PlayerEvent.EventType.start)
#endif
    }
    
    func stop() {
        
    }
    
    private func addToContainer(){
        if let containerView = containerView, let controller = controller {
            player.fillMode = .fit
            view.frame = containerView.bounds
            view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            containerView.addSubview(view)
            controller.addChild(self)
            self.didMove(toParent: controller)
        }
    }
    
    private func enterFullscreen(){//_ updateOrientation: Bool = false
        //        if let controller = controller {
        self.view.removeFromSuperview()
        removeFromParent()
        //            self.view.frame = UIScreen.main.bounds
        self.modalPresentationStyle = .overCurrentContext
        //            controller.present(self, animated: false)
        
        alertWindow = UIWindow(frame: UIScreen.main.bounds)
        
        alertWindow?.windowLevel = UIWindow.Level.alert + 1
        alertWindow?.backgroundColor = UIColor.clear
        alertWindow?.rootViewController = UIViewController()
        alertWindow?.rootViewController?.view.backgroundColor = .black
        
        self.view.frame = alertWindow?.bounds ?? CGRectZero
        
        alertWindow?.addSubview(self.view)
        alertWindow?.makeKeyAndVisible()
        alertWindow?.rootViewController?.present(self, animated: false)
        
//        if updateOrientation {
//            if #available(iOS 16.0, *) {
//                controller?.setNeedsUpdateOfSupportedInterfaceOrientations()
//                UIApplication.shared.connectedScenes.forEach { scene in
//                    if let windowScene = scene as? UIWindowScene {
//                        windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .landscapeRight))
//                    }
//                }
//            } else {
//                UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
//            }
//        }
        //        }
    }
    
    // MARK: Setup
    
    private func addPlayerToView() {
        player.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        player.view.frame = self.view.bounds
        self.view.insertSubview(player.view, at: 0)
        
        //        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(playerDoubleTapped))
        //        doubleTapRecognizer.numberOfTapsRequired = 2
        //        player.view.addGestureRecognizer(doubleTapRecognizer)
        
        let singleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(playerTapped))
        singleTapRecognizer.numberOfTapsRequired = 1
        //        singleTapRecognizer.require(toFail: doubleTapRecognizer)
        player.view.addGestureRecognizer(singleTapRecognizer)
        
        let singleTapRecognizer1 = UITapGestureRecognizer(target: self, action: #selector(overlayTapped))
        singleTapRecognizer1.numberOfTapsRequired = 1
        overlayView.addGestureRecognizer(singleTapRecognizer1)
        
        slider.addTarget(self, action: #selector(onSliderValChanged(slider:event:)), for: .valueChanged)
        
        player.view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleDismiss)))
        overlayView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleDismiss)))
        
        let landscapeLongPress = UILongPressGestureRecognizer(target: self, action:  #selector(self.tapAndSlide(_:)))
        landscapeLongPress.minimumPressDuration = 0
        slider.addGestureRecognizer(landscapeLongPress)
    }
    var animatingSlider = false
    @objc func tapAndSlide(_ gestureRecognizer: UILongPressGestureRecognizer){
        guard let slider = gestureRecognizer.view as? UISlider else {
            return
        }
        let pt = gestureRecognizer.location(in: slider)
        let trackRect = slider.trackRect(forBounds: slider.bounds)
        let thumbWidth = slider.thumbRect(forBounds: slider.bounds, trackRect: trackRect, value: slider.value).width
        
        var value: Float = 0.0
        
        if pt.x <= thumbWidth / 2.0 {
            value = slider.minimumValue
        }
        else if pt.x >= slider.bounds.size.width - thumbWidth / 2.0 {
            value = slider.maximumValue;
        }
        else {
            let percentage = (pt.x - thumbWidth/2.0)/(slider.bounds.size.width - thumbWidth)
            let delta = Float(percentage) * (slider.maximumValue - slider.minimumValue)
            value = slider.minimumValue + delta;
        }
        
        if gestureRecognizer.state == .began {
            self.animatingSlider = true
            
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut) {
                slider.setValue(value, animated: true)
            }
        }
        else {
            slider.value = value
        }
        
        if gestureRecognizer.state == .ended {
            self.animatingSlider = false
            slider.sendActions(for: .valueChanged)
        }
    }
    
    var viewTranslation = CGPoint(x: 0, y: 0)
    @objc func handleDismiss(sender: UIPanGestureRecognizer) {
        if presentingViewController != nil {
            switch sender.state {
            case .changed:
                viewTranslation = sender.translation(in: view)
                if viewTranslation.y > 0 {
                    if viewTranslation.y > 256 {
                        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                            self.view.transform = .identity
                        })
                    } else {
                        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                            self.view.transform = CGAffineTransform(translationX: self.viewTranslation.x, y: self.viewTranslation.y)
                        })
                    }
                } else {
                    if viewTranslation.y < -256 {
                        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                            self.view.transform = .identity
                        })
                    } else {
                        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                            self.view.transform = CGAffineTransform(translationX: self.viewTranslation.x, y: self.viewTranslation.y)
                        })
                    }
                }
            case .ended:
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    self.view.transform = .identity
                })
                if viewTranslation.y >= 256 {
                    exitFullScreen()
                }
            default:
                break
            }
        }
    }
    
    @objc func onSliderValChanged(slider: UISlider, event: UIEvent) {
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
            case .began:
                // handle drag began
                toggleOverlay(action: .keep)
            case .moved:
                // handle drag moved
                toggleOverlay(action: .keep)
            case .ended:
                // handle drag ended
                toggleOverlay(action: .hide)
            default:
                break
            }
        }
    }
    
    @objc private func overlayTapped() {
        toggleOverlay(action: .hide)
    }
    
    @objc private func playerTapped() {
        toggleOverlay(action: .toggle)
    }
    
    @objc private func playerDoubleTapped() {
        if presentingViewController != nil {
            if player.fillMode == .fit {
                player.fillMode = .fill
            } else {
                player.fillMode = .fit
            }
        }
    }
    // MARK: Actions
    
    @IBAction func didTapPlayButton() {
        if started {
            if self.player.playing {
                self.player.pause()
                fireEvent(PlayerEvent.EventType.pause)
            } else {
                self.player.play()
                fireEvent(PlayerEvent.EventType.play)
            }
        } else {
            start()
        }
    }
    
    @IBAction func didChangeSliderValue() {
        let value = Double(self.slider.value)
        
        let time = value * self.player.duration
        
        self.player.seek(to: time)
    }
    
    @IBAction func didTapMuteButton(){
        if player.volume > 0 {
            player.volume = 0.0
            volumeBtn.isSelected = true
        } else {
            player.volume = 1.0
            volumeBtn.isSelected = false
        }
        toggleOverlay(action: .none)
    }
    
    @IBAction func didTapFullScreenButton(){
        if presentingViewController == nil {
            enterFullscreen()
        } else {
            exitFullScreen()
        }
    }
    private func exitFullScreen() {
        dismiss(animated: false) { [weak self] in
            if self?.alertWindow != nil {
                self?.alertWindow?.dismiss()
                self?.alertWindow?.rootViewController = nil
                self?.alertWindow = nil
            }
            self?.addToContainer()
            
            if #available(iOS 16.0, *) {
                self?.controller?.setNeedsUpdateOfSupportedInterfaceOrientations()
                UIApplication.shared.connectedScenes.forEach { scene in
                    if let windowScene = scene as? UIWindowScene {
                        windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
                    }
                }
            } else {
                UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            }
        }
    }
    
    func playerDidUpdateState(player: Player, previousState: PlayerState) {
        self.activityIndicator.isHidden = true
        
        switch player.state {
        case .loading:
            
            self.activityIndicator.isHidden = false
            
        case .ready:
            if autoplay && !player.playing {
                autoplay = false
                start()
            }
            
            break
            
        case .failed:
            
            print("🚫 \(String(describing: player.error))")
        }
    }
    
    func playerDidUpdatePlaying(player: Player) {
        self.playButton.isSelected = player.playing
        if player.ended && started {
            fireEvent(PlayerEvent.EventType.complete)
            self.player.seek(to: 0)
            started = false
            exitFullScreen()
#if canImport(GoogleInteractiveMediaAds)
            adsLoader?.contentComplete()
            overlayView.alpha = 1.0
            controlsView.alpha = 0
            slider.alpha = 0
            toggleOverlay(action: .keep)
#endif
        }
    }
    
    func playerDidUpdateTime(player: Player) {
        guard player.duration > 0 else {
            progressLbl.text = nil
            liveView.isHidden = false
            slider.isHidden = true
            isStream = true
            return
        }
        isStream = false
        slider.isHidden = false
        liveView.isHidden = true
        let progress = player.time / player.duration
        slider.value =  Float(progress)
        
        if progress >= 0.25 && progress < 0.50 {
            if stackedEvents.contains(PlayerEvent.EventType.video_percent_25) {
                stackedEvents.removeAll { type in
                    type == PlayerEvent.EventType.video_percent_25
                }
                fireEvent(PlayerEvent.EventType.video_percent_25)
            }
        } else if progress >= 0.50 && progress < 0.75 {
            if stackedEvents.contains(PlayerEvent.EventType.video_percent_50) {
                stackedEvents.removeAll { type in
                    type == PlayerEvent.EventType.video_percent_50
                }
                fireEvent(PlayerEvent.EventType.video_percent_50)
            }
        } else if progress >= 0.75 && progress < 0.95 {
            if stackedEvents.contains(PlayerEvent.EventType.video_percent_75) {
                stackedEvents.removeAll { type in
                    type == PlayerEvent.EventType.video_percent_75
                }
                fireEvent(PlayerEvent.EventType.video_percent_75)
            }
        } else if progress >= 0.95 {
            if stackedEvents.contains(PlayerEvent.EventType.video_percent_95) {
                stackedEvents.removeAll { type in
                    type == PlayerEvent.EventType.video_percent_95
                }
                fireEvent(PlayerEvent.EventType.video_percent_95)
            }
        }
        let comps = max(player.duration.timeComponents(), 2)
        progressLbl.text = "\(player.time.asTime(comps)) / \(player.duration.asTime(comps))"
    }
    
    func playerDidUpdateBufferedTime(player: Player) {
        guard player.duration > 0 else {
            return
        }
        
        //        let ratio = Int((player.bufferedTime / player.duration) * 100)
        
        //        self.label.text = "Buffer: \(ratio)%"
    }
    
    private func fireEvent(_ event: PlayerEvent.EventType) {
        repository.sendMobileEvent(event: PlayerEvent(type: event, isStream: isStream, playerId: config.playerId, projectHash: config.projectHash, screen: config.screen)) { result in
            print(result)
        }
    }
    
    private func toggleOverlay(action: OverlayAction, toggleAfter: TimeInterval = 3.0) {
        switch(action){
        case .keep:
            if timer != nil {
                timer?.invalidate()
                timer = nil
            }
        case .none:
            if timer != nil {
                timer?.invalidate()
                timer = nil
            }
            timer = Timer.scheduledTimer(withTimeInterval: toggleAfter, repeats: false) { [weak self] timer in
                self?.toggleOverlay(action: .hide, toggleAfter: toggleAfter)
            }
            break
        case .toggle:
            if overlayView.alpha != 1 {
                UIView.animate(withDuration: 0.2) { [weak self] in
                    self?.overlayView.alpha = 1.0
                }
                timer = Timer.scheduledTimer(withTimeInterval: toggleAfter, repeats: false) { [weak self] timer in
                    self?.toggleOverlay(action: .hide, toggleAfter: toggleAfter)
                }
            } else {
                UIView.animate(withDuration: 0.2) { [weak self] in
                    self?.overlayView.alpha = 0.0
                }
            }
        case .show:
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.overlayView.alpha = 1.0
            }
            if timer != nil {
                timer?.invalidate()
                timer = nil
            }
            timer = Timer.scheduledTimer(withTimeInterval: toggleAfter, repeats: false) { [weak self] timer in
                self?.toggleOverlay(action: .hide, toggleAfter: toggleAfter)
            }
        case .hide:
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.overlayView.alpha = 0.0
            }
            if timer != nil {
                timer?.invalidate()
                timer = nil
            }
        }
    }
    
    enum OverlayAction {
        case keep
        case none
        case toggle
        case show
        case hide
    }
}

extension PlayerViewController: IMAAdsLoaderDelegate, IMAAdsManagerDelegate {
    
    func setUpAdsLoader() {
        let settings = IMASettings()
        settings.language = "sr"
        settings.autoPlayAdBreaks = true
        adsLoader = IMAAdsLoader(settings: settings)
        adsLoader?.delegate = self
    }
    
    func requestAds(adTag: String) {
        // Create ad display container for ad rendering.
        
        //        if let containerView = containerView {
        
        hideContentPlayer()
        let adContainerView = UIView(frame: view.bounds)
        adContainerView.backgroundColor = .black
        adContainerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(adContainerView, belowSubview: activityIndicator)
        activityIndicator.startAnimating()
        self.adContainerView = adContainerView
        
        let adDisplayContainer = IMAAdDisplayContainer(adContainer: adContainerView, viewController: self)
        activityIndicator.startAnimating()
        // Create an ad request with our ad tag, display container, and optional user context.
        let request = IMAAdsRequest(
            adTagUrl: adTag,
            adDisplayContainer: adDisplayContainer,
            contentPlayhead: contentPlayhead,
            userContext: nil)
        
        adsLoader?.requestAds(with: request)
        
        //        } else {
        //            activityIndicator.stopAnimating()
        //            player.play()
        //            fireEvent(PlayerEvent.EventType.start)
        //        }
    }
    
    func adsLoader(_ loader: IMAAdsLoader, adsLoadedWith adsLoadedData: IMAAdsLoadedData) {
        adsManager = adsLoadedData.adsManager
        adsManager?.delegate = self
        adsManager?.initialize(with: nil)
        activityIndicator.startAnimating()
    }
    
    func adsLoader(_ loader: IMAAdsLoader, failedWith adErrorData: IMAAdLoadingErrorData) {
        print("Error loading ads: " + (adErrorData.adError.message ?? "") )
        //        showContentPlayer()
        activityIndicator.stopAnimating()
        adContainerView?.removeFromSuperview()
        player.play()
        toggleOverlay(action: .show)
        fireEvent(PlayerEvent.EventType.start)
        
    }
    
    // MARK: - IMAAdsManagerDelegate
    
    func adsManager(_ adsManager: IMAAdsManager, didReceive event: IMAAdEvent) {
        // Play each ad once it has been loaded
        if event.type == IMAAdEventType.LOADED {
            activityIndicator.stopAnimating()
            adsManager.start()
            fireEvent(PlayerEvent.EventType.ad_start)
        }
        if event.type == IMAAdEventType.TAPPED {
            // You can also add allow the user to tap anywhere on the Ad to resume play
            if(!adsManager.adPlaybackInfo.isPlaying) {
                adsManager.resume()
            }
        }
    }
    
    func adsManager(_ adsManager: IMAAdsManager, didReceive error: IMAAdError) {
        activityIndicator.stopAnimating()
        adContainerView?.removeFromSuperview()
        player.play()
        toggleOverlay(action: .show)
        fireEvent(PlayerEvent.EventType.start)
    }
    
    func adsManagerDidRequestContentPause(_ adsManager: IMAAdsManager) {
        // Pause the content for the SDK to play ads.
        player.pause()
        hideContentPlayer()
    }
    
    func adsManagerDidRequestContentResume(_ adsManager: IMAAdsManager) {
        // Resume the content since the SDK is done playing ads (at least for now).
        showContentPlayer()
        adContainerView?.removeFromSuperview()
        player.play()
        toggleOverlay(action: .show)
        fireEvent(PlayerEvent.EventType.ad_end)
        fireEvent(PlayerEvent.EventType.start)
    }
}

extension UIWindow {
    func dismiss() {
        isHidden = true
        
        if #available(iOS 13, *) {
            windowScene = nil
        }
    }
}

extension Double {
    func asString(style: DateComponentsFormatter.UnitsStyle) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = style
        return formatter.string(from: self) ?? ""
    }
    
    func asTime(_ components: Int? = nil) -> String {
        var result = [Int]()
        if var components = components {
            var value = Int(self)
            while components > 0 {
                result.append(value % 60)
                value = value / 60
                components -= 1
            }
            if value > 0 {
                result.append(value)
            }
        } else {
            var value = Int(self)
            while value > 0 {
                result.append(value % 60)
                value = value / 60
            }
        }
        
        return String(result.reversed().map{
            String(format: "%02i", $0)
        }.joined(separator: ":"))
    }
    
    func timeComponents() -> Int {
        var value = Int(self)
        var result = 0
        while value > 0 {
            value = value / 60
            result = result + 1
        }
        return result
    }
}
