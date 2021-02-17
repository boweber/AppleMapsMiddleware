//
//  File.swift
//  
//
//  Created by Bo Weber on 08.02.21.
//

import MapKit
import CombineRex
import SwiftRex

extension AppleMapsMiddleware {
    static let testableLocalSearchCompleter = EffectMiddleware<LocalSearchCompleterAction, LocalSearchCompleterAction, LocalSearchCompleterState, LocalSearchCompleterProtocol>
        .onAction { action, source, _ in
            switch action.wrappedAction {
            case .cancel:
                return .toCancel(1)
            case let .initilize(resultTypes: resultTypes, filter: filter, region: region):
                return Effect(token: 1) { context in
                    context
                        .dependencies
                        .completerPublisher(
                            resultTypes: resultTypes,
                            filter: filter,
                            region: region
                        )
                        .map { DispatchedAction($0, dispatcher: source) }
                        .eraseToAnyPublisher()
                }
            case .requestCompletionsFor(queryFragment: let queryFragment):
                return .fireAndForget { context in
                    context.dependencies.updateCompleter(with: queryFragment)
                }
            default:
                return .doNothing
            }
        }
    /// A middleware that provides completions for a query received by an incoming `LocalSearchCompleterAction`.
    public static let localSearchCompleter = testableLocalSearchCompleter
        .inject(LocalSearchCompleter())
        .eraseToAnyMiddleware()
}
