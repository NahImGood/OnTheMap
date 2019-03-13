//
//  User.swift
//  OnTheMap
//
//  Created by Eli Warner on 3/12/19.
//  Copyright © 2019 EGW. All rights reserved.
//

import Foundation

struct User: Codable {
    let name: String
    enum CodingKeys: String, CodingKey {
        case name = "nickname"
    }
}


