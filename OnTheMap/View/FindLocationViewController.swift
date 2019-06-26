//
//  FindLocationViewController.swift
//  OnTheMap
//
//  Created by Eli Warner on 3/19/19.
//  Copyright © 2019 EGW. All rights reserved.
//

import UIKit
import MapKit

class FindLocationViewController: UIViewController, UITextFieldDelegate {

    //MARK: - Outlet
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var mediaURLTextField: UITextField!
    
    //MARK: - Properties
    var lat: Double = 0.0
    var long: Double = 0.0
    var mapItems: [MKMapItem]?
    
    //MARK: - Actions
    //After inputing a loctaion into the locationTextField. Pressing button searchs and makes sure its
    //a valid location. The creates cordinaties for the location using MapKit
    @IBAction func findLocationButtonPressed(_ sender: UIButton) {
        if (locationTextField.text?.isEmpty)! {
            showAlert(title: "No Location", message: "Please enter a location", titleResponse: "Ok")
        }else {
        getCoordinate(addressString: locationTextField.text!, completionHandler: handleGetCoordinate(response:error:))
        }
    }
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        locationTextField.delegate = self
        mediaURLTextField.delegate = self
        // Do any additional setup after loading the view.
    }
    
    //Takesa string and cretes a cordinate location from the string location
    func getCoordinate( addressString : String,
                        completionHandler: @escaping(CLLocationCoordinate2D, NSError?) -> Void ) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(addressString) { (placemarks, error) in
            if error == nil {
                if let placemark = placemarks?[0] {
                    let location = placemark.location!
                    
                    completionHandler(location.coordinate, nil)
                    return
                }
            }
            completionHandler(kCLLocationCoordinate2DInvalid, error as NSError?)
        }
    }
    
    //Makes sure no cordinate is out of range. if address -> cordinate fails then it will alert
    //the user and ask for a new address or more info to the address.
    func handleGetCoordinate(response: CLLocationCoordinate2D, error: NSError? ){
        if response.latitude == -180 || response.longitude == -180{
            showAlert(title: "Invalid Address", message: "Please enter a valid address", titleResponse: "Ok")
        } else {
            //Valid address
            long = response.longitude
            lat = response.latitude
            performSegue(withIdentifier: "locationToMap", sender: nil)
        }
    }
    
    //MARK: - Prepare for segue
    //gathers up needed resources before heading to new VC. Sending over the new long, lat, and url
    //to the postLocationViewController.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destinationVC = segue.destination as? PostLocationViewController else {
            print("Unable to cast ViewController")
            return
        }
        destinationVC.newlong = long
        destinationVC.newLat = lat
        destinationVC.mediaURL = mediaURLTextField.text ?? ""
    }
    
    //Helper function for showing alerts.
    func showAlert(title: String, message: String, titleResponse: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: titleResponse, style: .default, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    //For dismissing the keyboard field
    func textFieldShouldReturn(_ scoreText: UITextField) -> Bool {
        DispatchQueue.main.async {
        self.view.endEditing(true)
        }
        return true
    }

}
