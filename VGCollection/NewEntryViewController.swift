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
    
    @IBOutlet weak var consoleLabel: UILabel!
    @IBOutlet weak var genresLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    
    var db: OpaquePointer?
    var pickerData = [Int]()
    var newGame: Game?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        
        self.pickerView.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func insert(state: Int) {
        var insertStatement: OpaquePointer?
        
        let insertString = "INSERT INTO Game (title, year, state, c_url, c_id) VALUES (?,?,?,?,?);"
        
        //preparing the query
        if sqlite3_prepare_v2(db, insertString, -1, &insertStatement, nil) == SQLITE_OK {
            
            sqlite3_bind_text(insertStatement, 1, (gameTitle.text! as NSString).utf8String, -1, nil)
            print(gameTitle.text!)
            sqlite3_bind_int(insertStatement, 2, Int32(2018))
            sqlite3_bind_int(insertStatement, 3, Int32(state))
            sqlite3_bind_text(insertStatement, 4, (coverURL.text! as NSString).utf8String, -1, nil)
            print(coverURL.text!)
            sqlite3_bind_int(insertStatement, 5, 1)
            
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
    
    @IBAction func chooseConsole(_ sender: Any) {
        if chooseGenresButton.isEnabled == true {
            self.pickerView.isHidden = false
            
            pickerData.removeAll()
            for i in 1980...2018 { // zmien na dostep do konsoli
                pickerData.append(i)
            }
            
            self.pickerView.delegate = self
            chooseGenresButton.isEnabled = false
            chooseYearButton.isEnabled = false
        } else {
            print("Year has been chosen. Everything is back to normal.")
            newGame?.c_id = pickerData[pickerView.selectedRow(inComponent: 0)]
            print(newGame?.c_id) // nie dziala :(
            consoleLabel.text = String(pickerData[pickerView.selectedRow(inComponent: 0)])
            chooseGenresButton.isEnabled = true
            chooseYearButton.isEnabled = true
            self.pickerView.isHidden = true
        }
    }
    
    @IBAction func chooseGenres(_ sender: Any) {
    }
    
    @IBAction func chooseYear(_ sender: Any) {
        
        if chooseGenresButton.isEnabled == true {
            print("hello")
            self.pickerView.isHidden = false
            
            pickerData.removeAll()
            for i in 1980...2018 {
                pickerData.append(i)
            }
            
            self.pickerView.delegate = self
            chooseConsoleButton.isEnabled = false
            chooseGenresButton.isEnabled = false
        } else {
            print("Year has been chosen. Everything is back to normal.")
            newGame?.year = pickerData[pickerView.selectedRow(inComponent: 0)]
            print(newGame?.year) // nie dziala :(
            yearLabel.text = String(pickerData[pickerView.selectedRow(inComponent: 0)])
            chooseConsoleButton.isEnabled = true
            chooseGenresButton.isEnabled = true
            self.pickerView.isHidden = true
        }
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
            self.insert(state: 0)
            self.dismiss(animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Wish list", style: .default , handler:{ (UIAlertAction)in
            self.insert(state: 1)
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
