//
//  StudentLocation.swift
//  OnTheMap
//
//  Created by Eli Warner on 3/12/19.
//  Copyright © 2019 EGW. All rights reserved.
//

import Foundation

struct AllStudentInfo : Codable {
    let results:[StudentInformation]
}

struct SingleStudentInfo: Codable {
    let results: StudentInformation
}

struct StudentInformation: Codable {
    let createdAt: String?
    let firstName: String?
    let lastName: String?
    let latitude: Double?
    let longitude: Double?
    let mapString: String?
    let mediaURL: String?
    let objectId: String?
    let uniqueKey: String?
    let updatedAt: String?
    
    // Checking to make sure usernames arnt nil and if they are post so.
    var fullName: String {
        var name = ""
        if firstName != nil {
            name = "\(firstName!)"
            if lastName != nil {
                name = "\(firstName!) \(lastName!)"
            } else {
                name = "\(lastName!)"
            }
        } else {
            name = "No Name Available"
        }
        return name
    }
    
    // Checks for nil URL
    var userUrl: String {
        if mediaURL != nil {
        return  "\(mediaURL!)"
        }
        return ""
    }
}

//Returned info from login session
struct StudentInfo: Codable {
    let nickname: String
}


struct User: Codable {
    let lastname: String
    enum CodingKeys: String, CodingKey {
        case lastname = "last_name"
    }
}
