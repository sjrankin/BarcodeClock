//
//  TimeColors.swift
//  Barcode Clock
//
//  Created by Stuart Rankin on 8/18/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Code to manage the text time color settings UI.
class TimeColors: UITableViewController
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
        OutlineTextSwitch.isOn = _Settings.bool(forKey: Setting.Key.ShowTextOutline)
        TextColorSegment.selectedSegmentIndex = _Settings.integer(forKey: Setting.Key.TextColor)
        TextColorVarianceSegment.selectedSegmentIndex = _Settings.integer(forKey: Setting.Key.TextColorVariance)
        OutlineColorSegment.selectedSegmentIndex = _Settings.integer(forKey: Setting.Key.OutlineColor)
        OutlineColorVarianceSegment.selectedSegmentIndex = _Settings.integer(forKey: Setting.Key.OutlineColorVariance)
        EnterTextColorManuallySwitch.isOn = _Settings.bool(forKey: Setting.Key.TextColorVarianceIsNonStandard)
        EnterOutlineColorManuallySwitch.isOn = _Settings.bool(forKey: Setting.Key.OutlineColorVarianceIsNonStandard)
        var InteriorManual = _Settings.double(forKey: Setting.Key.ManualTextColorVariance)
        InteriorManual = Utility.Round(InteriorManual, ToPlaces: 3)
        TextColorVarianceEntry.text = String(InteriorManual)
        var ExteriorManual = _Settings.double(forKey: Setting.Key.ManualOutlineColorVariance)
        ExteriorManual = Utility.Round(ExteriorManual, ToPlaces: 3)
        OutlineColorVarianceEntry.text = String(ExteriorManual)
        UpdateUI()
    }
    
    func UpdateUI()
    {
        ColorVarianceText.isEnabled = TextColorSegment.selectedSegmentIndex == 0
        TextColorVarianceSegment.isEnabled = TextColorSegment.selectedSegmentIndex == 0
        TextColorVarianceTitle.isEnabled = TextColorSegment.selectedSegmentIndex == 0
        OutlineColorVarianceTitle.isEnabled = TextColorSegment.selectedSegmentIndex == 0
                EnterTextColorManuallySwitch.isEnabled = TextColorSegment.selectedSegmentIndex == 0
        ManualVarianceTitle.isEnabled = TextColorSegment.selectedSegmentIndex == 0
        
        OutlineVarianceText.isEnabled = OutlineColorSegment.selectedSegmentIndex == 0
        OutlineColorVarianceSegment.isEnabled = OutlineColorSegment.selectedSegmentIndex == 0
        ManualOutlineVarianceTitle.isEnabled = OutlineColorSegment.selectedSegmentIndex == 0
        EnterOutlineColorManuallySwitch.isEnabled = OutlineColorSegment.selectedSegmentIndex == 0
        
        TextColorVarianceTitle.isEnabled = EnterTextColorManuallySwitch.isOn
        TextColorVarianceEntry.isEnabled = EnterTextColorManuallySwitch.isOn
        OutlineColorVarianceEntry.isEnabled = EnterOutlineColorManuallySwitch.isOn
        OutlineColorVarianceTitle.isEnabled = EnterOutlineColorManuallySwitch.isOn

    }
    
    @IBOutlet weak var ManualOutlineVarianceTitle: UILabel!
    @IBOutlet weak var ManualVarianceTitle: UILabel!
    @IBOutlet weak var CurrentOutlineState: UILabel!
    @IBOutlet weak var ColorVarianceText: UILabel!
    @IBOutlet weak var OutlineVarianceText: UILabel!
    
    @IBOutlet weak var TextColorSegment: UISegmentedControl!
    
    @IBAction func HandleTextColorChanged(_ sender: Any)
    {
        _Settings.set(TextColorSegment.selectedSegmentIndex, forKey: Setting.Key.TextColor)
        UpdateUI()
    }
    
    @IBOutlet weak var TextColorVarianceSegment: UISegmentedControl!
    
    @IBAction func HandleTextColorVarianceChanged(_ sender: Any)
    {
        _Settings.set(TextColorVarianceSegment.selectedSegmentIndex, forKey: Setting.Key.TextColorVariance)
    }
    
    @IBOutlet weak var OutlineColorSegment: UISegmentedControl!
    
    @IBAction func HandleOutlineColorChanged(_ sender: Any)
    {
        _Settings.set(OutlineColorSegment.selectedSegmentIndex, forKey: Setting.Key.OutlineColor)
        UpdateUI()
    }
    
    @IBOutlet weak var OutlineColorVarianceSegment: UISegmentedControl!
    
    @IBAction func HandleOutlineColorVarianceChanged(_ sender: Any)
    {
        _Settings.set(OutlineColorVarianceSegment.selectedSegmentIndex, forKey: Setting.Key.OutlineColorVariance)
    }
    
    @IBOutlet weak var TextColorVarianceTitle: UILabel!
    @IBOutlet weak var EnterTextColorManuallySwitch: UISwitch!
    
    @IBAction func HandleTextColorManuallyChanged(_ sender: Any)
    {
        _Settings.set(EnterTextColorManuallySwitch.isOn, forKey: Setting.Key.TextColorVarianceIsNonStandard)
        TextColorVarianceTitle.isEnabled = EnterTextColorManuallySwitch.isOn
        TextColorVarianceEntry.isEnabled = EnterTextColorManuallySwitch.isOn
    }
    
    @IBOutlet weak var TextColorVarianceEntry: UITextField!
    
    @IBAction func HandleNewTextColorVarianceEntry(_ sender: Any)
    {
        view.endEditing(true)
        if let Raw = TextColorVarianceEntry.text
        {
            if let NewValue = Double(Raw)
            {
                var Final: Double = NewValue
                if NewValue > 1.0
                {
                    Final = Double(NewValue / 360.0)
                    Final = fmod(Final, 1.0)
                }
                if NewValue < 0.0
                {
                    Final = Double(abs(NewValue) / 360.0)
                    Final = fmod(Final, 1.0)
                }
                _Settings.set(Final, forKey: Setting.Key.ManualTextColorVariance)
            }
        }
    }
    
    @IBOutlet weak var OutlineColorVarianceTitle: UILabel!
    @IBOutlet weak var EnterOutlineColorManuallySwitch: UISwitch!
    
    @IBAction func HandleOutlineColorManuallyChanged(_ sender: Any)
    {
        _Settings.set(EnterOutlineColorManuallySwitch.isOn, forKey: Setting.Key.OutlineColorVarianceIsNonStandard)
        OutlineColorVarianceEntry.isEnabled = EnterOutlineColorManuallySwitch.isOn
        OutlineColorVarianceTitle.isEnabled = EnterOutlineColorManuallySwitch.isOn
    }
    
    @IBOutlet weak var OutlineColorVarianceEntry: UITextField!
    
    @IBAction func HandleNewOutlineColorVarianceEntry(_ sender: Any)
    {
        view.endEditing(true)
        if let Raw = OutlineColorVarianceEntry.text
        {
            if let NewValue = Double(Raw)
            {
                var Final: Double = NewValue
                if NewValue > 1.0
                {
                    Final = Double(NewValue / 360.0)
                    Final = fmod(Final, 1.0)
                }
                if NewValue < 0.0
                {
                    Final = Double(abs(NewValue) / 360.0)
                    Final = fmod(Final, 1.0)
                }
                _Settings.set(NewValue, forKey: Setting.Key.ManualOutlineColorVariance)
            }
        }
    }
    @IBOutlet weak var OutlineThicknessSegment: UISegmentedControl!
    
    @IBAction func HandleOutlineThicknessChanged(_ sender: Any)
    {
        let NewThickness = (OutlineThicknessSegment.selectedSegmentIndex + 1) * 2
        _Settings.set(NewThickness, forKey: Setting.Key.TextStrokeThickness)
    }
    
    @IBOutlet weak var OutlineTextSwitch: UISwitch!
    
    @IBAction func HandleOutlineTextChanged(_ sender: Any)
    {
        _Settings.set(OutlineTextSwitch.isOn, forKey: Setting.Key.ShowTextOutline)
    }
}
