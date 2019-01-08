//
//  RadialGradientClock.swift
//  Visualizer Clock
//
//  Created by Stuart Rankin on 10/31/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Class that creates a set of radial gradients that acts as a clock face.
class RadialGradientClock: NSObject, ClockProtocol
{
    let _Settings = UserDefaults.standard
    
    init(SurfaceSize: CGSize)
    {
        super.init()
        CommonInitialization(SurfaceSize)
    }
    
    /// Initialization common to all constructions (even if there is only one).
    ///
    /// - Parameter SurfaceSize: Size of the surface where the clock view will be placed.
    private func CommonInitialization(_ SurfaceSize: CGSize)
    {
        ViewPortSize = SurfaceSize
        ViewPortCenter = CGPoint(x: ViewPortSize.width / 2, y: ViewPortSize.height / 2)
        delegate?.ClockStarted(ID: ClockID)
    }
    
    /// Get changed settings.
    ///
    /// - Parameter Changed: List of changed settings. If nil, possibly no settings changed
    ///                      or too many to list.
    func ChangedSettings(_ Changed: [String])
    {
        var ChangeList = ""
        for Change in Changed
        {
            ChangeList = ChangeList + Change + " "
        }
        print("Notified of changes \(ChangeList)")
        if CA2 != nil
        {
        CA2.ResetClock()
        }
    }
    
    /// Returns the type of clock.
    func GetClockType() -> PanelActions
    {
        return PanelActions.SwitchToRadialColors
    }
    
    private func CreateGradients()
    {
        let ViewportFrame = CGRect(x: 0.0, y: 0.0, width: ViewPortSize.width, height: ViewPortSize.height)
        let G1 = RadialGradientDescriptor(Frame: ViewportFrame, Bounds: ViewportFrame,
                                          Location: CGPoint(x: 100, y: 100), GradientRadius: 100.0,
                                          RadialColors: [UIColor.green, UIColor.cyan],
                                          OuterAlphaValue: 0.0, AlphaDistance: 0.05)
        G1.ShowWork = false
        
        let G2 = RadialGradientDescriptor(Frame: ViewportFrame, Bounds: ViewportFrame,
                                          Location: CGPoint(x: 150, y: 200), GradientRadius: 120.0,
                                          RadialColors: [UIColor.red, UIColor.orange, UIColor.brown],
                                          OuterAlphaValue: 0.0, AlphaDistance: 0.05)
        G2.ShowWork = true
        
        let G3 = RadialGradientDescriptor(Frame: ViewportFrame, Bounds: ViewportFrame,
                                          Location: CGPoint(x: 300, y: 500), GradientRadius: 200.0,
                                          RadialColors: [UIColor.green],
                                          OuterAlphaValue: 0.0, AlphaDistance: 0.01)
        G3.ShowWork = true
        
        CA2 = CARadialGradientLayer2(ColorGradients: [G1, G2, G3])
        CA2.bounds = ViewportFrame
        CA2.frame = ViewportFrame
        CA2.setNeedsDisplay()
        SurfaceView.layer.addSublayer(CA2)
        let ShowRadialLine = _Settings.bool(forKey: Setting.Key.RadialGradient.ShowRadialLine)
        CA2.RunAsClock(true, ShowClockNumbers: true, ShowNumerals: false, ShowRadials: ShowRadialLine)
    }
    
    /// Where the actual work is done.
    private var CA2: CARadialGradientLayer2!
    
    /// Main UI delegate.
    weak var delegate: MainUIProtocol?
    
    var ClockLock = NSObject()
    
    func DrawClock(WithTime: Date)
    {
        //since the clock has a separate clock mechanism, do we need to draw this periodically?
        objc_sync_enter(ClockLock)
        defer {objc_sync_exit(ClockLock)}
        
        delegate?.PreparingClockUpdate(ID: ClockID)
        DoDrawClock(WithTime)
        delegate?.UpdateMainView(ID: ClockID, WithView: SurfaceView)
        delegate?.FinishedClockUpdate(ID: ClockID)
    }
    
    func DoDrawClock(_ WithTime: Date)
    {
        if SurfaceView == nil
        {
            SurfaceView = UIView()
            SurfaceView.frame = CGRect(x: 0, y: 0, width: ViewPortSize.width, height: ViewPortSize.height)
            SurfaceView.backgroundColor = UIColor.clear
            CreateGradients()
        }
    }
    
    /// Holds the UIView passed to the Main UI.
    private var SurfaceView: UIView!
    
    // MARK: ClockProtocol implementation.
    
    func UpdateTime(NewTime: Date)
    {
        DrawClock(WithTime: NewTime)
    }
    
    private var _ClockID: UUID = UUID(uuidString: Clocks.ClockIDMap[PanelActions.SwitchToRadialColors]!)!
    public var ClockID: UUID
    {
        get
        {
            return _ClockID
        }
    }
    
    private var _ClockName: String = "Radial Gradient Clock"
    public var ClockName: String
    {
        get
        {
            return _ClockName
        }
    }
    
    /// Size of the viewport. This is the UIView in the Main UI where the clock view will be placed.
    private var ViewPortSize: CGSize!
    
    /// Center of the viewport.
    private var ViewPortCenter: CGPoint!
    
    /// Clock timer.
    private var ClockTimer: Timer? = nil
    
    /// Initialize the clock timer. Barcodes are updated every half second.
    private func InitializeClockTimer()
    {
        let Interval = TimeInterval(0.5)
        ClockTimer = Timer.scheduledTimer(timeInterval: Interval, target: self, selector: #selector(UpdateClock), userInfo: nil, repeats: true)
    }
    
    /// Start time of the clock.
    private var StartTime = Date()
    
    func SetClockState(ToRunning: Bool, Animation: Int)
    {
        _IsRunning = ToRunning
        if ToRunning
        {
            InitializeClockTimer()
            StartTime = Date()
            UpdateClock()
        }
        else
        {
            ClockTimer?.invalidate()
            ClockTimer = nil
            delegate?.ClockStopped(ID: ClockID)
        }
    }
    
    /// Called by the clock timer.
    @objc func UpdateClock()
    {
        let TheTime = Date()
        if NewSecond(TheTime)
        {
            delegate?.OneSecondTick(ID: ClockID, Time: TheTime)
        }
        delegate?.CheckForDarkMode(TheTime)
        DrawClock(WithTime: TheTime)
    }
    
    /// Determines if a new second has occurred.
    ///
    /// - Parameter Time: The time used to check for new second state.
    /// - Returns: True if a new second occurred, false if not.
    func NewSecond(_ Time: Date) -> Bool
    {
        let Cal = Calendar.current
        let Second = Cal.component(.second, from: Time)
        if Second != PreviousSecond
        {
            PreviousSecond = Second
            return true
        }
        return false
    }
    
    var PreviousSecond: Int = -1
    
    private var _IsRunning: Bool = false
    public var IsRunning: Bool
    {
        get
        {
            return _IsRunning
        }
    }
    
    func UpdateViewPort(NewWidth: Int, NewHeight: Int)
    {
        ViewPortSize = CGSize(width: NewWidth, height: NewHeight)
        ViewPortCenter = CGPoint(x: NewWidth / 2, y: NewHeight / 2)
        UpdateClock()
    }
    
    func SecondsDisplayed() -> Int
    {
        let Now = Date()
        let Elapsed: Int = Int(Now.timeIntervalSince(StartTime))
        return Elapsed
    }
    
    func FinishedWithClock()
    {
        if ClockTimer != nil
        {
            ClockTimer?.invalidate()
            ClockTimer = nil
        }
        delegate?.ClockClosed(ID: ClockID)
        _IsValid = false
    }
    
    private var _IsValid: Bool = true
    public var IsValid: Bool
    {
        get
        {
            return _IsValid
        }
    }
    
    private var _CanUpdateColorsAsynchronously: Bool = true
    public var CanUpdateColorsAsynchronously: Bool
    {
        get
        {
            return _CanUpdateColorsAsynchronously
        }
    }
    
    func SetForegroundColorAsynchronously(_ Color: UIColor)
    {
        if !UpdateColorsAsynchronously
        {
            return
        }
        AsynchronousForeground = CIColor(color: Color)
        DrawClock(WithTime: Date())
    }
    
    var AsynchronousForeground: CIColor = CIColor.black
    
    private var _UpdateColorsAsynchronously: Bool = false
    public var UpdateColorsAsynchronously: Bool
    {
        get
        {
            return _UpdateColorsAsynchronously
        }
        set
        {
            _UpdateColorsAsynchronously = newValue
        }
    }
    
    private var _VectorNodeCount: Int = 0
    public var VectorNodeCount: Int
    {
        get
        {
            return _VectorNodeCount
        }
    }
    
    func UpdateNodeColors(_ Data: [(Int, UIColor)])
    {
    }
    
    private var _IsVectorBased: Bool = false
    public var IsVectorBased: Bool
    {
        get
        {
            return _IsVectorBased
        }
    }
    
    /// Holds the is full screen flag.
    private var _IsFullScreen: Bool = true
    /// Get the full screen flag.
    public var IsFullScreen: Bool
    {
        get
        {
            return _IsFullScreen
        }
    }
    
    /// Holds the handles taps flag.
    private var _HandlesTaps: Bool = true
    /// Get or set the handles tap flag.
    public var HandlesTaps: Bool
    {
        get
        {
            return _HandlesTaps
        }
        set
        {
            _HandlesTaps = newValue
        }
    }
    
    /// Handle taps on the screen by the user. Sent to us by the main UI.
    ///
    /// -Paramter At: Where the tap occured in the clock view.
    public func WasTapped(At: CGPoint)
    {
        CA2.ToggleClockNumerals(HideAnimation: CARadialGradientLayer2.HideTextAnimations.RandomBezierToOffScreen,
                                ShowAnimation: CARadialGradientLayer2.ShowTextAnimations.RandomBezierFromOffScreen,
                                Duration: 0.8, Delay: 0.01)
    }
    
    /// Run clock-specific settings.
    public func RunClockSettings()
    {
    }
    
    /// Get the segue ID of the settings view controller.
    ///
    /// - Returns: ID of the settings view controller. Nil if none available.
    func SettingsSegueID() -> String?
    {
        return "ToRadialGradientClockSettings"
    }
}
