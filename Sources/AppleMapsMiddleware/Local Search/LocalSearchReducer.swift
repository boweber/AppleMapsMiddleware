//
//  File.swift
//  
//
//  Created by Bo Weber on 06.02.21.
//

import SwiftRex

extension AppleMapsReducer {
    /// A reducer that updates an `LocalSearchState` with events from a `LocalSearchAction`.
    public static let localSearch = Reducer<LocalSearchAction, LocalSearchState>
        .reduce { action, state in
            switch action.wrappedAction {
            case .cancel:
                state = .canceled
            case .fail(let error):
                state = .failed(error)
            case .receive(let results):
                state = .received(results)
            case .searchWithCompletion,
                 .searchWithQuery:
                state = .searching
            }
        }
}
