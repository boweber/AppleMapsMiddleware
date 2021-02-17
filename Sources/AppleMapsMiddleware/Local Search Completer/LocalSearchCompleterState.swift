//
//  File.swift
//  
//
//  Created by Bo Weber on 08.02.21.
//

import MapKit

/// A current state of the a local search completion.
public enum LocalSearchCompleterState: CustomStringConvertible {
    case initial
    case initilized
    case searching
    case received([MKLocalSearchCompletion])
    case failed(Error)
    case canceled
    
    public var description: String {
        switch self {
        case .initial: return "Initial"
        case .initilized: return "Initilized"
        case .searching: return "Estimating"
        case .failed(let error):
            return "Searching failed due to \(error.localizedDescription)"
        case .received(let response):
            return "Received \(response)"
        case .canceled: return "Canceled"
        }
    }
}
