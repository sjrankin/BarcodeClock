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
class Barcode128Clock: ClockProtocol
{
    let _Settings = UserDefaults.standard
    
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
        Handle = VectorHandle.Make()
        ViewPortSize = SurfaceSize
        ViewPortCenter = CGPoint(x: ViewPortSize.width / 2, y: ViewPortSize.height / 2)
        delegate?.ClockStarted(ID: ClockID)
    }
    
    /// Returns the type of clock.
    func GetClockType() -> PanelActions
    {
        return PanelActions.SwitchToCode128
    }
    
    var Handle: VectorHandle? = nil
    
    /// Holds the name of the clock.
    private var _ClockName: String = "Code 128"
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
        let Interval = TimeInterval(1.0)
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
        PreviousTime = WithTime
        SurfaceView = UIView()
        SurfaceView.frame = CGRect(x: 0, y: 0, width: ViewPortSize.width, height: ViewPortSize.height)
        SurfaceView.backgroundColor = UIColor.clear
        let Final = Utility.GetTimeStampToEncode(From: WithTime)

        let BarcodeView2 = UIView()
        BarcodeView2.contentMode = .scaleAspectFit
        BarcodeView2.backgroundColor = UIColor.clear
        BarcodeView2.clipsToBounds = true
        BarcodeView2.bounds = SurfaceView.bounds
        BarcodeView2.frame = SurfaceView.frame
        
        Handle!.BarcodeShape = _Settings.integer(forKey: Setting.Key.Code128.BarcodeShape)
        Handle!.Foreground = _Settings.uicolor(forKey: Setting.Key.Code128.BarcodeForegroundColor1)!
        Handle!.HighlightColor = _Settings.uicolor(forKey: Setting.Key.Code128.BarcodeForegroundColor2)!
        Handle!.ShadowLevel = _Settings.integer(forKey: Setting.Key.Code128.ShadowEffect)
        Handle!.HighlightStyle = _Settings.integer(forKey: Setting.Key.Code128.SpecialEffect)
        Handle!.WaveEffects = _Settings.integer(forKey: Setting.Key.Code128.WavyHeights)
        Handle!.UseLongAxis = true
        
        if let C128 = Barcode128Clock.CommonMakeBarcode2(From: Final, TargetView: SurfaceView.frame, Handle: Handle!, Caller: "DoDrawClock")
        {
            BarcodeView2.addSubview(C128)
            SurfaceView.addSubview(BarcodeView2)
        }
        else
        {
            print("No view returned from MakeBarcode2.")
        }
    }
    
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
    
    #if false
    /// Calls the barcode generator to create the specified barcode.
    ///
    /// - Parameters:
    ///   - from: The time to use to generate the barcode.
    /// - Returns: UIImage of the barcode.
    func MakeBarcode(from: String) -> UIImage?
    {
        var FGColor: CIColor = CIColor.black
        if UpdateColorsAsynchronously
        {
            FGColor = AsynchronousForeground
        }
        else
        {
            FGColor = GetAttribute(Key: "FGColor") as! CIColor
        }
        #if false
        var BitmapWidth: Int = 0
        var BitmapHeight: Int = 0
        let BitmapArray = BarcodeGenerator.CreateBarcodeBitmap(from: from, WithType: "Code128",
                                                               FinalWidth: &BitmapWidth, FinalHeight: &BitmapHeight)
        #endif
        var NotUsed: CIImage? = nil
        let Code128Image = BarcodeGenerator.Create(from: from, WithType: "Code128", Foreground: FGColor,
                                                   Background: CIColor.clear, Native: &NotUsed)
        
        return Code128Image
    }
    #endif
    
    private static var BarcodeCreationLock = NSObject()
    private static var PreviousContents = ""
    #if false
    private static var PreviousCallTS: CFTimeInterval? = nil
    #endif
    
    #if false
    /// Common code to create barcodes. Can be called externally as well as internall. Creates a Code 128 barcode
    /// and returns it in the returned UIView. Non-reentrant. If called multiple times, execution will be delayed
    /// until the lock is cleared.
    ///
    /// - Parameters:
    ///   - From: The data to encode in the barcode. Assumed, but not required, to be the current time.
    ///   - TargetView: The target UIView.
    ///   - FinalCenter: If present, the final vertical center of the view. If not present, the entire screen is
    ///                  used to calculate the vertical center.
    ///   - UseLongAxis: If true, the long axis of the passed view is used to calculate the size of the Code 128
    ///                  barcode. If false, the short axis is used.
    ///   - CalledFrom: The name of the calling function.
    ///   - SampleOffset: Offset to use when showing a sample barcode.
    /// - Returns: UIView with the Code 128 barcode.
    public static func CommonMakeBarcode(From: String, _ TargetView: UIView, FinalCenter: CGFloat? = nil,
                                         UseLongAxis: Bool = false, CalledFrom: String,
                                         SampleOffset: CGFloat = 0.75) -> UIView?
    {
        objc_sync_enter(BarcodeCreationLock)
        defer {objc_sync_exit(BarcodeCreationLock)}
        
        if PreviousContents.count != From.count
        {
            PreviousContents = From
            PreviousResult = nil
            PreviousResult0 = nil
            PreviousResult1 = nil
        }
        #if false
        let Now = CACurrentMediaTime()
        if let Previous = PreviousCallTS
        {
            let Delta = Now - Previous
        }
        else
        {
            PreviousCallTS = Now
        }
        #endif
        
        //print("Called from \(CalledFrom), Bounds: \(TargetView.bounds), Frame: \(TargetView.frame)")
        let _Settings = UserDefaults.standard
        let ViewPortSize = TargetView.bounds.size
        var BitmapWidth: Int = 0
        var BitmapHeight: Int = 0
        var NotUsed: CIImage? = nil
        let BitmapArray = BarcodeGenerator.CreateBarcodeBitmap(from: From, WithType: "Code128",
                                                               FinalWidth: &BitmapWidth, FinalHeight: &BitmapHeight,
                                                               Native: &NotUsed)
        let Vector = BarcodeVector(Bitmap: BitmapArray!, Width: BitmapWidth, Height: BitmapHeight)
        var EdgeMargin = 10
        var RSize: CGFloat = 0.0
        var LeftMargin = 10
        var RightMargin = 10
        if UseLongAxis
        {
            RSize = max(TargetView.frame.width, TargetView.frame.height)
            LeftMargin = 0
            RightMargin = 0
            EdgeMargin = 0
        }
        else
        {
            RSize = min(TargetView.frame.width, TargetView.frame.height)
        }
        
        #if false
        var InnerRatio: CGFloat = 0.25
        var OuterRatio: CGFloat = 0.95
        var Ratio = 2.7
        switch _Settings.integer(forKey: Setting.Key.Code128.BarcodeHeight)
        {
        case 0:
            Ratio = 3.5
            InnerRatio = 0.3
            OuterRatio = 0.75
            
        case 1:
            Ratio = 2.7
            InnerRatio = 0.2
            OuterRatio = 0.85
            
        case 2:
            Ratio = 2.0
            InnerRatio = 0.1
            OuterRatio = 0.95
            
        default:
            Ratio = 2.7
            InnerRatio = 0.25
            OuterRatio = 0.95
        }
        #endif
        
        let BarcodeShape = _Settings.integer(forKey: Setting.Key.Code128.BarcodeShape)
        var BitmapView: UIView? = nil
        let FX = _Settings.integer(forKey: Setting.Key.Code128.SpecialEffect)
        switch BarcodeShape
        {
        case 0:
            let BarcodeSize = _Settings.double(forKey: Setting.Key.Code128.BarcodeHeight)
            let VSize = (TargetView.frame.height * 0.5) * CGFloat(BarcodeSize) * SampleOffset
            RSize = RSize - CGFloat(EdgeMargin * 2)
            BitmapView = Vector.MakeView1D(Foreground: _Settings.uicolor(forKey: Setting.Key.Code128.BarcodeForegroundColor1)!,
                                           Background: UIColor.clear,
                                           Highlight: _Settings.uicolor(forKey: Setting.Key.Code128.BarcodeForegroundColor2)!,
                                           ViewWidth: Int(RSize), ViewHeight: Int(VSize),
                                           LeftMargin: LeftMargin, RightMargin: RightMargin,
                                           FinalCenter: FinalCenter,
                                           PreviousResults: &PreviousResult0,
                                           HighlightFX: FX)
            
        case 1:
            RSize = min(TargetView.frame.width, TargetView.frame.height)
            let DSize = RSize / 2.0
            var Outer = _Settings.double(forKey: Setting.Key.Code128.OuterRadius)
            Outer = Double(DSize) * Outer
            var Inner = _Settings.double(forKey: Setting.Key.Code128.InnerRadius)
            Inner = Double(DSize) * Inner
            BitmapView = Vector.MakeView1DRing(Foreground1: _Settings.uicolor(forKey: Setting.Key.Code128.BarcodeForegroundColor1)!,
                                               Foreground2: _Settings.uicolor(forKey: Setting.Key.Code128.BarcodeForegroundColor2)!,
                                               PercentForeground1: 1.0,
                                               ViewPort: ViewPortSize, ViewWidth: Int(DSize), ViewHeight: Int(DSize),
                                               OuterRadius: CGFloat(Outer),
                                               InnerRadius: CGFloat(Inner),
                                               PreviousResults: &PreviousResult,
                                               HighlightFX: FX)
            
        case 2:
            RSize = min(TargetView.frame.width, TargetView.frame.height)
            let DSize = RSize / 2.0
            BitmapView = Vector.MakeView1DTarget(Foreground1: _Settings.uicolor(forKey: Setting.Key.Code128.BarcodeForegroundColor1)!,
                                                 Foreground2: _Settings.uicolor(forKey: Setting.Key.Code128.BarcodeForegroundColor2)!,
                                                 PercentForeground1: 1.0,
                                                 ViewPort: ViewPortSize, ViewWidth: Int(RSize), ViewHeight: Int(RSize),
                                                 PreviousResults: &PreviousResult1,
                                                 HighlightFX: FX)
            
        default:
            print("Unknown shape \(BarcodeShape) encountered.")
            return nil
        }
        
        BitmapView!.frame = TargetView.frame
        BitmapView!.bounds = TargetView.bounds
        return BitmapView
    }
    #endif
    
    static var PreviousResult0: [Int]? = nil
    static var PreviousResult1: [Int]? = nil
    static var PreviousResult: [Int]? = nil
    
    /// Common code to create barcodes. Can be called externally as well as internall. Creates a Code 128 barcode
    /// and returns it in the returned UIView. Non-reentrant. If called multiple times, execution will be delayed
    /// until the lock is cleared.
    ///
    /// - Parameters:
    ///   - From: The data to encode in the barcode. Assumed, but not required, to be the current time.
    ///   - TargetView: The target UIView.
    ///   - FinalCenter: If present, the final vertical center of the view. If not present, the entire screen is
    ///                  used to calculate the vertical center.
    ///   - UseLongAxis: If true, the long axis of the passed view is used to calculate the size of the Code 128
    ///                  barcode. If false, the short axis is used.
    ///   - CalledFrom: The name of the calling function.
    ///   - SampleOffset: Offset to use when showing a sample barcode.
    /// - Returns: UIView with the Code 128 barcode.
    public static func CommonMakeBarcode2(From: String, TargetView: CGRect, Handle: VectorHandle, Caller: String,
                                         SampleOffset: CGFloat = 0.75) -> UIView?
    {
        objc_sync_enter(BarcodeCreationLock)
        defer {objc_sync_exit(BarcodeCreationLock)}
        
        if PreviousContents.count != From.count
        {
            PreviousContents = From
            PreviousResult = nil
            PreviousResult0 = nil
            PreviousResult1 = nil
        }
        
        //print("Called from \(CalledFrom), Bounds: \(TargetView.bounds), Frame: \(TargetView.frame)")
        let _Settings = UserDefaults.standard
        //let ViewPortSize = CGSize(width: TargetView.width, height: TargetView.height)
        var BitmapWidth: Int = 0
        var BitmapHeight: Int = 0
        var NotUsed: CIImage? = nil
        let BitmapArray = BarcodeGenerator.CreateBarcodeBitmap(from: From, WithType: "Code128",
                                                               FinalWidth: &BitmapWidth, FinalHeight: &BitmapHeight,
                                                               Native: &NotUsed)
        let Vector = BarcodeVector(Bitmap: BitmapArray!, Width: BitmapWidth, Height: BitmapHeight)
        var EdgeMargin = 10
        var RSize: CGFloat = 0.0
        var LeftMargin = 10
        var RightMargin = 10
        #if false
        RSize = min(TargetView.width, TargetView.height)
        #else
        if Handle.UseLongAxis
        {
            RSize = max(TargetView.width, TargetView.height)
            LeftMargin = 0
            RightMargin = 0
            EdgeMargin = 0
        }
        else
        {
            RSize = min(TargetView.width, TargetView.height)
        }
        #endif
        Handle.ViewHeight = Int(RSize)
        Handle.ViewWidth = Int(RSize)
        
        let BarcodeShape = _Settings.integer(forKey: Setting.Key.Code128.BarcodeShape)
        var BitmapView: UIView? = nil
        switch BarcodeShape
        {
        case 0:
            let BarcodeSize = _Settings.double(forKey: Setting.Key.Code128.BarcodeHeight)
            Handle.LeftMargin = LeftMargin
            Handle.RightMargin = RightMargin
            Handle.ViewHeight = Int((TargetView.height * 0.5) * CGFloat(BarcodeSize) * SampleOffset)
            Handle.ViewWidth = Int(RSize - CGFloat(EdgeMargin * 2))
            BitmapView = Vector.MakeView1D(Handle)
            
        case 1:
            RSize = min(TargetView.width, TargetView.height)
            let DSize = RSize / 2.0
            let Outer = _Settings.double(forKey: Setting.Key.Code128.OuterRadius)
            Handle.OuterRadius = Double(DSize) * Outer
            let Inner = _Settings.double(forKey: Setting.Key.Code128.InnerRadius)
            Handle.InnerRadius = Double(DSize) * Inner
            BitmapView = Vector.MakeView1DRing(Handle)
            
        case 2:
            let BarcodeSize = _Settings.double(forKey: Setting.Key.Code128.BarcodeHeight)
            Handle.LeftMargin = LeftMargin
            Handle.RightMargin = RightMargin
            var FinalDim: Int = Int(min(TargetView.width, TargetView.height))
            FinalDim = Int(Double(FinalDim) * BarcodeSize)
            Handle.ViewHeight = FinalDim
            BitmapView = Vector.MakeView1DTarget(Handle)
            
        default:
            print("Unknown shape \(BarcodeShape) encountered.")
            return nil
        }
        
        let FinalFrame = CGRect(x: 0, y: UIScreen.main.bounds.size.height / 2.0 - RSize / 2.0,
                                width: RSize, height: RSize)
        BitmapView!.frame = FinalFrame
        BitmapView!.bounds = FinalFrame
        return BitmapView
    }
    
    #if false
    /// Calls the barcode generator to create the specified barcode. The returned barcode is a vector that's been
    /// rasterized onto the returned UIView.
    ///
    /// - Parameters:
    ///   - from: The time to use to generate the barcode.
    /// - Returns: UIImage of the barcode.
    public func MakeBarcode2(from: String, _ TargetView: UIView) -> UIView?
    {
        return Barcode128Clock.CommonMakeBarcode(From: from, TargetView, CalledFrom: "Barcode128Clock.MakeBarcode2")
    }
    #endif
    
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
    private var _ClockID: UUID = UUID(uuidString: Clocks.ClockIDMap[PanelActions.SwitchToCode128]!)!
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
        return "ToCode128Settings"
    }
    
    /// Get changed settings.
    ///
    /// - Parameter Changed: List of changed settings. If nil, possibly no settings changed
    ///                      or too many to list.
    func ChangedSettings(_ Changed: [String])
    {
    }
}

