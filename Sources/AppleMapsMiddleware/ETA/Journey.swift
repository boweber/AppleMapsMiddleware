//
//  File.swift
//  
//
//  Created by Bo Weber on 07.02.21.
//

import MapKit

/// A wrapper of `MKDirections.Request`.
public struct Journey: Equatable, CustomStringConvertible, CustomDebugStringConvertible {
    let request: MKDirections.Request
    
    public var description: String {
        request.description
    }
    
    public var debugDescription: String {
        request.debugDescription
    }
    
    /// Contains details of a journey.
    /// - Parameters:
    ///   - start: The start of the journey.
    ///   - destination: The destination of the journey.
    ///   - arrivalDate: The desired arrival date.
    ///   - transportType: The transport type for the estimation.
    public init(
        start: MKMapItem,
        destination: MKMapItem,
        arrivalDate: Date,
        transportType: MKDirectionsTransportType
    ) {
        let request = MKDirections.Request()
        request.arrivalDate = arrivalDate
        request.destination = destination
        request.source = start
        request.transportType = transportType
        self.request = request
    }
    
    /// Contains details of a journey.
    /// - Parameters:
    ///   - start: The start of the journey.
    ///   - destination: The destination of the journey.
    ///   - departureDate: The departure date of the journey.
    ///   - transportType: The transport type for the estimation.
    public init(
        start: MKMapItem,
        destination: MKMapItem,
        departureDate: Date? = nil,
        transportType: MKDirectionsTransportType
    ) {
        let request = MKDirections.Request()
        request.departureDate = departureDate
        request.destination = destination
        request.source = start
        request.transportType = transportType
        self.request = request
    }
}
