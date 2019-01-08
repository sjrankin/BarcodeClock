//
//  RightSidePanel2ViewController.swift
//  BarcodeTest
//
//  Created by Stuart Rankin on 8/16/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class RightSidePanelViewController: UIViewController
{
    let _Settings = UserDefaults.standard
    
    /// Tell the system that we don't want the status bar getting in the way.
    override var prefersStatusBarHidden: Bool
    {
        return _Settings.bool(forKey: Setting.Key.HideStatusBar)
    }
    
    func ActionTaken(PanelAction: PanelActions)
    {
    }
    
    func SelectClockType2(ClockID: UUID)
    {
        
    }
    
    var delegate: SidePanelViewControllerDelegate? = nil
}
