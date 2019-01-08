//
//  AmorphousColorBlob.swift
//  Barcode Clock
//
//  Created by Stuart Rankin on 9/12/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class AmorphousColorBlob: ClockProtocol
{    
    init(SurfaceSize: CGSize)
    {
        CommonInitialization(SurfaceSize)
        Attributes = AmorphousColorBlobAttributes()
    }
    
    init(SurfaceSize: CGSize, ClockAttributes: AmorphousColorBlobAttributes)
    {
        CommonInitialization(SurfaceSize)
        Attributes = ClockAttributes
    }
    
    private func CommonInitialization(_ SurfaceSize: CGSize)
    {
        ViewPortSize = SurfaceSize
        ViewPortCenter = CGPoint(x: ViewPortSize.width / 2, y: ViewPortSize.height / 2)
        HourLayer = CAGradientLayer()
        HourLayer.frame = CGRect(x: 0, y: 0, width: ViewPortSize.width, height: ViewPortSize.height)
        HourLayer.bounds = HourLayer.frame
        MinuteLayer = CAGradientLayer()
        MinuteLayer.frame = CGRect(x: 0, y: 0, width: ViewPortSize.width, height: ViewPortSize.height)
        MinuteLayer.bounds = HourLayer.frame
        SecondLayer = CAGradientLayer()
        SecondLayer.frame = CGRect(x: 0, y: 0, width: ViewPortSize.width, height: ViewPortSize.height)
        SecondLayer.bounds = HourLayer.frame
        delegate?.ClockStarted(ID: ClockID)
    }
    
    /// Holds the name of the clock.
    private var _ClockName: String = "Amorphous Color Blob"
    /// Get the name of the clock.
    public var ClockName: String
    {
        get
        {
            return _ClockName
        }
    }
    
    /// Returns the type of clock.
    func GetClockType() -> PanelActions
    {
        return PanelActions.SwitchToAmorphousColorBlob
    }
    
    public var Attributes: AmorphousColorBlobAttributes? = nil
    
    weak var delegate: MainUIProtocol? = nil
    
    func UpdateViewPort(NewWidth: Int, NewHeight: Int)
    {
        ViewPortSize = CGSize(width: NewWidth, height: NewHeight)
        ViewPortCenter = CGPoint(x: NewWidth / 2, y: NewHeight / 2)
        UpdateClock()
    }
    
    private var ViewPortSize: CGSize!
    private var ViewPortCenter: CGPoint!
    
    private var ClockTimer: Timer? = nil
    
    private func InitializeClockTimer()
    {
        let Interval = TimeInterval(0.05)
        ClockTimer = Timer.scheduledTimer(timeInterval: Interval, target: self, selector: #selector(UpdateClock), userInfo: nil, repeats: true)
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
    
    var ClockLock = NSObject()
    
    private func DrawClock(WithTime: Date)
    {
        objc_sync_enter(ClockLock)
        defer {objc_sync_exit(ClockLock)}
        
        delegate?.PreparingClockUpdate(ID: ClockID)
        DoDrawClock(WithTime)
        delegate?.UpdateMainView(ID: ClockID, WithView: SurfaceView)
        delegate?.FinishedClockUpdate(ID: ClockID)
    }
    
    func UpdateTime(NewTime: Date)
    {
        DrawClock(WithTime: NewTime)
    }
    
    func StartOfNextDay() -> Date
    {
        return Calendar.current.nextDate(after: Date(), matching: DateComponents(hour: 0, minute: 0, second: 0), matchingPolicy: .nextTimePreservingSmallerComponents)!
    }
    
    func TimeFromMidnight() -> Int
    {
        let MSInDay = Double(24 * 60 * 60 * 1000)
        let Interval = StartOfNextDay().timeIntervalSince(Date()) * 1000
        return Int(MSInDay - Interval)
    }
    
    func DoDrawClock(_ ClockTime: Date)
    {
        //let TimeSoFar = TimeFromMidnight()
        //let MaxDimension = min(ViewPortSize.width, ViewPortSize.height)
        DrawComponent(AtPercent: 0.0, Component: .Hour)
    }
    
    func DrawComponent(AtPercent: Double, Component: ComponentAttributes.ComponentTypes)
    {
    }
    
    func SetClockState(ToRunning: Bool, Animation: Int = 0)
    {
        _IsRunning = ToRunning
        if IsRunning
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
    
    private var _IsRunning: Bool = false
    public var IsRunning: Bool
    {
        get
        {
            return _IsRunning
        }
    }
    
    private var SurfaceView: UIView!
    private var HourLayer: CAGradientLayer!
    private var MinuteLayer: CAGradientLayer!
    private var SecondLayer: CAGradientLayer!
    
    /// Will contain the ID of the clock.
    private var _ClockID: UUID = UUID(uuidString: Clocks.ClockIDMap[PanelActions.SwitchToAmorphousColorBlob]!)!//"72035411-caab-4375-9198-fbc97cd85aed")!
    /// Get the ID of the clock.
    public var ClockID: UUID
    {
        get
        {
            return _ClockID
        }
    }
    
    /// Returns the number of seconds this clock was active.
    func SecondsDisplayed() -> Int
    {
        let Now = Date()
        let Elapsed: Int = Int(Now.timeIntervalSince(StartTime))
        return Elapsed
    }
    
    /// Start time of the clock.
    private var StartTime = Date()
    
    /// Should be called by the Main UI when another clock is selected. Shut down this clock and clean
    /// things up.
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
        return _IsValid
    }

    /// Holds the value that determines if callers can update colors asynchronously.
    private var _CanUpdateColorsAsynchronously: Bool = false
    /// Get the flag that indicates the clock can update colors asynchronously.
    public var CanUpdateColorsAsynchronously: Bool
    {
        get
        {
            return _CanUpdateColorsAsynchronously
        }
    }
    
    /// Sets the foreground color of the clock (where it makes sense) to the passed color, asynchronously.
    ///
    /// - Parameter Color: New foreground color.
    func SetForegroundColorAsynchronously(_ Color: UIColor)
    {
    }
    
    var AsynchronousForeground: CIColor = CIColor.black
    
    /// Holds the flag that lets callers update colors asynchronously.
    private var _UpdateColorsAsynchronously: Bool = false
    /// Enables or disables usage of asynchronous colors.
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
    
    /// Holds the number of vector nodes generated.
    private var _VectorNodeCount: Int = 0
    /// Get the number of vector nodes generated.
    public var VectorNodeCount: Int
    {
        get
        {
            return _VectorNodeCount
        }
    }
    
    /// Update the specified nodes with associated colors.
    ///
    /// - Parameter Data: List of tuples. First item is the node index (0-based) and the second item is the color to
    ///                   apply to the node. If there are insufficient nodes in the bitmap, excess node data will be ignored.
    public func UpdateNodeColors(_ Data: [(Int, UIColor)])
    {
        
    }
    /// This clock isn't vector based...
    public var IsVectorBased: Bool
    {
        return false
    }
    
    /// Holds the is full screen flag.
    private var _IsFullScreen: Bool = false
    /// Get the full screen flag.
    public var IsFullScreen: Bool
    {
        get
        {
            return _IsFullScreen
        }
    }
    
    /// Holds the handles taps flag.
    private var _HandlesTaps: Bool = false
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
        return nil
    }
    
    /// Get changed settings.
    ///
    /// - Parameter Changed: List of changed settings. If nil, possibly no settings changed
    ///                      or too many to list.
    func ChangedSettings(_ Changed: [String])
    {
    }
}
