//
//  MKConfig.swift
//  PlayerSDK
//
//  Created by Jovan Stojanov on 25.4.23..
//

import Foundation

@objcMembers public final class MKConfig: NSObject {
    let url: String?
    let playerId: String?
    let projectHash: String?
    let screen: String?
    let adTag: String?
    let autoplay: Bool
    let mute: Bool
    let lightTheme: Bool
    
    public init(url: String?, playerId: String?, projectHash: String?, screen: String?, adTag: String?, mute: Bool = false, autoplay: Bool = true, lightTheme: Bool = true) {
        self.url = url
        self.playerId = playerId
        self.projectHash = projectHash
        self.screen = screen
        self.adTag = adTag
        self.autoplay = autoplay
        self.mute = mute
        self.lightTheme = lightTheme
    }
}
