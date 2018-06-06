//
//  Game.swift
//  VGCollection
//
//  Created by Tobiasz Dobrowolski on 03.06.2018.
//  Copyright © 2018 Tobiasz Dobrowolski. All rights reserved.
//

import Foundation

class Game {
    
    var idg: Int
    var title: String
    var year: Int
    var state: Int
    var c_url: String
    var c_id: Int
    
    var console: String
    var genres: String
    var studio: String
    
    init(idg: Int = -1, title: String = "none", year: Int = 0, state: Int = 0, c_url: String = "none", c_id: Int = 0, console: String = "none", genres: String = "none", studio: String = "none") {
        self.idg = idg
        self.title = title
        self.year = year
        self.state = state
        self.c_url = c_url
        self.c_id = c_id
        
        self.console = console
        self.genres = genres
        self.studio = studio
    }
    
}
