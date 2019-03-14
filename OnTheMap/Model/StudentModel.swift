//
//  StudentLocationClass.swift
//  OnTheMap
//
//  Created by Eli Warner on 3/13/19.
//  Copyright © 2019 EGW. All rights reserved.
//

import Foundation

struct StudentModel {
    
    static var shared = StudentModel()
    
    private init() {}
    
    var studentLocation = [StudentLocation]()
    var studentInformation = [StudentInformation]()
}
