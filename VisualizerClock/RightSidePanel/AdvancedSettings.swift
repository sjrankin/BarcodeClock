//
//  AdvancedSettings.swift
//  BarcodeTest
//
//  Created by Stuart Rankin on 8/16/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Code for the editing of advanced settings by the user.
class AdvancedSettings: UITableViewController
{
    /// Tell the system that we don't want the status bar getting in the way.
    override var prefersStatusBarHidden: Bool
    {
        return _Settings.bool(forKey: Setting.Key.HideStatusBar)
    }
    
    /// User default settings.
    let _Settings = UserDefaults.standard
    
    /// Set up the UI.
    override func viewDidLoad()
    {
        super.viewDidLoad()
        HideStatusBarSwitch.isOn = _Settings.bool(forKey: Setting.Key.HideStatusBar)
        StayAwakeSwitch.isOn = _Settings.bool(forKey: Setting.Key.StayAwake)
        let RotationIndex = Utility.GetButtonRotationIndex(FromDuration: _Settings.double(forKey: Setting.Key.ButtonRotationDuration))
        MenuRotationSpeedSegment.selectedSegmentIndex = RotationIndex
        DynamicUISegments.selectedSegmentIndex = _Settings.integer(forKey: Setting.Key.UIDynamicMethod)
        MenuButtonSegments.selectedSegmentIndex = _Settings.integer(forKey: Setting.Key.MenuButtonBehavior)
        ShowStartupVersionSwitch.isOn = _Settings.bool(forKey: Setting.Key.ShowVersionOnMainScreen)
    }
    
    /// The hide status bar switch.
    @IBOutlet weak var HideStatusBarSwitch: UISwitch!
    
    /// Handle changes to the hide status bar switch.
    ///
    /// - Parameter sender: Not used.
    @IBAction func HandleHideStatusChanged(_ sender: Any)
    {
        let IsOn = HideStatusBarSwitch.isOn
        _Settings.set(IsOn, forKey: Setting.Key.HideStatusBar)
        #if false
        ShowAlert(Message: "This setting will take affect next time you start Barcode Clock.")
        #endif
    }
    
    @IBOutlet weak var StayAwakeSwitch: UISwitch!
    
    /// Handle changes to the stay awake switch.
    ///
    /// - Parameter sender: Not used.
    @IBAction func HandleStayAwakeChanged(_ sender: Any)
    {
        let IsOn = StayAwakeSwitch.isOn
        _Settings.set(IsOn, forKey: Setting.Key.StayAwake)
        ShowAlert(Message: "This setting will take affect next time you start Barcode Clock.")
    }
    
    /// Show a simple alert. Used when telling the user that something may not happen right away.
    ///
    /// - Parameter Message: Text message to display.
    func ShowAlert(Message: String)
    {
        let Alert = UIAlertController(title: "Settings", message: Message, preferredStyle: .alert)
        let AlertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        Alert.addAction(AlertAction)
        present(Alert, animated: true)
    }
    
    /// The segment control that lets the user control the velocity of the rotation.
    @IBOutlet weak var MenuRotationSpeedSegment: UISegmentedControl!
    
    /// Handle changes to the rotate menu buttons segment control. Lets the user specify the rotation speed of the
    /// menu buttons (or turn off rotation).
    ///
    /// - Parameter sender: Not used.
    @IBAction func HandleMenuRotationSpeedChanged(_ sender: Any)
    {
        let NewRotation = Utility.GetButtonRotationDuration(FromIndex: MenuRotationSpeedSegment.selectedSegmentIndex)
        _Settings.set(NewRotation, forKey: Setting.Key.ButtonRotationDuration)
    }
    
    /// The dynamic UI segment control. Lets the user tell the program how to handle appearance and disappearance of
    /// UI objects.
    @IBOutlet weak var DynamicUISegments: UISegmentedControl!
    
    /// Handle changes to the dynamic UI segment bar.
    ///
    /// - Parameter sender: Not used.
    @IBAction func HandleDynamicUIChanged(_ sender: Any)
    {
        _Settings.set(DynamicUISegments.selectedSegmentIndex, forKey: Setting.Key.UIDynamicMethod)
    }
    
    @IBOutlet weak var MenuButtonSegments: UISegmentedControl!
    
    @IBAction func HandleMenuButtonChanged(_ sender: Any)
    {
        _Settings.set(MenuButtonSegments.selectedSegmentIndex, forKey: Setting.Key.MenuButtonBehavior)
    }
    
    @IBOutlet weak var ShowStartupVersionSwitch: UISwitch!
    
    @IBAction func HandleShowStartupVersionChanged(_ sender: Any)
    {
        _Settings.set(ShowStartupVersionSwitch.isOn, forKey: Setting.Key.ShowVersionOnMainScreen)
    }
}
