//
//  FilmListViewController.swift
//  MFL
//
//  Created by Bahadir Altun on 24.01.2019.
//  Copyright © 2019 Bahadir Altun. All rights reserved.
//

import UIKit
import Firebase
import Alamofire
import SwiftyJSON
import SVProgressHUD

class FilmListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    static var currentFilm = ""
    static var currentFilmCategory = ""
    static var currentPosterURL = ""
    static var currentFilmID = ""
    
    let OMDB_API = "https://www.omdbapi.com"
    let API_KEY = "76b4842e"
    
    var filmArray: [FilmModel] = [FilmModel]()
    
    var selectedType = ""
    var username = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.delegate = self
        tableView.dataSource = self

        selectedType = ProfileViewController.selectedType
        username = ProfileViewController.currentUsername
        
        if selectedType == "Watched Films" { selectedType = "Watched" }
        else if selectedType == "None Watched Films" { selectedType = "Not Watched" }
        else if selectedType == "Will Be Watched Films" { selectedType = "Will Watch" }
        else { return }

        self.title = ProfileViewController.selectedType
        
        getFilms()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        SVProgressHUD.dismiss()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let film = filmArray[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilmCell", for: indexPath) as! TableViewCell
        
        cell.nameLabel.text! = film.name
        if film.category.contains(",") {
            cell.categoryLabel.text! = film.category.mySubstring(to: film.category.firstIndex(of: ",")!)
        } else {
            cell.categoryLabel.text! = film.category
        }
        cell.filmImageView.sd_setImage(with: URL(string: film.poster)) { (image, error, type, url) in
            
            if error != nil {
                print("Error occure while downloading image")
                cell.filmImageView.image = UIImage(named: "cross.png")
            } else {
                //    print("Success")
            }
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            let cell = tableView.cellForRow(at: indexPath) as! TableViewCell
            //    print("HELLO!", cell.nameLabel.text!)
            FilmListViewController.currentFilm = cell.nameLabel.text!
            FilmListViewController.currentFilmCategory = cell.categoryLabel.text!
            FilmListViewController.currentPosterURL = self.filmArray[indexPath.row].poster
            FilmListViewController.currentFilmID = self.filmArray[indexPath.row].ID
            print(cell.nameLabel.text!, "ASD", FilmListViewController.currentFilm)
            self.performSegue(withIdentifier: "goToOtherFilmPageViewController", sender: self)
        }
    
        tableView.reloadData()
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filmArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 125.0
    }

    
    func getFilms() {
        
        let db = Database.database().reference().child("Users").child(username).child("List").child(selectedType)
        
        SVProgressHUD.show(withStatus: "Getting content..")
        
        print("Start Getting Contents")
        
        db.observe(.value) { (snapshot) in
            if snapshot.exists() {
                print(snapshot)
            } else {
                SVProgressHUD.dismiss()
                print("No content")
                self.showAlert(title: "No content", message: "User do not have a content in selected category")
                self.navigationController?.popViewController(animated: true)
                return
            }
        }
        
        db.observe(.childAdded, with: { (snapshot) in
            print(snapshot)
            self.getFilmInfo(imdbID: snapshot.key)
        })
    }
    
    func getFilmInfo(imdbID: String) {
        
        let params = ["apikey" : API_KEY, "i" : imdbID]
        
        Alamofire.request(OMDB_API, method: .get, parameters: params).responseJSON { (response) in
            
            SVProgressHUD.dismiss()
            
            if response.result.isSuccess {
                
                //    print(response)
                
                let filmJSON: JSON = JSON(response.result.value!)
                //    let filmResponse = filmJSON["Response"].string
                let filmName = filmJSON["Title"].string
                let categoryName = filmJSON["Type"].string?.firstUppercased
                let posterURL = filmJSON["Poster"].string
                let filmID = filmJSON["imdbID"].string
                
                let newFilm = FilmModel(_name: filmName!, _category: categoryName!, _poster: posterURL!, _ID: filmID!)
                
                self.filmArray.append(newFilm)
                self.filmArray.reverse()
                
                self.tableView.reloadData()
                self.tableView.scroll(to: .top, animated: true)
            
            } else {
                print("Some error occured")
                self.showAlert(title: "Sorry", message: "Check your internet connection")
            }
        }

        
    }
 
    func showAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    
}
