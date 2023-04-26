//
//  CMTime+Utilities.swift
//  PlayerKit
//
//  Created by Jovan Stojanov on 24.4.23..
//
//

import Foundation
import AVFoundation

extension CMTime {
    var timeInterval: TimeInterval? {
        if CMTIME_IS_INVALID(self) || CMTIME_IS_INDEFINITE(self) {
            return nil
        }
        
        return CMTimeGetSeconds(self)
    }
}
