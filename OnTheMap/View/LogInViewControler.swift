//
//  LogInViewControler.swift
//  OnTheMap
//
//  Created by Eli Warner on 3/12/19.
//  Copyright © 2019 EGW. All rights reserved.
//

import UIKit

class LogInViewControler: UIViewController {

    //MARK: Outlets
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextFields: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    //MARK: Actions
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        
        print("login was selected")
        activityIndicator.startAnimating()

        guard let email = usernameTextField.text, !email.isEmpty else {
            activityIndicator.stopAnimating()
            //enableControllers(true)
            showInfo(withTitle: "Field required", withMessage: "Please fill in your email.")
            return
        }
        guard let password = passwordTextFields.text, !password.isEmpty else {
            activityIndicator.stopAnimating()
            //enableControllers(true)
            showInfo(withTitle: "Field required", withMessage: "Please fill in your password.")
            return
        }
        authenticateUserInfo(username: email, password: password)
 
    }
    
    @IBAction func dontHaveAccountButtonPressed(_ sender: UIButton) {
        let url = URL(string: "https://www.udacity.com/account/auth#!/signup")
        UIApplication.shared.open(url!, options: [:])
    }
    
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
                }
                self.performSegue(withIdentifier: "logInSegue", sender: nil)
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
}

extension UIViewController {
    func showInfo(withTitle: String = "Info", withMessage: String, action: (() -> Void)? = nil) {
        performUIUpdatesOnMain {
            let ac = UIAlertController(title: withTitle, message: withMessage, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: {(alertAction) in
                action?()
            }))
            self.present(ac, animated: true)
        }
    }
    
    func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
        DispatchQueue.main.async {
            updates()
        }
    }
}
