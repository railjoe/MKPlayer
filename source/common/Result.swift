//
//  Success.swift
//  PlayerSDK
//
//  Created by Jovan Stojanov on 25.4.23..
//

import Foundation

extension Result where Success == Void {
    public static var success: Result { .success(()) }
}
