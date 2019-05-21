//
//  HomeViewController.swift
//  MFL
//
//  Created by Bahadir Altun on 21.01.2019.
//  Copyright © 2019 Bahadir Altun. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SVProgressHUD
import SDWebImage

public extension String {
    
    public func mySubstring(to myIndex: String.Index) -> String {
        
        var resultString = ""
        for i in 1...self.count - 1 {
            resultString = resultString + String(self[index(startIndex, offsetBy: i - 1)])
            if myIndex == index(startIndex, offsetBy: i) {
                return resultString
            }
        }
        
        return resultString
    }
    
}

extension StringProtocol {
    var firstUppercased: String {
        guard let first = first else { return "" }
        return String(first).uppercased() + dropFirst()
    }
    var firstCapitalized: String {
        guard let first = first else { return "" }
        return String(first).capitalized + dropFirst()
    }
}

extension UITableView {
    
    public func reloadData(_ completion: @escaping ()->()) {
        UIView.animate(withDuration: 0, animations: {
            self.reloadData()
        }, completion:{ _ in
            completion()
        })
    }
    
    func scroll(to: scrollsTo, animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
            let numberOfSections = self.numberOfSections
            let numberOfRows = self.numberOfRows(inSection: numberOfSections-1)
            switch to {
            case .top:
                if numberOfRows > 0 {
                    let indexPath = IndexPath(row: 0, section: 0)
                    self.scrollToRow(at: indexPath, at: .top, animated: animated)
                }
                break
            case .bottom:
                if numberOfRows > 0 {
                    let indexPath = IndexPath(row: numberOfRows-1, section: (numberOfSections-1))
                    self.scrollToRow(at: indexPath, at: .bottom, animated: animated)
                }
                break
            }
        }
    }
    
    enum scrollsTo {
        case top,bottom
    }
}

class HomeViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
        
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    let currentUsername = MainPageViewController.username
    
    let OMDB_API = "https://www.omdbapi.com"
    let API_KEY = "76b4842e"
    
    var filmArray : [FilmModel] = [FilmModel]()
    let initialFilmArray = ["Avengers", "The Imitation Game", "Breaking Bad", "Game of Thrones", "Inception", "The 100"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    //    self.navigationController?.setNavigationBarHidden(true, animated: true)
        
    //    self.navigationItem.hidesBackButton = true
        
        
    //    self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        searchBar.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
                
        for i in initialFilmArray {
            initialFilmList(filmName: i)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.navigationItem.setHidesBackButton(true, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let film = filmArray[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilmCell", for: indexPath) as! TableViewCell
        
    //    print(film.name, film.category)
    //    cell.filmImageView = UIImageView(image: UIImage(named: "randImage.png"))
    //    cell.imageView?.image = UIImage(named: "randImage.png")
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filmArray.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 125.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchBar.endEditing(true)
        DispatchQueue.main.async {
            let cell = tableView.cellForRow(at: indexPath) as! TableViewCell
        //    print("HELLO!", cell.nameLabel.text!)
            FilmPageViewController.currentFilm = cell.nameLabel.text!
            FilmPageViewController.currentFilmCategory = cell.categoryLabel.text!
            FilmPageViewController.currentPosterURL = self.filmArray[indexPath.row].poster
            FilmPageViewController.currentFilmID = self.filmArray[indexPath.row].ID
            self.performSegue(withIdentifier: "goToFilmPageViewController", sender: self)
        }
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    
        if searchBar.text!.count < 3 {
            return
        }
        
        print(searchBar.text!)
    //    tappedOnScreen()
        
        let text = searchBar.text!
        let searchingText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let params = ["apikey" : API_KEY, "s" : searchingText]
        
    //    SVProgressHUD.show(withStatus: "Searching..")
        
        Alamofire.request(OMDB_API, method: .get, parameters: params).responseJSON { (response) in
            
        //    SVProgressHUD.dismiss()
            
            if response.result.isSuccess {
                
            //    print(response)
                
                let responseJSON : JSON = JSON(response.result.value!)
                
                if responseJSON["Response"] == "False" {
                    print("Film not found")
                //    self.showAlert(title: "Sorry", message: "Film not found")
                } else {
                    
                    self.filmArray = [FilmModel]()
                
                    for i in responseJSON["Search"] {
                    //    print(i)
                        
                        let filmJSON = i.1
                    //    let filmResponse = filmJSON["Response"].string
                        let filmName = filmJSON["Title"].string
                        let categoryName = filmJSON["Type"].string?.firstUppercased
                        let posterURL = filmJSON["Poster"].string
                        let filmID = filmJSON["imdbID"].string
                                                
                        let newFilm = FilmModel(_name: filmName!, _category: categoryName!, _poster: posterURL!, _ID: filmID!)
                        
                        self.filmArray.append(newFilm)
                        self.filmArray.reverse()
                    }

                    self.tableView.reloadData()
                    self.tableView.scroll(to: .top, animated: true)
                }
                
            } else {
                print("Some error occured")
                self.showAlert(title: "Sorry", message: "Check your internet connection")
            }
        }
        
    }
    
    func initialFilmList(filmName: String) {
        
        let params = ["apikey" : API_KEY, "t" : filmName]
        
        DispatchQueue.main.async {
            
            Alamofire.request(self.OMDB_API, method: .get, parameters: params).responseJSON { (response) in
                
                print(response)
                
                if response.result.isSuccess {
                
                    let filmJSON : JSON = JSON(response.result.value!)
                    let filmName = filmJSON["Title"].string
                    let categoryName = filmJSON["Type"].string?.firstUppercased
                    let posterURL = filmJSON["Poster"].string
                    let filmID = filmJSON["imdbID"].string
                    
                    let newFilm = FilmModel(_name: filmName!, _category: categoryName!, _poster: posterURL!, _ID: filmID!)
                    
                    self.filmArray.append(newFilm)
                //    self.filmArray.reverse()
                    self.tableView.reloadData()

                } else {
                    print("Some error occured")
                    self.showAlert(title: "Sorry", message: "Check your internet connection")
                }
                
            }
            
        }

    }
    
    func showAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    
}
