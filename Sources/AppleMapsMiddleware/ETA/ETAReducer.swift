//
//  File.swift
//  
//
//  Created by Bo Weber on 06.02.21.
//

import SwiftRex

extension AppleMapsReducer {
    /// A reducer that updates an `ETAState` with details from an `ETAAction`.
    public static let eta = Reducer<ETAAction, ETAState>.reduce { action, state in
        switch action.wrappedAction {
        case .estimateETAFor:
            state = .estimating
        case let .fail(error, journey: details):
            state = .failed(error: error, journey: details)
        case .receive(let response):
            state = .received(response)
        case .cancel:
            state = .canceled
        }
    }
}
