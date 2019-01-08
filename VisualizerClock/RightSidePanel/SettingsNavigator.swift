//
//  SettingsNavigator.swift
//  BarcodeTest
//
//  Created by Stuart Rankin on 8/13/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class SettingsNavigator: UINavigationController
{
    let _Settings = UserDefaults.standard
    
    /*
    /// Tell the system that we don't want the status bar getting in the way.
    override var prefersStatusBarHidden: Bool
    {
        return true//_Settings.bool(forKey: Setting.Key.HideStatusBar)
    }
    */
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
}
