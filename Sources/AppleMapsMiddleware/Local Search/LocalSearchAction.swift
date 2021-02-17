//
//  File.swift
//  
//
//  Created by Bo Weber on 06.02.21.
//

import MapKit

/// An action to request local search results for a query. The results are provided by the Apple Maps api,
public struct LocalSearchAction {
    let wrappedAction: WrappedAction
    
    enum WrappedAction {
        case searchWithQuery(query: String, region: MKCoordinateRegion?, resultTypes: MKLocalSearch.ResultType)
        case searchWithCompletion(MKLocalSearchCompletion)
        case fail(Error)
        case receive([MKMapItem])
        case cancel
        
        var request: MKLocalSearch.Request? {
            switch self {
            case .searchWithCompletion(let completion):
                return MKLocalSearch.Request(completion: completion)
            case let .searchWithQuery(query: query, region: region, resultTypes: resultTypes):
                let request = MKLocalSearch.Request()
                request.naturalLanguageQuery = query
                request.resultTypes = resultTypes
                region.map { request.region = $0 }
                return request
            default:
                return nil
            }
        }
    }
}

public extension LocalSearchAction {
    static func search(
        for query: String,
        in region: MKCoordinateRegion?,
        resultTypes: MKLocalSearch.ResultType
    ) -> LocalSearchAction {
        LocalSearchAction(wrappedAction: .searchWithQuery(query: query, region: region, resultTypes: resultTypes))
    }

    static func search(for completion: MKLocalSearchCompletion) -> LocalSearchAction {
        LocalSearchAction(wrappedAction: .searchWithCompletion(completion))
    }
    
    /// Creates an `LocalSearchAction` to cancel the currently running search request.
    static let cancel = LocalSearchAction(wrappedAction: .cancel)
}
