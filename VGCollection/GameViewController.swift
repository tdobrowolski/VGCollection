//
//  GameViewController.swift
//  VGCollection
//
//  Created by Tobiasz Dobrowolski on 13.05.2018.
//  Copyright © 2018 Tobiasz Dobrowolski. All rights reserved.
//

import UIKit
import SQLite3

class GameViewController: UIViewController {
    
    var db: OpaquePointer?
    var passedValue: Int?
    var curGame: Game?
    
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var consoleLabel: UILabel!
    @IBOutlet weak var studioLabel: UILabel!
    @IBOutlet weak var genresLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        readGameValues()
    
        titleTextView.text = curGame?.title
        consoleLabel.text = String(describing: curGame?.c_id)
        
        deleteButton.layer.cornerRadius = 5
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func readGameValues() {
        
        let selectString: String
        
        selectString = "SELECT * FROM Game WHERE idg LIKE \(String(describing: passedValue!))"

        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, selectString, -1, &statement, nil) == SQLITE_OK {
            
            if sqlite3_step(statement) == SQLITE_ROW {
                let id = sqlite3_column_int(statement, 0)
                let title = String(cString: sqlite3_column_text(statement, 1))
                let year = sqlite3_column_int(statement, 2)
                let state = sqlite3_column_int(statement, 3)
                let c_url = String(cString: sqlite3_column_text(statement, 4))
                let c_id = sqlite3_column_int(statement, 5)
                
                curGame = Game(idg: Int(id), title: String(describing: title), year: Int(year), state: Int(state), c_url: String(describing: c_url), c_id: Int(c_id))
                
            } else {
                print("Nothing to select")
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        
        sqlite3_finalize(statement)
    }
    
    @IBAction func deleteAction(_ sender: Any) {
        
        var statement: OpaquePointer? = nil
        
        let deleteString = "DELETE FROM Game WHERE idg = \(String(describing: passedValue!))"
        
        if sqlite3_prepare_v2(db, deleteString, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Successfully deleted row")
                self.navigationController?.popViewController(animated: true)
            } else {
                print("Could not delete row")
            }
        } else {
            print("DELETE statement could not be prepared")
        }
        
        sqlite3_finalize(statement)
    }
    
    
}
