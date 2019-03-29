//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Eli Warner on 3/12/19.
//  Copyright © 2019 EGW. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate  {
    
    //MARK: Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    var sessionID:String = ""
    var mapAnnotations = [MKAnnotation]()

    //MARK: Actions
    @IBAction func refreshButtonPressed(_ sender: UIBarButtonItem) {
        reloadMapView()
    }
    @IBAction func addPinButtonPressed(_ sender: UIBarButtonItem) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "addLocation", sender: nil)
        }
    }
    
    @IBAction func logOut(_ sender: UIBarButtonItem) {
        print("log out pressed")
        UdacityClient.taskForDelete {
        }
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }

    }
    var studentInfos:[StudentInformation] = [StudentInformation]()
    
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
    
    @objc func reloadMapView(){
        UdacityClient.requestSignedInUserInfo(completionHandler: handleGetSingleStudentInfo(studentInfo:error:))
        ParseClient.requestLimitedStudents(completion: handleGetStudentInfo(studentInfos:error:))
    }

    func handleGetStudentInfo(studentInfos:[StudentInformation]?, error:Error?) {
        guard let studentInfos = studentInfos else {
            showInfo(withMessage: "Unable to Download Student Locations")
            print(error!)
            return
        }
        createMapAnnotation(studentInfos:studentInfos)
    }
    
    func handleGetSingleStudentInfo(studentInfo:StudentInfo?, error:Error?) {
        guard let studentInfo = studentInfo else {
            showInfo(withMessage: "Unable to Download Your Student Info")
            print(error!)
            return
        }
        UserDefaults.standard.set(studentInfo.nickname, forKey: "nickname")
    }
    
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
        
        self.mapView.addAnnotations(mapAnnotations)
    }
    
    // each pin's rendering
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
