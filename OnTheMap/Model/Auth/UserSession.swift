//
//  UserSession.swift
//  OnTheMap
//
//  Created by Eli Warner on 3/12/19.
//  Copyright © 2019 EGW. All rights reserved.
//

import Foundation

struct UserSession: Codable {
    let account: Account?
    let session: Session?
}

struct Session: Codable {
    let id: String
    let expiration: String
}

struct Account: Codable {
    let registered: Bool
    let key: String
}
