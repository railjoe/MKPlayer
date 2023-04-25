//
//  MainViewController.swift
//  PlayerSDK
//
//  Created by Jovan Stojanov on 24.4.23..
//

import UIKit

class MainViewController: UIViewController {
    @IBOutlet weak var containerView: UIView!
    var player: MKPlayer!
    override func viewDidLoad() {
        super.viewDidLoad()

        
        player = MKPlayer(config: MKConfigBuilder().with(url: "https://kurir-tv.haste-cdn.net/providus/live2805.m3u8").with(playerId: "qwerwcd").with(playerHash: "kj4sdfq24").with(autoplay: true).with(lightTheme: true).build(), view: self.containerView, controller: self)
//        let playerViewController = PlayerViewController()
//        playerViewController.view.frame = self.containerView.bounds
//        playerViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        self.containerView.addSubview(playerViewController.view)
//        addChild(playerViewController)
        
        // Do any additional setup after loading the view.
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
