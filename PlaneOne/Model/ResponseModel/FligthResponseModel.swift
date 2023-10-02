//
//  FligthResponseModel.swift
//  PlaneOne
//
//  Created by Yasin Dalkilic on 30.09.2023.
//

import Foundation

public struct FligthResponseModel: Codable {
    let time: Int?
    let states: [Flights]?
}
