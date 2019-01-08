//
//  ColorGradientClock.swift
//  Visualizer Clock
//
//  Created by Stuart Rankin on 1/2/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class ColorGradientClock: NSObject, ClockProtocol
{
    let _Settings = UserDefaults.standard
    
    init(SurfaceSize: CGSize)
    {
        super.init()
        CommonInitialization(SurfaceSize)
    }
    
    private func CommonInitialization(_ SurfaceSize: CGSize)
    {
        Handle = VectorHandle.Make()
        Handle?.ColorGradientClock = CARadialGradientLayer2()
        ViewPortSize = SurfaceSize
        ViewPortCenter = CGPoint(x: ViewPortSize.width / 2, y: ViewPortSize.height / 2)
        delegate?.ClockStarted(ID: ClockID)
    }
    
    var Handle: VectorHandle? = nil
    weak var delegate: MainUIProtocol? = nil
    var ViewPortCenter: CGPoint!
    var ViewPortSize: CGSize!
    
    func UpdateTime(NewTime: Date)
    {
        DrawClock(WithTime: NewTime)
    }
    
    var ClockLock = NSObject()
    
    func DrawClock(WithTime: Date)
    {
       objc_sync_enter(ClockLock)
        defer{objc_sync_exit(ClockLock)}
        
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
        }
    }
    
    private var SurfaceView: UIView!
    
    public static func DrawClock()
    {
        
    }
    
    private static func InitializeStaticClockTimer()
    {
        let Interval = TimeInterval(0.5)
        StaticClockTimer = Timer.scheduledTimer(timeInterval: Interval, target: self, selector: #selector(StaticUpdateClock), userInfo: nil, repeats: true)
    }
    
    private static var StaticClockTimer: Timer? = nil
    
    @objc static func StaticUpdateClock()
    {
        
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
    
        var AsynchronousForeground: CIColor = CIColor.black
    
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
    
    func WasTapped(At: CGPoint)
    {
        Handle?.ColorGradientClock!.ToggleClockNumerals(HideAnimation: CARadialGradientLayer2.HideTextAnimations.RandomBezierToOffScreen,
                                                        ShowAnimation: CARadialGradientLayer2.ShowTextAnimations.RandomBezierFromOffScreen,
                                                        Duration: 0.8, Delay: 0.01)
    }
    
    func RunClockSettings()
    {
        
    }
    
    func SettingsSegueID() -> String?
    {
                return "ToRadialGradientClockSettings"
    }
    
    func GetClockType() -> PanelActions
    {
        return PanelActions.SwitchToRadialColors
    }
    
    func ChangedSettings(_ Changed: [String])
    {
        var ChangeList = ""
        for Change in Changed
        {
            ChangeList = ChangeList + Change + " "
        }
        print("Notified of changes \(ChangeList)")
    }
}
