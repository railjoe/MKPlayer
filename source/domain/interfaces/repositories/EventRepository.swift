//
//  EventRepository.swift
//  PlayerKit
//
//  Created by Jovan Stojanov on 24.4.23..
//

import Foundation

protocol EventRepository {
    @discardableResult
    func sendMobileEvent(event: PlayerEvent,
                         completion: @escaping (Result<Void, Error>) -> Void) -> Cancellable?
}
