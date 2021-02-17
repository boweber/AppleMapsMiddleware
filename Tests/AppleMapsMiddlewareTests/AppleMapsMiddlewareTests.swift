import XCTest
import Combine
import MapKit
import CombineRex
import SwiftRex
@testable import AppleMapsMiddleware

final class AppleMapsMiddlewareTests: XCTestCase {
    var cancellables: Set<AnyCancellable>!
    let useAppleMaps = false

    override func setUp() {
        cancellables = []
    }
    
    override func tearDown() {
        cancellables.forEach { $0.cancel() }
    }

    // MARK: ETA Tests
    
    var exampleRoute: Journey {
        let bigBen = MKMapItem(
            placemark: MKPlacemark(
                coordinate: CLLocationCoordinate2D(latitude: 51.5007292, longitude: -0.1268141)
            )
        )
        let eiffelTower = MKMapItem(
            placemark: MKPlacemark(
                coordinate: CLLocationCoordinate2D(latitude: 48.8583701, longitude: 2.2922926)
            )
        )
        return Journey(start: bigBen, destination: eiffelTower, transportType: .automobile)
    }

    func testFailingETA() {
        let store = ReduxStoreBase<ETAAction, ETAState>(
            subject: .combine(initialValue: .initial),
            reducer: AppleMapsReducer.eta,
            middleware: AppleMapsMiddleware.testableETA.inject((nil, MKError(.placemarkNotFound))),
            emitsValue: .always
        )
        
        let expectInitialState = expectation(description: "Initial")
        let expectEstimating = expectation(description: "Estimating")
        let expectFailure = expectation(description: "Failed")
        
        store.statePublisher.sink { state in
            switch state {
            case .initial:
                expectInitialState.fulfill()
            case .estimating:
                expectEstimating.fulfill()
            case .failed(error: let error, journey: _):
                expectFailure.fulfill()
                XCTAssertEqual(error as! MKError, MKError(.placemarkNotFound))
            default: XCTFail()
            }
        }.store(in: &cancellables)
        
        store.dispatch(.calculateETA(for: exampleRoute))
        wait(for: [expectInitialState, expectEstimating, expectFailure], timeout: 1, enforceOrder: true)
    }
    
    func testSuccessfulETA() {
        let store = ReduxStoreBase<ETAAction, ETAState>(
            subject: .combine(initialValue: .initial),
            reducer: AppleMapsReducer.eta,
            middleware: AppleMapsMiddleware.testableETA.inject( (MKDirections.ETAResponse(), nil)),
            emitsValue: .always
        )
        
        let expectInitialState = expectation(description: "Initial")
        let expectEstimating = expectation(description: "Estimating")
        let expectSuccess = expectation(description: "Successful")
        
        store.statePublisher.sink { state in
            switch state {
            case .initial:
                expectInitialState.fulfill()
            case .estimating:
                expectEstimating.fulfill()
            case .received:
                expectSuccess.fulfill()
            default: XCTFail()
            }
        }.store(in: &cancellables)
        
        store.dispatch(.calculateETA(for: exampleRoute))
        wait(for: [expectInitialState, expectEstimating, expectSuccess], timeout: 3, enforceOrder: true)
    }
    
    func testCancelETA() {
        let store = ReduxStoreBase<ETAAction, ETAState>(
            subject: .combine(initialValue: .initial),
            reducer: AppleMapsReducer.eta,
            middleware: AppleMapsMiddleware.testableETA.inject((nil, MKError(.unknown))),
            emitsValue: .always
        )
        
        let expectInitialState = expectation(description: "Initial")
        let expectEstimating = expectation(description: "Estimating")
        let expectCancelation = expectation(description: "Canceled")
        
        store.statePublisher.sink { state in
            switch state {
            case .initial:
                expectInitialState.fulfill()
            case .estimating:
                expectEstimating.fulfill()
            case .canceled:
                expectCancelation.fulfill()
            default: XCTFail()
            }
        }.store(in: &cancellables)
        
        store.dispatch(.calculateETA(for: exampleRoute))
        store.dispatch(.cancel)
        wait(for: [expectInitialState, expectEstimating, expectCancelation], timeout: 3, enforceOrder: true)
    }
    
    func testETAWithCurrentLocation() throws {
        guard useAppleMaps else {
            throw XCTSkip()
        }
        throw XCTSkip("Currently failing")
        // Error:
        
        // "msg":"#Spi, CLInternalGetPrecisionPermission failed",
        // "error":"Error Domain=com.apple.locationd.internalservice.errorDomain Code=0 \"(null)\""
        
        let store = ReduxStoreBase<ETAAction, ETAState>(
            subject: .combine(initialValue: .initial),
            reducer: AppleMapsReducer.eta,
            middleware: AppleMapsMiddleware.eta,
            emitsValue: .always
        )
        
        let expectInitialState = expectation(description: "Initial")
        let expectEstimating = expectation(description: "Estimating")
        let expectSuccess = expectation(description: "Successful")
        
        store.statePublisher.sink { state in
            switch state {
            case .initial:
                expectInitialState.fulfill()
            case .estimating:
                expectEstimating.fulfill()
            case .received:
                expectSuccess.fulfill()
            default: XCTFail()
            }
        }.store(in: &cancellables)
        
        let eiffelTower = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 48.8583701, longitude: 2.2922926)))
        let details = Journey(start: .forCurrentLocation(), destination: eiffelTower, transportType: .automobile)
        
        store.dispatch(.calculateETA(for: details))
        wait(for: [expectInitialState, expectEstimating, expectSuccess], timeout: 6, enforceOrder: true)
    }
    
    func testETAWithAppleMaps() throws {
        guard useAppleMaps else {
            throw XCTSkip()
        }
        
        let store = ReduxStoreBase<ETAAction, ETAState>(
            subject: .combine(initialValue: .initial),
            reducer: AppleMapsReducer.eta,
            middleware: AppleMapsMiddleware.eta,
            emitsValue: .always
        )
        
        let expectInitialState = expectation(description: "Initial")
        let expectEstimating = expectation(description: "Estimating")
        let expectSuccess = expectation(description: "Successful")
        
        store.statePublisher.sink { state in
            switch state {
            case .initial:
                expectInitialState.fulfill()
            case .estimating:
                expectEstimating.fulfill()
            case .received(let response):
                XCTAssertEqual(23330.0, response.expectedTravelTime, accuracy: 1000)
                expectSuccess.fulfill()
            default: XCTFail()
            }
        }.store(in: &cancellables)
        
        store.dispatch(.calculateETA(for: exampleRoute))
        wait(for: [expectInitialState, expectEstimating, expectSuccess], timeout: 3, enforceOrder: true)
    }
    
    // MARK: - Local Search Completer tests
    
    func testSuccessfulCompleter() {
        let completer = MockLocalSearch()
        let store = ReduxStoreBase<LocalSearchCompleterAction, LocalSearchCompleterState>(
            subject: .combine(initialValue: .initial),
            reducer: AppleMapsReducer.localSearchCompleter,
            middleware: AppleMapsMiddleware.testableLocalSearchCompleter.inject(completer),
            emitsValue: .always
        )
        
        let expectInitialState = expectation(description: "Initial")
        let expectInitilized = expectation(description: "initilized")
        let expectSearching = expectation(description: "Searching")
        expectSearching.expectedFulfillmentCount = 3
        let expectSearchResults = expectation(description: "Received results")
        let expectCancellation = expectation(description: "Canceled")
        store.statePublisher.sink { state in
            switch state {
            case .initial:
                expectInitialState.fulfill()
            case .initilized:
                expectInitilized.fulfill()
            case .searching:
                expectSearching.fulfill()
            case .received:
                expectSearchResults.fulfill()
            case .canceled:
                expectCancellation.fulfill()
            default:
                print(state)
                XCTFail()
            }
        }
        .store(in: &cancellables)
        store.dispatch(.initilize(resultTypes: .pointOfInterest, filter: nil, region: nil))
        store.dispatch(.requestCompletionsFor(queryFragment: "Ne"))
        store.dispatch(.requestCompletionsFor(queryFragment: "New Y"))
        store.dispatch(.requestCompletionsFor(queryFragment: "New York"))
        completer.completerPublisher?.send(LocalSearchCompleterAction(wrappedAction: .receive([MKLocalSearchCompletion()])))
        wait(
            for: [
                expectInitialState,
                expectInitilized,
                expectSearching,
                expectSearchResults
            ],
            timeout: 1,
            enforceOrder: true
        )
        store.dispatch(.cancel)
        wait(for: [expectCancellation], timeout: 1)
    }
    
    func testFailingCompleter() {
        let completer = MockLocalSearch()
        let store = ReduxStoreBase<LocalSearchCompleterAction, LocalSearchCompleterState>(
            subject: .combine(initialValue: .initial),
            reducer: AppleMapsReducer.localSearchCompleter,
            middleware: AppleMapsMiddleware.testableLocalSearchCompleter.inject(completer),
            emitsValue: .always
        )
        
        let expectInitialState = expectation(description: "Initial")
        let expectInitilized = expectation(description: "initilized")
        let expectSearching = expectation(description: "Searching")
        expectSearching.expectedFulfillmentCount = 3
        let expectFailure = expectation(description: "Failed")
        store.statePublisher.sink { state in
            switch state {
            case .initial:
                expectInitialState.fulfill()
            case .initilized:
                expectInitilized.fulfill()
            case .searching:
                expectSearching.fulfill()
            case .failed:
                expectFailure.fulfill()
            default:
                print(state)
                XCTFail()
            }
        }
        .store(in: &cancellables)
        store.dispatch(.initilize(resultTypes: .pointOfInterest, filter: nil, region: nil))
        store.dispatch(.requestCompletionsFor(queryFragment: "Ne"))
        store.dispatch(.requestCompletionsFor(queryFragment: "New Y"))
        store.dispatch(.requestCompletionsFor(queryFragment: "New York"))
        completer.completerPublisher?.send(LocalSearchCompleterAction(wrappedAction: .fail(MKError(.serverFailure))))
        wait(
            for: [
                expectInitialState,
                expectInitilized,
                expectSearching,
                expectFailure
            ],
            timeout: 1,
            enforceOrder: true
        )
    }
    
    func testCompleterWithAppleMaps() throws {
        guard useAppleMaps else {
            throw XCTSkip()
        }

        let store = ReduxStoreBase<LocalSearchCompleterAction, LocalSearchCompleterState>(
            subject: .combine(initialValue: .initial),
            reducer: AppleMapsReducer.localSearchCompleter,
            middleware: AppleMapsMiddleware.localSearchCompleter,
            emitsValue: .always
        )
        
        let expectInitialState = expectation(description: "Initial")
        let expectInitilized = expectation(description: "initilized")
        let expectSearching = expectation(description: "Searching")
        expectSearching.expectedFulfillmentCount = 3
        let expectSearchResults = expectation(description: "Received results")
        let expectCancellation = expectation(description: "Canceled")
        store.statePublisher.sink { state in
            switch state {
            case .initial:
                expectInitialState.fulfill()
            case .initilized:
                expectInitilized.fulfill()
            case .searching:
                expectSearching.fulfill()
            case .received:
                expectSearchResults.fulfill()
            case .canceled:
                expectCancellation.fulfill()
            default:
                print(state)
                XCTFail()
            }
        }
        .store(in: &cancellables)
        store.dispatch(.initilize(resultTypes: .pointOfInterest, filter: nil, region: nil))
        store.dispatch(.requestCompletionsFor(queryFragment: "Ne"))
        store.dispatch(.requestCompletionsFor(queryFragment: "New Y"))
        store.dispatch(.requestCompletionsFor(queryFragment: "New York"))
        wait(
            for: [
                expectInitialState,
                expectInitilized,
                expectSearching,
                expectSearchResults
            ],
            timeout: 3,
            enforceOrder: true
        )
        store.dispatch(.cancel)
        wait(for: [expectCancellation], timeout: 1)
    }
    
    // MARK: - Local Search tests
    
    func testSuccessfulLocalSearch() {
        let store = ReduxStoreBase<LocalSearchAction, LocalSearchState>(
            subject: .combine(initialValue: .initial),
            reducer: AppleMapsReducer.localSearch,
            middleware: AppleMapsMiddleware.testableLocalSearch.inject((MKLocalSearch.Response(), nil)),
            emitsValue: .always
        )
        let expectInitialState = expectation(description: "Initial state")
        let expectSearchingState = expectation(description: "Searching")
        let expectSuccess = expectation(description: "Successful")
        store.statePublisher.sink { state in
            switch state {
            case .initial:
                expectInitialState.fulfill()
            case .searching:
                expectSearchingState.fulfill()
            case .received:
                expectSuccess.fulfill()
            default: XCTFail()
            }
        }.store(in: &cancellables)
        
        store.dispatch(.search(for: "New York", in: nil, resultTypes: .pointOfInterest))
        wait(for: [expectInitialState, expectSearchingState, expectSuccess], timeout: 1, enforceOrder: true)
    }
    
    func testFailingLocalSearch() {
        let store = ReduxStoreBase<LocalSearchAction, LocalSearchState>(
            subject: .combine(initialValue: .initial),
            reducer: AppleMapsReducer.localSearch,
            middleware: AppleMapsMiddleware.testableLocalSearch.inject((nil, MKError(.directionsNotFound))),
            emitsValue: .always
        )
        let expectInitialState = expectation(description: "Initial state")
        let expectSearchingState = expectation(description: "Searching")
        let expectFailure = expectation(description: "Failed")
        store.statePublisher.sink { state in
            switch state {
            case .initial:
                expectInitialState.fulfill()
            case .searching:
                expectSearchingState.fulfill()
            case .failed:
                expectFailure.fulfill()
            default: XCTFail()
            }
        }.store(in: &cancellables)
        
        store.dispatch(.search(for: "New York", in: nil, resultTypes: .pointOfInterest))
        wait(for: [expectInitialState, expectSearchingState, expectFailure], timeout: 1, enforceOrder: true)
    }
    
    func testCancelLocalSearch() {
        let store = ReduxStoreBase<LocalSearchAction, LocalSearchState>(
            subject: .combine(initialValue: .initial),
            reducer: AppleMapsReducer.localSearch,
            middleware: AppleMapsMiddleware.testableLocalSearch.inject((nil, nil)),
            emitsValue: .always
        )
        let expectInitialState = expectation(description: "Initial state")
        let expectSearchingState = expectation(description: "Searching")
        let expectCancellation = expectation(description: "Canceled")
        store.statePublisher.sink { state in
            switch state {
            case .initial:
                expectInitialState.fulfill()
            case .searching:
                expectSearchingState.fulfill()
            case .canceled:
                expectCancellation.fulfill()
            default: XCTFail()
            }
        }.store(in: &cancellables)
        
        store.dispatch(.search(for: "New York", in: nil, resultTypes: .pointOfInterest))
        store.dispatch(.cancel)
        wait(for: [expectInitialState, expectSearchingState, expectCancellation], timeout: 1, enforceOrder: true)
    }
    
    func testLocalSearchWithAppleMaps() throws {
        guard useAppleMaps else {
            throw XCTSkip()
        }
        let store = ReduxStoreBase<LocalSearchAction, LocalSearchState>(
            subject: .combine(initialValue: .initial),
            reducer: AppleMapsReducer.localSearch,
            middleware: AppleMapsMiddleware.localSearch,
            emitsValue: .always
        )
        let expectInitialState = expectation(description: "Initial state")
        let expectSearchingState = expectation(description: "Searching")
        let expectSuccess = expectation(description: "Successful")
        store.statePublisher.sink { state in
            switch state {
            case .initial:
                expectInitialState.fulfill()
            case .searching:
                expectSearchingState.fulfill()
            case .received:
                expectSuccess.fulfill()
            default: XCTFail()
            }
        }.store(in: &cancellables)
        
        store.dispatch(.search(for: "New York", in: nil, resultTypes: .pointOfInterest))
        wait(for: [expectInitialState, expectSearchingState, expectSuccess], timeout: 3, enforceOrder: true)
    }
    
    func testSuccessfulLocalSearchWithCompletion() {
        let store = ReduxStoreBase<LocalSearchAction, LocalSearchState>(
            subject: .combine(initialValue: .initial),
            reducer: AppleMapsReducer.localSearch,
            middleware: AppleMapsMiddleware.testableLocalSearch.inject((MKLocalSearch.Response(), nil)),
            emitsValue: .always
        )
        let expectInitialState = expectation(description: "Initial state")
        let expectSearchingState = expectation(description: "Searching")
        let expectSuccess = expectation(description: "Successful")
        store.statePublisher.sink { state in
            switch state {
            case .initial:
                expectInitialState.fulfill()
            case .searching:
                expectSearchingState.fulfill()
            case .received:
                expectSuccess.fulfill()
            default: XCTFail()
            }
        }.store(in: &cancellables)
        
        store.dispatch(.search(for: MKLocalSearchCompletion()))
        wait(for: [expectInitialState, expectSearchingState, expectSuccess], timeout: 1, enforceOrder: true)
    }
    
    func testFailingLocalSearchWithCompletion() {
        let store = ReduxStoreBase<LocalSearchAction, LocalSearchState>(
            subject: .combine(initialValue: .initial),
            reducer: AppleMapsReducer.localSearch,
            middleware: AppleMapsMiddleware.testableLocalSearch.inject((nil, MKError(.directionsNotFound))),
            emitsValue: .always
        )
        let expectInitialState = expectation(description: "Initial state")
        let expectSearchingState = expectation(description: "Searching")
        let expectFailure = expectation(description: "Failed")
        store.statePublisher.sink { state in
            switch state {
            case .initial:
                expectInitialState.fulfill()
            case .searching:
                expectSearchingState.fulfill()
            case .failed:
                expectFailure.fulfill()
            default: XCTFail()
            }
        }.store(in: &cancellables)
        
        store.dispatch(.search(for: MKLocalSearchCompletion()))
        wait(for: [expectInitialState, expectSearchingState, expectFailure], timeout: 1, enforceOrder: true)
    }
}

class MockLocalSearch: LocalSearchCompleterProtocol {
    var completerPublisher: PassthroughSubject<LocalSearchCompleterAction, Never>?
    
    init() {
        self.completerPublisher = nil
    }
    
    func updateCompleter(with queryFragment: String) {}
    
    func completerPublisher(
        resultTypes: MKLocalSearchCompleter.ResultType,
        filter: MKPointOfInterestFilter?,
        region: MKCoordinateRegion?
    ) -> AnyPublisher<LocalSearchCompleterAction, Never> {
        let publisher = PassthroughSubject<LocalSearchCompleterAction, Never>()
        self.completerPublisher = publisher
        return publisher
            .handleEvents(
                receiveCancel: { [weak self] in
                    self?.completerPublisher = nil
                }
            )
            .eraseToAnyPublisher()
    }
}
