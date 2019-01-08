//
//  ProgramStatus.swift
//  Barcode Clock
//
//  Created by Stuart Rankin on 8/25/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class ProgramStatus: UITableViewController
{
    let _Settings = UserDefaults.standard
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        #if DEBUG
        DEBUGLabel.text = "TRUE"
        #else
        DEBUGLabel.text = "FALSE"
        #endif
        let OnSimulator = _Settings.bool(forKey: Setting.Key.RunningOnSimulator)
        SimulatorLabel.text = OnSimulator ? "TRUE" : "FALSE"
    }
    
    @IBOutlet weak var DEBUGLabel: UILabel!
    
    @IBOutlet weak var SimulatorLabel: UILabel!
}
