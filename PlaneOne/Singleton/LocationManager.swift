//
//  LocationManager.swift
//  PlaneOne
//
//  Created by Yasin Dalkilic on 1.10.2023.
//

import CoreLocation
import Foundation

protocol LocationManagerDelegate{
    func addressUpdate(address: String)
}

class LocationManager: NSObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    let manager = CLLocationManager()
    var completion: ((CLLocation) -> Void)?
    var streetAdreess = ""
    var locationManagerDelegate: LocationManagerDelegate?

    public func getUserLocation(completion: @escaping ((CLLocation) -> Void)){
        self.completion = completion
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    //MARK: Get user current Location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }

        completion?(location)
        manager.stopUpdatingLocation()
    }

    //MARK: Get chosen area address
    func convertLatLongToAddress(latitude: Double, longitude: Double){
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: latitude, longitude: longitude)
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            self.streetAdreess = ""
            // Place details
            var placeMark: CLPlacemark?
            placeMark = placemarks?[0]

            // Location name
            if let locationName = placeMark?.location {
                print(locationName)
            }
            // Street address
            if let street = placeMark?.thoroughfare {
                print(street)
                self.streetAdreess += "\(street)"
            }
            // City
            if let city = placeMark?.locality {
                print(city)
                self.streetAdreess += "/\(city)"
            }
            // Zip code
            if let zipCode = placeMark?.postalCode {
                print(zipCode)
            }
            // Country
            if let country = placeMark?.country {
                print(country)
                self.streetAdreess += "/\(country)"
            }
            self.locationManagerDelegate?.addressUpdate(address: self.streetAdreess)
        })
    }
}


