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
    
    let createGameTable = """
    CREATE TABLE IF NOT EXISTS `Game` (
    `idg` int NOT NULL PRIMARY KEY,
    `title` varchar(100) NOT NULL,
    `year` int NOT NULL,
    `state` tinyint(5) NOT NULL,
    `c_url` text,
    `c_id` int NOT NULL);
    """
    
    let games = ["Uncharted 4: A Thief's End", "Spider Man", "Forza Horizon", "Kinect Adventures", "Mirror's Edge", "Heavy Rain", "The Last Of Us"]
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    /*@IBAction func indexChanged(_ sender: Any) {
        
        switch segmentedControl.selectedSegmentIndex {
            case 0:
            
            case 1:
            
            default:
                break
        }
    }*/
    
    // Funkcje do SQLite3
    @IBAction func navAdd(_ sender: Any) {
        self.performSegue(withIdentifier: "Indentifier", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nav = segue.destination as! UINavigationController
        let vc = nav.topViewController as! NewEntryViewController
        vc.db = db
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return games.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath) as! GameTableViewCell
        let row = indexPath.row
        
        cell.gameTitle.text = games[row]
        cell.console.text = consoles[row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

