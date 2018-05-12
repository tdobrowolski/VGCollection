//
//  ViewController.swift
//  VGCollection
//
//  Created by Tobiasz Dobrowolski on 12.05.2018.
//  Copyright © 2018 Tobiasz Dobrowolski. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    let games = ["Uncharted 4: A Thief's End", "Spider Man", "Forza Horizon", "Kinect Adventures", "Mirror's Edge", "Heavy Rain", "The Last Of Us"]
    
    let consoles = ["PS4", "PS4", "Xbox 360", "Xbox 360", "PC", "PS3", "PS3"]
    
    let textCellIdentifier = "gameCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
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

