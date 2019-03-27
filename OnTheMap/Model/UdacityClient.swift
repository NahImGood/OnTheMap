//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Eli Warner on 3/12/19.
//  Copyright © 2019 EGW. All rights reserved.
//

import Foundation

class UdacityClient: NSObject {
    
    
    //Shared Session
    let session = URLSession.shared
    //Parse application ID
    static let ParseApplicationID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
    //REST API Key
    static let RESTAPIKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    
    struct Auth {
        static var sessionID = ""
        static var userKey = ""
        static var userName = ""
    }
    
    enum EndPoints {
        static let base = "https://parse.udacity.com/parse/classes"
        case allStudentLocation
        case logIn
        case singleStudentLocation
        case postStudentLocation
        case delete
        
        
        var stringValue: String {
            switch self {
            case .allStudentLocation:
                return "https://parse.udacity.com/parse/classes/StudentLocation"
            case .logIn:
                return "https://onthemap-api.udacity.com/v1/session"
            case .singleStudentLocation:
                return "https://onthemap-api.udacity.com/v1/users/\(Auth.userKey)"
            case .postStudentLocation:
                return "https://parse.udacity.com/parse/classes/StudentLocation"
            case .delete:
                return "https://onthemap-api.udacity.com/v1/session"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    class func requestPostStudentInfo(postData:NewLocation, completionHandler: @escaping (PostLocationResponse?,Error?)->Void) {
        let endpoint:URL = EndPoints.allStudentLocation.url
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
    
    
    class func requestGetStudents(completionHandler: @escaping ([StudentInformation]?,Error?)->Void) {
        let endpoint:URL = EndPoints.allStudentLocation.url
        var request = URLRequest(url: endpoint)
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
    
    class func requestSignedInUserInfo(completionHandler: @escaping (StudentInfo?,Error?)->Void) {
        let url = EndPoints.singleStudentLocation.url
        print(url)
        var request = URLRequest(url: url)
        request.addValue(ParseApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(RESTAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue(Auth.userKey, forHTTPHeaderField: "User-Key")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
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
            let range = Range(5..<data.count)
            let newData = data.subdata(in: range)
            let jsonDecoder = JSONDecoder()
            do {
                let result = try jsonDecoder.decode(StudentInfo.self, from: newData)
                DispatchQueue.main.async {
                    completionHandler(result, nil)
                }
                
            } catch {
                DispatchQueue.main.async {
                    completionHandler(nil,error)
                }
            }
        }
        
        downloadTask.resume()
    }
    
    //MARK: POST Requests
    class func taskForPOSTRequest(url: URL, body: String, completion: @escaping (
        Data?, Error?) -> Void)-> URLSessionDataTask{
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body.data(using: String.Encoding.utf8)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completion(nil, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            guard (error == nil) else {
                sendError("There was an error with your request: \(error!.localizedDescription)")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                sendError("Request did not return a valid response.")
                return
            }
            
            switch (statusCode) {
            case 403:
                sendError("Please check your credentials and try again.")
            case 200 ..< 299:
                break
            default:
                sendError("Your request returned a status code other than 2xx!")
            }
            
                guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            var newData = data
            let range = Range(5..<data.count)
            newData = data.subdata(in: range)
            
            completion(newData, nil)
        }
        task.resume()
        return task
    }
    
    
    class func logInUdacity(password: String, username: String, completion: @escaping (Bool, Error?)->Void){
        let body = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}"
        _ = taskForPOSTRequest(url: EndPoints.logIn.url, body: body, completion: { (data, error) in
            if let error = error {
                print(error)
                completion(false, error)
            } else {
                let userSessionData = self.parseUserSession(data: data)
                if let sessionData = userSessionData.0 {
                    guard let account = sessionData.account, account.registered == true else {
                        completion(false, error)
                        return
                    }
                    guard let userSession = sessionData.session else {
                        completion(false, error)
                        return
                    }
                    Auth.userKey = account.key
                    print("AuthKey = \(Auth.userKey)")
                    UserDefaults.standard.set(account.key, forKey: "accountKey")
                    UserDefaults.standard.set(userSession.id, forKey: "UserSession")
                    Auth.userName = userSession.id
                    completion(true, nil)
                } else {
                    completion(false, error)
                }
            }
        })
    }
    
    class func taskForDelete(url: URL, completion: @escaping (Session?, Error?)-> Void){
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                print("Error In Delete: \(error)")
                completion(nil, error)
                return
            }
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                print("Your request returned a status code other than 2xx!")
                return
            }
        }
        task.resume()
    }
    
    class func deleteSession(url: URL, completion: @escaping(Session?, Error?)->Void){
        let url = EndPoints.delete.url
        let task = taskForDelete(url: url) { (data, error) in
            guard let data = data else {
                completion(nil, error)
                return
            }
            print("Delete Block")
        }
    }
    
    
    class func parseUserSession(data: Data?) -> (UserSession?, Error?) {
        var studensLocation: (userSession: UserSession?, error: Error?) = (nil, nil)
        do {
            if let data = data {
                let jsonDecoder = JSONDecoder()
                studensLocation.userSession = try jsonDecoder.decode(UserSession.self, from: data)
            }
        } catch {
            print("Could not parse the data as JSON: \(error.localizedDescription)")
            let userInfo = [NSLocalizedDescriptionKey : error]
            studensLocation.error = NSError(domain: "parseUserSession", code: 1, userInfo: userInfo)
        }
        return studensLocation
    }


}
