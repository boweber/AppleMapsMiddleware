//
//  File.swift
//  
//
//  Created by Bo Weber on 08.02.21.
//

import SwiftRex

extension AppleMapsReducer {
    /// A reducer that updates an `LocalSearchCompleterState` with events from a `LocalSearchCompleterAction`.
    public static let localSearchCompleter = Reducer<LocalSearchCompleterAction, LocalSearchCompleterState>
        .reduce { action, state in
            switch action.wrappedAction {
            case .cancel:
                state = .canceled
            case .fail(let error):
                state = .failed(error)
            case .initilize:
                state = .initilized
            case .receive(let results):
                state = .received(results)
            case .requestCompletionsFor:
                state = .searching
            }
    }
}
