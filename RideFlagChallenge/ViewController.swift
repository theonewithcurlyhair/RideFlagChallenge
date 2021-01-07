//
//  ViewController.swift
//  RideFlagChallenge
//
//  Created by Nikita on 2021-01-06.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController, URLSessionDelegate {

    var session = URLSession.shared
    @IBOutlet weak var filter: UISegmentedControl!
    @IBOutlet weak var mapView: MKMapView!
    
    let url = "https://5vb5vug3qg.execute-api.us-east-1.amazonaws.com/get_trip"
    
    var activeFilter : ActiveFilter = ActiveFilter.Off
    
    //Global Variables to Work With
    var payloadsArray = [PayloadStruct]()
    var sortedPayloads = [PayloadStruct]()
    
    @IBAction func FilterChanged(_ sender: UISegmentedControl) {
        self.activeFilter = ActiveFilter(rawValue: self.filter.selectedSegmentIndex) ?? ActiveFilter.Off
        Display(payloads: self.payloadsArray)
    }
    
    
    
    // MARK : Main Code
    override func viewDidLoad() {
        super.viewDidLoad()
        self.filter.isHidden = true     //Will only be visible after the successful request
        self.activeFilter = ActiveFilter(rawValue: self.filter.selectedSegmentIndex) ?? ActiveFilter.Off
        doTheThing()
        Display(payloads: payloadsArray)
    }
    
    //Parses json result to codable structs
    private func parse(jsonData: Data) -> [PayloadStruct]? {
        do {
            let decodedData = try JSONDecoder().decode(Response.self,
                                                       from: jsonData)
            print("Response Code: ", decodedData.ResponseCode)
            print("Response Message: \(decodedData.Message)")
            print("===================================")
            return decodedData.Payload
        } catch {
            print("decode error \(error)")
            return nil
        }
    }
    
    //Loads json from the url
    private func loadJson(fromURLString urlString: String,
                          completion: @escaping (Result<Data, Error>) -> Void) {
        if let url = URL(string: urlString) {
            let urlSession = URLSession(configuration: .default).dataTask(with: url) { (data, response, error) in
                if let error = error {
                    completion(.failure(error))
                }
                
                if let data = data {
                    completion(.success(data))
                }
            }
            
            urlSession.resume()
        }
    }
    
    private func doTheThing() -> Void {
        self.loadJson(fromURLString: self.url) { (result) in
            switch result {
            case .success(let data):
                if let unwrappedJson = self.parse(jsonData: data) {
                    self.payloadsArray = unwrappedJson
                    
                    DispatchQueue.main.async {
                            [unowned self] in
                        self.filter.isHidden = false
                    }
                }else{
                    DispatchQueue.main.async{[unowned self] in
                        let alertController = UIAlertController(title: "Something Went Wrong, Please Try Again", message: "Request Unsuccessful", preferredStyle: .alert)
                        
                        let actionRetry = UIAlertAction(title: "Retry", style: .destructive, handler: {_ in doTheThing()})
                        
                        alertController.addAction(actionRetry)
                        self.present(alertController, animated: true, completion: nil)
                    }
                    return
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func Display(payloads: [PayloadStruct]) -> Void {
        //Check filter
        switch activeFilter {
        case .Drivers:
            sortedPayloads = Array(payloads.sorted{
                $0.driver_miles > $1.driver_miles
            }.prefix(5))
        case .Passengers:
            sortedPayloads = Array(payloads.sorted{
                $0.passenger_miles > $1.passenger_miles
            }.prefix(5))
        default:
            print("Active filter is OFF")
            sortedPayloads = payloads
        }
        
        for i in 0..<sortedPayloads.count{
            let annotation = MKPointAnnotation()
            
            annotation.subtitle = String(format: "%@ %@\n%@ %.6f\n %@ %.6f\n%@ %.0f\n%@ %.0f",
                                         "Direction:",sortedPayloads[i].direction,
                                         "P Miles:",sortedPayloads[i].passenger_miles,
                                         "D Miles:",sortedPayloads[i].driver_miles,
                                         "Trip ID:",sortedPayloads[i].trip_id,
                                         "Trip Date:",sortedPayloads[i].trip_date)
            
            annotation.coordinate = CLLocationCoordinate2DMake(sortedPayloads[i].latitude, sortedPayloads[i].longitude)
            self.mapView.addAnnotation(annotation)
            
            
            DispatchQueue.main.async { [unowned self] in
                let coordinate = CLLocationCoordinate2DMake(sortedPayloads[i].latitude, sortedPayloads[i].longitude)
                let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 150, longitudinalMeters: 150)
                self.mapView.setRegion(region, animated: true)
            }
        }
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}



