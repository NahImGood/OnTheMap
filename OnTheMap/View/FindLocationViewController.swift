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

    //MARK: Outlet
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var mediaURLTextField: UITextField!
    
    //MARK: Variables
    var lat: Double = 0.0
    var long: Double = 0.0
    var mapItems: [MKMapItem]?
    
    @IBAction func findLocationButtonPressed(_ sender: UIButton) {
        if (locationTextField.text?.isEmpty)! {
            showAlert(title: "No Location", message: "Please enter a location", titleResponse: "Ok")
        }else {
        getCoordinate(addressString: locationTextField.text!, completionHandler: handleGetCoordinate(response:error:))
        }
    }
    
    func handleGetSingleStudentInfo(studentInfo:StudentInformation?, error:Error?) {
        guard let studentInfo = studentInfo else {
            print(error!)
            return
        }
        UserDefaults.standard.set(studentInfo.lastName, forKey: "lastname")
        UserDefaults.standard.set(studentInfo.firstName, forKey: "firstname")
        print(studentInfo.lastName)
        print(studentInfo.firstName)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationTextField.delegate = self
        mediaURLTextField.delegate = self
        // Do any additional setup after loading the view.
    }
    
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
    
    func handleGetCoordinate(response: CLLocationCoordinate2D, error: NSError? ){
        if response.latitude == -180 || response.longitude == -180{
            showAlert(title: "Invalid Address", message: "Please enter a valid address", titleResponse: "Ok")
        } else {
            long = response.longitude
            lat = response.latitude
            performSegue(withIdentifier: "locationToMap", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destinationVC = segue.destination as? PostLocationViewController else {
            print("Unable to cast ViewController")
            return
        }
        destinationVC.newlong = long
        destinationVC.newLat = lat
        destinationVC.mediaURL = mediaURLTextField.text ?? ""
    }
    

    func showAlert(title: String, message: String, titleResponse: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: titleResponse, style: .default, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    func textFieldShouldReturn(_ scoreText: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }

}
