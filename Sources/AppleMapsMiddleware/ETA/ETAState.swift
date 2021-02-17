//
//  File.swift
//  
//
//  Created by Bo Weber on 06.02.21.
//

import MapKit

/// A current state of an eta estimation.
public enum ETAState: CustomStringConvertible {
    case initial
    case estimating
    case failed(error: Error, journey: Journey)
    case received(MKDirections.ETAResponse)
    case canceled
    
    public var description: String {
        switch self {
        case .initial: return "Initial"
        case .estimating: return "Estimating"
        case let .failed(error: error, journey: journey):
            return "Estimation failed for \(journey), due to \(error.localizedDescription)"
        case .received(let response):
            return "Received \(response)"
        case .canceled: return "Canceled"
        }
    }
}
