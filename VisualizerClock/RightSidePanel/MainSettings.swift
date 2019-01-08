//
//  MainSettings.swift
//  BarcodeTest
//
//  Created by Stuart Rankin on 8/13/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class MainSettings: UITableViewController
{    
    var _Settings = UserDefaults.standard
    
    #if DEBUG
    let ShowDebugCells = true
    #else
    let ShowDebugCells = false
    #endif
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setNeedsStatusBarAppearanceUpdate()
    }
    
    @IBAction func HandleDonePressed(_ sender: Any)
    {
        navigationController?.dismiss(animated: true, completion: nil)
    }
}
