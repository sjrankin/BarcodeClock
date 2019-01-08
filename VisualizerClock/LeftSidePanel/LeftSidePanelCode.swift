//
//  SettingsPanel.swift
//  BarcodeTest
//
//  Created by Stuart Rankin on 8/13/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class LeftSidePanelCode: LeftSidePanelViewController, SidePanelViewControllerDelegate
{
    /// Tell the system that we don't want the status bar getting in the way.
    override var prefersStatusBarHidden: Bool
    {
        return _Settings.bool(forKey: Setting.Key.HideStatusBar)
    }
    
    func SelectClockType(ClockID: UUID)
    {
    }
    
    func ActionTaken(PanelAction: PanelActions)
    {
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
}
