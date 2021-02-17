//
//  File.swift
//  
//
//  Created by Bo Weber on 06.02.21.
//

import MapKit

/// An action to estimate time of arrival informations. The calculation is carried out by the Apple Maps api.
public struct ETAAction {
    let wrappedAction: WrappedAction
    
    enum WrappedAction {
        case estimateETAFor(Journey)
        case cancel
        case fail(Error, journey: Journey)
        case receive(MKDirections.ETAResponse)
    }
    
    /// Creates an `ETAAction` to cancel the currently running estimation.
    public static let cancel = ETAAction(wrappedAction: .cancel)
    
    /// Creates an `ETAAction` to estimate time of arrival informations.
    /// - Parameter journey: Contains details about a route.
    /// - Returns: An `ETAAction` containing the provided routing details.
    public static func calculateETA(for journey: Journey) -> ETAAction {
        ETAAction(wrappedAction: .estimateETAFor(journey))
    }
}

