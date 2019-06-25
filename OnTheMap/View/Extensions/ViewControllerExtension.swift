//
//  ViewControllerExtension.swift
//  OnTheMap
//
//  Created by Eli Warner on 3/28/19.
//  Copyright © 2019 EGW. All rights reserved.
//

import UIKit


extension UIViewController {
    // Showing pop up
    func showInfo(withTitle: String = "Info", withMessage: String, action: (() -> Void)? = nil) {
        performUIUpdatesOnMain {
            let ac = UIAlertController(title: withTitle, message: withMessage, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: {(alertAction) in
                action?()
            }))
            self.present(ac, animated: true)
        }
    }
    
    // Helper function for performing on Main Thread
    func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
        DispatchQueue.main.async {
            updates()
        }
    }
    
    // Log out helper used in MapViewController
    func handleLogOut(response: Session? , error: Error?){
        guard let response = response else {
            showInfo(withMessage: "Unable To Log Out")
            return
        }
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "logOutAccapted", sender: nil)
        }
    }
}
