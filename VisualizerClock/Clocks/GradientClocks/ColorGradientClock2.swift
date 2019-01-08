//
//  ColorGradientClock2.swift
//  Visualizer Clock
//
//  Created by Stuart Rankin on 1/5/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class ColorGradientClock2: NSObject, ClockProtocol
{
    let _Settings = UserDefaults.standard
    
    init(SurfaceSize: CGSize)
    {
        super.init()
    }
    
    private func CommonInitialization(_ SurfaceSize: CGSize)
    {
        Handle = VectorHandle.Make()
        Handle?.ColorGradientClock2 = CARadialGradientLayer3()
        ViewPortSize = SurfaceSize
        ViewPortCenter = CGPoint(x: ViewPortSize.width / 2, y: ViewPortSize.height / 2)
        delegate?.ClockStarted(ID: ClockID)
    }
    
    weak var delegate: MainUIProtocol? = nil
    var ViewPortCenter: CGPoint!
    var ViewPortSize: CGSize!
    var Handle: VectorHandle? = nil
    
    func UpdateTime(NewTime: Date)
    {
        DrawClock(WithTime: NewTime)
    }
    
    func UpdateTime(Handle: VectorHandle, NewTime: Date) -> UIView?
    {
        return DrawClock(Handle: Handle, WithTime: NewTime)
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
    
    let HandleClockLock = NSObject()
    
    func DrawClock(Handle: VectorHandle, WithTime: Date) -> UIView?
    {
        objc_sync_enter(HandleClockLock)
        defer{objc_sync_exit(HandleClockLock)}
        
        return DoDrawClock(Handle: Handle, WithTime)
    }
    
    var PreviousTime: Date? = nil
    
    func DoDrawClock(_ WithTime: Date)
    {
        if PreviousTime == nil
        {
            PreviousTime = WithTime
        }
        else
        {
            if SecondsEqual(PreviousTime!, WithTime)
            {
                return
            }
        }
        
        PreviousTime = WithTime
        SurfaceView = UIView()
        SurfaceView.frame = CGRect(x: 0, y: 0, width: ViewPortSize.width, height: ViewPortSize.height)
        SurfaceView.backgroundColor = UIColor.clear
        
        let ClockSurface = UIView()
        ClockSurface.contentMode = .scaleAspectFit
        ClockSurface.backgroundColor = UIColor.clear
        ClockSurface.clipsToBounds = true
        ClockSurface.bounds = SurfaceView.bounds
        ClockSurface.frame = SurfaceView.frame
        
        ClockSurface.addSubview(CreateClock(ForTime: WithTime, Handle: Handle!))
    }
    
    public func DoDrawClock(Handle: VectorHandle, _ WithTime: Date) -> UIView?
    {
        let ClockSurface = UIView()
        ClockSurface.contentMode = .scaleAspectFit
        ClockSurface.backgroundColor = UIColor.clear
        ClockSurface.clipsToBounds = true
        ClockSurface.bounds = SurfaceView.bounds
        ClockSurface.frame = SurfaceView.frame
        Handle.ViewWidth = Int(ClockSurface.frame.width)
        Handle.ViewHeight = Int(ClockSurface.frame.height)
        
        ClockSurface.addSubview(CreateClock(ForTime: WithTime, Handle: Handle))
        return ClockSurface
    }
    
    private var SurfaceView: UIView!
    
    /// Determines if the seconds component in the two passed dates are equal.
    ///
    /// - Parameters:
    ///   - Time1: First time structure.
    ///   - Time2: Second time structure.
    /// - Returns: True if the second components are equal, false if not.
    func SecondsEqual(_ Time1: Date, _ Time2: Date) -> Bool
    {
        let Cal = Calendar.current
        let Sec1 = Cal.component(.second, from: Time1)
        let Sec2 = Cal.component(.second, from: Time2)
        return Sec1 == Sec2
    }
    
    private func CreateClock(ForTime: Date, Handle: VectorHandle) -> UIView
    {
        let ClockSurface = UIView()
        
        return ClockSurface
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
        #if false
        Handle?.ColorGradientClock2!.ToggleClockNumerals(HideAnimation: CARadialGradientLayer2.HideTextAnimations.RandomBezierToOffScreen,
                                                         ShowAnimation: CARadialGradientLayer2.ShowTextAnimations.RandomBezierFromOffScreen,
                                                         Duration: 0.8, Delay: 0.01)
        #endif
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
    
    func RunClockSettings()
    {
    }
}
