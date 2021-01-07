//
//  Trip.swift
//  RideFlagChallenge
//
//  Created by Nikita on 2021-01-06.
//

import Foundation

class Trip:NSObject{
    var longitude:Double = 0.0
    var latitude:Double = 0.0
    var passengerMiles:Double = 0.0
    var driverMiles:Double = 0.0
    var Id:String = ""
    var direction:String = ""
    var date:Double = 0.0
}


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
