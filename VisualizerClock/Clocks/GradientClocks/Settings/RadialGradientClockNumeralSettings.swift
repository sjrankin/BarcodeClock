//
//  RadialGradientClockNumeralSettings.swift
//  Visualizer Clock
//
//  Created by Stuart Rankin on 12/31/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class RadialGradientClockNumeralSettings: UITableViewController, SettingProtocol
{
    let _Settings = UserDefaults.standard
    var Parent: RadialGradientSettingsNav!
    var ThisClockID: UUID? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        Parent = parent as? RadialGradientSettingsNav
        if Parent == nil
        {
            fatalError("Unable to retrieve parent in RadialGradientNumeralSettings.")
        }
        MainDelegate = Parent.MainDelegate
        ThisClockID = Clocks.GetActualID(PanelActions.SwitchToRadialColors)
        if ThisClockID == nil
        {
            fatalError("Unable to get ID of radial color clock.")
        }
        ShowHoursSwitch.isOn = _Settings.bool(forKey: Setting.Key.RadialGradient.ShowHourNumerals)
        TappingTogglesNumeralsSwitch.isOn = _Settings.bool(forKey: Setting.Key.RadialGradient.TappingTogglesNumerals)
        NumeralColorAnimationSwitch.isOn = _Settings.bool(forKey: Setting.Key.RadialGradient.EnableNumeralColorAnimation)
        DisplayAnimationType()
    }
    
    private weak var _MainDelegate: MainUIProtocol? = nil
    weak var MainDelegate: MainUIProtocol?
        {
        get
        {
            return _MainDelegate
        }
        set
        {
            print("Main delegate set")
            _MainDelegate = newValue
        }
    }
    
    func DoSet(Key: String, Value: Any?)
    {
        switch Key
        {
        case "AnimationDescription":
            DisplayAnimationType()
            
        default:
            break
        }
    }
    
    func DisplayAnimationType()
    {
        if AnimationTypes == nil
        {
            AnimationTypes = CARadialGradientLayer2.AnimationDescriptions
            AnimationTypes = AnimationTypes!.sorted(by: {$0.0 < $1.0})
        }
        let Index = _Settings.integer(forKey: Setting.Key.RadialGradient.NumeralAnimationStyle)
        let AnimationType = AnimationTypes![Index].1
        AnimationLabel.text = AnimationType
    }
    
    var AnimationTypes: [(Int, String, String, CARadialGradientLayer2.ShowTextAnimations, CARadialGradientLayer2.HideTextAnimations, Bool)]? = nil
    
    @IBOutlet weak var AnimationLabel: UILabel!
    
    @IBOutlet weak var TappingTogglesNumeralsSwitch: UISwitch!
    
    @IBAction func HandleTappingTogglesNumeralsChanged(_ sender: Any)
    {
        _Settings.set(TappingTogglesNumeralsSwitch.isOn, forKey: Setting.Key.RadialGradient.TappingTogglesNumerals)
        MainDelegate?.BroadcastChanges(ToClock: ThisClockID!, [Setting.Key.RadialGradient.TappingTogglesNumerals])
    }
    
    @IBOutlet weak var NumeralColorAnimationLabel: UILabel!
    @IBOutlet weak var NumeralColorAnimationSwitch: UISwitch!
    
    @IBAction func HandleNumeralColorAnimationChanged(_ sender: Any)
    {
        _Settings.set(NumeralColorAnimationSwitch.isOn, forKey: Setting.Key.RadialGradient.EnableNumeralColorAnimation)
        MainDelegate?.BroadcastChanges(ToClock: ThisClockID!, [Setting.Key.RadialGradient.EnableNumeralColorAnimation])
    }
    
    @IBOutlet weak var ShowHoursSwitch: UISwitch!
    
    @IBAction func HandleShowHoursChanged(_ sender: Any)
    {
        _Settings.set(ShowHoursSwitch.isOn, forKey: Setting.Key.RadialGradient.ShowHourNumerals)
        MainDelegate?.BroadcastChanges(ToClock: ThisClockID!, [Setting.Key.RadialGradient.ShowHourNumerals])
        UpdateUI()
    }
    
    @IBOutlet weak var NumeralAnimationLabel: UILabel!
    
    @IBOutlet weak var TappingTogglesLabel: UILabel!
    
    func UpdateUI()
    {
        let ShowHours = _Settings.bool(forKey: Setting.Key.RadialGradient.ShowHourNumerals)
        TappingTogglesLabel.isEnabled = ShowHours
        TappingTogglesNumeralsSwitch.isEnabled = ShowHours
        NumeralAnimationLabel.isEnabled = ShowHours
        NumeralColorAnimationSwitch.isEnabled = ShowHours
        NumeralColorAnimationLabel.isEnabled = ShowHours
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool
    {
        switch identifier
        {
        case "ToNumeralAnimationSettings":
            return _Settings.bool(forKey: Setting.Key.RadialGradient.ShowHourNumerals)
            
        default:
            return true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        switch segue.identifier
        {
        case "ToNumeralAnimationSettings":
            if !_Settings.bool(forKey: Setting.Key.RadialGradient.ShowHourNumerals)
            {
                return
            }
            let Dest = segue.destination as? NumeralAnimationSelection
            Dest?.delegate = self 
            
        default:
            break
        }
        super.prepare(for: segue, sender: self)
    }
}
