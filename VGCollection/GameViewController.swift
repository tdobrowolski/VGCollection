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
    
    var genresArr = [String]()
    var studioArr = [String]()
    
    var genres = ""
    var studios = ""
    
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var consoleLabel: UILabel!
    @IBOutlet weak var studioLabel: UILabel!
    @IBOutlet weak var genresLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        readGameValues()
        
        coverImage.layer.shadowColor = UIColor.black.cgColor
        coverImage.layer.shadowOpacity = 0.3
        coverImage.layer.shadowOffset = CGSize.zero
        coverImage.layer.shadowRadius = 10
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        readGameValues()
    }
    
    // Pobieranie okładki
    func setUI() {
        let url = URL(string: (curGame?.c_url)!)
        
        let task = URLSession.shared.dataTask(with: url!) { data, response, error in
            guard let data = data, error == nil else { return }
            
            DispatchQueue.main.async() {    // execute on main thread
                self.coverImage.image = UIImage(data: data)
            }
        }
        
        task.resume()
        
        titleTextView.text = curGame!.title + " (" + String(curGame!.year) + ")"
        consoleLabel.text = curGame!.console
        
        genres = ""
        
        for i in genresArr {
            if (genres == "") {
                genres = genres + String(i)
            } else {
                genres = genres + ", "
                genres = genres + String(i)
            }
        }
        
        studios = ""
        
        for i in studioArr {
            if (studios == "") {
                studios = studios + String(i)
            } else {
                studios = studios + ", "
                studios = studios + String(i)
            }
        }
        
        genresLabel.text = genres
        studioLabel.text = studios
        
        curGame?.studio = studios
        
        deleteButton.layer.cornerRadius = 5
    }
    
    // Wczytywanie danych danej gry
    func readGameValues() {
        
        var selectString: String
        selectString = "SELECT Game.title, Game.year, Game.c_url, Console.title FROM Game INNER JOIN Console ON Game.c_id = Console.idc WHERE idg = \(String(describing: passedValue!))"

        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, selectString, -1, &statement, nil) == SQLITE_OK {
            
            if sqlite3_step(statement) == SQLITE_ROW {
                let title = String(cString: sqlite3_column_text(statement, 0))
                let year = sqlite3_column_int(statement, 1)
                let c_url = String(cString: sqlite3_column_text(statement, 2))
                let console = String(cString: sqlite3_column_text(statement, 3))
                curGame = Game(idg: passedValue!, title: String(describing: title), year: Int(year), c_url: String(describing: c_url), console: console)
                
            } else {
                print("Nothing to select")
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        
        selectString = """
        SELECT game_to_genre.g_id, Genre.name FROM game_to_genre
        INNER JOIN Genre ON game_to_genre.ge_id = Genre.idge
        WHERE g_id LIKE \(String(describing: passedValue!));
        """
        
        genresArr.removeAll()
        
        if sqlite3_prepare_v2(db, selectString, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                genresArr.append(String(cString: sqlite3_column_text(statement, 1)))
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        
        selectString = """
        SELECT game_to_studio.g_id, Studio.name FROM game_to_studio
        INNER JOIN Studio ON game_to_studio.s_id = Studio.ids
        WHERE g_id LIKE \(String(describing: passedValue!));
        """
        
        studioArr.removeAll()
        
        if sqlite3_prepare_v2(db, selectString, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                studioArr.append(String(cString: sqlite3_column_text(statement, 1)))
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        
        sqlite3_finalize(statement)
        
        setUI()
    }
    
    // Usuwanie
    @IBAction func deleteAction(_ sender: Any) {
        
        var statement: OpaquePointer? = nil
        
        let deleteString = """
        BEGIN;
        DELETE FROM game_to_genre WHERE g_id = \(String(describing: passedValue!));
        DELETE FROM game_to_studio WHERE g_id = \(String(describing: passedValue!));
        DELETE FROM Game WHERE idg = \(String(describing: passedValue!));
        COMMIT;
        """
        
        if sqlite3_prepare_v2(db, deleteString, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_exec(db, deleteString, nil, nil, nil) == SQLITE_OK {
                print("Successfully deleted game")
            } else {
                print("Can't delete game")
            }
        } else {
            print("DELETE statement could not be prepared")
        }
        
        self.navigationController?.popViewController(animated: true)
        
        sqlite3_finalize(statement)
    }
    
    @IBAction func edit(_ sender: Any) {
        self.performSegue(withIdentifier: "edit", sender: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "edit" {
            let nav = segue.destination as! UINavigationController
            let svc = nav.topViewController as! NewEntryViewController
            svc.passedGame = curGame
            svc.db = db
        }
    }
}
