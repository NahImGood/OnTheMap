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
    
    var userUrl: String {
        if mediaURL != nil {
        return  "\(mediaURL!)"
        }
        return ""
    }
}

struct StudentInfo: Codable {
    let nickname: String
}

struct User: Codable {
    let lastname: String
    enum CodingKeys: String, CodingKey {
        case lastname = "last_name"
    }
}
