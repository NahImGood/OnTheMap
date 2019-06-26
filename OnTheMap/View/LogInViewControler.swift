//
//  LogInViewControler.swift
//  OnTheMap
/*
    Used for controlling the logIn Viewcontroller
    No transfered data from VC to other VC's. Once logIN has been verified by server
    You directed to new MapViewController that controlled by a tabView
 */
//  Created by Eli Warner on 3/12/19.
//  Copyright © 2019 EGW. All rights reserved.
//

import UIKit

class LogInViewControler: UIViewController, UITextFieldDelegate {

    //MARK: - Outlets
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextFields: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK: - Actions
    //MARK: - LogIn Button
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        activityIndicator.startAnimating()
        
        //Make sure email isnt nil, if so alert user
        guard let email = usernameTextField.text, !email.isEmpty else {
            activityIndicator.stopAnimating()
            //enableControllers(true)
            showInfo(withTitle: "Field required", withMessage: "Please fill in your email.")
            return
        }
        //Make sure password isnt nil, if so alert user
        guard let password = passwordTextFields.text, !password.isEmpty else {
            activityIndicator.stopAnimating()
            //enableControllers(true)
            showInfo(withTitle: "Field required", withMessage: "Please fill in your password.")
            return
        }
        //Calls helper function for authenticating user info
        authenticateUserInfo(username: email, password: password)
    }
    
    //MARK: - No Account Button
    //Upon pressing the no account button you are redirected using safari in a new
    //window to create an account on udacity.com
    @IBAction func dontHaveAccountButtonPressed(_ sender: UIButton) {
        self.performUIUpdatesOnMain {
        let url = URL(string: "https://www.udacity.com/account/auth#!/signup")
        UIApplication.shared.open(url!, options: [:])
        }
    }
    
    //MARK: - User Authentication
    //Authenticates the username and password against the udacity's database.
    //If failed user is alerted with helpful info to fix the situation
    //Takes strings for password and username
    private func authenticateUserInfo(username: String, password: String){
        UdacityClient.logInUdacity(password: password, username: username) { (success, error) in
            if success {
                print(username)
                print(password)
                UserDefaults.standard.set(username, forKey: "username")
                UserDefaults.standard.set(password, forKey: "password")
                self.performUIUpdatesOnMain {
                    self.usernameTextField.text = ""
                    self.passwordTextFields.text = ""
                    self.performSegue(withIdentifier: "logInSegue", sender: nil)
                }
            } else {
                self.performUIUpdatesOnMain {
                    self.showInfo(withTitle: "Login falied", withMessage: "Please Check Log In Info")
                }
            }
            self.performUIUpdatesOnMain {
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    //MARK - Lifecycle
    override func viewDidLoad() {
        usernameTextField.delegate = self
        passwordTextFields.delegate = self
    }
    
    //MARK: - Keyboard Adjustments
    func textFieldShouldReturn(_ scoreText: UITextField) -> Bool {
        DispatchQueue.main.async {
            self.view.endEditing(true)
        }
        return true
    }
}

