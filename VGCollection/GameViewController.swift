//
//  GameViewController.swift
//  VGCollection
//
//  Created by Tobiasz Dobrowolski on 13.05.2018.
//  Copyright © 2018 Tobiasz Dobrowolski. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {
    
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var consoleLabel: UILabel!
    @IBOutlet weak var studioLabel: UILabel!
    @IBOutlet weak var genresLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        deleteButton.layer.cornerRadius = 5
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
