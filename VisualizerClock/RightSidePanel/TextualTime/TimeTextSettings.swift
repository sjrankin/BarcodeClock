//
//  TimeTextSettings.swift
//  BarcodeTest
//
//  Created by Stuart Rankin on 8/14/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class TimeTextSettings: UITableViewController
{
    /// Tell the system that we don't want the status bar getting in the way.
    override var prefersStatusBarHidden: Bool
    {
        return _Settings.bool(forKey: Setting.Key.HideStatusBar)
    }
    
    let _Settings = UserDefaults.standard
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        ShowTextTimeButton.isOn = _Settings.bool(forKey: Setting.Key.ShowTextualTime)
        ShowSecondsSwitch.isOn = _Settings.bool(forKey: Setting.Key.Text.ShowSeconds)
        As24HourTimeSwitch.isOn = _Settings.bool(forKey: Setting.Key.Text.Use24HourTime)
        ShowAMPMSwitch.isOn = _Settings.bool(forKey: Setting.Key.Text.ShowAMPM)
        ShowAMPMSwitch.isEnabled = !As24HourTimeSwitch.isOn
        AMPMTitle.isEnabled = !As24HourTimeSwitch.isOn
        TextLocationSegment.selectedSegmentIndex = _Settings.integer(forKey: Setting.Key.TimeLocation)
        TimeFillsVerticalSpaceSwitch.isOn = _Settings.bool(forKey: Setting.Key.Text.LandscapeTimeFitsSpace)
    }
    
    @IBOutlet weak var ShowSecondsSwitch: UISwitch!
    
    @IBAction func HandleShowSecondsChanged(_ sender: Any)
    {
        _Settings.set(ShowSecondsSwitch.isOn, forKey: Setting.Key.Text.ShowSeconds)
    }
    
    @IBOutlet weak var As24HourTimeSwitch: UISwitch!
    
    @IBAction func Handle24HourTimeChanged(_ sender: Any)
    {
        _Settings.set(As24HourTimeSwitch.isOn, forKey: Setting.Key.Text.Use24HourTime)
        ShowAMPMSwitch.isEnabled = !As24HourTimeSwitch.isOn
        AMPMTitle.isEnabled = !As24HourTimeSwitch.isOn
        if As24HourTimeSwitch.isOn
        {
            ShowAMPMSwitch.isOn = false
        }
    }
    
    @IBOutlet weak var AMPMTitle: UILabel!
    
    @IBOutlet weak var ShowAMPMSwitch: UISwitch!
    
    @IBAction func HandleShowAMPMChanged(_ sender: Any)
    {
        _Settings.set(ShowAMPMSwitch.isOn, forKey: Setting.Key.Text.ShowAMPM)
    }
    
    @IBOutlet weak var TextLocationSegment: UISegmentedControl!
    
    @IBAction func HandleTextLocationChanged(_ sender: Any)
    {
        _Settings.set(TextLocationSegment.selectedSegmentIndex, forKey: Setting.Key.TimeLocation)
    }
    @IBOutlet weak var TimeFillsVerticalSpaceSwitch: UISwitch!
    
    @IBAction func HandleChangesToFillingVerticalSpace(_ sender: Any)
    {
        _Settings.set(TimeFillsVerticalSpaceSwitch.isOn, forKey: Setting.Key.Text.LandscapeTimeFitsSpace)
    }
    
    @IBOutlet weak var ShowTextTimeButton: UISwitch!
    
    @IBAction func HandleTextTimeChanged(_ sender: Any)
    {
        _Settings.set(ShowTextTimeButton.isOn, forKey: Setting.Key.ShowTextualTime)
    }
}
