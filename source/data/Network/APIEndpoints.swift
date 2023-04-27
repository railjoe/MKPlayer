//
//  APIEndpoints.swift
//  PlayerKit
//
//  Created by Jovan Stojanov on 24.4.23..
//

import Foundation

struct APIEndpoints {
    static func mobileView(with playerEvent: PlayerEvent) -> Endpoint<Void> {
        return Endpoint(path: "api/mobile-video",
                        method: .post,
                        headerParameters: ["accept":"application/json", "Content-Type": "application/json"],
                        bodyParametersEncodable: playerEvent
        )
    }
}
