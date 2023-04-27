//
//  PlayerEvent.swift
//  PlayerSDK
//
//  Created by Jovan Stojanov on 25.4.23..
//

import Foundation
import UIKit

struct PlayerEvent: Codable {
    let type: EventType
    let isStream: Bool
//    let videoId: String?
    let playerId: String?
    let projectHash: String?
    let date: Int64 = Int64((Date().timeIntervalSince1970 * 1000.0).rounded())
    let device: String?
    let os: String?
    let osVersion: String?
    let app: String?
    let appVersion: String?
    let screen: String?
    let videoTitle: String?
    let poster: String?

    init(type: EventType, isStream: Bool, playerId: String?, projectHash: String?, screen: String? = nil , videoTitle: String? = nil, poster: String? = nil) {
        self.type = type
        self.isStream = isStream
        self.playerId = playerId
        self.projectHash = projectHash
        self.device = UIDevice.modelName
        self.os = UIDevice.current.systemName
        self.osVersion = UIDevice.current.systemVersion
        self.app = Bundle.main.displayName
        self.appVersion = Bundle.main.releaseVersionNumber
        self.screen = screen
//        self.videoId = videoId
        self.videoTitle = videoTitle
        self.poster = poster
    }
    
    enum CodingKeys: String, CodingKey {
        case type = "type"
        case isStream = "is_stream"
        case playerId = "player_id"
        case projectHash = "project_hash"
        case date = "date"
        case device = "device"
        case os = "os"
        case osVersion = "os_version"
        case app = "app"
        case appVersion = "app_version"
        case screen = "screen"
//        case videoId = "video_id"
        case videoTitle = "video_title"
        case poster = "poster"
    }
    
    enum EventType: String, Codable {
        case initalize = "init"
        case start = "start"
        case play = "play"
        case pause = "pause"
        case ad_start = "ad_start"
        case ad_end = "ad_end"
        case complete = "complete"
        case video_percent_25 = "video_percent_25"
        case video_percent_50 = "video_percent_50"
        case video_percent_75 = "video_percent_75"
        case video_percent_95 = "video_percent_95"
    }
}



