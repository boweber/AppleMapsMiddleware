//
//  File.swift
//  
//
//  Created by Bo Weber on 06.02.21.
//

import CombineRex
import MapKit

extension AppleMapsMiddleware {
    static let testableETA = EffectMiddleware<ETAAction, ETAAction, ETAState, (MKDirections.ETAResponse?, Error?)?>
        .onAction { action, dispatcher, _ in
            switch action.wrappedAction {
            case let .estimateETAFor(journey):
                return .promise(token: 1, from: dispatcher) { context, output in
                    let handler: MKDirections.ETAHandler = { response, error in
                        if let error = error {
                            output(ETAAction(wrappedAction: .fail(error, journey: journey)))
                        } else if let response = response {
                            output(ETAAction(wrappedAction: .receive(response)))
                        }
                    }
                    if let result = context.dependencies {
                        handler(result.0, result.1)
                    } else {
                        MKDirections(request: journey.request)
                            .calculateETA(completionHandler: handler)
                    }
                }
            case .cancel:
                return .toCancel(1)
            default:
                return .doNothing
            }
        }
    
    /// A middleware that estimates information of a journey, based on details provided by an incoming `ETAAction`.
    public static let eta = testableETA
        .inject(nil)
        .eraseToAnyMiddleware()
}



