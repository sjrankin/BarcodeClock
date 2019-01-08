//
//  RadialGradientSettings.swift
//  Visualizer Clock
//
//  Created by Stuart Rankin on 11/3/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class RadialGradientSettings: UITableViewController, SettingProtocol, ClockSettingsProtocol
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
            fatalError("Unable to retrieve parent from RadialGradientSettingsNav.")
        }
        MainDelegate = Parent.MainDelegate
        ThisClockID = Clocks.GetActualID(PanelActions.SwitchToRadialColors)
        if ThisClockID == nil
        {
            fatalError("Unable to get ID of the radial colors clock: \(Clocks.ClockIDMap[PanelActions.SwitchToRadialColors]!)")
        }
        ShowSecondsSwitch.isOn = _Settings.bool(forKey: Setting.Key.RadialGradient.ShowSeconds)
        ShowHandValuesSwitch.isOn = _Settings.bool(forKey: Setting.Key.RadialGradient.ShowClockHandValues)
        ShowCenterDotSwitch.isOn = _Settings.bool(forKey: Setting.Key.RadialGradient.ShowCenterDot)
        CenterDotPulsatesSwitch.isOn = _Settings.bool(forKey: Setting.Key.RadialGradient.CenterDotPulsates)
        HandeShapeSegment.selectedSegmentIndex = _Settings.integer(forKey: Setting.Key.RadialGradient.HandShape)
        UpdateUI()
        UpdateSample()
        SampleView.layer.borderColor = UIColor.black.cgColor
        SampleView.layer.borderWidth = 0.5
        SampleView.layer.cornerRadius = 5.0
        Background = BackgroundServer(SampleView)
        Background.UpdateBackgroundColors()
        BGTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(UpdateBG), userInfo: nil, repeats: true)
    }
    
    @IBOutlet weak var SampleView: UIView!
    
    func UpdateSample()
    {
        if let Layer = ClockLayer
        {
            
        }
        else
        {
            /*
             let Center = CGPoint(x: SampleView.bounds.width / 2.0, y: SampleView.bounds.height / 2.0)
             ClockLayer = CARadialGradientLayer2(Frame: SampleView.frame, Bounds: SampleView.bounds, Location: Center,
             Description: Working, OuterAlphaValue: 0.0, AlphaDistnce: 0.05)
             */
        }
    }
    
    var ClockLayer: CARadialGradientLayer2? = nil
    
    var Background: BackgroundServer!
    var BGTimer: Timer!
    
    @objc func UpdateBG()
    {
        Background.UpdateBackgroundColors()
    }
    
    func FromClock(_ ClockType: PanelActions)
    {
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
            _MainDelegate = newValue
        }
    }
    
    func UpdateUI()
    {
        let ShowCenter = _Settings.bool(forKey: Setting.Key.RadialGradient.ShowCenterDot)
        CenterDotPulsatesLabel.isEnabled = ShowCenter
        CenterDotPulsatesSwitch.isEnabled = ShowCenter
    }
    
    @IBOutlet weak var ShowSecondsSwitch: UISwitch!
    
    @IBAction func HandleShowSecondsChanged(_ sender: Any)
    {
        _Settings.set(ShowSecondsSwitch.isOn, forKey: Setting.Key.RadialGradient.ShowSeconds)
        MainDelegate?.BroadcastChanges(ToClock: ThisClockID!, [Setting.Key.RadialGradient.ShowSeconds])
    }
    
    @IBOutlet weak var ShowCenterDotSwitch: UISwitch!
    
    @IBAction func HandleShowCenterDotChanged(_ sender: Any)
    {
        _Settings.set(ShowCenterDotSwitch.isOn, forKey: Setting.Key.RadialGradient.ShowCenterDot)
        MainDelegate?.BroadcastChanges(ToClock: ThisClockID!, [Setting.Key.RadialGradient.ShowCenterDot])
        UpdateUI()
    }
    
    @IBOutlet weak var CenterDotPulsatesSwitch: UISwitch!
    
    @IBAction func HandleCenterDotPulsationChanged(_ sender: Any)
    {
        _Settings.set(CenterDotPulsatesSwitch.isOn, forKey: Setting.Key.RadialGradient.CenterDotPulsates)
        MainDelegate?.BroadcastChanges(ToClock: ThisClockID!, [Setting.Key.RadialGradient.CenterDotPulsates])
    }
    
    @IBOutlet weak var ShowHandValuesSwitch: UISwitch!
    
    @IBAction func HandleShowHandValuesChanged(_ sender: Any)
    {
        _Settings.set(ShowHandValuesSwitch.isOn, forKey: Setting.Key.RadialGradient.ShowClockHandValues)
        MainDelegate?.BroadcastChanges(ToClock: ThisClockID!, [Setting.Key.RadialGradient.ShowClockHandValues])
    }
    
    func DoSet(Key: String, Value: Any?)
    {
    }
    
    @IBOutlet weak var CenterDotPulsatesLabel: UILabel!
    
    @IBAction func HandleDonePressed(_ sender: Any)
    {
        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var HandeShapeSegment: UISegmentedControl!
    
    @IBAction func HandleHandShapeChanged(_ sender: Any)
    {
        _Settings.set(HandeShapeSegment.selectedSegmentIndex, forKey: Setting.Key.RadialGradient.HandShape)
        MainDelegate?.BroadcastChanges(ToClock: ThisClockID!, [Setting.Key.RadialGradient.HandShape])
    }
}
