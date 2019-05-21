//
//  FilmModel.swift
//  MFL
//
//  Created by Bahadir Altun on 22.01.2019.
//  Copyright © 2019 Bahadir Altun. All rights reserved.
//

class FilmModel {
    
    var name = "";
    var category = "";
    var poster = "";
    var ID = "";
    
    init(_name: String, _category: String, _poster: String, _ID: String) {
        name = _name
        category = _category
        poster = _poster;
        ID = _ID
    }
    
}
