//
//  PlaneOneTests.swift
//  PlaneOneTests
//
//  Created by Yasin Dalkilic on 30.09.2023.
//

import XCTest
@testable import PlaneOne

final class PlaneOneTests: XCTestCase {
    let fetchData = MockClass()

    func testFetchDataFuncSuccess(){
        var successData = false
        fetchData.fetchFlights(lomin: 1.0, lamin: 1.0, lomax: 1.0, lamax: 1.0) { result in
            switch result{
            case .success(_):
                successData = true
            case .failure(_):
                successData = false
            }
        }
        XCTAssertEqual(successData, true)
    }

    func testFetchDataFuncError(){
        var errorValue: ErrorClasss?
        fetchData.fetchFlights(lomin: 1.0, lamin: nil, lomax: 1.0, lamax: nil) { result in
            switch result{
            case .success(_):
                return
            case .failure(let error):
                switch error {
                case .failedFetch:
                    errorValue = ErrorClasss.failedFetch
                case .unknown:
                    errorValue = ErrorClasss.unknown
                }
            }
        }
        XCTAssertEqual(errorValue, ErrorClasss.failedFetch)
    }
}
