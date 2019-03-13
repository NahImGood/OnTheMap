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
        
        var stringValue: String {
            switch self {
            case .allStudentLocation:
                return EndPoints.base + "https://parse.udacity.com/parse/classes/StudentLocation"
            case .logIn:
                return "https://onthemap-api.udacity.com/v1/session"
            }
        }
        var url: URL {
            return URL(string: stringValue)!
        }
        
    }
    
    //MARK: GET
    class func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionDataTask {
        var request = URLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = URLSession.shared
        let task = session.dataTask(with: url) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                do {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            }
        }
        task.resume()
        
        return task
    }
    
    
    class func getStudentLocations(completion: @escaping ([StudentLocation], Error?)-> Void){
        let task = taskForGETRequest(url: EndPoints.allStudentLocation.url, responseType: StudentLocation.self) { (response, error) in
            if let response = response {
                completion([response], nil)
            } else {
                completion([], error)
            }
        }
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
            completion(data, nil)
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
                print(data)
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
                    Auth.userName = userSession.id
                    completion(true, nil)
                } else {
                    completion(false, error)
                    
                }
            }
        })
        
    }
    
    class func parseUserSession(data: Data?) -> (UserSession?, Error?) {
        var studensLocation: (userSession: UserSession?, error: Error?) = (nil, nil)
        do {
            if let data = data {
                print("In the data block")
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
