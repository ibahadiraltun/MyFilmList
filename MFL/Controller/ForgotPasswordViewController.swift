//
//  ForgotPasswordViewController.swift
//  MFL
//
//  Created by Bahadir Altun on 21.01.2019.
//  Copyright © 2019 Bahadir Altun. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class ForgotPasswordViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedOnScreen))
        view.addGestureRecognizer(tapGesture)
        
    }
    
    @IBAction func resetButtonPressed(_ sender: UIButton) {
        SVProgressHUD.show()

        Auth.auth().sendPasswordReset(withEmail: self.emailTextField.text!, completion: { (error) in
            
            SVProgressHUD.dismiss()
            
            if (error == nil) {
                self.showAlert(title: "Email Sent", message: "Check your email")
            } else {
                print(error!)
                self.showAlert(title: "Error", message: "Check your internet connection")
            }
        })

    }
    
    func showAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @objc func tappedOnScreen() {
        emailTextField.endEditing(true)
    }
    
}
