//
//  EventRepository.swift
//  PlayerSDK
//
//  Created by Jovan Stojanov on 25.4.23..
//

import Foundation

protocol EventRepository {
    @discardableResult
    func sendMobileEvent(event: PlayerEvent,
                         completion: @escaping (Result<Void, Error>) -> Void) -> Cancellable?
}
