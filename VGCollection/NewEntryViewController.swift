//
//  NewEntryViewController.swift
//  
//
//  Created by Tobiasz Dobrowolski on 16.05.2018.
//

import UIKit
import SQLite3

class NewEntryViewController: UITableViewController {
    
    // TextField Outlets
    @IBOutlet weak var gameTitle: UITextField!
    @IBOutlet weak var studio: UITextField!
    @IBOutlet weak var coverURL: UITextField!
    
    var db: OpaquePointer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func insert(state: Int) {
        var insertStatement: OpaquePointer?
        
        let insertString = "INSERT INTO Game (idg, title, year, state, c_url, c_id) VALUES (?,?,?,?,?,?);"
        
        //preparing the query
        if sqlite3_prepare_v2(db, insertString, -1, &insertStatement, nil) == SQLITE_OK {
            
            sqlite3_bind_int(insertStatement, 1, 0)
            sqlite3_bind_text(insertStatement, 2, gameTitle.text, -1, nil)
            sqlite3_bind_int(insertStatement, 3, 2018)
            sqlite3_bind_int(insertStatement, 4, Int32(state))
            sqlite3_bind_text(insertStatement, 5, coverURL.text, -1, nil)
            sqlite3_bind_int(insertStatement, 6, 1)
            
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("Successfully inserted row.")
            } else {
                print("Could not insert row.")
            }
            
        } else {
            print("INSERT statement could not be prepared.")
        }
        
        sqlite3_finalize(insertStatement)
    }
    
    @IBAction func Done(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: "Add to:", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "My games", style: .default , handler:{ (UIAlertAction)in
            self.insert(state: 1)
        }))
        
        alert.addAction(UIAlertAction(title: "Wish list", style: .default , handler:{ (UIAlertAction)in
            self.insert(state: 0)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{ (UIAlertAction)in }))
        
        self.present(alert, animated: true, completion: {
            print("completion block")
        })
    }
    
    @IBAction func Cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
