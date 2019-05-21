//
//  FilmPageViewController.swift
//  MFL
//
//  Created by Bahadir Altun on 22.01.2019.
//  Copyright © 2019 Bahadir Altun. All rights reserved.
//

import UIKit
import Firebase
import Alamofire
import SwiftyJSON
import SDWebImage

class FilmPageViewController: UIViewController {
    
    @IBOutlet weak var filmNameLabel: UILabel!
    @IBOutlet weak var filmCategoryLabel: UILabel!
    @IBOutlet weak var filmGenreLabel: UILabel!
    @IBOutlet weak var segmentController: UISegmentedControl!
    @IBOutlet weak var posterImageView: UIImageView!
    
    let currentUsername = MainPageViewController.username
    
    let OMDB_API = "https://www.omdbapi.com"
    let API_KEY = "76b4842e"
    
    static var currentFilm = "";
    static var currentFilmCategory = "";
    static var currentPosterURL = "";
    static var currentFilmID = "";
    
    var _currentFilm = ""
    var _currentFilmCategory = ""
    var _currentPosterURL = ""
    var _currentFilmID = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        _currentFilm = FilmPageViewController.currentFilm
        _currentFilmCategory = FilmPageViewController.currentFilmCategory
        _currentPosterURL = FilmPageViewController.currentPosterURL
        _currentFilmID = FilmPageViewController.currentFilmID
        
        print(_currentFilm, _currentFilmCategory)
                
        filmNameLabel.text = _currentFilm
        filmCategoryLabel.text = _currentFilmCategory
        posterImageView.sd_setImage(with: URL(string: _currentPosterURL)) { (image, error, type, url) in
            if error != nil {
                print("Error occured while downloading image")
                self.posterImageView.image = UIImage(named: "cross.png")
            } else {
            //    print("Success")
            }
        }
        
        getFilmGenre(film: _currentFilm)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        switch segmentController.selectedSegmentIndex {
        case 0: updateList(status: "Watched"); break
        case 1: updateList(status: "Not Watched"); break
        case 2: updateList(status: "Will Watch"); break
        default: break
        }
    }
    
    func updateList(status: String) {
        let db = Database.database().reference().child("Users").child(currentUsername)
        db.child("List").child(status).child(_currentFilmID).child("Name").setValue(_currentFilm)
        db.child("List").child(status).child(_currentFilmID).child("Status").setValue(status)
        db.child("List").child(status).child(_currentFilmID).child("Point").setValue("N/A")
    }
        
    func getFilmGenre(film: String) {
        
        var resultGenre = "";
        let params = ["apikey" : API_KEY, "i" : _currentFilmID]
        
        DispatchQueue.main.async {
            
            Alamofire.request(self.OMDB_API, method: .get, parameters: params).responseJSON { (response) in
                
                print(response)
                
                if response.result.isSuccess {
                    let filmJSON : JSON = JSON(response.result.value!)
                    resultGenre = filmJSON["Genre"].string!
                } else {
                    print("Some error occured")
                    self.showAlert(title: "Sorry", message: "Check your internet connection")
                }
                
                if resultGenre.contains(",") {
                    resultGenre = resultGenre.mySubstring(to: resultGenre.firstIndex(of: ",")!)
                }
                
                self.filmGenreLabel.text = resultGenre

            }
            
        }
        
    //    print("ASDASD", resultGenre)
    }
    
    func showAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }

    
}
