//
//  TableViewController.swift
//  OnTheMap
//
//  Created by Eli Warner on 3/13/19.
//  Copyright © 2019 EGW. All rights reserved.
//

import UIKit

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {

    //MARK: Outlets
    @IBOutlet weak var pinTableView: UITableView!
    //Reloads the view.
    @IBAction func reloadTableViewButton(_ sender: UIBarButtonItem) {
        reload()
    }
    
    //MARK: - Properties
    var studentInfos: [StudentInformation] = [StudentInformation]()
    
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
        reload()
        pinTableView.delegate = self
        pinTableView.dataSource = self
        navigationItem.title = "On The Map"
    }
    
    // MARK: - Table view data source
    //Sections are sepereated by headers. So one will be okay because all
    //data is of same type, Student
     func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //Returns number of items in list of students.
    //If found nil whole page crashes
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentInfos.count
    }
    
    //creation of student cell in tableView. Any adjustments to ALL cells must be made here.
    //Uses non custom class of cell. If more function/content needed to be added
    //create a custom class and cast cell to custom class. (as! "CUSTOMCLASS")
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "studentlocation", for: indexPath)
        
        pinTableView.estimatedRowHeight = 80
        pinTableView.rowHeight = UITableView.automaticDimension
        cell.textLabel?.text = studentInfos[indexPath.row].fullName
        cell.detailTextLabel?.text = studentInfos[indexPath.row].userUrl
        cell.imageView?.image = UIImage(named: "icon_pin")
        
        return cell
    }
    
    //Verifies the students url before posting it to reusable studentCells
    //Upon selection opens link in safari directing user to link in student name
    //If found nil or not a web url it will alert user
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let url = studentInfos[indexPath.row].userUrl
        if verifyUrl(urlString: url){
            let temp = URL(string: url)
            UIApplication.shared.open(temp!, options: [:])
        }else {
            showAlert(title: "Invalid URL", message: "Appears to be an invalid URL", titleResponse: "Ok")
        }
    }

    
    //MARK: - Reload
    //reloads the student list in tableView
    @objc func reload() {
        ParseClient.requestOrderedLocations(completion: handleGetStudentInfos(infos:error:))
        
    }
    
    func handleGetStudentInfos(infos:[StudentInformation]?, error:Error?) {
        guard let infos = infos else {
            showInfo(withMessage: "Unable to Download Student Locations")
            print(error!)
            return
        }
        studentInfos = infos
        DispatchQueue.main.async {
            // reload table
            self.pinTableView.reloadData()
        }
    }
    
    func verifyUrl (urlString: String?) -> Bool {
        if let urlString = urlString {
            if let url = URL(string: urlString) {
                return UIApplication.shared.canOpenURL(url)
            }
        }
        return false
    }
    
    func showAlert(title: String, message: String, titleResponse: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: titleResponse, style: .default, handler: nil))
        
        self.present(alert, animated: true)
    }
}
