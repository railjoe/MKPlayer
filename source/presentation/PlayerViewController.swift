//
//  PlayerViewController.swift
//  PlayerKit
//
//  Created by King, Gavin on 3/8/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import AVFoundation

class PlayerViewController: UIViewController, PlayerDelegate {
    private struct Constants {
        static let VideoURL = URL(string: "https://kurir-tv.haste-cdn.net/providus/live2805.m3u8")!
    }
    
    @IBOutlet weak var liveView: UIView!
    @IBOutlet weak var liveLbl: UILabel!
    @IBOutlet weak var playButton: UIButton!
    
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var progressLbl: UILabel!
    @IBOutlet weak var volumeBtn: UIButton!
    @IBOutlet weak var fullscreenButton: UIButton!
    @IBOutlet weak var airplayButton: UIButton!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private let player = RegularPlayer()
    private weak var containerView: UIView?
    private weak var controller: UIViewController?
    private var config: MKConfig
    
    var autoplay = true
    var isStream = false
    var timer: Timer?
    
    private let repository: EventRepository = DefaultEventRepository(dataTransferService: DefaultDataTransferService(with: DefaultNetworkService(config: ApiDataNetworkConfig(baseURL: URL(string: "https://moa.mediaoutcast.com/")!), logger: DefaultNetworkErrorLogger())))
    
    private var firstStart = true
    
    init(config: MKConfig, containerView: UIView, controller: UIViewController){
        self.config = config
        self.containerView = containerView
        self.controller = controller
        super.init(nibName: nil, bundle: nil)
        fireEvent(PlayerEvent.EventType.initalize)
        addToContainer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func stop() {
        
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
        overlayView.alpha = 0.0
        toggleOverlay(action: .show)
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
    
    private func addToContainer(){
        if let containerView = containerView, let controller = controller {
            player.fillMode = .fit
            view.frame = containerView.bounds
            view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            containerView.addSubview(view)
            controller.addChild(self)
        }
    }
    
    private func addToFullscreen(){
        if let controller = controller {
            self.view.removeFromSuperview()
            removeFromParent()
            self.view.frame = UIScreen.main.bounds
            self.modalPresentationStyle = .fullScreen
            controller.present(self, animated: false)
        }
    }
    
    // MARK: Setup
    
    private func addPlayerToView() {
        player.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        player.view.frame = self.view.bounds
        self.view.insertSubview(player.view, at: 0)
        
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(playerDoubleTapped))
        doubleTapRecognizer.numberOfTapsRequired = 2
        player.view.addGestureRecognizer(doubleTapRecognizer)
        
        let singleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(playerTapped))
        singleTapRecognizer.numberOfTapsRequired = 1
        singleTapRecognizer.require(toFail: doubleTapRecognizer)
        player.view.addGestureRecognizer(singleTapRecognizer)
        
        let singleTapRecognizer1 = UITapGestureRecognizer(target: self, action: #selector(overlayTapped))
        singleTapRecognizer1.numberOfTapsRequired = 1
        overlayView.addGestureRecognizer(singleTapRecognizer1)
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
        if self.player.playing {
            self.player.pause()
            fireEvent(PlayerEvent.EventType.pause)
        } else {
            self.player.play()
            fireEvent(PlayerEvent.EventType.play)
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
            addToFullscreen()
        } else {
            dismiss(animated: false) { [weak self] in
                self?.addToContainer()
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
                player.play()
                fireEvent(PlayerEvent.EventType.play)
            }
            break
            
        case .failed:
            
            print("🚫 \(String(describing: player.error))")
        }
    }
    
    func playerDidUpdatePlaying(player: Player) {
        self.playButton.isSelected = player.playing
        if player.ended && !firstStart {
            fireEvent(PlayerEvent.EventType.complete)
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
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        progressLbl.text = "\(formatter.string(for: player.time) ?? "") / \(formatter.string(for: player.duration) ?? "")"
    }
    
    func playerDidUpdateBufferedTime(player: Player) {
        guard player.duration > 0 else {
            return
        }
        
        //        let ratio = Int((player.bufferedTime / player.duration) * 100)
        
        //        self.label.text = "Buffer: \(ratio)%"
    }
    
    private func fireEvent(_ event: PlayerEvent.EventType) {
        if event == PlayerEvent.EventType.play && firstStart {
            firstStart = false
            fireEvent(PlayerEvent.EventType.start)
        }
        repository.sendMobileEvent(event: PlayerEvent(type: event, isStream: isStream, playerId: config.playerId, projectHash: config.playerHash, videoId: config.playerId)) { result in
            print(result)
        }
    }
    
    private func toggleOverlay(action: OverlayAction, toggleAfter: TimeInterval = 3.0) {
        switch(action){
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
        case none
        case toggle
        case show
        case hide
    }
}
