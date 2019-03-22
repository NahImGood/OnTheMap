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
    
    var studentInfos: [StudentInformation] = [StudentInformation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reload()
        pinTableView.delegate = self
        pinTableView.dataSource = self
    }
    
    // MARK: - Table view data source
    
     func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return studentInfos.count
    }
    
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "studentlocation", for: indexPath)
        
        pinTableView.estimatedRowHeight = 80
        pinTableView.rowHeight = UITableView.automaticDimension
        cell.textLabel?.text = studentInfos[indexPath.row].fullName
        cell.detailTextLabel?.text = studentInfos[indexPath.row].userUrl
        cell.imageView?.image = UIImage(named: "icon_pin")
        
        return cell
    }
    
    
    @objc func reload() {
        UdacityClient.requestGetStudents(completionHandler: handleGetStudentInfos(infos:error:))
        
    }
    
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let url = studentInfos[indexPath.row].userUrl
        if verifyUrl(urlString: url){
            let temp = URL(string: url)
            UIApplication.shared.open(temp!, options: [:])
        }else {
            showAlert(title: "Invalid URL", message: "Appears to be an invalid URL", titleResponse: "Ok")
        }
    }
    
    func handleGetStudentInfos(infos:[StudentInformation]?, error:Error?) {
        guard let infos = infos else {
            print(error!)
            return
        }
        studentInfos = infos
        print(studentInfos)
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
