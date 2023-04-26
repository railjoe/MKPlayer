//
//  PlayerView.swift
//  PlayerKit
//
//  Created by Jovan Stojanov on 24.4.23..
//

/// This file creates a `typealias` called `PlayerView` that determines which core view component to use depending on
/// which platform the binary is being compiled for. If iOS or tvOS, `UIKit` will be imported and `UIView` will be used.
/// otherwise, if macOS is used, `AppKit` will be imported and `NSView` will be used.

#if canImport(UIKit)
    import UIKit
    public typealias PlayerView = UIView
#elseif canImport(AppKit)
    import AppKit
    public typealias PlayerView = NSView
#endif
