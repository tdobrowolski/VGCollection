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
    `c_id` INTEGER NOT NULL);
    """
    
    let consoles = ["PS4", "PS4", "Xbox 360", "Xbox 360", "PC", "PS3", "PS3"]
    
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
        
        if sqlite3_exec(db, createGameTable, nil, nil, nil) == SQLITE_OK {
            print("Table created successfully")
        } else {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("Error creating table: \(errmsg)")
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
            selectString = "SELECT * FROM Game WHERE state LIKE 0"
        } else {
            selectString = "SELECT * FROM Game WHERE state LIKE 1"
        }
        
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, selectString, -1, &statement, nil) == SQLITE_OK {
            
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = sqlite3_column_int(statement, 0)
                let title = String(cString: sqlite3_column_text(statement, 1))
                let year = sqlite3_column_int(statement, 2)
                let state = sqlite3_column_int(statement, 3)
                let c_url = String(cString: sqlite3_column_text(statement, 4))
                let c_id = sqlite3_column_int(statement, 5)
                
                gameList.append(Game(idg: Int(id), title: String(describing: title), year: Int(year), state: Int(state), c_url: String(describing: c_url), c_id: Int(c_id)))
                
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
        cell.console.text = String(game.c_id)
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

