//
//  Trip.swift
//  RideFlagChallenge
//
//  Created by Nikita on 2021-01-06.
//

import Foundation

struct Response: Codable {
    var ResponseCode: Int
    var ExecutedVersion: String
    var Message: String
    var Payload: [PayloadStruct]
}

struct PayloadStruct: Codable {
    var direction: String
    var passenger_miles: Double
    var driver_id: String
    var driver_miles: Double
    var start_location: [Double]
    var trip_id: String
    var trip_date: Double
    
    var latitude: Double {
            return self.start_location[0]
    }
    
    var longitude: Double {
            return self.start_location[1]
    }
    
}

enum ActiveFilter : Int {
    case Drivers = 0
    case Passengers = 1
    case Off = 2
}
