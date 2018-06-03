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
    
    init(idg: Int, title: String, year: Int, state: Int, c_url: String, c_id: Int) {
        self.idg = idg
        self.title = title
        self.year = year
        self.state = state
        self.c_url = c_url
        self.c_id = c_id
    }
    
}
