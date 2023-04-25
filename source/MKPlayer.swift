//
//  Player.swift
//  PlayerSDK
//
//  Created by Jovan Stojanov on 24.4.23..
//

import Foundation
import UIKit

@objcMembers public final class MKPlayer: NSObject {
    private var playerController: PlayerViewController
    public init(config: MKConfig, view: UIView, controller: UIViewController){
        playerController = PlayerViewController(config:config, containerView: view, controller: controller)
    }
    public func remove() {
        playerController.stop()
        if playerController.presentingViewController != nil {
            playerController.dismiss(animated: false)
        } else {
            playerController.view.removeFromSuperview()
            playerController.removeFromParent()
        }
    }
}
