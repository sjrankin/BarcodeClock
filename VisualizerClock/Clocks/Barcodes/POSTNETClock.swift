//
//  POSTNETClock.swift
//  Visualizer Clock
//
//  Created by Stuart Rankin on 12/21/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

//https://en.wikipedia.org/wiki/POSTNET
class POSTNETClock
{
    let _Settings = UserDefaults.standard
    
    init(SurfaceSize: CGSize)
    {
        CommonInitialization(SurfaceSize)
    }
    
    private func CommonInitialization(_ SurfaceSize: CGSize)
    {
        ViewPortSize = SurfaceSize
        ViewPortCenter = CGPoint(x: ViewPortSize.width / 2, y: ViewPortSize.height / 2)
        CreateAttributes()
        delegate?.ClockStarted(ID: ClockID)
    }
    
    weak var delegate: MainUIProtocol? = nil
    
    /// Returns the type of clock.
    func GetClockType() -> PanelActions
    {
        return PanelActions.SwitchToPOSTNET
    }
    
    private var _ClockName: String = "POSTNET"
    public var ClockName: String
    {
        get
        {
            return _ClockName
        }
    }
    
    /// Will contain the ID of the clock.
    private var _ClockID: UUID = UUID(uuidString: Clocks.ClockIDMap[PanelActions.SwitchToPOSTNET]!)!
    /// Get the ID of the clock.
    public var ClockID: UUID
    {
        get
        {
            return _ClockID
        }
    }
    
    private var ViewPortSize: CGSize!
    
    private var ViewPortCenter: CGPoint!
    
    private var ClockTimer: Timer? = nil
    
    private func InitializeClockTimer()
    {
        let Interval = TimeInterval(1.0)
        ClockTimer = Timer.scheduledTimer(timeInterval: Interval, target: self,
                                          selector: #selector(UpdateClock), userInfo: nil, repeats: true)
    }
    
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
    
    /// Object used to synchronize the function that draws the clock.
    var ClockLock = NSObject()
    
    func DrawClock(WithTime: Date)
    {
        objc_sync_enter(ClockLock)
        defer {objc_sync_exit(ClockLock)}
        
        delegate?.PreparingClockUpdate(ID: ClockID)
        DoDrawClock(WithTime)
        delegate?.UpdateMainView(ID: ClockID, WithView: SurfaceView)
        delegate?.FinishedClockUpdate(ID: ClockID)
    }
    
    public func DoDrawClock(_ WithTime: Date)
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
    }
    
    /// Calculate the check digit value of the raw value passed as a string. POSTNET check digits are a single value that
    /// when added to the sum of the payload, causes the final sum to be evenly divisible by 10.
    ///
    /// - Parameter Raw: String representation of the value used to generate a check digit. Only digits are allowed to be in
    ///                  this parameter. Invalid characters cause a nil to be returned.
    /// - Returns: Check digit for the passed value. Nil returned on error (most likely due to finding a non-digit character).
    public static func POSTNETCheckDigit(_ Raw: String) -> Int?
    {
        var stemp = Raw
        var Digits = [Int]()
        while stemp.count > 0
        {
            let char = stemp.removeFirst()
            if char < "0" || char > "9"
            {
                return nil
            }
            Digits.append(Int(String(char))!)
        }
        var Sum = 0
        Digits.forEach{Sum = Sum + $0}
        let Mod = Sum % 10
        let Final = 10 - Mod
        return Final
    }
    
    /// Describes bar types for digits.
    ///
    /// - High: High bar (eg, tall)
    /// - Low: Low bar (eg, short)
    enum BarTypes
    {
        case High
        case Low
    }
    
    /// Map of digits to a list of bar types. The -1 entry is for the
    /// start/stop bar.
    static let DigitMap: [Int: [BarTypes]] =
        [
            -1: [.High],
            0: [.High, .High, .Low, .Low, .Low],
            1: [.Low, .Low, .High, .High, .High],
            2: [.Low, .Low, .High, .Low, .High],
            3: [.Low, .Low, .High, .High, .Low],
            4: [.Low, .High, .Low, .Low, .High],
            5: [.Low, .High, .Low, .High, .Low],
            6: [.Low, .High, .High, .Low, .Low],
            7: [.High, .Low, .Low, .Low, .High],
            8: [.High, .Low, .Low, .High, .Low],
            9: [.High, .Low, .High, .Low, .Low],
        ]
    
    var PreviousTime: Date? = nil
    
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
    
    /// Contains the is valid flag.
    private var _IsValid: Bool = true
    /// Get the is valid flag. If false is returned, do not use the clock - reinstantiate it first.
    public var IsValid: Bool
    {
        return _IsValid
    }
    
    /// Holds the value that determines if callers can update colors asynchronously.
    private var _CanUpdateColorsAsynchronously: Bool = true
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
        if !UpdateColorsAsynchronously
        {
            return
        }
        AsynchronousForeground = CIColor(color: Color)
        DrawClock(WithTime: Date())
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
    
    /// Update the specified nodes with associated colors.
    ///
    /// - Parameter Data: List of tuples. First item is the node index (0-based) and the second item is the color to
    ///                   apply to the node. If there are insufficient nodes in the bitmap, excess node data will be ignored.
    public func UpdateNodeColors(_ Data: [(Int, UIColor)])
    {
        
    }
    
    /// This clock is vector based...
    public var IsVectorBased: Bool
    {
        return true
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
        return "ToPOSTNETSettings"
    }
    
    /// Convenience function to allow the Main UI to display a different time than the clock timer.
    ///
    /// - Parameter NewTime: The time to display.
    func UpdateTime(NewTime: Date)
    {
        DrawClock(WithTime: NewTime)
    }
    
    /// Set the clock state to run or halt. The state of the clock does not affect the validity (IsValid) flag.
    ///
    /// - Parameter ToRunning: Pass true to set the clock state to running, false to stop the clock.
    func SetClockState(ToRunning: Bool, Animation: Int = 0)
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
    
    /// Holds the running state of the clock.
    private var _IsRunning: Bool = false
    /// Get the running state of the clock.
    public var IsRunning: Bool
    {
        get
        {
            return _IsRunning
        }
    }
    
    /// Update the viewport where the clock is drawn. Called when the user changes the orientation of the device.
    ///
    /// - Parameters:
    ///   - NewWidth: New viewport width.
    ///   - NewHeight: New viewport height.
    func UpdateViewPort(NewWidth: Int, NewHeight: Int)
    {
        ViewPortSize = CGSize(width: NewWidth, height: NewHeight)
        ViewPortCenter = CGPoint(x: NewWidth / 2, y: NewHeight / 2)
        UpdateClock()
    }
    
    /// Holds the UIView passed to the Main UI.
    private var SurfaceView: UIView!
    
    /// Holds the UIImageView of the actual barcode to display.
    private var BarcodeView: UIImageView!
    
    func CreateAttributes()
    {
        AttributeList.append(("FGColor","CIColor",CIColor.black))
    }
    
    /// Return the index of the specified attribute key name.
    ///
    /// - Parameter Key: Name of the key whose index will be returned.
    /// - Returns: Index of the attribute of the passed key. Nil if not found.
    func IndexOfAttribute(Key: String) -> Int?
    {
        var Index = 0
        for (KeyName, _, _) in AttributeList
        {
            if KeyName == Key
            {
                return Index
            }
            Index = Index + 1
        }
        return nil
    }
    
    /// Called internally when an attribute has been changed.
    ///
    /// - Parameter Key: Name of the key of the changed attribute.
    func AttributeWasEdited(Key: String)
    {
        switch Key
        {
        default:
            return
        }
    }
    
    /// Set the value of the attribute with the passed key name.
    ///
    /// - Parameters:
    ///   - Key: Key name of the attribute to set.
    ///   - Value: New value for the attribute.
    /// - Returns: True on success, false on failure.
    @discardableResult func SetAttribute(Key: String, Value: Any) -> Bool
    {
        if let OldKeyIndex = IndexOfAttribute(Key: Key)
        {
            let OldTypeName = AttributeList[OldKeyIndex].1
            AttributeList.remove(at: OldKeyIndex)
            AttributeList.append((Key, OldTypeName, Value))
            AttributeWasEdited(Key: Key)
            return true
        }
        else
        {
            return false
        }
    }
    
    /// Get the value of the attribute with the passed key name.
    ///
    /// - Parameter Key: Name of the key of the attribute value to return.
    /// - Returns: Attribute value on success, nil if the key name was not be found.
    func GetAttribute(Key: String) -> Any?
    {
        for (KeyName, _, KeyValue) in AttributeList
        {
            if KeyName == Key
            {
                return KeyValue
            }
        }
        return nil
    }
    
    /// Returns a list of all attributes and their types.
    ///
    /// - Returns: List of attributes and their types, with each attribute, type pair in a tuple in the
    ///            returned list.
    func GetAttributeDescriptions() -> [(String, String)]
    {
        var Final = [(String, String)]()
        for (KeyName, KeyType, _) in AttributeList
        {
            Final.append((KeyName, KeyType))
        }
        return Final
    }
    
    /// Determines if the clock as the specified key name in the attribute list.
    ///
    /// - Parameter Key: Name of the key to search for.
    /// - Returns: True if the key exists in the attribute list, false if not.
    func HasAttribute(Key: String) -> Bool
    {
        for (KeyName, _, _) in AttributeList
        {
            if KeyName == Key
            {
                return true
            }
        }
        return false
    }
    
    /// Returns the number of attributes in the attribute list.
    ///
    /// - Returns: Number of attributes in the attribute list.
    func AttributeCount() -> Int
    {
        return AttributeList.count
    }
    
    /// List of attributes settable by callers.
    private var AttributeList = [(String, String, Any)]()
    
    private var _VectorNodeCount: Int = 0
    var VectorNodeCount: Int
    {
        get
        {
            return _VectorNodeCount
        }
    }
    
    /// Get changed settings.
    ///
    /// - Parameter Changed: List of changed settings. If nil, possibly no settings changed
    ///                      or too many to list.
    func ChangedSettings(_ Changed: [String]?)
    {
    }
}
