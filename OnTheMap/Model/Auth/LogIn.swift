//
//  LogIn.swift
//  OnTheMap
//
//  Created by Eli Warner on 3/12/19.
//  Copyright © 2019 EGW. All rights reserved.
//

import Foundation


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

struct LogInSessionId: Codable{
    var sessionId: String
}
