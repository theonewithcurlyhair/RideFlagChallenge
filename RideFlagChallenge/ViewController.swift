//
//  ViewController.swift
//  RideFlagChallenge
//
//  Created by Nikita on 2021-01-06.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController {


    @IBOutlet weak var filter: UISegmentedControl!
    @IBOutlet weak var mapView: MKMapView!
    
    //Global Variables to Work With
    var payloadArray:NSArray = []
    var tripArray = [Trip]()
    var topDriversArray = [Trip]()
    var topPassengersArray = [Trip]()
    
    //REGION : Standard Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.filter.isHidden = true //?
    }
    
    override func viewDidAppear(_ animated: Bool) {
        FetchTripData()
    }
    
    @IBAction func FilterChanged(_ sender: UISegmentedControl) {
        
    }
    
    
    
    //Region : Working with Data
    func FetchTripData() -> Void {
        
    }
    
    
    //Region : Helpers
    func SortByDriverMiles() -> Void {
        
    }
    
    func SortByPassengerMiles() -> Void {
        
    }


}

