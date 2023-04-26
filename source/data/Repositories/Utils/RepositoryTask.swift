//
//  RepositoryTask.swift
//  PlayerKit
//
//  Created by Jovan Stojanov on 24.4.23..
//

import Foundation

class RepositoryTask: Cancellable {
    var networkTask: NetworkCancellable?
    var isCancelled: Bool = false
    
    func cancel() {
        networkTask?.cancel()
        isCancelled = true
    }
}
