//
//  BarcodeClocks.swift
//  Barcode Clock
//
//  Created by Stuart Rankin on 9/13/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Class that generates barcodes with time as the content. This class handles iOS built-in barcodes
/// from the CIFilter class.
class BarcodeAztecClock: ClockProtocol
{
    /// Clock initializer.
    ///
    /// - Parameter SurfaceSize: Size of the surface where the clock view will be placed.
    init(SurfaceSize: CGSize)
    {
        CommonInitialization(SurfaceSize)
    }
    
    /// Main UI delegate.
    var delegate: MainUIProtocol? = nil
    
    /// Initialization common to all constructions (even if there is only one).
    ///
    /// - Parameter SurfaceSize: Size of the surface where the clock view will be placed.
    private func CommonInitialization(_ SurfaceSize: CGSize)
    {
        ViewPortSize = SurfaceSize
        ViewPortCenter = CGPoint(x: ViewPortSize.width / 2, y: ViewPortSize.height / 2)
        delegate?.ClockStarted(ID: ClockID)
    }
    
    /// Returns the type of clock.
    func GetClockType() -> PanelActions
    {
        return PanelActions.SwitchToAztecCode
    }
    
    /// Holds the name of the clock.
    private var _ClockName: String = "Aztec Code"
    /// Get the name of the clock.
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
    
    /// Object used to synchronize the function that draws the clock.
    var ClockLock = NSObject()
    
    /// Draw the clock. Notifies the Main UI of major tasks.
    ///
    /// - Parameter WithTime: Time to use to draw the clock.
    func DrawClock(WithTime: Date)
    {
        objc_sync_enter(ClockLock)
        defer {objc_sync_exit(ClockLock)}
        
        delegate?.PreparingClockUpdate(ID: ClockID)
        DoDrawClock(WithTime)
        delegate?.UpdateMainView(ID: ClockID, WithView: SurfaceView)
        delegate?.FinishedClockUpdate(ID: ClockID)
    }
    
    /// Actual clock drawing takes place here. This function does not communicate with the Main UI.
    ///
    /// - Parameter WithTime: Time to use to draw the clock.
    func DoDrawClock(_ WithTime: Date)
    {
        SurfaceView = UIView()
        SurfaceView.frame = CGRect(x: 0, y: 0, width: ViewPortSize.width, height: ViewPortSize.height)
        SurfaceView.backgroundColor = UIColor.clear
        BarcodeView = UIImageView()
        BarcodeView.contentMode = .scaleAspectFit
        BarcodeView.backgroundColor = UIColor.clear
        BarcodeView.frame = SurfaceView.frame
        BarcodeView.bounds = SurfaceView.bounds
        BarcodeView.clipsToBounds = true
        let format = DateFormatter()
        format.timeStyle = .medium
        let Final = Utility.GetTimeStampToEncode(From: WithTime)
        #if true
        if let AzView = MakeBarcode3(From: Final, OutputFrame: BarcodeView.frame)
        {
        BarcodeView.addSubview(AzView)
        }
        else
        {
            fatalError("Error creating Aztec barcode.")
        }
//        BarcodeView.addSubview(MakeBarcode2(from: Final, OutputFrame: BarcodeView.frame))
        #else
        BarcodeView.image = MakeBarcode(from: Final)
        #endif
        SurfaceView.addSubview(BarcodeView)
    }
    
    func MakeBarcode2(from: String, OutputFrame: CGRect) -> UIView
    {
        let _Settings = UserDefaults.standard
        return BarcodeAztecClock.CreateAztecBarcode(From: from, OutputFrame: OutputFrame,
                                                    ForegroundColor: _Settings.uicolor(forKey: Setting.Key.Aztec.NodeColor)!,
                                                    Count: &_VectorNodeCount)
    }
    
    var Handle: VectorHandle? = nil
    
    func MakeBarcode3(From: String, OutputFrame: CGRect) -> UIView?
    {
        if Handle == nil
        {
            Handle = VectorHandle.Make()
        }
        let _Settings = UserDefaults.standard
        Handle!.Background = UIColor.clear
        Handle!.Foreground = _Settings.uicolor(forKey: Setting.Key.Aztec.NodeColor)!
        Handle!.HighlightColor = _Settings.uicolor(forKey: Setting.Key.Aztec.HighlightColor)!
        Handle!.ShadowLevel = _Settings.integer(forKey: Setting.Key.Aztec.ShadowLevel)
        Handle!.NodeShape = _Settings.integer(forKey: Setting.Key.Aztec.NodeStyle)
        Handle!.HighlightStyle = _Settings.integer(forKey: Setting.Key.Aztec.HighlightStyle)
        return BarcodeAztecClock.CreateAztecBarcodeA(From: From, OutputFrame: OutputFrame,
                                               Count: &_VectorNodeCount, Handle: Handle!, Caller: "MakeBarcode3")
    }
    
    private static var PreviousData = ""
    
    public static func CreateAztecBarcodeA(From: String, OutputFrame: CGRect, Count: inout Int,
                                           Handle: VectorHandle, Caller: String? = nil) -> UIView?
    {
        if PreviousData.count != From.count
        {
            Handle.ClearPreviousData()
            PreviousData = From
        }
        
        var BitmapWidth: Int = 0
        var BitmapHeight: Int = 0
        var NotUsed: CIImage? = nil
        let BitmapArray = BarcodeGenerator.CreateBarcodeBitmap(from: From, WithType: "CodeAztec",
                                                               FinalWidth: &BitmapWidth, FinalHeight: &BitmapHeight,
                                                               Native: &NotUsed)
        let Vector = BarcodeVector(Bitmap: BitmapArray!, Width: BitmapWidth, Height: BitmapHeight)
        Handle.RawData = BitmapArray
        Handle.BitmapWidth = BitmapWidth
        Handle.BitmapHeight = BitmapHeight
        let RSize = min(OutputFrame.width, OutputFrame.height)
        Handle.ViewHeight = Int(RSize)
        Handle.ViewWidth = Int(RSize)
        if let BarcodeView = Vector.MakeView2D(Handle)
        {
            let FinalFrame = CGRect(x: 0, y: UIScreen.main.bounds.size.height / 2.0 - RSize / 2.0,
                                    width: RSize, height: RSize)
            BarcodeView.frame = FinalFrame
            Count = Vector.LastNodeCount
            return BarcodeView
        }
        print("MakeView2D returned error.")
        return nil
    }
    
    private static var Previous: [[Int]]? = nil
    
    public static func CreateAztecBarcode(From: String, OutputFrame: CGRect, ForegroundColor: UIColor,
                                          Count: inout Int) -> UIView
    {
        var BitmapWidth: Int = 0
        var BitmapHeight: Int = 0
        var NotUsed: CIImage? = nil
        let BitmapArray = BarcodeGenerator.CreateBarcodeBitmap(from: From, WithType: "CodeAztec",
                                                               FinalWidth: &BitmapWidth, FinalHeight: &BitmapHeight,
                                                               Native: &NotUsed)
        let Vector = BarcodeVector(Bitmap: BitmapArray!, Width: BitmapWidth, Height: BitmapHeight)
        let RSize = min(OutputFrame.width, OutputFrame.height)
        let BarcodeView = Vector.MakeView(Foreground: ForegroundColor, Background: UIColor.clear,
                                          Highlight: UIColor.yellow,
                                          ViewWidth: Int(RSize), ViewHeight: Int(RSize), Previous: &Previous)
        let FinalFrame = CGRect(x: 0, y: UIScreen.main.bounds.size.height / 2.0 - RSize / 2.0,
                                width: RSize, height: RSize)
        BarcodeView!.frame = FinalFrame
        Count = Vector.LastNodeCount
        return BarcodeView!
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
    
    /// Will contain the ID of the clock.
    private var _ClockID: UUID = UUID(uuidString: Clocks.ClockIDMap[PanelActions.SwitchToAztecCode]!)!//"1927d69a-cd6d-44e2-ab56-af40db0bde99")!
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
        return "ToAztecCodeSettings"
    }
    
    /// Get changed settings.
    ///
    /// - Parameter Changed: List of changed settings. If nil, possibly no settings changed
    ///                      or too many to list.
    func ChangedSettings(_ Changed: [String])
    {
    }
}

