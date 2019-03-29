//
//  ParseClient.swift
//  OnTheMap
//
//  Created by Eli Warner on 3/27/19.
//  Copyright © 2019 EGW. All rights reserved.
//

import Foundation

class ParseClient {
    
    //Parse application ID
    static let ParseApplicationID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
    //REST API Key
    static let RESTAPIKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    

    enum EndPoints {
        static let base = "https://parse.udacity.com/parse/classes"
        
        case allStudentLocation
        case singleStudentLocation
        case orderedStudentsLocation
        
        var stringValue: String {
            switch self {
            case .allStudentLocation:
            return "https://parse.udacity.com/parse/classes/StudentLocation?limit=100"
            case .singleStudentLocation:
                return "https://parse.udacity.com/parse/classes/StudentLocation"
            case .orderedStudentsLocation:
                return "https://parse.udacity.com/parse/classes/StudentLocation?order=-updatedAt"
            
            }
        }
    
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    
    class func requestGetStudents(url: URL, completionHandler: @escaping ([StudentInformation]?,Error?)->Void) {
        var request = URLRequest(url: url)
        request.addValue(ParseApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(RESTAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        let downloadTask = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            // guard there is data
            guard let data = data else {
                // TODO: CompleteHandler can return error
                DispatchQueue.main.async {
                    completionHandler(nil, error)
                }
                return
            }
            
            let jsonDecoder = JSONDecoder()
            do {
                let result = try jsonDecoder.decode(AllStudentInfo.self, from: data)
                DispatchQueue.main.async {
                    completionHandler(result.results, nil)
                }
                
            } catch {
                DispatchQueue.main.async {
                    completionHandler(nil,error)
                }
            }
        }
        
        downloadTask.resume()
    }
    
    class func requestOrderedLocations(completion: @escaping([StudentInformation]?, Error?)->Void){
        requestGetStudents(url: EndPoints.orderedStudentsLocation.url) { (response, error) in
            guard let response = response else {
                print("RequestOrderedLocations: Failed")
                completion(nil, error)
                return
            }
            completion(response,nil)
        }
    }
    
    class func requestLimitedStudents(completion: @escaping ([StudentInformation]?, Error?)-> Void){
        requestGetStudents(url: EndPoints.allStudentLocation.url) { (response, error) in
            guard let response = response else {
                print("requestLimitedStudents: Failed")
                completion(nil, error)
                return
            }
            completion(response,nil)
        }
    }
    
    
    class func requestPostStudentInfo(postData:NewLocation, completionHandler: @escaping (PostLocationResponse?,Error?)->Void) {
        let endpoint:URL = EndPoints.singleStudentLocation.url
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.addValue(ParseApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(RESTAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonEncoder = JSONEncoder()
        let encodedPostData = try! jsonEncoder.encode(postData)
        request.httpBody = encodedPostData
        print(encodedPostData)
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            guard let data = data else {
                print(error!)
                DispatchQueue.main.async {
                    completionHandler(nil,error)
                }
                return
            }
            
            let jsonDecoder = JSONDecoder()
            do {
                print(data.base64EncodedString())
                let decodedData = try jsonDecoder.decode(PostLocationResponse.self, from: data)
                print(decodedData)
                DispatchQueue.main.async {
                    completionHandler(decodedData,nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completionHandler(nil,error)
                }
            }
        }
        task.resume()
    }
    
}
