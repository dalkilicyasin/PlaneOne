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

//Burada teknik mülakkatta red almanın sebebi initilazierı private yapmaman. func da public kalmıştı. Eğerki intiliazerı private yapmazsan burdaki sınıfın fonksiyonuna 2 3 yerden ulaşım sağlanabilirdi. Farklı bir sınıfta aşşağıdaki gibi bir instance oluşturduğunda hem sigleton hemde normal şekilde getUserLocation() fonksiyonuna ulaşabilirsin fakat private init yaptığında sadece sigleton ile access sağlanabilir. Sigleton yapısının amacıda tek bir yerden ulaşım sağlamaktır.

/*let locationManager = LocationManager()
 locationManager.getUserLocation() // eğerki init private yapılmazsa direk bu şekilde de func aceess yapabilirsin. Eğer LocationManager içersinde init private olarak tanımlanmışsa ve  bu şekilde  ulaşmaya çalışırsan access hatası alırsın

 */

class LocationManager: NSObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    let manager = CLLocationManager()
    var completion: ((CLLocation) -> Void)?
    var streetAdreess = ""
    var locationManagerDelegate: LocationManagerDelegate?

    private override init(){

    }

     func getUserLocation(completion: @escaping ((CLLocation) -> Void)){
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


