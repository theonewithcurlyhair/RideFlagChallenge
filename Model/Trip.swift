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
    var Id:Int = 0
    var direction:String = ""
    var date:Date = Date()
}
