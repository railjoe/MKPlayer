//
//  APIEndpoints.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 01.10.18.
//

import Foundation

struct APIEndpoints {
    static func mobileView(with playerEvent: PlayerEvent) -> Endpoint<Void> {
        return Endpoint(path: "api/mobile-video",
                        method: .post,
                        bodyParametersEncodable: playerEvent)
    }
}
