//
//  MockData.swift
//  PlaneOne
//
//  Created by Yasin Dalkilic on 2.10.2023.
//

import Foundation

public enum ErrorClasss:  Error {
    case failedFetch
    case unknown
}

public class MockClass: FlightServiceProtocol {
    public func fetchFlights(lomin: Float?, lamin: Float?, lomax: Float?, lamax: Float?, completion: @escaping (Result<FligthResponseModel, ErrorClasss>) -> Void)  {
        let baseURL = "\(lomin ?? 0.00)\(lamin ?? 0.00)\(lomax ?? 0.00)\(lamax ?? 0.00)"
        let states: [Flights] = []

        let flightResponseModel = FligthResponseModel(time: 1, states: states)

        guard (lamax != nil), lamin != nil else {
            completion(.failure(ErrorClasss.failedFetch))
            return
        }

        completion(.success(flightResponseModel))
    }
}
