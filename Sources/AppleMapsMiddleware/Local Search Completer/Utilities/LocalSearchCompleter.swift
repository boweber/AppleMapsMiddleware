//
//  File.swift
//  
//
//  Created by Bo Weber on 07.02.21.
//

import MapKit
import Combine

class LocalSearchCompleter: NSObject, MKLocalSearchCompleterDelegate, LocalSearchCompleterProtocol {
    var searchCompleter: MKLocalSearchCompleter?
    var actionPublisher: PassthroughSubject<LocalSearchCompleterAction, Never>?
    
    required override init() {
        self.searchCompleter = nil
        self.actionPublisher = nil
        super.init()
    }
    
    func completerPublisher(
        resultTypes: MKLocalSearchCompleter.ResultType,
        filter: MKPointOfInterestFilter?,
        region: MKCoordinateRegion?
    ) -> AnyPublisher<LocalSearchCompleterAction, Never> {
        let publisher = PassthroughSubject<LocalSearchCompleterAction, Never>()
        let completer = MKLocalSearchCompleter()
        completer.resultTypes = resultTypes
        completer.pointOfInterestFilter = filter
        completer.delegate = self
        region.map { completer.region = $0 }
        self.searchCompleter = completer
        self.actionPublisher = publisher
        return publisher
            .handleEvents(receiveCancel: { [weak self] in
                guard let self = self else { return }
                self.searchCompleter?.cancel()
                self.searchCompleter = nil
                self.actionPublisher = nil
            })
            .eraseToAnyPublisher()
    }

    func updateCompleter(with queryFragment: String) {
        searchCompleter?.queryFragment = queryFragment
    }

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        actionPublisher?.send(.init(wrappedAction: .receive(completer.results)))
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        actionPublisher?.send(.init(wrappedAction: .fail(error)))
    }
}
