//
//  Bundle+name.swift
//  PlayerSDK
//
//  Created by Jovan Stojanov on 25.4.23..
//

import Foundation

extension Bundle {
    var displayName: String? {
        return object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
    }
    var releaseVersionNumber: String? {
        return object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
    var buildVersionNumber: String? {
        return object(forInfoDictionaryKey: "CFBundleVersion") as? String
    }
}
