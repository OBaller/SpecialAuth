//
//  RegisterViewController.swift
//  SpecialAuth
//
//  Created by Naseem Oyebola on 14/06/2022.
//

import UIKit

class RegisterViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var firstnameField: UITextField!
    @IBOutlet weak var lastnameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        self.navigationController?.isNavigationBarHidden = true
        
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
    
    @IBAction func cancelButton(_ sender: UIButton) {
        
    }
    
    @IBAction func registerButton(_ sender: UIButton) {
        if (firstnameField.text?.isEmpty)! || (lastnameField.text?.isEmpty)! || (emailField.text?.isEmpty)! || (passwordField.text?.isEmpty)! {
            // Display alert
            displayMessage(userMessage: "All fields are required")
            return
        }
        
        if ((passwordField.text?.elementsEqual(confirmPasswordField.text!))! != true) {
            // Display alert
            displayMessage(userMessage: "Password must match")
            return
        }
        // create activity indicator
        
        // Send HTTP Request to create user
        let myUrl = URL(string: "http://localhost:8080/api/users")
        var request = URLRequest(url: myUrl!)
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let postString = [
            "firstName": firstnameField.text!,
            "lastName": lastnameField.text!,
            "userPassword": passwordField.text!
        ] as [String: String]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: postString, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
            displayMessage(userMessage: "Something went wrong. Try again")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                self.displayMessage(userMessage: "Could not successfully perform this request. Please try again later")
                print("error \(String(describing: error))")
                return
            }
            
            // convert response sent from a server side code to a NSDictionary object
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                
                if let parseJSON = json {
                    let userId = parseJSON["userId"] as? String
                    print("User Id: \(String(describing: userId!))")
                    
                    if (userId?.isEmpty)! {
                        // display alert
                        self.displayMessage(userMessage: "Could not successfully perform this request. Please try again later.")
                        return
                    } else {
                        self.displayMessage(userMessage: "Successfully registered a new account. Please proceed to Sign in")
                        return
                    }
                } else {
                    self.displayMessage(userMessage: "Could not successfully perform this request. Please try again later.")
                    return
                }
                
            } catch {
                
            }
            
            
        }
        task.resume()

    }
     
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
