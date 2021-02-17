# AppleMapsMiddleware

This package provides middlewares for [SwiftRex](https://github.com/SwiftRex/SwiftRex) handling *MapKit* related actions. 

## ETA 

In order to estimate the time of arrival, the first step is to create a `Journey` object containing facts about the intended route. This object can then be used to create an `ETAAction`, which, after it is dispatched, is handled by the eta middleware (`AppleMapsMiddleware.eta`). The accompanying reducer (`AppleMapsReducer.eta`) updates the state (`ETAState`) accordingly.

```swift
struct ETAAction {
    static let cancel: ETAAction
    static func calculateETA(for journey: Journey) -> ETAAction
}

enum ETAState {
    case initial
    case estimating
    case failed(error: Error, journey: Journey)
    case received(MKDirections.ETAResponse)
    case canceled
}
```

## Local Search

A dispatched `LocalSearchAction` object initializes a map related search, which is conducted by `AppleMapsMiddleware.localSearch` based on either a search query filtered by region and/or results types or a `MKLocalSearchCompletion` object. The `AppleMapsReducer.localSearch` object updates to current state with the resulting output of the middleware.

```swift
struct LocalSearchAction {
    static let cancel: LocalSearchAction
    static func search(for query: String, in region: MKCoordinateRegion?, resultTypes: MKLocalSearch.ResultType) -> LocalSearchAction
    static func search(for completion: MKLocalSearchCompletion) -> LocalSearchAction
}

enum LocalSearchState {
    case initial
    case searching
    case canceled
    case received([MKMapItem])
    case failed(Error)
}
```

## Local Search Completer

The related `AppleMapsMiddleware.localSearchCompleter` middleware provides completions for a query fragment received by an incoming `LocalSearchCompleterAction` object. Before the middleware sends completions, it needs to be *activated* (or: *initialized*) with an action containing result types, an optional points of interest filter and a possible region to reduce the search spectrum.

```swift
struct LocalSearchCompleterAction {
    static let cancel: LocalSearchCompleterAction
    static func initilize(resultTypes: MKLocalSearchCompleter.ResultType, filter: MKPointOfInterestFilter?, region: MKCoordinateRegion?) -> LocalSearchCompleterAction
    static func requestCompletionsFor(queryFragment: String) -> LocalSearchCompleterAction
}

enum LocalSearchCompleterState {
    case initial
    case initilized
    case searching
    case received([MKLocalSearchCompletion])
    case failed(Error)
    case canceled
}
```
