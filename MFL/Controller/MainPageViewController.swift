//
//  ViewController.swift
//  MFL
//
//  Created by Bahadir Altun on 21.01.2019.
//  Copyright © 2019 Bahadir Altun. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class MainPageViewController: UIViewController {

    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginStatusLabel: UILabel!
    
    static var username = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedOnScreen))
        view.addGestureRecognizer(tapGesture)

    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        
        print("TAPPED")
        
        tappedOnScreen()
        
        if idTextField.text!.isEmpty
            || passwordTextField.text!.isEmpty {
            
            self.loginStatusLabel.text = "Enter valid username/password"
            UIView.animate(withDuration: 1.5) { self.loginStatusLabel.alpha = 1.0 }
            UIView.animate(withDuration: 1.5) { self.loginStatusLabel.alpha = 0 }
            
        } else {

            SVProgressHUD.setBorderColor(UIColor.blue)
            SVProgressHUD.show(withStatus: "Signin in..")
            
            let db = Database.database().reference()
            
            db.child("Users").observeSingleEvent(of: .value) { (ss) in

                SVProgressHUD.dismiss()

                if ss.hasChild((self.idTextField.text?.lowercased())!) {
                    let sss = ss.childSnapshot(forPath: (self.idTextField.text?.lowercased())!)
                    let value = sss.value as? NSDictionary
                    if value?["Email"] as! String == self.emailTextField.text! {
                        MainPageViewController.username = self.idTextField.text!
                        ProfileViewController.currentUsername = MainPageViewController.username
                        self.loginUser(user: self.emailTextField.text!, password: self.passwordTextField.text!)
                    } else {
                        self.loginStatusLabel.text = "Wrong Email"
                        UIView.animate(withDuration: 1.5) { self.loginStatusLabel.alpha = 1.0 }
                        UIView.animate(withDuration: 1.5) { self.loginStatusLabel.alpha = 0 }
                    }
                } else {
                    self.loginStatusLabel.text = "No such user"
                    UIView.animate(withDuration: 1.5) { self.loginStatusLabel.alpha = 1.0 }
                    UIView.animate(withDuration: 1.5) { self.loginStatusLabel.alpha = 0 }

                }
                
            }
        }
    }
    
    func loginUser(user: String, password: String) {
        
        print(user, password)
        
        Auth.auth().signIn(withEmail: user, password: password) {
            (result, error) in
            
            if error != nil {
                print(error!)
                UIView.animate(withDuration: 0.5, animations: {
                    self.loginStatusLabel.alpha = 1.0
                    self.loginStatusLabel.text = error?.localizedDescription
                })
            } else {
                print("Sign In Successful")
                self.idTextField.text = ""
                self.emailTextField.text = ""
                self.passwordTextField.text = ""
                self.performSegue(withIdentifier: "goToHomeViewController", sender: self)
            }
            
        }

        
    }
    
    @IBAction func registerButtonPressed(_ sender: UIButton) {
        tappedOnScreen()
        performSegue(withIdentifier: "goToRegisterViewController", sender: self)
    }
    
    @IBAction func forgotPasswordButtonPressed(_ sender: UIButton) {
        tappedOnScreen()
        performSegue(withIdentifier: "goToForgotPasswordViewController", sender: self)
    }
    
    @objc func tappedOnScreen() {
        emailTextField.endEditing(true)
        idTextField.endEditing(true)
        passwordTextField.endEditing(true)
    }
    
}

