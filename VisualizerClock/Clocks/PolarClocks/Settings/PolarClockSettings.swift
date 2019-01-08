//
//  PolarClockSettings.swift
//  Visualizer Clock
//
//  Created by Stuart Rankin on 12/2/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class PolarClockSettings: UITableViewController, SettingProtocol, ColorReceiver, ClockSettingsProtocol
{
    let _Settings = UserDefaults.standard
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        PolarGridColorSample.layer.borderColor = UIColor.black.cgColor
        PolarGridColorSample.layer.borderWidth = 0.5
        PolarGridColorSample.layer.cornerRadius = 5.0
        UpdatePolarGridColor(_Settings.uicolor(forKey: Setting.Key.Polar.PolarGridColor)!)
        PolarClockSampleView.layer.borderColor = UIColor.black.cgColor
        PolarClockSampleView.layer.borderWidth = 0.5
        PolarClockSampleView.layer.cornerRadius = 5.0
        PolarClockSampleView.backgroundColor = UIColor.darkGray
        ClockTypeSegment.selectedSegmentIndex = _Settings.integer(forKey: Setting.Key.Polar.PolarType)
        ViewTypeSegment.selectedSegmentIndex = _Settings.bool(forKey: Setting.Key.Polar.Is2D) ? 0 : 1
        TextTypeSegment.selectedSegmentIndex = _Settings.bool(forKey: Setting.Key.Polar.DigitText) ? 0 : 1
        UpdateSample()
    }
    
    func FromClock(_ ClockType: PanelActions)
    {
        
    }
    
    var _MainDelegate: MainUIProtocol? = nil
    var MainDelegate: MainUIProtocol?
    {
        get
        {
            return _MainDelegate
        }
        set
        {
            _MainDelegate = newValue
        }
    }
    
    func UpdateSample()
    {
        
    }
    
    func UpdatePolarGridColor(_ WithColor: UIColor)
    {
        PolarGridColorSample.backgroundColor = WithColor
    }
    
    func ColorChanged(NewColor: UIColor, DidChange: Bool, Tag: String?)
    {
        if !DidChange
        {
            return
        }
        switch Tag
        {
        case "PolarGridColor":
            _Settings.set(NewColor, forKey: Setting.Key.Polar.PolarGridColor)
            UpdateSample()
            UpdatePolarGridColor(NewColor)
            
        default:
            break
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        switch segue.identifier
        {
        case "ToTextFormatter":
            let Dest = segue.destination as? TextFormatter
            Dest?.DoSet(Key: "ViewTitle", Value: "Polar Clock Text")
            Dest?.DoSet(Key: "FontColor", Value: Setting.Key.Polar.TextColor)
            Dest?.DoSet(Key: "OutlineColor", Value: Setting.Key.Polar.StrokeColor)
            Dest?.DoSet(Key: "OutlineSetting", Value: Setting.Key.Polar.TextStroked)
            Dest?.DoSet(Key: "FontSetting", Value: Setting.Key.Polar.Font)
            Dest?.DoSet(Key: "GlowColor", Value: Setting.Key.Polar.GlowColor)
            Dest?.DoSet(Key: "GlowSetting", Value: Setting.Key.Polar.TextGlow)
            Dest?.DoSet(Key: "ShadowColor", Value: Setting.Key.Polar.ShadowColor)
            Dest?.DoSet(Key: "ShadowSetting", Value: Setting.Key.Polar.TextShadow)
            Dest?.delegate = self
            
        case "ToPolarGridColorEditor":
            let Dest = segue.destination as? BasicColorEditor
            Dest?.CallerDelegate = self
            Dest?.DelegateTag = "PolarGridColor"
            Dest?.InitialColor = _Settings.uicolor(forKey: Setting.Key.Polar.PolarGridColor)!
            Dest?.InitialTitle = "Polar Grid Color"
            Dest?.InitialColorSpace = ColorEditorColorSpaces.HSB
            
        default:
            break
        }
        super.prepare(for: segue, sender: self)
    }
    
    func DoSet(Key: String, Value: Any?)
    {
        UpdateSample()
    }
    
    @IBAction func HandleDonePressed(_ sender: Any)
    {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func ViewTypeChanged(_ sender: Any)
    {
    }
    
    @IBOutlet weak var ClockTypeSegment: UISegmentedControl!
    
    @IBAction func HandleClockTypeChanged(_ sender: Any)
    {
        
    }
    
    @IBOutlet weak var ViewTypeSegment: UISegmentedControl!
    
    @IBAction func HandleTextTypeSegmentChanged(_ sender: Any)
    {
    }
    
    @IBAction func HandlePolarGridChanged(_ sender: Any)
    {
    }
    
    @IBOutlet weak var PolarGridColorSample: UIView!
    @IBOutlet weak var ShowPolarGridSwitch: UISwitch!
    @IBOutlet weak var TextTypeSegment: UISegmentedControl!
    @IBOutlet weak var PolarClockSampleView: UIView!
}
