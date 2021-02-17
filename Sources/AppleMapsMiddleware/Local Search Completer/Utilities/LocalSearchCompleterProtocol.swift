//
//  File.swift
//  
//
//  Created by Bo Weber on 07.02.21.
//

import MapKit
import Combine

protocol LocalSearchCompleterProtocol {
    func updateCompleter(with queryFragment: String)
    func completerPublisher(
        resultTypes: MKLocalSearchCompleter.ResultType,
        filter: MKPointOfInterestFilter?,
        region: MKCoordinateRegion?
    ) -> AnyPublisher<LocalSearchCompleterAction, Never>
}
