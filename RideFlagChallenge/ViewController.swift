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

    @IBOutlet weak var filter: UISegmentedControl!
    @IBOutlet weak var mapView: MKMapView!
    
    //Global Variables to Work With
    func url() -> String{
        return "https://5vb5vug3qg.execute-api.us-east-1.amazonaws.com/get_trip"
    }
    
    var activeFilter : ActiveFilter = ActiveFilter.Off
    var payloadsArray = [PayloadStruct]()
    var sortedPayloads = [PayloadStruct]()
    
    @IBAction func FilterChanged(_ sender: UISegmentedControl) {
        self.activeFilter = ActiveFilter(rawValue: self.filter.selectedSegmentIndex) ?? ActiveFilter.Off
        DisplayMarkers(payloads: self.payloadsArray)
    }
    
    
    // MARK : Main Code
    override func viewDidLoad() {
        super.viewDidLoad()
        self.filter.isHidden = true     //Will only be visible after the successful request
        self.activeFilter = ActiveFilter(rawValue: self.filter.selectedSegmentIndex) ?? ActiveFilter.Off
        
        //Populate data and display on the map right after the view load
        GetData()
        DisplayMarkers(payloads: payloadsArray)
    }
    
    
    /// Parses and Decodes JSON Data object into an array of PayloadStructs
    /// - Parameter jsonData: loaded JSON object from the url request
    /// - Returns: if sucess -> an array of PayloadStruct, if failure -> nil
    private func DecodeJSON(jsonData: Data) -> [PayloadStruct]? {
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
    /// This method loads JSON from the requested URL. It waits for the URL to be finished before moving to the next steps
    /// - Parameters:
    ///   - urlString: URL from what make a request
    ///   - completion: Returns loaded DATA object and any applicable errors
    private func loadJson(fromURLString urlString: String,
                          completion: @escaping (Result<Data, Error>) -> Void) {
        var done = false
        
        if let url = URL(string: urlString) {
            let urlSession = URLSession(configuration: .default).dataTask(with: url) { (data, response, error) in
                if let error = error {
                    completion(.failure(error))
                }
                
                if let data = data {
                    completion(.success(data))
                }
                
                done = true
            }
            
            urlSession.resume()
            
            //Waiting for the URL to be finished
            repeat {
                RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.1))
            } while !done
        }
    }
    
    
    /// Accesses DATA From Url, Parses, Decodes and tries to unwrap the result
    /// If the result is empty showst the alert to the user with the option to Retry
    /// - Returns: Void
    private func GetData() -> Void {
        self.loadJson(fromURLString: self.url()) { (result) in
            switch result {
            case .success(let data):
                if let unwrappedJson = self.DecodeJSON(jsonData: data) {
                    self.payloadsArray = unwrappedJson
                    
                    DispatchQueue.main.async {
                            [unowned self] in
                        self.filter.isHidden = false
                    }
                }else{
                    DispatchQueue.main.async{[unowned self] in
                        let alertController = UIAlertController(title: "Something Went Wrong, Please Try Again", message: "Request Unsuccessful", preferredStyle: .alert)
                        
                        let actionRetry = UIAlertAction(title: "Retry", style: .destructive, handler: {_ in GetData()})
                        
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
    
    
    /// Displays Markers on the map with the trip details
    /// - Parameter payloads: Payloads from which to display on the map
    /// - Returns: Void
    private func DisplayMarkers(payloads: [PayloadStruct]) -> Void {
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



