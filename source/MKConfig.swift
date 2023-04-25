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
    let playerHash: String?
    let autoplay: Bool
    let mute: Bool
    let lightTheme: Bool
    
    public init(url: String?, playerId: String?, playerHash: String?, mute: Bool = false, autoplay: Bool = true, lightTheme: Bool = true) {
        self.url = url
        self.playerId = playerId
        self.playerHash = playerHash
        self.autoplay = autoplay
        self.mute = mute
        self.lightTheme = lightTheme
    }
}
