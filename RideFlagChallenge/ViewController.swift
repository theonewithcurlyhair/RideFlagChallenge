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
    var jsonArray:NSArray = []
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
        if filter.selectedSegmentIndex == 0{    //Top Drivers
            filter.selectedSegmentTintColor = UIColor.lightGray
            
            SortByDriverMiles()
            
            for obj in 0..<5{
                DisplayTrips(tripObj: topDriversArray[obj], showDetails: false, passMiles: false, driverMiles: true, showAll: false)
            }
        }
        else if filter.selectedSegmentIndex == 1{   //Top Passengers
            filter.selectedSegmentTintColor = UIColor.yellow
            
            SortByPassengerMiles()
            
            for obj in 0..<5{
                DisplayTrips(tripObj: topPassengersArray[obj], showDetails: false, passMiles: true, driverMiles: false, showAll: false)
            }
            
        }
        else if filter.selectedSegmentIndex == 2{   //No Filter
            filter.selectedSegmentTintColor = UIColor.green
            
            for obj in tripArray{
                DisplayTrips(tripObj: obj, showDetails: false, passMiles: false, driverMiles: false, showAll: true)
            }
        }
    }
    
    
    
    //Region : Working with Data
    func FetchTripData() -> Void {
        var request = URLRequest(url: URL(string: "https://5vb5vug3qg.execute-api.us-east-1.amazonaws.com/get_trip")!)
        request.httpMethod = "GET"
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
            
            //No Data Found
            if(data == nil){
                DispatchQueue.main.async{[unowned self] in
                    let alertController = UIAlertController(title: "Something Went Wrong, Please Try Again", message: "Request Unsuccessful", preferredStyle: .alert)
                    
                    let actionRetry = UIAlertAction(title: "Retry", style: .destructive, handler: {_ in FetchTripData()})
                    
                    alertController.addAction(actionRetry)
                    self.present(alertController, animated: true, completion: nil)
                }
                return
            }
            
            //Proceed if no errors
            do{
                //Parsing JSON
                let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                
                self.jsonArray = json["Payload"] as! NSArray
                
                for i in 0..<self.jsonArray.count{
                    let trip = Trip()
                    let jsonObj = self.jsonArray[i] as! NSDictionary
                    trip.driverMiles = jsonObj.value(forKey: "driver_miles") as! Double
                    trip.passengerMiles = jsonObj.value(forKey: "passenger_miles") as! Double
                    trip.direction = jsonObj.value(forKey: "direction") as! String
                    trip.Id = jsonObj.value(forKey: "trip_id") as! Int
                    trip.date = jsonObj.value(forKey: "trip_date") as! Date
                    
                    let startLoc = jsonObj.value(forKey: "start_location") as! NSArray
                    
                    trip.latitude = startLoc[0] as! Double
                    trip.longitude = startLoc[1] as! Double
                    
                    self.DisplayTrips(tripObj: trip, showDetails: true, passMiles: false, driverMiles: false, showAll: true)
                }
            } catch{
                print("error")
            }
            
            DispatchQueue.main.async {
                    [unowned self] in
                self.filter.isHidden = false
            }
        })
        
        task.resume()
    }
    
    //Displays Trips on the Map
    func DisplayTrips(tripObj: Trip, showDetails: Bool, passMiles: Bool, driverMiles: Bool, showAll:Bool) -> Void {
        
        if showDetails{
            tripArray.append(tripObj)
            
            let annotation = MKPointAnnotation()
            annotation.subtitle = String(format: "%@ %@\n%@ %.6f\n %@ %.6f\n%@ %.0f\n%@ %.0f", "Directions", tripObj.direction, "Passenger Miles:", tripObj.passengerMiles, "Driver Miles:", tripObj.driverMiles, "Trip ID:", tripObj.Id, "Trip Date", tripObj.date as CVarArg)
            
            annotation.coordinate = CLLocationCoordinate2DMake(tripObj.latitude, tripObj.longitude)
            self.mapView.addAnnotation(annotation)
            
            
            DispatchQueue.main.async { [unowned self] in
                let coordinate = CLLocationCoordinate2DMake(tripObj.latitude, tripObj.longitude)
                let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 150, longitudinalMeters: 150)
                self.mapView.setRegion(region, animated: true)
            }
        }
        else{
            let annotation = MKPointAnnotation()
            
            annotation.title = ""
            
            if(passMiles){
                annotation.title = "Among Top 5 Passengers"
            }
            else if(driverMiles){
                annotation.title = "Among Top 5 Drivers"
            }
            else if(showAll){
                annotation.title = "Trip"
            }
            
            annotation.subtitle = String(format: "%@ %@\n%@ %.6f\n %@ %.6f\n%@ %.0f\n%@ %.0f", "Directions", tripObj.direction, "Passenger Miles:", tripObj.passengerMiles, "Driver Miles:", tripObj.driverMiles, "Trip ID:", tripObj.Id, "Trip Date", tripObj.date as CVarArg)
            
            annotation.coordinate = CLLocationCoordinate2DMake(tripObj.latitude, tripObj.longitude)
            self.mapView.addAnnotation(annotation)
            
            DispatchQueue.main.async { [unowned self] in
                let coordinate = CLLocationCoordinate2DMake(tripObj.latitude, tripObj.longitude)
                let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 100, longitudinalMeters: 100)
                self.mapView.setRegion(region, animated: true)
    
            }
        }
    }
    
    
    //Region : Helpers
    func SortByDriverMiles() -> Void {
        topDriversArray = tripArray.sorted {
            $0.driverMiles > $1.driverMiles
        }
    }
    
    func SortByPassengerMiles() -> Void {
        topDriversArray = tripArray.sorted {
            $0.passengerMiles > $1.passengerMiles
        }
    }
    


}

