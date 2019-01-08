//
//  AdvancedRadialGradientSettings.swift
//  Visualizer Clock
//
//  Created by Stuart Rankin on 1/5/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class AdvancedRadialGradientSettings: UITableViewController, SettingProtocol, ClockSettingsProtocol
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
        
        Blend1Segment.selectedSegmentIndex = UISegmentedControl.noSegment
        Blend2Segment.selectedSegmentIndex = UISegmentedControl.noSegment
        let SegmentControl = GetSegmentControl(From: _Settings.integer(forKey: Setting.Key.RadialGradient.CompositeBlendMode))
        let SegmentIndex = GetSegmentIndex(From: _Settings.integer(forKey: Setting.Key.RadialGradient.CompositeBlendMode))
        switch SegmentControl
        {
        case 0:
            Blend1Segment.selectedSegmentIndex = SegmentIndex
            
        case 1:
            Blend2Segment.selectedSegmentIndex = SegmentIndex
            
        default:
            Blend1Segment.selectedSegmentIndex = 0
        }
        
        SmoothMotionSwitch.isOn = _Settings.bool(forKey: Setting.Key.RadialGradient.SmoothMotion)
        FilterSegments.selectedSegmentIndex = _Settings.integer(forKey: Setting.Key.RadialGradient.GradientFilter)
        SampleView.layer.borderColor = UIColor.black.cgColor
        SampleView.layer.borderWidth = 0.5
        SampleView.layer.cornerRadius = 5.0
        Background = BackgroundServer(SampleView)
        Background.UpdateBackgroundColors()
        BGTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(UpdateBG), userInfo: nil, repeats: true)
        UpdateSample()
    }
    
    @IBOutlet weak var SampleView: UIView!
    
    var ClockLayer: CARadialGradientLayer2? = nil
    
    var Background: BackgroundServer!
    var BGTimer: Timer!
    
    @objc func UpdateBG()
    {
        Background.UpdateBackgroundColors()
    }
    
    /// Returns the segment control for blending modes based on the blending mode passed as a parameter.
    ///
    /// - Parameter From: The current blending mode - determines the segment control to return.
    /// - Returns: 0 for the first blending mode segment control, 1 for the second blending mode segment control.
    func GetSegmentControl(From: Int) -> Int
    {
        switch From
        {
        case 0:
            fallthrough
        case 1:
            fallthrough
        case 2:
            return 0
            
        case 3:
            fallthrough
        case 4:
            fallthrough
        case 5:
            return 1
            
        default:
            return 0
        }
    }
    
    /// Gets the index of the blending mode for the segment control.
    ///
    /// - Parameter From: The blending mode that determines the index.
    /// - Returns: Index of the blending mode for a segment control.
    func GetSegmentIndex(From: Int) -> Int
    {
        switch From
        {
        case 0:
            return 0
            
        case 1:
            return 1
            
        case 2:
            return 2
            
        case 3:
            return 0
            
        case 4:
            return 1
            
        case 5:
            return 2
            
        default:
            return 0
        }
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
    
    func DoSet(Key: String, Value: Any?)
    {
    }
    
    func UpdateSample()
    {
        
    }
    
    @IBOutlet weak var SmoothMotionSwitch: UISwitch!
    
    @IBAction func HandleSmoothMotionChanged(_ sender: Any)
    {
        _Settings.set(SmoothMotionSwitch.isOn, forKey: Setting.Key.RadialGradient.SmoothMotion)
        MainDelegate?.BroadcastChanges(ToClock: ThisClockID!, [Setting.Key.RadialGradient.SmoothMotion])
        UpdateSample()
    }
    
    @IBAction func HandleFilterSegmentsChanged(_ sender: Any)
    {
        _Settings.set(FilterSegments.selectedSegmentIndex, forKey: Setting.Key.RadialGradient.GradientFilter)
        MainDelegate?.BroadcastChanges(ToClock: ThisClockID!, [Setting.Key.RadialGradient.GradientFilter])
        UpdateSample()
    }
    
    @IBOutlet weak var FilterSegments: UISegmentedControl!
    
    @IBOutlet weak var Blend1Segment: UISegmentedControl!
    @IBOutlet weak var Blend2Segment: UISegmentedControl!
    
    @IBAction func HandleBlend1Changed(_ sender: Any)
    {
        _Settings.set(Blend1Segment.selectedSegmentIndex, forKey: Setting.Key.RadialGradient.CompositeBlendMode)
        Blend2Segment.selectedSegmentIndex = UISegmentedControl.noSegment
        UpdateSample()
    }
    
    @IBAction func HandleBlend2Changed(_ sender: Any)
    {
        _Settings.set(Blend2Segment.selectedSegmentIndex + 3, forKey: Setting.Key.RadialGradient.CompositeBlendMode)
        Blend1Segment.selectedSegmentIndex = UISegmentedControl.noSegment
        UpdateSample()
    }
}
