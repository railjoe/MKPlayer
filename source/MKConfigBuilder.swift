//
//  MKConfigBuilder.swift
//  PlayerSDK
//
//  Created by Jovan Stojanov on 25.4.23..
//

import Foundation

@objcMembers public final class MKConfigBuilder: NSObject {
    private var url: String?
    private var playerId: String?
    private var playerHash: String?
    private var mute: Bool?
    private var autoplay: Bool?
    private var lightTheme: Bool?
    
    public func with(url: String) -> MKConfigBuilder {
        self.url = url
        return self
    }
    public func with(playerId: String) -> MKConfigBuilder {
        self.playerId = playerId
        return self
    }
    public func with(playerHash: String) -> MKConfigBuilder {
        self.playerHash = playerHash
        return self
    }
    public func with(mute: Bool) -> MKConfigBuilder {
        self.mute = mute
        return self
    }
    public func with(autoplay: Bool) -> MKConfigBuilder {
        self.autoplay = autoplay
        return self
    }
    public func with(lightTheme: Bool) -> MKConfigBuilder {
        self.lightTheme = lightTheme
        return self
    }
    public func build() -> MKConfig {
        return MKConfig(url: url, playerId: playerId, playerHash: playerHash, mute: mute ?? false, autoplay: autoplay ?? true, lightTheme: lightTheme ?? true)
    }
}
