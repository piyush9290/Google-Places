//
//  FindAddressViewController.swift
//  GooglePlaces
//
//  Created by Piyush Sharma on 2017-09-03.
//  Copyright © 2017 Piyush. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire

class FindAddressViewController: UIViewController, CLLocationManagerDelegate {

    private final var GooglePlacesKey = "AIzaSyAk3YSywuiJAj7fTaTcSQcYVkp8DctDqMg"
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchResultLabel: UILabel!
    @IBOutlet weak var searchResultView: UIView! {
        didSet {
            searchResultView.isHidden = true
        }
    }
    
    var locationManager = CLLocationManager()
    var locationString = ""
    
    @IBAction func textFieldChanged(_ sender: Any) {
        if searchTextField.text != "" {
            searchResultView.isHidden = false
            getPlaces(searchString: searchTextField.text!, locationString: locationString)
        } else {
            searchResultView.isHidden = true
        }
    }
    
    @IBAction func addButtonClick(_ sender: Any) {
        let alert = UIAlertController(title: "Congratulations!", message: "Your address\" \(String(describing: self.searchResultLabel.text!)) \" has been found successfully", preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: {
            self.searchResultView.isHidden = true
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
            //print(locationManager.location ?? "Location is Nil")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func getPlaces(searchString: String, locationString: String) {
        var param: [String: Any] = [
            "input": searchString,
            "types": "geocode",
            "language": "en",
            "key": GooglePlacesKey
        ]
        
        if locationString != "" {
            param["location"] = locationString
            param["radius"] = 500
        }
        
        Alamofire.request("https://maps.googleapis.com/maps/api/place/autocomplete/json", method: .get, parameters: param).responseJSON { response in
            if let json = response.result.value as? NSDictionary {
                let status = json["status"] as? String
                if status == "OK" {
                    if let predictions = json["predictions"] as? Array<Any> {
                        let obj1 = predictions[0] as? NSDictionary
                        let descr = obj1?["description"] as! String
                        self.searchResultLabel.text = descr
                    }
                } else {
                    print("Result not found")
                }
                
            }
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation: CLLocation = locations[0] as CLLocation
        self.locationString = String(userLocation.coordinate.latitude) + "," + String(userLocation.coordinate.longitude)
        print(self.locationString)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error while updating Location: \(error.localizedDescription)")
    }

}
