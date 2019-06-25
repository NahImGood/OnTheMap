//
//  UdacityClient.swift
//  OnTheMap
/*
    API returns JSON Data in the struct of StudentInfo
 */
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
        static let base = "https://onthemap-api.udacity.com/v1/"
        case logIn
        case singleStudentLocation
        case delete
        
        
        var stringValue: String {
            switch self {

            case .logIn:
                return  EndPoints.base + "session"
            case .singleStudentLocation:
                return EndPoints.base + "users/\(Auth.userKey)"
            case .delete:
                return EndPoints.base + "session"
            }
        }
        //Used to return a url from created API Strings
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    
    //MARK: - Sign in User to get udacity info
    // Takes no parameters, returns a StudentInfo? and Error? on escaping.
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
            // Guard to make sure there is no error. If error, it will exit into Guard and return
            // Just an error. Error carried to calling function for use.
            guard let data = data else {
                DispatchQueue.main.async {
                    completionHandler(nil, error)
                }
                return
            }
            // First 5 chars returned from API must be stripped away before using the returned
            // JSON data for decoding into StudentInfo
            let range = Range(5..<data.count)
            let newData = data.subdata(in: range)
            let jsonDecoder = JSONDecoder()
            do {
                //Decode data into StudentInfo
                let result = try jsonDecoder.decode(StudentInfo.self, from: newData)
                DispatchQueue.main.async {
                    //data was able to decode into StudentInfo
                    completionHandler(result, nil)
                }
                
            } catch {
                //Failed to Decode StudentInfo
                DispatchQueue.main.async {
                    completionHandler(nil,error)
                }
            }
        }
        downloadTask.resume()
    }
    
   
    //MARK: - POST Requests
    // Genereic Post request to API, reusable taking a URL(URL) and Body(String), escaping Data and Error
    // Use for adding new features as if Boiler plate code.
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

    // MARK: - LogInStudent
    // Log in student to have see all pins dropped for that student and other students.
    class func logInUdacity(password: String, username: String, completion: @escaping (Bool, Error?)->Void){
        let body = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}"
        _ = taskForPOSTRequest(url: EndPoints.logIn.url, body: body, completion: { (data, error) in
            // Check for missing data
            guard let data = data else {
                print(error)
                completion(false, error)
                return
            }
            let userSessionData = self.parseUserSession(data: data)
            if let sessionData = userSessionData.0 {
                // User data parsed and retuned valid data
                guard let account = sessionData.account, account.registered == true else {
                    completion(false, error)
                    return
                }
                guard let userSession = sessionData.session else {
                    completion(false, error)
                    return
                }
                // Save UserDefaults
                Auth.userKey = account.key
                print("AuthKey = \(Auth.userKey)")
                UserDefaults.standard.set(account.key, forKey: "accountKey")
                UserDefaults.standard.set(userSession.id, forKey: "UserSession")
                Auth.sessionID = userSession.id
                completion(true, nil)
            } else {
                // User data didn't parse
                completion(false, error)
            }
            
        })
    }
    
    //MARK: - Delete Post
    // Used to remove posts from the map, Only one post is allowed on the map at a time
    // Must be called before adding a second pin to the map.
    class func taskForDelete(completion: @escaping ()-> Void){
        var request = URLRequest(url: EndPoints.logIn.url)
        request.httpMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            print("enter task for delete")
            let range = 5..<data!.count
            let newData = data?.subdata(in: range)
            Auth.sessionID = ""
            Auth.userKey = ""
        }
        task.resume()
    }
    
    // MARK: -  Parse student info on return from server. Parsed into UserSession.
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
