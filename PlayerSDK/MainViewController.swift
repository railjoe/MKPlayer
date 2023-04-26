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

        //https://video.adriamedia.tv/2023/04/24/67704tqkmy/67704tqkmy.m3u8
        //https://kurir-tv.haste-cdn.net/providus/live2805.m3u8
        player = MKPlayer(config: MKConfigBuilder().with(url: "https://video.adriamedia.tv/2023/04/24/67704tqkmy/67704tqkmy.m3u8").with(playerId: "qwerwcd").with(projectHash: "kj4sdfq24").with(autoplay: false).with(lightTheme: true)
//            .with(adTag: "https://pubads.g.doubleclick.net/gampad/ads?iu=/21775744923/external/single_ad_samples&sz=640x480&cust_params=sample_ct%3Dlinear&ciu_szs=300x250%2C728x90&gdfp_req=1&output=vast&unviewed_position_start=1&env=vp&impl=s&correlator=")
            .build(), view: self.containerView, controller: self)
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
