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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UdacityClient.getStudentLocations{ (StudentLocation, error) in
            print("STUDENT LOCATINONS")
            print(StudentLocation)
            StudentModel.shared.studentLocation = StudentLocation
        }
        mapView.delegate = self
        // Do any additional setup after loading the view.
    }
    
    @objc func reloadMapView(){
        
        //showStudentsInformation(StudentModel.shared.studentLocation)
    }

    private func showStudentsInformation(_ studentsInformation: [StudentInformation]) {
        mapView.removeAnnotations(mapView.annotations)
        for info in studentsInformation where info.latitude != 0 && info.longitude != 0 {
            let annotation = MKPointAnnotation()
            //annotation.title = info.labelName
            //annotation.subtitle = info.mediaURL
            annotation.coordinate = CLLocationCoordinate2DMake(info.latitude, info.longitude)
            mapView.addAnnotation(annotation)
        }
        mapView.showAnnotations(mapView.annotations, animated: true)
    }


    
}
