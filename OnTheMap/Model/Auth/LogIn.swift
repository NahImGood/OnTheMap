//
//  LogIn.swift
//  OnTheMap
//
//  Created by Eli Warner on 3/12/19.
//  Copyright © 2019 EGW. All rights reserved.
//

import Foundation

// All login structs

// Sent to Udacity to verify Login
struct LogInRequest: Codable {
    let password: String
    let username: String
    let udacity: [String:String]
    
    enum CodingKeys: String, CodingKey {
        case password
        case username
        case udacity
    }
}

// Saved info of Account
struct Account: Codable {
    let registered:Bool
    let key:String
}

//Saved info of session
struct Session: Codable {
    let id:String
    let expiration:String
}

// Returned from Udacity API
struct UserSession: Codable {
    let account:Account?
    let session:Session?
}

// Returned from login, Used to verify who logged out
struct LogInSessionId: Codable{
    var sessionId: String
}

// Returned from posting new location
struct PostLocationResponse: Codable {
    let createdAt: String
    let objectId: String
}

// Post body sent to API
struct NewLocation: Codable {
    var uniqueKey:String
    var firstName:String?
    var lastName:String?
    var mapString:String
    var mediaURL:String
    var latitude:Double
    var longitude:Double
}
