//
//  MapViewController.swift
//  OnTheMap
/*
    Shows map pins on the map. Calls both Udacity and Parse API to get needed info for creating
    and validating pin information
 */
//  Created by Eli Warner on 3/12/19.
//  Copyright © 2019 EGW. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate  {
    
    //MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!
    
    //MARK: - Properties
    var sessionID:String = ""
    var mapAnnotations = [MKAnnotation]()
    var studentInfos:[StudentInformation] = [StudentInformation]()

    //MARK: - Actions
    //Will refresh the mapView
    @IBAction func refreshButtonPressed(_ sender: UIBarButtonItem) {
        reloadMapView()
    }
    //Segues to make a new pin. Pin is created and placed on the map after pushing new
    //Pin location to Udacity API
    @IBAction func addPinButtonPressed(_ sender: UIBarButtonItem) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "addLocation", sender: nil)
        }
    }
    
    //MARK - Logout
    //Button used for logging out of udacity client. Upon logout the user the presented
    //with launch screen for logging back in
    @IBAction func logOut(_ sender: UIBarButtonItem) {
        print("log out pressed")
        UdacityClient.taskForDelete {
        }
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "On The Map"
        let _ = self.tabBarController?.tabBar.items
        reloadMapView()
        mapView.delegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        reloadMapView()
    }
    
    //Used to reload the map info by calling Udacity API to retrive all student pins
    @objc func reloadMapView(){
        UdacityClient.requestSignedInUserInfo(completionHandler: handleGetSingleStudentInfo(studentInfo:error:))
        ParseClient.requestLimitedStudents(completion: handleGetStudentInfo(studentInfos:error:))
    }

    //Helper function for converting returned info into StudentInformation struct
    //Called in reloadMapView
    func handleGetStudentInfo(studentInfos:[StudentInformation]?, error:Error?) {
        guard let studentInfos = studentInfos else {
            showInfo(withMessage: "Unable to Download Student Locations")
            print(error!)
            return
        }
        //Func auto reloads table data. So no need to reload in this func
        createMapAnnotation(studentInfos:studentInfos)
    }
    
    //Helper function for adding the nickname to the UserDefaults info.
    //Called in reloadMapView
    func handleGetSingleStudentInfo(studentInfo:StudentInfo?, error:Error?) {
        guard let studentInfo = studentInfo else {
            showInfo(withMessage: "Unable to Download Your Student Info")
            print(error!)
            return
        }
        UserDefaults.standard.set(studentInfo.nickname, forKey: "nickname")
    }
    
    //Converts StudentInformation into pin for placement on the map
    //Pin is savedto mapAnnotation that feed the map view
    func createMapAnnotation(studentInfos:[StudentInformation]) {
        for info in studentInfos {
            let title = info.fullName
            
            let lat = CLLocationDegrees(info.latitude ?? 0)
            let long = CLLocationDegrees(info.longitude ?? 0)
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            let mediaURL = info.userUrl
            
            let annotation = MKPointAnnotation()
            annotation.title = title
            annotation.coordinate = coordinate
            annotation.subtitle = mediaURL
            mapAnnotations.append(annotation)
        }
        //Relaods map view for additions of pins
        self.mapView.addAnnotations(mapAnnotations)
    }
    
    //MARK: - MapView
    //Renders each pin on the map
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationId)
            pinView?.canShowCallout = true
            pinView?.pinTintColor = .red
            pinView?.rightCalloutAccessoryView = UIButton(type:.detailDisclosure)
        } else {
            pinView?.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if (control == view.rightCalloutAccessoryView) {
            let app = UIApplication.shared
            if let url = view.annotation?.subtitle! {
                guard !url.isEmpty else {
                    showInfo(withMessage: "No Valid URl")
                    return
                }
                app.open(URL(string: url)!, options: [:], completionHandler: nil)
            }
        }
    }

    
}
