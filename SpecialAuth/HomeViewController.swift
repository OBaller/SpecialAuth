//
//  HomeViewController.swift
//  SpecialAuth
//
//  Created by Naseem Oyebola on 14/06/2022.
//

import UIKit
import SwiftKeychainWrapper

class HomeViewController: UIViewController {
    
    // MARK: - Outlet
    @IBOutlet weak var fullnameLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // load profile function
        loadProfile()
        
    }
    // MARK: - Functions
    func displayMessage(userMessage: String) -> Void {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "Alert", message: userMessage, preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default) { (action: UIAlertAction!) in
                print("OK button tapped")
                
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            }
            alertController.addAction(OKAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    private func loadProfile() {
        let accessToken: String? = KeychainWrapper.standard.string(forKey: "accessToken")
        let userId: String? = KeychainWrapper.standard.string(forKey: "userID")
        // send http request
        
        let myUrl = URL(string: "http://localhost:8080/api/users/\(userId!)")
        var request = URLRequest(url: myUrl!)
        request.httpMethod = "GET"
        request.addValue("Bearer \(accessToken!)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                self.displayMessage(userMessage: "Could not successfully perform this request. Please try again later")
                print("error \(String(describing: error))")
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                if let parseJSON = json {
                    DispatchQueue.main.async {
                        let firstName: String? = parseJSON["firstName"] as? String
                        let lastName: String? = parseJSON["lastName"] as? String
                        
                        if firstName?.isEmpty != true && lastName?.isEmpty != true {
                            self.fullnameLabel.text = firstName! + " " + lastName!
                        }
                    }
                } else {
                    self.displayMessage(userMessage: "Could not successfully perform this request. Please try again later")
                    print("error \(String(describing: error))")
                    return
                }
                
            } catch {
                self.displayMessage(userMessage: "Could not successfully perform this request. Please try again later")
                print("error \(String(describing: error))")
                return
            }
            
        }
        task.resume()
    }
    
    // MARK: - Actions
    @IBAction func signoutButton(_ sender: UIBarButtonItem) {
        KeychainWrapper.standard.removeObject(forKey: "accessToken")
        KeychainWrapper.standard.removeObject(forKey: "userId")
        
        
        //        let rootNavController = self.window?.rootViewController as! UINavigationController
        //        rootNavController.popToRootViewController(animated: true)
    }
    
    @IBAction func loadProfileButton(_ sender: UIButton) {
        
    }
}
