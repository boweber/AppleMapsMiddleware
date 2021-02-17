//
//  File.swift
//  
//
//  Created by Bo Weber on 08.02.21.
//

import MapKit

/// An action to request completions for a query fragment. The completions are provided by the Apple Maps api,
public struct LocalSearchCompleterAction {
    let wrappedAction: WrappedAction
    
    enum WrappedAction {
        case initilize(
                resultTypes: MKLocalSearchCompleter.ResultType,
                filter: MKPointOfInterestFilter?,
                region: MKCoordinateRegion?
             )
        case requestCompletionsFor(queryFragment: String)
        case fail(Error)
        case cancel
        case receive([MKLocalSearchCompletion])
    }
}

public extension LocalSearchCompleterAction {
    /// Creates an `LocalSearchCompleterAction` to cancel the currently running completion request.
    static let cancel = LocalSearchCompleterAction(wrappedAction: .cancel)
    
    /// Creates an `LocalSearchCompleterAction` to initilize a completion request
    /// - Parameters:
    ///   - resultTypes: Result types to reduce the search spectrum.
    ///   - filter: Point of interest filter to reduce the search spectrum.
    ///   - region: Region to reduce the search spectrum.
    /// - Returns: An `LocalSearchCompleterAction` containing the completion request details.
    static func initilize(
        resultTypes: MKLocalSearchCompleter.ResultType,
        filter: MKPointOfInterestFilter?,
        region: MKCoordinateRegion?
    ) -> LocalSearchCompleterAction {
        LocalSearchCompleterAction(
            wrappedAction: .initilize(resultTypes: resultTypes, filter: filter, region: region)
        )
    }
    
    /// Creates an `LocalSearchCompleterAction` to request completions.
    /// - Parameter queryFragment: A query fragment to search for.
    /// - Returns: An `LocalSearchCompleterAction` containing the query.
    static func requestCompletionsFor(queryFragment: String) -> LocalSearchCompleterAction {
        LocalSearchCompleterAction(wrappedAction: .requestCompletionsFor(queryFragment: queryFragment))
    }
}
