//
//  DarkModeSettings.swift
//  BarcodeTest
//
//  Created by Stuart Rankin on 8/14/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class DarkModeSettings: UITableViewController
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
        EnableDarkModeSwitch.isOn = _Settings.bool(forKey: Setting.Key.EnableDarkMode)
        let StartTime = _Settings.string(forKey: Setting.Key.DarkModeStartTime)
        let StartDate = Utility.SimpleStringToDate(StartTime!)
        DarkModeStartPicker.date = StartDate!
        let Duration = _Settings.integer(forKey: Setting.Key.DarkModeDuration)
        let StopDate = Utility.TimeWithOffset(Start: StartDate!, Duration: Duration)
        DarkModeEndPicker.date = StopDate
        DurationOutput.text = String("\(Duration)")
        
        RelativeSaturationSegments.selectedSegmentIndex = _Settings.integer(forKey: Setting.Key.DarkModeRelativeSaturation)
        RelativeBrightnessSegments.selectedSegmentIndex = _Settings.integer(forKey: Setting.Key.DarkModeRelativeBrightness)
        ChangeSaturationSwitch.isOn = _Settings.bool(forKey: Setting.Key.DarkModeChangeSaturation)
        ChangeBrightnessSwitch.isOn = _Settings.bool(forKey: Setting.Key.DarkModeChangeBrightness)
        SetUI()
    }
    
    func SetUI()
    {
        DarkModeEndPicker.isEnabled = EnableDarkModeSwitch.isOn
        DarkModeStartPicker.isEnabled = EnableDarkModeSwitch.isOn
        DarkModeStartTimeTitle.isEnabled = EnableDarkModeSwitch.isOn
        DarkModeEndTimeTitle.isEnabled = EnableDarkModeSwitch.isOn
        DurationTitle.isEnabled = EnableDarkModeSwitch.isOn
        DurationOutput.isEnabled = EnableDarkModeSwitch.isOn
        ChangeSaturationTitle.isEnabled = EnableDarkModeSwitch.isOn
        ChangeBrightnessTitle.isEnabled = EnableDarkModeSwitch.isOn
        ChangeBrightnessSwitch.isEnabled = EnableDarkModeSwitch.isOn
        ChangeSaturationSwitch.isEnabled = EnableDarkModeSwitch.isOn
        RelativeBrightnessTitle.isEnabled = EnableDarkModeSwitch.isOn
        RelativeSaturationTitle.isEnabled = EnableDarkModeSwitch.isOn
        RelativeBrightnessSegments.isEnabled = EnableDarkModeSwitch.isOn
        RelativeSaturationSegments.isEnabled = EnableDarkModeSwitch.isOn
        NextDayTitle.isEnabled = EnableDarkModeSwitch.isOn
        EndDayIsNextDaySwitch.isEnabled = EnableDarkModeSwitch.isOn
    }
    
    @IBOutlet weak var EnableDarkModeSwitch: UISwitch!
    
    @IBAction func HandleDarkModeChanged(_ sender: Any)
    {
        _Settings.set(EnableDarkModeSwitch.isOn, forKey: Setting.Key.EnableDarkMode)
        SetUI()
    }
    
    @IBAction func HandleDarkModeStartChanged(_ sender: Any)
    {
        UpdateDurations()
    }
    
    @IBAction func HandleDarkModeEndChanged(_ sender: Any)
    {
        UpdateDurations()
    }
    
    func UpdateDurations()
    {
        let StartTime = DarkModeStartPicker.date
        var EndTime = DarkModeEndPicker.date
        if EndDayIsNextDaySwitch.isOn
        {
            EndTime = Utility.AddDayTo(EndTime)
        }
        //print("New duration: from \(Utility.MakeSimpleTime(FromDate: StartTime)) to \(Utility.MakeSimpleTime(FromDate: EndTime))")
        let StartForSettings = Utility.MakeSimpleTime(FromDate: StartTime)
        _Settings.set(StartForSettings, forKey: Setting.Key.DarkModeStartTime)
        let Duration = Utility.DurationBetween(Start: StartTime, End: EndTime)
        DurationOutput.text = String(Duration)
        _Settings.set(Duration, forKey: Setting.Key.DarkModeDuration)
    }
    
    @IBOutlet weak var ChangeBrightnessSwitch: UISwitch!
    
    @IBAction func HandleChangedBrightness(_ sender: Any)
    {
        _Settings.set(ChangeBrightnessSwitch.isOn, forKey: Setting.Key.DarkModeChangeBrightness)
    }
    
    @IBOutlet weak var ChangeSaturationSwitch: UISwitch!
    
    @IBAction func HandleChangedSaturation(_ sender: Any)
    {
        _Settings.set(ChangeSaturationSwitch.isOn, forKey: Setting.Key.DarkModeChangeSaturation)
    }
    
    @IBOutlet weak var RelativeBrightnessSegments: UISegmentedControl!
    
    @IBAction func HandlChangesToRelativeBrightness(_ sender: Any)
    {
        _Settings.set(RelativeBrightnessSegments.selectedSegmentIndex, forKey: Setting.Key.DarkModeRelativeBrightness)
    }
    
    @IBOutlet weak var RelativeSaturationSegments: UISegmentedControl!
    
    @IBAction func HandleChangesToRelativeSaturation(_ sender: Any)
    {
        _Settings.set(RelativeSaturationSegments.selectedSegmentIndex, forKey: Setting.Key.DarkModeRelativeSaturation)
    }
    
    @IBAction func HandleEndDayIsNextDayChanged(_ sender: Any)
    {
        UpdateDurations()
    }
    
    @IBOutlet weak var EndDayIsNextDaySwitch: UISwitch!
    
    @IBOutlet weak var NextDayTitle: UILabel!
    @IBOutlet weak var RelativeSaturationTitle: UILabel!
    @IBOutlet weak var RelativeBrightnessTitle: UILabel!
    @IBOutlet weak var ChangeSaturationTitle: UILabel!
    @IBOutlet weak var ChangeBrightnessTitle: UILabel!
    @IBOutlet weak var DarkModeEndPicker: UIDatePicker!
    @IBOutlet weak var DarkModeStartPicker: UIDatePicker!
    @IBOutlet weak var DarkModeStartTimeTitle: UILabel!
    @IBOutlet weak var DarkModeEndTimeTitle: UILabel!
    @IBOutlet weak var DurationTitle: UILabel!
    @IBOutlet weak var DurationOutput: UILabel!
}
