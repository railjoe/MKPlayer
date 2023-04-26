//
//  DefaultMoviesRepository.swift
//  PlayerKit
//
//  Created by Jovan Stojanov on 24.4.23..
//
// **Note**: DTOs structs are mapped into Domains here, and Repository protocols does not contain DTOs

import Foundation

final class DefaultEventRepository {

    private let dataTransferService: DataTransferService

    init(dataTransferService: DataTransferService) {
        self.dataTransferService = dataTransferService
    }
}

extension DefaultEventRepository: EventRepository {

    func sendMobileEvent(event: PlayerEvent,
                         completion: @escaping (Result<Void, Error>) -> Void) -> Cancellable? {

        let task = RepositoryTask()
        let endpoint = APIEndpoints.mobileView(with: event)
        task.networkTask = self.dataTransferService.request(with: endpoint) { result in
            switch result {
            case .success():
                completion(.success)
            case .failure(let error):
                completion(.failure(error))
            }
        }
        return task
    }
}
