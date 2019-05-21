//
//  RegisterViewController.swift
//  MFL
//
//  Created by Bahadir Altun on 21.01.2019.
//  Copyright © 2019 Bahadir Altun. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
//    @IBOutlet weak var passwordTextField: UITextField!
//    @IBOutlet weak var passwordAgainTextField: UITextField!
    @IBOutlet weak var registerStatusLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    
    let db = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedOnScreen))
        view.addGestureRecognizer(tapGesture)
        
    }
    
    @IBAction func registerButtonPressed(_ sender: UIButton) {
        
        tappedOnScreen()
        if usernameTextField.text!.isEmpty {
            
            self.registerStatusLabel.text = "Enter valid username"
            self.registerStatusLabel.alpha = 0
            UIView.animate(withDuration: 1.5) { self.registerStatusLabel.alpha = 1.0 }
            UIView.animate(withDuration: 1.5) { self.registerStatusLabel.alpha = 0 }
            
        } else {

            SVProgressHUD.show()
            
            Auth.auth().createUser(withEmail: emailTextField.text!, password: "123456") { (user, error) in
                
                SVProgressHUD.dismiss()
                
                if error != nil {
                    
                    print(error!)
                    UIView.animate(withDuration: 0.5, animations: {
                        self.registerStatusLabel.alpha = 1.0
                        self.registerStatusLabel.text = error?.localizedDescription
                    })
                    
                } else {
                    
                    print("Registration Succesfull!")
                    self.initializeUser()
                    
                }
                
            }

            
            /*
            if passwordTextField.text! != passwordAgainTextField.text! {
                self.registerStatusLabel.text = "Passwords don't match"
                self.registerStatusLabel.alpha = 0
                UIView.animate(withDuration: 1.5) { self.registerStatusLabel.alpha = 1.0 }
                UIView.animate(withDuration: 1.5) { self.registerStatusLabel.alpha = 0 }
            } else {
                
                SVProgressHUD.show(withStatus: "Registering...")
                let db = Database.database().reference()
                db.child("Users").observeSingleEvent(of: .value) { (ss) in
                    
                    if ss.hasChild((self.usernameTextField.text?.lowercased())!) {
                        SVProgressHUD.dismiss()
                        print("Username already taken")
                        self.registerStatusLabel.alpha = 0
                        self.registerStatusLabel.textColor = UIColor.red
                        self.registerStatusLabel.text = "Username already taken"
                        UIView.animate(withDuration: 1.5) { self.registerStatusLabel.alpha = 1.0 }
                        UIView.animate(withDuration: 1.5) { self.registerStatusLabel.alpha = 0 }
                    } else {
                        
                        db.child("Users").child((self.usernameTextField.text?.lowercased())!).child("Password").setValue(self.passwordTextField.text!) { (error, ref) in
                            SVProgressHUD.dismiss()
                            self.registerStatusLabel.alpha = 0
                            self.registerStatusLabel.textColor = (error == nil) ? UIColor.green : UIColor.red
                            self.registerStatusLabel.text = (error == nil) ? "Registration Successful" : error?.localizedDescription
                            UIView.animate(withDuration: 1.5) { self.registerStatusLabel.alpha = 1.0 }
                            UIView.animate(withDuration: 1.5) { self.registerStatusLabel.alpha = 0 }
                            if error == nil {
                                self.navigationController?.popToRootViewController(animated: true)
                            }
                        }
                    }
                }
 
            }
            */
 
        }
        
    }
    
//    func userExists(username: String) -> Bool {
//        var usernameHasTaken = false
//        DispatchQueue.main.async {
//            let db = Database.database().reference()
//            db.child("Users").observeSingleEvent(of: .value) { (ss) in
//
//                if ss.hasChild(username) {
//                //    print(username)
//                    usernameHasTaken = true
//                    return
//                }
//
//            }
//        }
//
//        print(username, usernameHasTaken)
//        return usernameHasTaken
//    }
    
    func passwordResetting() {
        Auth.auth().sendPasswordReset(withEmail: self.emailTextField.text!, completion: { (error) in
            SVProgressHUD.dismiss()
            if (error == nil) {
                self.showAlert(title: "Registration Completed", message: "Check your email to verify your account.")
            } else {
                print(error!)
                self.showAlert(title: "Error", message: "Error occured while registering account. Check your connection.")
            }
        })
        //    self.performSegue(withIdentifier: "goToChatViewController", sender: self)
        
    }
    
    func initializeUser() {
        
        let db = Database.database().reference()
        db.child("Users").child((self.usernameTextField.text?.lowercased())!).child("Email").setValue(emailTextField.text!)
        { (error, db) in
            if error != nil {
                SVProgressHUD.dismiss()
                self.showAlert(title: "Error", message: "Error occured while registering account. Check your connection.")
            } else {
                self.passwordResetting()
            }
        }
        
    }
    
    func showAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @objc func tappedOnScreen() {
        usernameTextField.endEditing(true)
    //    passwordTextField.endEditing(true)
    //    passwordAgainTextField.endEditing(true)
        emailTextField.endEditing(true)
    }
    
}

