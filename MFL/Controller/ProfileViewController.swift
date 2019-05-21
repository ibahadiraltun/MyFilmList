//
//  ProfileViewController.swift
//  MFL
//
//  Created by Bahadir Altun on 24.01.2019.
//  Copyright © 2019 Bahadir Altun. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class ProfileViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate,
                            UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    
    let imagePicker = UIImagePickerController()
    
    static var currentUsername = ""
    static var selectedType = ""
    
    let array = ["Watched Films", "None Watched Films", "Will Be Watched Films", "Logout"]
    
    let userDefaults = UserDefaults.standard
    var tapGesture = UITapGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tapGesture = UITapGestureRecognizer()
        
        if ProfileViewController.currentUsername == MainPageViewController.username {
            tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectImage))
            userImageView.isUserInteractionEnabled = true
        } else {
            userImageView.image = UIImage(named: "cross.png")
        }
        userImageView.addGestureRecognizer(tapGesture)
        
        usernameLabel.text! = ProfileViewController.currentUsername
        
        imagePicker.delegate = self
        navigationController?.delegate = self
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        downloadPhotoFromDB()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath)
        cell.textLabel?.text = array[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if cell?.textLabel?.text == "Logout" {
            do {
                try Auth.auth().signOut()
            } catch {
                print("Error")
            }
            self.navigationController?.popToRootViewController(animated: true)
            return
        }
        ProfileViewController.selectedType = (cell?.textLabel?.text!)!
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text! == "" {
            ProfileViewController.currentUsername = MainPageViewController.username
            self.viewDidLoad()
            return 
        }
        
        let text = searchBar.text!
        let searchingUser = text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        searchBar.endEditing(true)
        
        SVProgressHUD.show(withStatus: "Searching user..")
        
        let db = Database.database().reference()
        db.child("Users").observeSingleEvent(of: .value) { (ss) in
            
            SVProgressHUD.dismiss()
            
            if ss.hasChild(searchingUser) {
                ProfileViewController.currentUsername = searchingUser
                self.viewDidLoad()
            } else {
                print("No such user")
                self.showAlert(title: "Sorry", message: "No Such User")
            }
        }
        
    }
    
    func showAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            userImageView.image = pickedImage
            uploadPhotoToDB(image: pickedImage)
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func selectImage() {
        if MainPageViewController.username == ProfileViewController.currentUsername {
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = false
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func uploadPhotoToDB(image: UIImage) {
        
        let imageData = image.jpegData(compressionQuality: 1.0)
        let storageRef = Storage.storage().reference().child("Users").child(MainPageViewController.username)
        
        let uploadTask = storageRef.putData(imageData!, metadata: nil) { (metadata, error) in
            
        //    print(metadata)
            
            print(error ?? "No Error")
            
            if (error == nil) {
                self.userDefaults.set(true, forKey: MainPageViewController.username)
            }
            
            // after uploading data...
        }
        
        uploadTask.resume()
        
    }
    
    func downloadPhotoFromDB() {
        
        if userDefaults.value(forKeyPath: ProfileViewController.currentUsername) != nil {
            
            userImageView.removeGestureRecognizer(tapGesture)
            
            print("user has a photo")
            
            let storageRef = Storage.storage().reference().child("Users").child(ProfileViewController.currentUsername)
            let downloadTask = storageRef.getData(maxSize: 1024 * 1024 * 16) { (data, error) in
                self.userImageView.addGestureRecognizer(self.tapGesture)
                if (error != nil) {
                    print(error?.localizedDescription ?? "Error occured while downloading image")
                //    self.showAlert(title: "Bad Connection", message: "Profile photo cannot be loaded")
                } else {
                //    print(data, error)
                    if let data = data {
                        self.userImageView.image = UIImage(data: data)
                    }
                }
            }
            
            downloadTask.resume()
        }

    }
    
}

