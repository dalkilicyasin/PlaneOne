//
//  MainPageViewModel.swift
//  PlaneOne
//
//  Created by Yasin Dalkilic on 30.09.2023.
//

import Foundation
import UIKit
import CoreLocation

protocol MainPageVieModelDelegate {
    func valueHasChanged(flight: [Flights], coordinate: CLLocationCoordinate2D)
}

class MainPageViewModel {
    var flightProtocolDelegate: FlightServiceProtocol
    var flightLocations: [CLLocation]?
    
    var searchDistance = 50.00 //km
    var lomin = 0.00
    var lamin = 0.00
    var lomax = 0.00
    var lamax = 0.00
    var flights: [Flights] = []
    var mainPageVieModelDelegate: MainPageVieModelDelegate?
    var coordinate = CLLocationCoordinate2D()
    var timeRemaining = 5
    var selectedCountry = "Selected Country :"
    
    init(flightProtocolDelegate: FlightServiceProtocol = FlightService() ) {
        self.flightProtocolDelegate = flightProtocolDelegate
    }
    
    func filterPlanesSelectedCountry(value: String){
        if flights.isEmpty {
            self.contDownTimer()
        }
        var flights = self.flights
        flights = self.flights.filter({$0.originCountry == value ? true : false})
        self.mainPageVieModelDelegate?.valueHasChanged(flight: flights, coordinate: self.coordinate)
    }
    
    func fetchFlightData(){
        self.flights = []
        flightProtocolDelegate.fetchFlights(lomin: Float(lomin), lamin: Float(lamin), lomax: Float(lomax), lamax: Float(lamax), completion: { [weak self] result in
            
            guard let strongSelf = self else {return}
            
            switch result{
            case .success(let flights):
                strongSelf.flights = flights.states ?? []
                self?.mainPageVieModelDelegate?.valueHasChanged(flight: strongSelf.flights, coordinate: strongSelf.coordinate)
            case .failure(_):
                return
            }
        })
    }
    
    func contDownTimer() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (Timer) in
            if self.timeRemaining > 0 {
                print ("\(self.timeRemaining) seconds")
                self.timeRemaining -= 1
                if self.timeRemaining == 0 {
                    guard self.flights.isEmpty else {return}
                    self.fetchFlightData()
                }
            } else {
                Timer.invalidate()
                self.timeRemaining = 5
            }
        }
    }
}

