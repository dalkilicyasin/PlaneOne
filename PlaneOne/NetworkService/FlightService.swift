//
//  FlightService.swift
//  PlaneOne
//
//  Created by Yasin Dalkilic on 30.09.2023.
//

import Foundation
import UIKit


//MARK: BaseURL and user info for data fetch
enum Constants: String {
    case baseURL = "https://opensky-network.org/api/states/all"
    case userName = "Dalkilici"
    case password = "Yd123456"
}

//MARK: Error Handling
public enum ErrorClasss: Error {
    case failedFetch
    case unknown
}

// MARK: - Protocol

public protocol FlightServiceProtocol: AnyObject {
    func fetchFlights(lomin: Float?, lamin: Float?, lomax: Float?, lamax: Float?, completion: @escaping (Result<FligthResponseModel, ErrorClasss>) -> Void)
}

//MARK: - Class
public class FlightService: FlightServiceProtocol {

    public func fetchFlights(lomin: Float?, lamin: Float?, lomax: Float?, lamax: Float?, completion: @escaping (Result<FligthResponseModel, ErrorClasss>) -> Void) {
        let urlString = Constants.baseURL.rawValue + "?lomin=\(lomin ?? 0.0)&lamin=\(lamin ?? 0.0)&lomax=\(lomax ?? 0.0)&lamax=\(lamax ?? 0.0)"
        let loginString = "\(Constants.userName.rawValue):\(Constants.password.rawValue)"
        guard let loginData = loginString.data(using: String.Encoding.utf8) else {
            return
        }
        let base64LoginString = loginData.base64EncodedString()

        guard let url = URL(string: urlString) else {
            print("invalid URL")
            return
        }

        let config = URLSessionConfiguration.default
        let authString = "Basic \(base64LoginString)"
        config.httpAdditionalHeaders = ["Authorization" : authString]
        let session = URLSession(configuration: config)

        let task = session.dataTask(with: url) { data, response, error in

            if let error = error {
                print("**** GEÇİCİ BİR HATA OLUŞTU: \(error.localizedDescription) ******")
                completion(.failure(ErrorClasss.failedFetch))
                return
            }

            guard let data = data else {
                print("Invalid Data")
                return
            }

            let decoder = JSONDecoder()

            do {
                let response = try decoder.decode(FligthResponseModel.self, from: data)
                completion(.success(response))
            } catch {
                print("********** Your daily data fetch has expired pleaase make new Login to Opensky *******")
                completion(.failure(ErrorClasss.failedFetch))
            }
        }
        task.resume()
    }
}
