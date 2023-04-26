//
//  Success.swift
//  PlayerKit
//
//  Created by Jovan Stojanov on 24.4.23..
//

import Foundation

extension Result where Success == Void {
    public static var success: Result { .success(()) }
}
