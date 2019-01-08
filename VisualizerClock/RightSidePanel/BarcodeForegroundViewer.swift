//
//  BarcodeForegroundViewer.swift
//  Barcode Clock
//
//  Created by Stuart Rankin on 8/23/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class BarcodeForegroundViewer: UITableViewController, ColorReceiver
{
    let _Settings = UserDefaults.standard
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        ForegroundColorSegment.selectedSegmentIndex = _Settings.integer(forKey: Setting.Key.BarcodeForegroundColorMethod)
        HueVariesSegment.selectedSegmentIndex = _Settings.integer(forKey: Setting.Key.BarcodeForegroundStandardVariance)
        UseManualVarianceSwitch.isOn = _Settings.bool(forKey: Setting.Key.BarcodeForegroundUseManualVariance)
        var Manual = _Settings.double(forKey: Setting.Key.BarcodeForegroundColorVariance)
        Manual = Utility.Round(Manual, ToPlaces: 3)
        ColorVarianceEntry.text = String(Manual)
        UserColorSample.layer.borderColor = UIColor.black.cgColor
        UserColorSample.layer.borderWidth = 1.0
        UserColorSample.layer.cornerRadius = 5.0
        let d: String = _Settings.string(forKey: Setting.Key.ElementForegroundColor)!
        print("ElementForegroundColor: \(d)")
        let (R, G, B) = Utility.GetRGB(_Settings.uicolor(forKey: Setting.Key.ElementForegroundColor)!)
        print("ElementForegroundColor: \(R),\(G),\(B)")
        UserColorSample.backgroundColor = _Settings.uicolor(forKey: Setting.Key.ElementForegroundColor)!
        UpdateUI()
    }
    
    func UpdateUI()
    {
        switch ForegroundColorSegment.selectedSegmentIndex
        {
        case 0:
            HueVarianceTitle.isEnabled = true
            HueVariesSegment.isEnabled = true
            ManualVarianceTitle.isEnabled = true
            ColorVarianceTitle.isEnabled  = true
            UseManualVarianceSwitch.isEnabled = true
            ColorVarianceEntry.isEnabled = true
            if UseManualVarianceSwitch.isOn
            {
                HueVarianceTitle.isEnabled = false
                HueVariesSegment.isEnabled = false
                ColorVarianceEntry.isEnabled = true
                ColorVarianceTitle.isEnabled = true
            }
            else
            {
                HueVarianceTitle.isEnabled = true
                HueVariesSegment.isEnabled = true
                ColorVarianceEntry.isEnabled = false
                ColorVarianceTitle.isEnabled = false
            }
            EnableUserColor = false
            SelectUserColorText.isEnabled = false
            UserColorSample.layer.borderColor = UIColor.gray.cgColor
            
        case 1:
            fallthrough
        case 2:
            HueVarianceTitle.isEnabled = false
            HueVariesSegment.isEnabled = false
            ManualVarianceTitle.isEnabled = false
            ColorVarianceTitle.isEnabled  = false
            UseManualVarianceSwitch.isEnabled = false
            ColorVarianceEntry.isEnabled = false
            EnableUserColor = false
            SelectUserColorText.isEnabled = false
            UserColorSample.layer.borderColor = UIColor.gray.cgColor
            
        case 3:
            HueVarianceTitle.isEnabled = false
            HueVariesSegment.isEnabled = false
            ManualVarianceTitle.isEnabled = false
            ColorVarianceTitle.isEnabled  = false
            UseManualVarianceSwitch.isEnabled = false
            ColorVarianceEntry.isEnabled = false
            EnableUserColor = true
            SelectUserColorText.isEnabled = true
            UserColorSample.layer.borderColor = UIColor.black.cgColor
            
        default:
            break
        }
    }
    
    var EnableUserColor: Bool = false
    
    @IBOutlet weak var ForegroundColorSegment: UISegmentedControl!
    
    @IBAction func HandleForegroundColorChanged(_ sender: Any)
    {
        _Settings.set(ForegroundColorSegment.selectedSegmentIndex, forKey: Setting.Key.BarcodeForegroundColorMethod)
        UpdateUI()
    }
    
    @IBOutlet weak var HueVariesSegment: UISegmentedControl!
    
    @IBAction func HandleHueVarianceChanged(_ sender: Any)
    {
        _Settings.set(HueVariesSegment.selectedSegmentIndex, forKey: Setting.Key.BarcodeForegroundStandardVariance)
    }
    
    @IBOutlet weak var UseManualVarianceSwitch: UISwitch!
    
    @IBAction func HandleManualVarianceChanged(_ sender: Any)
    {
        _Settings.set(UseManualVarianceSwitch.isOn, forKey: Setting.Key.BarcodeForegroundUseManualVariance)
        UpdateUI()
    }
    
    @IBOutlet weak var ColorVarianceEntry: UITextField!
    
    @IBAction func HandleColorVarianceChanged(_ sender: Any)
    {
        view.endEditing(true)
        if let Raw = ColorVarianceEntry.text
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
                _Settings.set(Final, forKey: Setting.Key.BarcodeForegroundColorVariance)
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool
    {
        switch identifier
        {
        case "ToColorEditor":
            return EnableUserColor
            
        default:
            return true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        switch segue.identifier
        {
        case "ToColorEditor":
            let Dest = segue.destination as? BasicColorEditor
            Dest?.InitialTitle = "Foreground Color"
            Dest?.InitialColorSpace = ColorEditorColorSpaces.HSB
//            Dest?.InitialColorSpaceIsHSB = true
            if let FGColor = _Settings.uicolor(forKey: Setting.Key.ElementForegroundColor)
            {
                Dest?.InitialColor = FGColor
                let (R, G, B) = Utility.GetRGB(FGColor)
                print("FGColor = \(R),\(G),\(B)")
            }
            else
            {
                Dest?.InitialColor = UIColor.black
            }
            Dest?.CallerDelegate = self
            
        default:
            break
        }
        
        super.prepare(for: segue, sender: self)
    }
    
    func ColorChanged(NewColor: UIColor, DidChange: Bool, Tag: String?)
    {
        if DidChange
        {
            UserColorSample.backgroundColor = NewColor
            _Settings.set(NewColor, forKey: Setting.Key.ElementForegroundColor)
        }
    }
    
    @IBOutlet weak var UserColorSample: UIView!
    @IBOutlet weak var HueVarianceTitle: UILabel!
    @IBOutlet weak var ManualVarianceTitle: UILabel!
    @IBOutlet weak var ColorVarianceTitle: UILabel!
    @IBOutlet weak var SelectUserColorText: UILabel!
}
