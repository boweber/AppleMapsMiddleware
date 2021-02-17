//
//  File.swift
//  
//
//  Created by Bo Weber on 06.02.21.
//

import MapKit

/// A current state of the a local search request.
public enum LocalSearchState: CustomStringConvertible {
    case initial
    case searching
    case canceled
    case received([MKMapItem])
    case failed(Error)
    
    public var description: String {
        switch self {
        case .initial: return "Initial"
        case .searching: return "Estimating"
        case .failed(let error):
            return "Searching failed due to \(error.localizedDescription)"
        case .received(let response):
            return "Received \(response)"
        case .canceled: return "Canceled"
        }
    }
}
