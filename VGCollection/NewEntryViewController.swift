//
//  NewEntryViewController.swift
//  
//
//  Created by Tobiasz Dobrowolski on 16.05.2018.
//

import UIKit
import SQLite3

class NewEntryViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    // TextField Outlets
    @IBOutlet weak var gameTitle: UITextField!
    @IBOutlet weak var studio: UITextField!
    @IBOutlet weak var coverURL: UITextField!
    @IBOutlet weak var pickerView: UIPickerView!
    
    @IBOutlet weak var chooseConsoleButton: UIButton!
    @IBOutlet weak var chooseGenresButton: UIButton!
    @IBOutlet weak var chooseYearButton: UIButton!
    
    @IBOutlet weak var closeGenresButton: UIButton!
    
    @IBOutlet weak var consoleLabel: UILabel!
    @IBOutlet weak var genresLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    
    var db: OpaquePointer?
    var pickerData = [String]()
    var newGame: Game?
    var genres: String?
    
    var availableConsoles = [String]()
    var availableGenres = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        newGame = Game()
        queryConsolesAndGenres()
        
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        
        self.pickerView.isHidden = true
        self.closeGenresButton.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func insertGame(state: Int) {
        var insertStatement: OpaquePointer?
        
        let insertString = "INSERT INTO Game (title, year, state, c_url, c_id) VALUES (?,?,?,?,?);"
        
        //preparing the query
        if sqlite3_prepare_v2(db, insertString, -1, &insertStatement, nil) == SQLITE_OK {
            
            sqlite3_bind_text(insertStatement, 1, (gameTitle.text! as NSString).utf8String, -1, nil)
            sqlite3_bind_int(insertStatement, 2, Int32(newGame!.year))
            sqlite3_bind_int(insertStatement, 3, Int32(state))
            sqlite3_bind_text(insertStatement, 4, (coverURL.text! as NSString).utf8String, -1, nil)
            sqlite3_bind_int(insertStatement, 5, Int32(newGame!.c_id))
            
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("Successfully inserted row.")
                newGame!.idg = Int(sqlite3_last_insert_rowid(db))
            } else {
                print("Could not insertGame row.")
            }
            
        } else {
            print("INSERT statement could not be prepared.")
        }
        
        sqlite3_finalize(insertStatement)
    }
    
    func insertStudio() {
        let studioArr = studio.text?.components(separatedBy: ", ")
        
    }
    
    func insertGameToGenre() {
        var insertStatement: OpaquePointer?
        
        let insertGameGenre = "INSERT INTO game_to_genre (g_id, ge_id) VALUES (?,?);"
        
        for i in newGame!.genres {
            print(i)
            if sqlite3_prepare_v2(db, insertGameGenre, -1, &insertStatement, nil) == SQLITE_OK {
                sqlite3_bind_int(insertStatement, 2, Int32(newGame!.idg))
                sqlite3_bind_int(insertStatement, 3, Int32(i))
                if sqlite3_step(insertStatement) == SQLITE_DONE {
                    print("Successfully inserted row.")
                } else {
                    print("Could not insertGameToGenre row.")
                }
            } else {
                print("INSERT statement could not be prepared.")
            }
        }
        
        sqlite3_finalize(insertStatement)
    }
    
    func queryConsolesAndGenres() {
        
        var statement: OpaquePointer?
        
        let selectConsole = "SELECT title FROM Console;"
        
        if sqlite3_prepare_v2(db, selectConsole, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let title = String(cString: sqlite3_column_text(statement, 0))
                availableConsoles.append(title)
            }
        } else {
            print("SELECT statement could not be prepared (Console)")
        }
        
        let selectGenres = "SELECT name FROM Genre;"
        
        if sqlite3_prepare_v2(db, selectGenres, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let title = String(cString: sqlite3_column_text(statement, 0))
                availableGenres.append(title)
            }
        } else {
            print("SELECT statement could not be prepared (Genre)")
        }
        
        sqlite3_finalize(statement)
    }
    
    @IBAction func chooseConsole(_ sender: Any) {
        if chooseGenresButton.isEnabled == true {
            self.pickerView.isHidden = false
            
            pickerData.removeAll()
            for i in availableConsoles {
                pickerData.append(i)
            }
            
            self.pickerView.delegate = self
            chooseGenresButton.isEnabled = false
            chooseYearButton.isEnabled = false
        } else {
            print("Console has been chosen. Everything is back to normal.")
            newGame!.c_id = pickerView.selectedRow(inComponent: 0)+1
            consoleLabel.text = String(pickerData[pickerView.selectedRow(inComponent: 0)])
            chooseGenresButton.isEnabled = true
            chooseYearButton.isEnabled = true
            self.pickerView.isHidden = true
        }
    }
    
    @IBAction func chooseGenres(_ sender: Any) {
        if chooseYearButton.isEnabled == true {
            self.pickerView.isHidden = false
            self.closeGenresButton.isHidden = false
            
            newGame?.genres = []
            genres = ""
            genresLabel.text = "Genres"
            
            pickerData.removeAll()
            for i in availableGenres { // zmien na dostep do gatunkow
                pickerData.append(i)
            }
            
            self.pickerView.delegate = self
            chooseConsoleButton.isEnabled = false
            chooseYearButton.isEnabled = false
        } else {
            print("Genre has been chosen. Waiting for more.")
            let newGenre = availableGenres.index(of: pickerData[pickerView.selectedRow(inComponent: 0)])! + 1
            
            newGame?.genres.append(newGenre)
            print(newGame!.genres)
            
            pickerData.remove(at: pickerView.selectedRow(inComponent: 0))
            pickerView.reloadAllComponents()
            
            if (genres == "") {
                genres = genres! + String(pickerData[pickerView.selectedRow(inComponent: 0)])
            } else {
                genres = genres! + ", "
                genres = genres! + String(pickerData[pickerView.selectedRow(inComponent: 0)])
            }
            
            genresLabel.text = genres
        }
    }
    
    @IBAction func chooseYear(_ sender: Any) {
        
        if chooseGenresButton.isEnabled == true {
            self.pickerView.isHidden = false
            
            pickerData.removeAll()
            for i in 1980...2018 {
                pickerData.append(String(i))
            }
            
            self.pickerView.delegate = self
            chooseConsoleButton.isEnabled = false
            chooseGenresButton.isEnabled = false
        } else {
            print("Year has been chosen. Everything is back to normal.")
            newGame!.year = Int(pickerData[pickerView.selectedRow(inComponent: 0)])!
            yearLabel.text = String(pickerData[pickerView.selectedRow(inComponent: 0)])
            chooseConsoleButton.isEnabled = true
            chooseGenresButton.isEnabled = true
            self.pickerView.isHidden = true
        }
    }
    
    @IBAction func closeGenresPicker(_ sender: Any) {
        chooseConsoleButton.isEnabled = true
        chooseYearButton.isEnabled = true
        
        if (genres == "") {
            genresLabel.text = "Genres"
        }
        
        self.pickerView.isHidden = true
        self.closeGenresButton.isHidden = true
    }
    
    // UIPickerView
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(pickerData[row])
    }
    
    @IBAction func Done(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: "Add to:", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "My games", style: .default , handler:{ (UIAlertAction)in
            self.insertGame(state: 0)
            self.insertGameToGenre()
            self.dismiss(animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Wish list", style: .default , handler:{ (UIAlertAction)in
            self.insertGame(state: 1)
            self.dismiss(animated: true, completion: nil)
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
