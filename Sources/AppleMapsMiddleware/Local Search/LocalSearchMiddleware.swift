//
//  File.swift
//  
//
//  Created by Bo Weber on 06.02.21.
//

import MapKit
import CombineRex

extension AppleMapsMiddleware {
    static let testableLocalSearch = EffectMiddleware<LocalSearchAction, LocalSearchAction, LocalSearchState, (MKLocalSearch.Response?, Error?)?>
        .onAction { action, source, _ in
            if let request = action.wrappedAction.request {
                return .promise(token: 1, from: source) { context, output in
                    let handler: MKLocalSearch.CompletionHandler = { response, error in
                        if let error = error {
                            output(LocalSearchAction(wrappedAction: .fail(error)))
                        } else if let response = response {
                            output(LocalSearchAction(wrappedAction: .receive(response.mapItems)))
                        }
                    }
                    
                    if let result = context.dependencies {
                        handler(result.0, result.1)
                    } else {
                        MKLocalSearch(request: request)
                            .start(completionHandler: handler)
                    }
                }
            } else if case .cancel = action.wrappedAction {
                return .toCancel(1)
            } else {
                return .doNothing
            }
        }

    /// A middleware that provides search results for a query received by an incoming `LocalSearchAction`.
    public static let localSearch = testableLocalSearch
        .inject(nil)
        .eraseToAnyMiddleware()
}

