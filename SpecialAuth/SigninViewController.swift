//
//  ViewController.swift
//  SpecialAuth
//
//  Created by Naseem Oyebola on 14/06/2022.
//

import UIKit

class SigninViewController: UIViewController {
    
    // MARK: = Outlet
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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

    @IBAction func signinButton(_ sender: UIButton) {
        let username = usernameField.text
        let password = passwordField.text
        
        if (username?.isEmpty)! || (password?.isEmpty)! {
            print("Username \(String(describing: username)) or password \(String(describing: password)) is empty")
            displayMessage(userMessage: "One of the required field is missing")
            return
        }
        
        let myUrl = URL(string: "http://localhost:8080/api/authentication")
        var request = URLRequest(url: myUrl!)
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let postString = [
            "username": username!,
            "userPassword": password!
        ] as [String: String]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: postString, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
            displayMessage(userMessage: "Something went wrong. ")
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
                    let accessToken = parseJSON["token"] as? String
                    let userId = parseJSON["id"] as? String
                    print("Acess Token: \(String(describing: accessToken ))")
                    print("User Id: \(String(describing: userId!))")
                    
                    if (accessToken?.isEmpty)! {
                        // display alert
                        self.displayMessage(userMessage: "Could not successfully perform this request. Please try again later.")
                        return
                    }
                    
                    DispatchQueue.main.async {
                        let homepage = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController
                        let appDelegate = UIApplication.shared.delegate
                        appDelegate?.window??.rootViewController = homepage 
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
    
    @IBAction func registerButton(_ sender: UIButton) {
        if let next = storyboard?.instantiateViewController(withIdentifier: "RegisterViewController") as? RegisterViewController {
            self.navigationController?.pushViewController(next, animated: true)
        }
    }
    
}

