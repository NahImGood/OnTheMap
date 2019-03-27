//
//  PostLocationViewController.swift
//  OnTheMap
//
//  Created by Eli Warner on 3/20/19.
//  Copyright © 2019 EGW. All rights reserved.
//

import UIKit
import MapKit

class PostLocationViewController: UIViewController {

    var newLat: Double = 0.0
    var newlong: Double = 0.0
    var userLocation: NewLocation?
    var mediaURL: String = ""
    var location: String = ""
    var nickName = UserDefaults.standard.object(forKey: "nickname") as! String


    
    @IBOutlet weak var mapView: MKMapView!
    @IBAction func postLocationButtonPressed(_ sender: UIButton) {
        setUserInfo()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setMapAnnotation()
        // Do any additional setup after loading the view.
    }
    

    
    func setUserInfo(){
        let newLocation = NewLocation(uniqueKey: UserDefaults.standard.object(forKey: "accountKey") as! String ,firstName: "", lastName: nickName, mapString: location, mediaURL:mediaURL, latitude:newLat, longitude:newlong)
        UdacityClient.requestPostStudentInfo(postData: newLocation, completionHandler: handlePostLocationReponse(postLocationResponse:error:))
    }
    

    
    
    func setMapAnnotation() {

        let lat = CLLocationDegrees(newLat)
        let long = CLLocationDegrees(newlong)
        let cordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        let annotation = MKPointAnnotation()
        annotation.coordinate = cordinate
        annotation.title = "New Location Marker"
        self.mapView.addAnnotation(annotation)
        let coordinateRegion = MKCoordinateRegion.init(center: annotation.coordinate, latitudinalMeters: 30000, longitudinalMeters: 30000  )
        mapView.setRegion(coordinateRegion, animated: true)

    }
    

    func handlePostLocationReponse(postLocationResponse:PostLocationResponse?, error:Error?) {
        
        guard let response = postLocationResponse else {
            print(error!)
            let alertVC = UIAlertController(title: "Add Location", message: error?.localizedDescription, preferredStyle: .alert)

            alertVC.addAction(UIAlertAction(title:"OK" , style: UIAlertAction.Style.default, handler: { (action) in
                self.dismiss(animated: true, completion: nil)
            })
            )
            present(alertVC, animated: true, completion: nil)
            return
        }
        dismiss(animated: true, completion: nil)
        
    }
    

    

}
