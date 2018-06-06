//
//  ViewController.swift
//  VGCollection
//
//  Created by Tobiasz Dobrowolski on 12.05.2018.
//  Copyright © 2018 Tobiasz Dobrowolski. All rights reserved.
//

import UIKit
import SQLite3

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var db: OpaquePointer?
    var gameList = [Game]()
    var valueToPass: Int!
    
    let createGameTable = """
    CREATE TABLE IF NOT EXISTS `Game` (
    `idg` INTEGER PRIMARY KEY AUTOINCREMENT,
    `title` TEXT NOT NULL,
    `year` INTEGER NOT NULL,
    `state` tinyint(5) NOT NULL,
    `c_url` TEXT,
    `c_id` INTEGER NOT NULL,
    FOREIGN KEY(c_id) REFERENCES Console(idc));
    """
    
    let createConsoleTable = """
    CREATE TABLE IF NOT EXISTS `Console` (
    `idc` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    `title` varchar(20) NOT NULL);
    INSERT INTO Console (title) VALUES ('PS4');
    INSERT INTO Console (title) VALUES ('Xbox One');
    INSERT INTO Console (title) VALUES ('Switch');
    INSERT INTO Console (title) VALUES ('PS3');
    INSERT INTO Console (title) VALUES ('Xbox 360');
    INSERT INTO Console (title) VALUES ('Wii U');
    INSERT INTO Console (title) VALUES ('Wii');
    INSERT INTO Console (title) VALUES ('PC');
    """
    
    let createGenreTable = """
    CREATE TABLE IF NOT EXISTS `Genre` (
    `idge` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    `name` varchar(40) NOT NULL);
    INSERT INTO Genre (name) VALUES ('Adventure');
    INSERT INTO Genre (name) VALUES ('Shooter');
    INSERT INTO Genre (name) VALUES ('Platform');
    INSERT INTO Genre (name) VALUES ('Survival');
    INSERT INTO Genre (name) VALUES ('RPG');
    INSERT INTO Genre (name) VALUES ('Action');
    INSERT INTO Genre (name) VALUES ('RTS');
    INSERT INTO Genre (name) VALUES ('Racing');
    INSERT INTO Genre (name) VALUES ('Sports');
    INSERT INTO Genre (name) VALUES ('Simulation');
    INSERT INTO Genre (name) VALUES ('Party');
    INSERT INTO Genre (name) VALUES ('F2P');
    """
    
    let createGameToGenreTable = """
    CREATE TABLE IF NOT EXISTS `game_to_genre` (
    `g_id` INTEGER NOT NULL,
    `ge_id` INTEGER NOT NULL,
    FOREIGN KEY (g_id) REFERENCES Game(idg)
    ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY(ge_id) REFERENCES Genre(idge)
    ON DELETE CASCADE ON UPDATE CASCADE);
    """
    
    let createStudioTable = """
    CREATE TABLE IF NOT EXISTS `Studio` (
    `ids` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    `name` varchar(40) NOT NULL);
    """
    
    let createGameToStudioTable = """
    CREATE TABLE IF NOT EXISTS `game_to_studio` (
    `g_id` INTEGER NOT NULL,
    `s_id` INTEGER NOT NULL,
    FOREIGN KEY (g_id) REFERENCES Game(idg)
    ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY(s_id) REFERENCES Studio(ids)
    ON DELETE CASCADE ON UPDATE CASCADE);
    """
        
    let textCellIdentifier = "gameCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create database file
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("GamesDatabase.sqlite")
        
        if sqlite3_open(fileURL.path, &db) == SQLITE_OK {
            print("Database opened successfully")
        } else {
            print("Unable to open database")
        }
        
        // Create tables if app is opened for the first time
        if !UserDefaults.standard.bool(forKey: "FirstTimeLauched") {
            UserDefaults.standard.set(true, forKey: "FirstTimeLauched")
            UserDefaults.standard.synchronize()
            execute(query: createConsoleTable)
            execute(query: createGameTable)
            execute(query: createGenreTable)
            execute(query: createGameToGenreTable)
            execute(query: createStudioTable)
            execute(query: createGameToStudioTable)
            print("first time")
        }

        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        readValues(state: segmentedControl.selectedSegmentIndex)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func execute(query: String) {
        if sqlite3_exec(db, query, nil, nil, nil) == SQLITE_OK {
            print("Table created successfully")
        } else {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("Error creating table: \(errmsg)")
        }
    }

    @IBAction func indexChanged(_ sender: Any) {
        
        switch segmentedControl.selectedSegmentIndex {
            case 0:
                readValues(state: 0)
            case 1:
                readValues(state: 1)
            default:
                break
        }
    }
    
    // Czytanie wartosci z bazy danych
    func readValues(state: Int) {
        
        gameList.removeAll()
        let selectString: String
        
        if state == 0 {
            selectString = "SELECT idg, Game.title, year, state, c_url, c_id, Console.title FROM Game INNER JOIN Console ON Game.c_id = Console.idc WHERE state LIKE 0"
        } else {
            selectString = "SELECT idg, Game.title, year, state, c_url, c_id, Console.title FROM Game INNER JOIN Console ON Game.c_id = Console.idc WHERE state LIKE 1"
        }
        
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, selectString, -1, &statement, nil) == SQLITE_OK {
            
            while sqlite3_step(statement) == SQLITE_ROW {
                let idg = sqlite3_column_int(statement, 0)
                let title = String(cString: sqlite3_column_text(statement, 1))
                let year = sqlite3_column_int(statement, 2)
                let state = sqlite3_column_int(statement, 3)
                let c_url = String(cString: sqlite3_column_text(statement, 4))
                let c_id = sqlite3_column_int(statement, 5)
                
                let console = String(cString: sqlite3_column_text(statement, 6))
                
                gameList.append(Game(idg: Int(idg), title: String(describing: title), year: Int(year), state: Int(state), c_url: String(describing: c_url), c_id: Int(c_id), console: String(describing: console)))
                
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        
        sqlite3_finalize(statement)
        self.tableView.reloadData()
    }
    
    // Prepare for segue
    @IBAction func navAdd(_ sender: Any) {
        self.performSegue(withIdentifier: "Indentifier", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detail" {
            let vc = segue.destination as! GameViewController
            vc.passedValue = valueToPass
            vc.db = db
        } else {
            let nav = segue.destination as! UINavigationController
            let vc = nav.topViewController as! NewEntryViewController
            vc.db = db
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gameList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath) as! GameTableViewCell
        let row = indexPath.row
        let game: Game
        
        game = gameList[row]
        cell.gameTitle.text = game.title
        cell.console.text = game.console
        cell.idg = game.idg
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let currentCell = tableView.cellForRow(at: indexPath) as! GameTableViewCell
        valueToPass = currentCell.idg
        performSegue(withIdentifier: "detail", sender: self)
        
    }
    
}

