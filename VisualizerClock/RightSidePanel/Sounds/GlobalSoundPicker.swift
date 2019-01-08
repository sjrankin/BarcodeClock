//
//  GlobalSoundPicker.swift
//  Visualizer Clock
//
//  Created by Stuart Rankin on 11/29/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class GlobalSoundPicker: UIViewController, SettingProtocol, UITableViewDelegate, UITableViewDataSource
{
    var delegate: SettingProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        SoundListView.delegate = self
        SoundListView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        return UITableViewCell()
    }
    
    func DoSet(Key: String, Value: Any?)
    {
        switch Key
        {
        case "NewTitle":
            title = Value as? String
            
        case "SoundList":
            break
            
        default:
            break
        }
    }
    
    @IBOutlet weak var LoopButton: UIBarButtonItem!
    
    @IBAction func HandleLoopPressed(_ sender: Any)
    {
        Looping = !Looping
        let LoopTitle = Looping ? "Loop" : "No Loop"
        LoopButton.title = LoopTitle
    }
    
    var Looping: Bool = true
    
    @IBOutlet weak var PlayButton: UIBarButtonItem!
    
    @IBAction func HandlePlayButtonPressed(_ sender: Any)
    {
        Playing = !Playing
        let TitleString = Playing ? "Stop" : "Play"
        PlayButton.title = TitleString
    }
    
    var Playing: Bool = false
    
    @IBOutlet weak var SoundListView: UITableView!
}
