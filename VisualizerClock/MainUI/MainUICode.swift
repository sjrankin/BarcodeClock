//
//  MainUICode.swift
//  BarcodeTest
//
//  Created by Stuart Rankin on 7/30/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import CoreImage

/// Main code for creating and showing barcodes that contain the current time and are updated on a second-by-second basis.
class MainUICode: UIViewController, MainUIProtocol
{
    /// Settings for the application
    var _Settings = UserDefaults.standard
    
    /// The hardware model we're running on. (Determined in Utility by the size of the screen.)
    //var RunningModel: Utility.Models = Utility.Models.Unknown
    var RunningModel: Utility.DeviceClasses = Utility.DeviceClasses.Unknown
    var RunningModelName: String = "iPhone 3G"
    
    /// Initialize the program and set up the UI.
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //Watch the battery level.
        UIDevice.current.isBatteryMonitoringEnabled = true
        NotificationCenter.default.addObserver(self, selector: #selector(HandleBatteryLevelChanged),
                                               name: UIDevice.batteryLevelDidChangeNotification, object: nil)
        LastBatteryNotificationTime = CACurrentMediaTime()
        print("Initial battery level: \(BatteryLevel) (Negative values indicate running on a simulator)")
        
        CreateSpirals()
        
        TimeTextView.text = "Hello"
        RunningModelName = Utility.GetUserDeviceName()
        print("Device name: \(RunningModelName)")
        
        RunningModel = Utility.Model()
        let (ModelWidth, ModelHeight) = Utility.ScreenSize(ForDeviceClass: RunningModel)
        print("Running on \(RunningModel): (\(ModelWidth),\(ModelHeight))")
        
        Clocks.Initialize()
        
        ClockViewPort.backgroundColor = UIColor.clear
        
        FontManager.LoadFonts()
        
        /*
        NotificationCenter.default.addObserver(self, selector: #selector(DefaultsChanged),
                                               name: UserDefaults.didChangeNotification, object: nil)
        //Observe the menu button behavior settings key.
        _Settings.addObserver(self, forKeyPath: Setting.Key.MenuButtonBehavior, options: NSKeyValueObservingOptions.new, context: nil)
        _Settings.addObserver(self, forKeyPath: Setting.Key.TimeLocation, options: NSKeyValueObservingOptions.new, context: nil)
        #if DEBUG
        _Settings.addObserver(self, forKeyPath: Setting.Key.Debug.ShowDebugGrid, options: NSKeyValueObservingOptions.new, context: nil)
        #endif
 */
        
        ClockViewPort.contentMode = .scaleAspectFit
        ClockViewPort.clipsToBounds = true
        
        #if false
        //Need to create the gradient layer before doing the first update to the background.
        if _Settings.integer(forKey: Setting.Key.Background.BGType) == 0
        {
            MakeGradientBackground()
        }
        #endif
        
        //Smoothly transition from the launch screen background color to the time-appropriate current background color.
        let Now = Date()
        let Cal = Calendar.current
        let Seconds = Cal.component(.second, from: Now)
        Background = BackgroundServer(BackgroundView)
        UpdateTextColors(Seconds: Seconds)
        
        ScreenWidth = UIScreen.main.bounds.width
        ScreenHeight = UIScreen.main.bounds.height
        InitialTimeTextFrame = TimeTextView.frame
        
        TimeTextView.layer.zPosition = 1000
        ClockViewPort.layer.zPosition = 102
        
        ShowingTime = _Settings.bool(forKey: "ShowingTime")
        #if false
        let MultiTap = UITapGestureRecognizer(target: self, action: #selector(HandleMultiTaps))
        MultiTap.numberOfTapsRequired = 2
        BackgroundView.addGestureRecognizer(MultiTap)
        #endif
        #if true
        let DefadeTap = UITapGestureRecognizer(target: self, action: #selector(HandleMainUITap))
        DefadeTap.numberOfTapsRequired = 1
        BackgroundView.addGestureRecognizer(DefadeTap)
        //DefadeTap.require(toFail: MultiTap)     //Needed to get single and double tapping to work.
        #else
        let DefadeTap = UITapGestureRecognizer(target: self, action: #selector(HandleMainUITap))
        BackgroundView.addGestureRecognizer(DefadeTap)
        #endif
        let LongPress = UILongPressGestureRecognizer(target: self, action: #selector(HandleLongPress))
        LongPress.minimumPressDuration = TimeInterval(1.0)
        BackgroundView.addGestureRecognizer(LongPress)
        //let ClockTap = UITapGestureRecognizer(target: ClockViewPort, action: #selector(HandleClockTap))
        //ClockViewPort.addGestureRecognizer(ClockTap)
        
        PeriodicUpdateUI()
        StartMainTimer()
        SetTimeState()
        DoSetOutline(To: _Settings.bool(forKey: Setting.Key.OutlineObjects))
        CheckForDarkMode(Date())
        SetMenuButtons()
        
        if _Settings.bool(forKey: Setting.Key.ShowVersionOnMainScreen)
        {
            ShowingVersionNumber = true
            VersionLabelView.layer.cornerRadius = 15.0
            VersionLabelView.layer.borderColor = UIColor.black.cgColor
            VersionLabelView.layer.borderWidth = 0.5
            VersionLabelView.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.35)
            VersionDataLabel.backgroundColor = UIColor.clear
            //Move the version number to near the bottom of the screen.
            let NewY = UIScreen.main.bounds.height - 80
            VersionLabelView.frame = CGRect(x: VersionLabelView.frame.minX, y: NewY,
                                            width: VersionLabelView.frame.width, height: VersionLabelView.frame.height)
            print("VersionLabelView: \(VersionLabelView.frame)")
            #if DEBUG
            let VersionString = Versioning.MakeVersionString() + ", Build \(Versioning.Build)"
            #else
            let VersionString = Versioning.MakeVersionString()
            #endif
            VersionDataLabel.text = VersionString
            VersionTimer = Timer.scheduledTimer(timeInterval: TimeInterval(5.0), target: self,
                                                selector: #selector(HideVersion), userInfo: nil, repeats: false)
            if _Settings.bool(forKey: Setting.Key.TapRemovesVersion)
            {
                let VersionTap = UITapGestureRecognizer(target: self, action: #selector(RemoveVersionEarly))
                VersionLabelView.addGestureRecognizer(VersionTap)
            }
        }
        else
        {
            print("Version number removed from main screen at start-up time.")
            ShowingVersionNumber = false
            VersionLabelView.removeFromSuperview()
            VersionLabelView = nil
        }
        
        let DeviceScreen = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        UpdateClockPosition(ScreenSize: DeviceScreen)
        UpdateTimeTextPosition(DeviceScreen)
        CreateClocks()
        CurrentClock?.SetClockState(ToRunning: true, Animation: 0)
        
        InitializeUIElementLocations()
        #if DEBUG
        ShowDebugGrid(_Settings.bool(forKey: Setting.Key.Debug.ShowDebugGrid), CalledFrom: "ViewDidLoad")
        #endif
        
        NotificationCenter.default.addObserver(self, selector: #selector(HandleSettingNotice), name: Setting.NotificationName, object: nil)
        ViewPortFrame = ClockViewPort.frame
        ViewPortBounds = ClockViewPort.bounds
        
        let AppDel = UIApplication.shared.delegate as! AppDelegate
        AppDel.Container?.MainDelegate = self
    }
    
    private var Background: BackgroundServer!
    
    private var LastBatteryNotificationTime = CACurrentMediaTime()
    
    /// Handle notifications of battery level changes.
    ///
    /// - Parameter notification: Not used.
    @objc func HandleBatteryLevelChanged(_ notification: Notification)
    {
        let Now = CACurrentMediaTime()
        var Delta = Now - LastBatteryNotificationTime
        Delta = Utility.Round(Delta, ToPlaces: 3)
        let Pretty = "\(BatteryLevel * 100.0)%"
        LastBatteryNotificationTime = Now
        print("Battery level at \(Pretty) after \(Delta) seconds")
    }
    
    /// Get the current battery level in percent values (eg, 1.0 is 100%).
    public var BatteryLevel: Float
    {
        get
        {
            return UIDevice.current.batteryLevel
        }
    }
    
    #if false
    @objc func HandleClockTap(sender: UITapGestureRecognizer)
    {
        let Location = sender.location(in: ClockViewPort)
        if (CurrentClock?.HandlesTaps)!
        {
            CurrentClock?.WasTapped(At: Location)
        }
    }
    #endif
    
    var ViewPortBounds: CGRect!
    var ViewPortFrame: CGRect!
    
    func TapFromClock(_ ID: UUID)
    {
        
    }
    
    func HandledTapInClock(_ ID: UUID)
    {
    }
    
    // MARK: Pre-generate spirals.
    
    /// Create a list of spiral coordinates, one spiral per clock face hour. Save in the Geometry class for use later on.
    func CreateSpirals()
    {
        let Start = CACurrentMediaTime()
        
        let HalfX = UIScreen.main.bounds.width / 2.0
        let HalfY = UIScreen.main.bounds.height / 2.0
        let Radius = min(HalfX, HalfY) - CGFloat(UIDevice.current.userInterfaceIdiom == .pad ? 25.0 : 15.0)
        let Center = CGPoint(x: HalfX, y: HalfY)
        let BasePoints = Geometry.MakeSpiral(StartingAngle: 0.0, InitialRadius: Radius, Rotations: 0.75, Steps: 100, RadialDelta: -1.0, Center: Center)
        
        for Hour in 1 ... 12
        {
            var PointList = [CGPoint]()
            let Angle = CGFloat(Hour) * 30.0
            if Hour == 12
            {
                PointList = BasePoints
            }
            else
            {
                PointList = Geometry.RotatePointList(BasePoints, Degrees: Double(Angle), Around: Center)
            }
            Geometry.SaveSpiral(Hour: Hour, SpiralPath: PointList)
        }
        
        let OBasePoints = Geometry.MakeSpiral(StartingAngle: 0.0, InitialRadius: Radius, Rotations: 0.75, Steps: 100,
                                              RadialDelta: 1.0, Center: Center, RadiusOffset: 0.0)
        
        for Hour in 1 ... 12
        {
            var PointList = [CGPoint]()
            let Angle = CGFloat(Hour) * 30.0
            if Hour == 12
            {
                PointList = OBasePoints
            }
            else
            {
                PointList = Geometry.RotatePointList(OBasePoints, Degrees: Double(Angle), Around: Center)
            }
            Geometry.SaveSpiral(Hour: Hour + 100, SpiralPath: PointList)
        }
        
        let Now = CACurrentMediaTime()
        print("Spiral generation time: \(Now - Start) seconds")
    }
    
    // MARK: - MainUIProtocol implementations.
    
    /// Determines if we are in dark mode or not based on user settings.
    ///
    /// - Parameter Now: The date/time to check to see if we're in dark mode.
    func CheckForDarkMode(_ Now: Date)
    {
        if _Settings.bool(forKey: Setting.Key.EnableDarkMode)
        {
            var DBG = ""
            var Transitioning = false
            let InDarkModeRange = IsInDarkModeRange(Now, DidTransition: &Transitioning)
            _Settings.set(InDarkModeRange, forKey: Setting.Key.InDarkMode)
            #if DEBUG
            DBG = "Is in dark mode range: \(InDarkModeRange), InDarkMode: \(InDarkMode)"
            if InDarkModeRange && Transitioning
            {
                DBG = DBG + ", " + "Transitioning to dark mode at \(Utility.DateToString(Now, Parts: .TimeAndDate))"
            }
            if !InDarkModeRange && Transitioning
            {
                DBG = DBG + ", " + "Transitioning out of dark mode at \(Utility.DateToString(Now, Parts: .TimeAndDate))"
            }
            if !Transitioning
            {
                DBG = ", " + "No transition, InDarkMode: \(InDarkMode)"
            }
            #endif
        }
        else
        {
            _Settings.set(false, forKey: Setting.Key.InDarkMode)
        }
    }
    
    /// Called when some aspect of the background has changed. This function is called by "dialogs" from customization or
    /// other functionality and not directly from MainUICode.
    func BackgroundChange(From: String)
    {
        #if false
        print("BackgroundChange called from \(From)")
        let c = _Settings.double(forKey: Setting.Key.BGColor2Location)
        let x = Utility.Round(c, ToPlaces: 2)
        print("Color 2 location: \(x)")
        #endif
        Background.UpdateBackgroundColors()
    }
    
    /// Status of left and right panel visibility send by the various panel controllers. Used to start or end timers and animation.
    /// It's possible we may receive the same status more than once in a row. So, all duplicate statuses are ignored.
    ///
    /// - Parameter Status: Status that caused the call.
    func ReportPanelStatus(Status: PanelStatuses)
    {
        if PreviousPanelStatus == Status
        {
            return
        }
        PreviousPanelStatus = Status
        let IsImpatient = _Settings.bool(forKey: Setting.Key.EnableImpatientUI)
        let ImpatientDelay = _Settings.integer(forKey: Setting.Key.ImpatientDelay)
        switch Status
        {
        case .LeftClosed:
            print("Left panel closed.")
            if LeftIsShowingImpatience
            {
                //https://stackoverflow.com/questions/39443163/remove-animation-in-swift
                LeftButton.layer.removeAllAnimations()
                if let LeftButtonRestoreX = LeftButtonRestoreX
                {
                    LeftButton.frame = CGRect(x: LeftButtonRestoreX, y: LeftButton.frame.minY, width: LeftButton.frame.width, height: LeftButton.frame.height)
                }
            }
            if LeftButtonPatienceTimer != nil
            {
                LeftButtonPatienceTimer?.invalidate()
                LeftButtonPatienceTimer = nil
            }
            LeftIsShowingImpatience = false
            
        case .RightClosed:
            print("Right panel closed.")
            if RightIsShowingImpatience
            {
                //https://stackoverflow.com/questions/39443163/remove-animation-in-swift
                RightButton.layer.removeAllAnimations()
                if let RightButtonRestoreX = RightButtonRestoreX
                {
                    RightButton.frame = CGRect(x: RightButtonRestoreX, y: RightButton.frame.minY, width: RightButton.frame.width, height: RightButton.frame.height)
                }
            }
            if RightButtonPatienceTimer != nil
            {
                RightButtonPatienceTimer?.invalidate()
                RightButtonPatienceTimer = nil
            }
            RightIsShowingImpatience = false
            
        case .LeftOpen:
            print("Left panel open.")
            if IsImpatient
            {
                LeftButtonRestoreX = LeftButton.frame.minX
                LeftButtonPatienceTimer = Timer.scheduledTimer(timeInterval: TimeInterval(ImpatientDelay), target: self,
                                                               selector: #selector(LeftButtonBecameImpatient), userInfo: nil, repeats: false)
            }
            
        case .RightOpen:
            print("Right panel open.")
            if IsImpatient
            {
                RightButtonRestoreX = RightButton.frame.minX
                RightButtonPatienceTimer = Timer.scheduledTimer(timeInterval: TimeInterval(ImpatientDelay), target: self,
                                                                selector: #selector(RightButtonBecameImpatient), userInfo: nil, repeats: false)
            }
            
        default:
            break
        }
    }
    
    var PreviousPanelStatus: PanelStatuses = .Unknown
    
    var LeftButtonRestoreX: CGFloat? = nil
    var RightButtonRestoreX: CGFloat? = nil
    var LeftButtonPatienceTimer: Timer? = nil
    var RightButtonPatienceTimer: Timer? = nil
    var LeftIsShowingImpatience: Bool = false
    var RightIsShowingImpatience: Bool = false
    
    var OldLeftFrame: CGRect = CGRect.zero
    
    /// The left-button impatience timer triggered. Start the impatient animation.
    @objc func LeftButtonBecameImpatient()
    {
        print("Left button is impatient.")
        LeftButtonPatienceTimer?.invalidate()
        LeftButtonPatienceTimer = nil
        LeftIsShowingImpatience = true
        OldLeftFrame = LeftButton.frame
        let Interval = TimeInterval(CGFloat(_Settings.double(forKey: Setting.Key.ImpatientMenuButtonInterval)))
        //https://stackoverflow.com/questions/41208298/uibuttons-are-not-responding-during-animation-ios-swift-3
        UIView.animate(withDuration: Interval, delay: 0, options: [.repeat, .autoreverse, .allowUserInteraction], animations:
            {
                self.LeftButton.frame = CGRect(x: self.OldLeftFrame.minX + 10, y: self.OldLeftFrame.minY,
                                               width: self.OldLeftFrame.width, height: self.OldLeftFrame.height)
        })
    }
    
    var OldRightFrame: CGRect = CGRect.zero
    
    /// The right-button impatience timer tiggered. Start theimpatient animation.
    @objc func RightButtonBecameImpatient()
    {
        print("Right button is impatient.")
        RightButtonPatienceTimer?.invalidate()
        RightButtonPatienceTimer = nil
        RightIsShowingImpatience = true
        OldRightFrame = RightButton.frame
        let Interval = TimeInterval(CGFloat(_Settings.double(forKey: Setting.Key.ImpatientMenuButtonInterval)))
        //https://stackoverflow.com/questions/41208298/uibuttons-are-not-responding-during-animation-ios-swift-3
        UIView.animate(withDuration: Interval, delay: 0, options: [.repeat, .autoreverse, .allowUserInteraction], animations:
            {
                /*
                 self.RightButton.frame = CGRect(x: self.OldRightFrame.minX - 10, y: self.OldRightFrame.minY,
                 width: self.OldRightFrame.width, height: self.OldRightFrame.height)
                 */
                self.RightButton.frame = CGRect(x: self.RightButton.frame.minX - 10, y: self.RightButton.frame.minY,
                                                width: self.RightButton.frame.width, height: self.RightButton.frame.height)
        },
                       completion:
            {
                finished in
                self.RightButton.layer.removeAllAnimations()
        })
    }
    
    /// Called by clocks when they have a new view to display.
    ///
    /// - Parameter ID: The ID of the clock with the new view.
    /// - Parameter WithView: The view to display.
    func UpdateMainView(ID: UUID, WithView: UIView)
    {
        //https://stackoverflow.com/questions/24312760/how-to-remove-all-subviews-of-a-view-in-swift
        ClockViewPort.subviews.forEach({ $0.removeFromSuperview() })
        ClockViewPort.bounds = UIScreen.main.bounds
        ClockViewPort.frame = UIScreen.main.bounds
        ClockViewPort.addSubview(WithView)
    }
    
    /// Called by the clock - this is called when the clock is ready to update the clock but hasn't yet done so.
    ///
    /// - Parameter ID: ID of the clock preparing an update.
    func PreparingClockUpdate(ID: UUID)
    {
    }
    
    /// Called by the clock - this is called after the clock has completed updating the clock.
    ///
    /// - Parameter ID: ID of the clock finishing an update.
    func FinishedClockUpdate(ID: UUID)
    {
    }
    
    /// Called when a clock is started.
    ///
    /// - Parameter ID: ID of the clock that started.
    func ClockStarted(ID: UUID)
    {
        let TheClock = GetClock(ID: ID)
        let ClockName: String = (TheClock?.ClockName)!
        print("Clock \(ClockName) started.")
    }
    
    /// Called when a clock is stopped - usually before a new clock is displayed.
    ///
    /// - Parameter ID: ID of the clock that stopped.
    func ClockStopped(ID: UUID)
    {
        let TheOldClock = GetClock(ID: ID)
        if let OldInstanceCount = ClockInstanceExecutions[ID]
        {
            let NewInstanceCount = OldInstanceCount + 1
            ClockInstanceExecutions[ID] = NewInstanceCount
        }
        else
        {
            ClockInstanceExecutions[ID] = 1
        }
        let SessionSeconds: Int = (TheOldClock?.SecondsDisplayed())!
        if let OldCount = ClockDurations[ID]
        {
            let NewCount = OldCount + SessionSeconds
            ClockDurations[ID] = NewCount
        }
        else
        {
            ClockDurations[ID] = SessionSeconds
        }
        let Total: Int = ClockDurations[ID]!
        let InstanceCount: Int = ClockInstanceExecutions[ID]!
        let Mean = Utility.Round(Double(Total) / Double(InstanceCount), ToPlaces: 2)
        //track instance counts as well
        print("Clock \((TheOldClock?.ClockName)!) stopped.")
        print("Clock ran for \(SessionSeconds) seconds, total duration (all sessions): \(Total). Instance count: \(InstanceCount). Mean seconds/instance: \(Mean)")
    }
    
    /// Called when a clock is shut down (such as by moving to a different clock). There is no guarentee
    /// that the clock still exists in the clock map or clock list.
    ///
    /// - Parameter ID: ID of the clock that finished.
    func ClockClosed(ID: UUID)
    {
        print("Clock \(ID.uuidString) closed.")
    }
    
    /// Allows calling clocks to show or hide the textual time.
    ///
    /// - Parameter IsOn: If true, the time is displayed. If false, the time is hidden. User settings override this function.
    func TextClockDisplay(IsOn: Bool)
    {
        
    }
    
    /// Ideally this is called once a second by the clock being displayed.
    ///
    /// - Parameter ID: ID of the clock that called.
    func OneSecondTick(ID: UUID, Time: Date)
    {
        UpdateFancyText(Time)
    }
    
    // MARK: - Settings notifications.
    
    /// Handle notifications from Setting. Mainly used to get notices of changed settings in an easier and more reliable and
    /// maintainable fashion than chaining protocols together.
    ///
    /// - Parameter notification: Notification data.
    @objc func HandleSettingNotice(notification: Notification)
    {
        let UserData = notification.userInfo as? [String : Any]
        let (Key, Value) = ParseRaw(UserData!)!
        if Key.isEmpty
        {
            return
        }
        switch Key
        {
        case "BGColorChanged":
            if !Value.isEmpty
            {
                if let BGColorIndex = Int(Value)
                {
                    //Get new background colors.
                    Background.UpdateBGColor(BGColorIndex)
                }
            }
            
        case "BGColorCountChanged":
            if !Value.isEmpty
            {
                if let _ = Int(Value)
                {
                    //Reload background colors into the gradient.
                    Background.GetBackgroundColors()
                }
            }
            
        default:
            break
        }
    }
    
    /// Parse data from a setting notification call. This function assumes two items in the passed
    /// data - one whose key is "Key" and one whose key is "Value".
    ///
    /// - Parameter Data: Array of key/value pairs.
    /// - Returns: Tuple in the form (key, value).
    func ParseRaw(_ Data: [String : Any]) -> (String, String)?
    {
        var Key: String = ""
        if let KeyName = Data["Key"] as? String
        {
            Key = KeyName
        }
        var Value: String = ""
        if let ValueContents = Data["Value"] as? String
        {
            Value = ValueContents
        }
        return (Key, Value)
    }
    
    /// Timer that is used to make the version disappear after a short period of time.
    var VersionTimer: Timer? = nil
    
    /// Called when the VersionTimer expires. Hides the version label.
    @objc func HideVersion()
    {
        print("Hiding version number.")
        ShowingVersionNumber = false
        UIView.animate(withDuration: TimeInterval(2.0), animations:
            {
                self.VersionLabelView.alpha = 0.0
        }
            , completion:
            {
                _ in
                self.VersionLabelView.removeFromSuperview()
                self.VersionLabelView = nil
        })
    }
    
    /// Flag that indicates whether the version number is showing on the screen or not.
    var ShowingVersionNumber: Bool = true
    
    /// Tell the system that we don't want the status bar getting in the way.
    override var prefersStatusBarHidden: Bool
    {
        let NoStatusBar: Bool = _Settings.bool(forKey: Setting.Key.HideStatusBar)
        print(">>>>>>>>>> Hide the status bar: \(NoStatusBar)")
        return NoStatusBar
    }
    
    /// Used to keep track of barcode types.
    var PreviousBarcodeType: Int = -1
    
    /// Broadcast settings changes to all clocks.
    ///
    /// - Parameter Changes: List of settings keys whose values were changed. May be nil.
    func BroadcastChanges(_ Changes: [String])
    {
        for (_, Clock) in RunTimeClockList!
        {
            Clock.ChangedSettings(Changes)
        }
    }
    
    /// Broadcast settings changes to a specific clock.
    ///
    /// - Parameters:
    ///   - ToClock: ID of the clock to broadcast changes to.
    ///   - Changes: List of settings keys whose values were changed. May be nil.
    /// - Returns: True on success, false on failure (due to not finding the clock).
    @discardableResult func BroadcastChanges(ToClock: UUID, _ Changes: [String]) -> Bool
    {
        if let Clock = RunTimeClockList![ToClock]
        {
            Clock.ChangedSettings(Changes)
            return true
        }
        return false
    }
    
    /// Handle settings changes.
    @objc func DefaultsChanged(forKeyPath keyPath: String, of object: Any?,
                               change: [NSKeyValueChangeKey: Any]?,
                               context: UnsafeMutableRawPointer?)
    {
        print("MainUI.DefaultsChanged")
        //Handle local changes (eg, to the main UI).
        if IgnoreChanges
        {
            return
        }
        DoSetOutline(To: _Settings.bool(forKey: Setting.Key.OutlineObjects))
        SetTimeState()
        ShowingTime = _Settings.bool(forKey: Setting.Key.ShowingTime)

        let ScreenSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        UpdateTimeTextPosition(ScreenSize)
        #if DEBUG
        if PreviousShowGrid == nil
        {
            PreviousShowGrid = _Settings.bool(forKey: Setting.Key.Debug.ShowDebugGrid)
        }
        //Be parsimonius in updating the grid.
        if PreviousShowGrid! != _Settings.bool(forKey: Setting.Key.Debug.ShowDebugGrid)
        {
            ShowDebugGrid(_Settings.bool(forKey: Setting.Key.Debug.ShowDebugGrid), CalledFrom: "DefaultsChanged")
            PreviousShowGrid = _Settings.bool(forKey: Setting.Key.Debug.ShowDebugGrid)
        }
        #endif
    }
    
    var PreviousShowGrid: Bool? = nil
    
    /// Changed user setting event for Setting.Key.MenuButtonBehavior. Used to be notified immediately when the user changes how
    /// the button menus are viewed.
    ///
    /// - Parameters:
    ///   - keyPath: Path of the object that was changed. Not used.
    ///   - object: The object that was changed. Not used.
    ///   - change: The changed value. Not used.
    ///   - context: Context. Not used.
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?)
    {
        SetMenuButtons()
    }
    
    /// Move a UIView (or descendant class) with the passed offsets.
    ///
    /// - Parameters:
    ///   - Element: The control to move.
    ///   - XOffset: Horizontal offset (negative or positive).
    ///   - YOffset: Vertical offset (negative or positivie).
    func MoveUIElement(_ Element: UIView, XOffset: CGFloat, YOffset: CGFloat)
    {
        let NewFrame = CGRect(x: Element.frame.minX + XOffset, y: Element.frame.minY + YOffset,
                              width: Element.frame.width, height: Element.frame.height)
        Element.frame = NewFrame
    }
    
    /// If true, the buttons were moved. Used to prevent migating buttons.
    var ButtonsMoved = false
    
    /// Move a button to a different location. No care is taken to clamp "invalid" values.
    ///
    /// - Parameters:
    ///   - Button: The button to move.
    ///   - XOffset: The horizontal offset, positive or negative.
    ///   - YOffset: The vertical offset, positive or negative.
    func MoveButton(_ Button: UIButton, XOffset: CGFloat, YOffset: CGFloat)
    {
        #if false
        if !_Settings.bool(forKey: Setting.Key.HideStatusBar)
        {
            //If the user wants to show the status bar, don't move the buttons - they'll just get in the way.
            return
        }
        #endif
        let Frame = Button.frame
        let NewFrame = CGRect(x: Frame.minX + XOffset, y: Frame.minY + YOffset, width: Frame.width, height: Frame.height)
        Button.frame = NewFrame
        //print("MenuButton at \(NewFrame)")
    }
    
    /// Move the menu buttons to appropriate locations, taking into account cutout and safe areas.
    func MoveMenuButtons()
    {
        if ButtonsMoved
        {
            return
        }
        ButtonsMoved = true
        #if true
        MoveButton(LeftButton, XOffset: 0.0, YOffset: 24.0)
        MoveButton(RightButton, XOffset: 0.0, YOffset: 24.0)
        //print("MoveMenuButtons: Left(\(LeftButton.frame)), Right(\(RightButton.frame))")
        #else
        MoveButton(LeftButton, XOffset: 15.0, YOffset: -10.0)
        MoveButton(RightButton, XOffset: -15.0, YOffset: -10.0)
        #endif
    }
    
    /// Move menu buttons back to their original location.
    func MoveButtonsBack()
    {
        ButtonsMoved = false
        #if true
        MoveButton(LeftButton, XOffset: 0.0, YOffset: -24.0)
        MoveButton(RightButton, XOffset: 0.0, YOffset: -24.0)
        //print("MoveButtonsBack: Left(\(LeftButton.frame)), Right(\(RightButton.frame))")
        #else
        MoveButton(LeftButton, XOffset: -15.0, YOffset: 10.0)
        MoveButton(RightButton, XOffset: 15.0, YOffset: 10.0)
        #endif
    }
    
    /// Set the visibility of the menu buttons.
    func SetMenuButtons()
    {
        #if true
        if RunningModel == .iPhoneX || RunningModel == .iPhoneXSMax
        {
            if UIDevice.current.orientation == .portrait
            {
                MoveMenuButtons()
                let Element = TimeTextView as UIView
                MoveUIElement(Element, XOffset: 0.0, YOffset: 20.0)
            }
            else
            {
                MoveButtonsBack()
                let Element = TimeTextView as UIView
                MoveUIElement(Element, XOffset: 0.0, YOffset: -20.0)
            }
        }
        #endif
        switch _Settings.integer(forKey: Setting.Key.MenuButtonBehavior)
        {
            #if false
        case 0:
            //Tapped
            SetMenuButtonVisibility(IsVisible: true)
            #endif
            
        case 1:
            //Always visible
            SetMenuButtonVisibility(IsVisible: true)
            
        case 2:
            //Never visible
            SetMenuButtonVisibility(IsVisible: false)
            
        default:
            SetMenuButtonVisibility(IsVisible: true)
        }
    }
    
    /// Sets the left and right menu button visibility. Also modifies the isEnabled flag for each button.
    ///
    /// - Parameter IsVisible: Determines visibility of both directionaly menu buttons.
    func SetMenuButtonVisibility(IsVisible: Bool)
    {
        RightButton.isEnabled = IsVisible
        LeftButton.isEnabled = IsVisible
        RightButton.alpha = 1.0
        LeftButton.alpha = 1.0
    }
    
    /// Flag that tells DefaultsChanged to immediately return without doing anything. Used to prevent infinite loops from SetTimeState.
    var IgnoreChanges = false
    
    /// Set the state of the text time display.
    func SetTimeState()
    {
        IgnoreChanges = true
        #if true
        if _Settings.bool(forKey: Setting.Key.ShowTextualTime)
        {
            _Settings.set(true, forKey: Setting.Key.ShowingTime)
            TimeTextView.isEnabled = true
            TimeTextView.alpha = 1.0
        }
        else
        {
            _Settings.set(false, forKey: Setting.Key.ShowingTime)
            TimeTextView.isEnabled = false
            TimeTextView.alpha = 0.0
        }
        #else
        switch _Settings.integer(forKey: Setting.Key.TimeDisplayMethod)
        {
        case 1:
            //Always show time.
            _Settings.set(true, forKey: Setting.Key.ShowingTime)
            
        case 2:
            //Never show time.
            _Settings.set(false, forKey: Setting.Key.ShowingTime)
            
        case 0:
            //Visibility of the time depends on the user tapping the screen. Show the time to let the user
            //know his setting took effect.
            _Settings.set(true, forKey: Setting.Key.ShowingTime)
            
        default:
            break
        }
        #endif
        IgnoreChanges = false
    }
    
    #if false
    /// Create the gradient background layer.
    func MakeGradientBackground()
    {
        GradientBG = CAGradientLayer()
        GradientBG!.frame = self.view.frame
        GradientBG!.colors = [UIColor.white.cgColor, UIColor.black.cgColor]
        self.view.layer.insertSublayer(GradientBG!, at: 0)
    }
    #endif
    
    /// Start the main clock timer.
    func StartMainTimer()
    {
        let Interval = TimeInterval(1.0)
        MainTimer = Timer.scheduledTimer(timeInterval: Interval, target: self,
                                         selector: #selector(PeriodicUpdateUI), userInfo: nil, repeats: true)
    }
    
    /// Start the label timer (which updates attributes in the time text label).
    func StartLabelTimer()
    {
        LabelTimer = Timer.scheduledTimer(timeInterval: TimeInterval(0.05), target: self,
                                          selector: #selector(UpdateTimeTextAttributes), userInfo: nil, repeats: true)
    }
    
    /// Timer for updating attributes in the text label.
    var LabelTimer: Timer!
    
    /// Changes attributes in the time text.
    @objc func UpdateTimeTextAttributes()
    {
        #if false
        let Now = Date()
        let Cal = Calendar.current
        let Second = Cal.component(.second, from: Now)
        if Second != PreviousSecond
        {
            let Range = NSRange(location: 0, length: TimeTextString.string.count)
            #if true
            let NewHue: CGFloat = CGFloat(Second * 6) / CGFloat(360.0)
            let Stroke = UIColor(hue: NewHue, saturation: 1.0, brightness: 0.4, alpha: 1.0)
            #else
            let OffsetSecond = (Second + 12) % 60
            let NewHue: CGFloat = CGFloat(OffsetSecond * 6) / CGFloat(360.0)
            let Stroke = UIColor(hue: NewHue, saturation: 1.0, brightness: 0.7, alpha: 1.0)
            #endif
            TimeTextString.removeAttribute(NSAttributedString.Key.strokeColor, range: Range)
            TimeTextString.addAttribute(NSAttributedString.Key.strokeColor, value: Stroke, range: Range)
            TimeTextView.attributedText = TimeTextString
        }
        #endif
    }
    
    /// Previous second usec.
    var PreviousSecond: Int = -1
    
    /// Layer used for gradient color shifting.
    var GradientBG: CAGradientLayer? = nil
    /// Value of the initial time text frame.
    var InitialTimeTextFrame: CGRect!
    
    /// Timer used to fade out certain elements of the UI.
    var FadeTimer: Timer!
    /// Main timer for the clock.
    var MainTimer: Timer!
    /// Flag that indicates the time text is being shown.
    var ShowingTime: Bool = true
    
    /// Given a panel action, return a UIAlertAction properly populated such that the user can use it to select a clock.
    ///
    /// - Parameters:
    ///   - Action: The panel action whose name will be shown to the user in the returned UIAlertAction.
    ///   - Handler: Handler for the UIAlertAction.
    /// - Returns: UIAlertAction populated by information based on Action.
    func MakeClockAlertAction(Action: PanelActions, Handler: ((UIAlertAction) -> Void)?) -> UIAlertAction?
    {
        if let Name = Clocks.NameForClock(Action: Action)
        {
            let AlertStyle: UIAlertAction.Style = .default
            let TheAlert = UIAlertAction(title: Name, style: AlertStyle, handler: Handler)
            return TheAlert
        }
        return nil
    }
    
    @objc func HandleMultiTaps(_ sender: UITapGestureRecognizer)
    {
        if sender.state != UIGestureRecognizer.State.ended
        {
            return
        }
        if (delegate?.SidePanelShowing())!
        {
            delegate?.CollapseSidePanels!()
            return
        }
        HandleMenuTap()
    }
    
    /// Handle long press events. Show a UIAlert letting the user select different clocks.
    ///
    /// - Parameter sender: Long press gesture recognizer.
    @objc func HandleLongPress(_ sender: UITapGestureRecognizer)
    {
        if sender.state != UIGestureRecognizer.State.began
        {
            return
        }
        //print("Long press recognized")
        let GetClockSheet = UIAlertController(title: "Actions",
                                              message: "Select the clock to display. Or take a screenshot.",
                                              preferredStyle: UIAlertController.Style.alert)
        GetClockSheet.addAction(MakeClockAlertAction(Action: PanelActions.TakePicture, Handler: HandleSelectClockAlert)!)
        GetClockSheet.addAction(MakeClockAlertAction(Action: PanelActions.SwitchToCode128, Handler: HandleSelectClockAlert)!)
        GetClockSheet.addAction(MakeClockAlertAction(Action: PanelActions.SwitchToQRCode, Handler: HandleSelectClockAlert)!)
        GetClockSheet.addAction(MakeClockAlertAction(Action: PanelActions.SwitchToAztecCode, Handler: HandleSelectClockAlert)!)
        GetClockSheet.addAction(MakeClockAlertAction(Action: PanelActions.SwitchToPDF417, Handler: HandleSelectClockAlert)!)
        GetClockSheet.addAction(MakeClockAlertAction(Action: PanelActions.SwitchToRadialColors, Handler: HandleSelectClockAlert)!)
        GetClockSheet.addAction(MakeClockAlertAction(Action: PanelActions.SwitchToRadialGrayscale, Handler: HandleSelectClockAlert)!)
        GetClockSheet.addAction(MakeClockAlertAction(Action: PanelActions.SwitchToAmorphousColorBlob, Handler: HandleSelectClockAlert)!)
        GetClockSheet.addAction(MakeClockAlertAction(Action: PanelActions.SwitchToPolarText, Handler: HandleSelectClockAlert)!)
        GetClockSheet.addAction(MakeClockAlertAction(Action: PanelActions.SwitchToPolarLines, Handler: HandleSelectClockAlert)!)
        let CancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        GetClockSheet.addAction(CancelAction)
        present(GetClockSheet, animated: true)
    }
    
    /// Called by a UIAlertController when the user selects a new clock to display.
    ///
    /// - Parameter Action: The UIAlert that was selected. Used to determine the clock to display.
    @objc func HandleSelectClockAlert(Action: UIAlertAction!)
    {
        let Title: String = Action.title!
        if Title == "Take Screenshot"
        {
            TakeScreenShot()
            return
        }
        if let ID = Clocks.GetClockIDFromName(ClockName: Title)
        {
            SetClock(ClockID: ID)
        }
        else
        {
            print("Error getting ID for clock \(Title)")
        }
    }
    
    /// Save an image of the screen to the photo album.
    func TakeScreenShot()
    {
        var ScreenImage: UIImage?
        let Layer = UIApplication.shared.keyWindow!.layer
        let Scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(Layer.frame.size, false, Scale)
        guard let Context = UIGraphicsGetCurrentContext() else
        {
            print("Error getting context for screen shot.")
            return
        }
        Layer.render(in: Context)
        ScreenImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if let Final = ScreenImage
        {
            UIImageWriteToSavedPhotosAlbum(Final, nil, nil, nil)
            NotificationAlert("Image Saved", "Your screen shot was saved to the photo album successfully.")
        }
        else
        {
            NotificationAlert("Error", "Unable to save the screen shot to your photo album.")
        }
    }
    
    /// Show a small notification using the passed text. The only available action for the user is "OK".
    ///
    /// - Parameters:
    ///   - Title: Title of the notification.
    ///   - Text: Text of the notification.
    func NotificationAlert(_ Title: String, _ Text: String)
    {
        let Alert = UIAlertController(title: Title,
                                      message: Text,
                                      preferredStyle: UIAlertController.Style.alert)
        Alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(Alert, animated: true)
    }
    
    /// The user tapped on the versio number before it faded out - hide it early.
    ///
    /// - Parameter sender: Not used.
    @objc func RemoveVersionEarly(_ sender: UITapGestureRecognizer)
    {
        print("Removing version number early.")
        if HidingVersionNumber
        {
            //The version number is already being hidden - do nothing.
            return
        }
        //Stop the version timer from getting in the way.
        VersionTimer?.invalidate()
        VersionTimer = nil
        let Interval = TimeInterval(0.5)
        UIView.animate(withDuration: Interval, delay: 0.0, options: .curveEaseIn, animations:
            {
                self.VersionLabelView.alpha = 0.0
                //If scaleX and y are set to 0.0, the version disappears immediately. Use a small, non-zero number to get around this.
                self.VersionLabelView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        },
                       completion:
            { _ in
                self.VersionLabelView.removeFromSuperview()
                self.VersionLabelView = nil
        })
    }
    
    /// Handle the time text visibility tap. When the screen is tapped, the textual time appears or disappears, depending on its
    /// previous state. This functionality is disabled depending on user settings.
    @objc func HandleMainUITap(sender: UITapGestureRecognizer)
    {
        #if false
        if sender.state != UIGestureRecognizer.State.ended
        {
            return
        }
        if sender.numberOfTapsRequired == 2
        {
            return
        }
        print("Taps required: \(sender.numberOfTapsRequired)")
        #endif
        let Location = sender.location(in: self.view!)
        print("Main UI tap at \(Location)")
        //If the side panel (eg, settings) is showing, ignore taps.
        if (delegate?.SidePanelShowing())!
        {
            delegate?.CollapseSidePanels!()
            return
        }
        
        if Location.y > LeftButton.frame.minY && Location.y < LeftButton.frame.maxY
        {
            HandleMenuTap()
            return
        }
        
        #if false
        let TimeTextPoint = self.TimeTextView.convert(Location, from: self.view!)
        if TimeTextView.bounds.contains(TimeTextPoint)
        {
            print("Tapped in time text.")
        }
        #endif
        
        if (CurrentClock?.HandlesTaps)!
        {
            CurrentClock?.WasTapped(At: Location)
        }
        #if false
        HandleTimeTap()
        #endif
        //HandleMenuTap()
        HandleVersionTap()
    }
    
    /// If the version number is visible, hide it via the tap. The version number label is permanently hidden as part
    /// of the animation closure when this tap is handled.
    func HandleVersionTap()
    {
        if !ShowingVersionNumber
        {
            return
        }
        VersionTimer?.invalidate()
        VersionTimer = nil
        let UIDynamicType = _Settings.integer(forKey: Setting.Key.UIDynamicMethod).Clamp(0, 2)
        AnimateVersionNumber(Method: UIDynamicType, Duration: 0.2)
        ShowingVersionNumber = false
    }
    
    #if false
    /// If enabled, hide or show the textual time in response to a tap on the screen.
    func HandleTimeTap()
    {
        if !_Settings.bool(forKey: Setting.Key.ShowTextualTime)
        {
            return
        }
        IgnoreChanges = true
        var OldShowing = _Settings.bool(forKey: Setting.Key.ShowingTime)
        OldShowing.toggle()
        _Settings.set(OldShowing, forKey: Setting.Key.ShowingTime)
        let UIDynamicType = _Settings.integer(forKey: Setting.Key.UIDynamicMethod).Clamp(0, 2)
        AnimateTextualTime(OldShowing ? .Show : .Hide, Method: UIDynamicType, Duration: OldShowing ? 0.3 : 1.0)
        IgnoreChanges = false
    }
    #endif
    
    /// If enabled, hide or show the menu buttons in response to a tap on the screen.
    func HandleMenuTap()
    {
        if _Settings.integer(forKey: Setting.Key.MenuButtonBehavior) != 0
        {
            return
        }
        var IsShowing = _Settings.bool(forKey: Setting.Key.MenuButtonShowing)
        IsShowing.toggle()
        _Settings.set(IsShowing, forKey: Setting.Key.MenuButtonShowing)
        let UIDynamicType = _Settings.integer(forKey: Setting.Key.UIDynamicMethod).Clamp(0, 2)
        let Duration: CGFloat = IsShowing ? 0.3 : 1.0
        AnimateMenuButtons(IsShowing ? AnimationActions.Show : AnimationActions.Hide, Method: UIDynamicType, Duration: Duration)
    }
    
    /// Holds the value that indicates the transition is to visible.
    var TransitionToVisible: Bool = true
    
    /// If true, the version number is being hidden and not available for the user to hide manually.
    var HidingVersionNumber: Bool = false
    
    enum AnimationActions
    {
        case Hide
        case Show
    }
    
    /// Animate the textual time.
    ///
    /// - Parameters:
    ///   - AnimateAction: Determines if the time is hidden or shown.
    ///   - Method: The animation method: 0 - no animation or transition; 1 - alpha animation; 3 - motion and alpha animation.
    ///   - Duration: Duration of the animation in seconds. Ignored if Method is 0.
    func AnimateTextualTime(_ AnimateAction: AnimationActions, Method: Int, Duration: CGFloat)
    {
        let Interval = TimeInterval(Duration)
        switch Method
        {
        case 0:
            //Alpha transition - no animations, alpha change takes effect immediately.
            TimeTextView.alpha = AnimateAction == .Show ? 1.0 : 0.0
            
        case 1:
            //Animated alpha transition.
            UIView.animate(withDuration: Interval, animations: {
                self.TimeTextView.alpha = AnimateAction == .Show ? 1.0 : 0.0
            })
            
        case 2:
            //Motion + animated alpha transition.
            print("Animating text time.")
            if AnimateAction == .Show
            {
                print("Show text time.")
                let delta = LastTimeY + abs(TimeTextView.center.y)
                let velocity = 100.0 / delta
                print("velocity is \(velocity), moving to \(LastTimeY) from \(TimeTextView.center.y)")
                UIView.animate(withDuration: Interval, delay: 0.0,
                               usingSpringWithDamping: 0.2, initialSpringVelocity: velocity,//1.0,
                    options: .curveEaseOut, animations: {
                        self.TimeTextView.center.y = self.LastTimeY
                        self.TimeTextView.alpha = 1.0
                })
            }
            else
            {
                print("Hiding text time. [\(TimeTextView.center.y)]")
                LastTimeY = TimeTextView.center.y
                let NewInterval = TimeInterval(0.25)
                #if false
                UIView.animate(withDuration: NewInterval, animations:
                    {
                        self.TimeTextView.center.y = -20
                        self.TimeTextView.alpha = 0.0
                })
                #else
                UIView.animate(withDuration: NewInterval, delay: 0.0, options: .curveEaseIn, animations: {
                    self.TimeTextView.center.y = -20
                    self.TimeTextView.alpha = 0.0
                },
                               completion:
                    {
                        finished in
                        print("Completed 0: \(self.TimeTextView.center.y)")
                        self.TimeTextView.center.y = -20
                        print("Completed 1: \(self.TimeTextView.center.y)")
                })
                #endif
            }
            
        default:
            TimeTextView.alpha = AnimateAction == .Show ? 1.0 : 0.0
        }
    }
    
    /// Animate the menu buttons.
    ///
    /// - Parameters:
    ///   - AnimateAction: Determines if the menu buttons are hidden or shown.
    ///   - Method: The animation method: 0 - no animation or transition; 1 - alpha animation; 3 - motion and alpha animation.
    ///   - Duration: Duration of the animation in seconds. Ignored if Method is 0.
    func AnimateMenuButtons(_ AnimateAction: AnimationActions, Method: Int, Duration: CGFloat)
    {
        let Interval = TimeInterval(Duration)
        switch Method
        {
        case 0:
            //Alpha transition - no animations, alpha change takes effect immediately.
            LeftButton.alpha = AnimateAction == .Show ? 1.0 : 0.0
            LeftButton.isEnabled = AnimateAction == .Show
            RightButton.alpha = AnimateAction == .Show ? 1.0 : 0.0
            RightButton.isEnabled = AnimateAction == .Show
            
        case 1:
            //Animated alpha transition.
            UIView.animate(withDuration: Interval, animations: {
                self.RightButton.alpha = AnimateAction == .Show ? 1.0 : 0.0
                self.LeftButton.alpha = AnimateAction == .Show ? 1.0 : 0.0
            },
                           completion:
                {
                    finished in
                    self.RightButton.isEnabled = AnimateAction == .Show
                    self.LeftButton.isEnabled = AnimateAction == .Show
            })
            
        case 2:
            //Motion + animated alpha transition.
            if AnimateAction == .Show
            {
                //print("LastLeftX: \(LastLeftX), LastRightX: \(LastRightX)")
                let LeftFudgeFactor = CGFloat.random(in: 0.0 ... 0.05)
                UIView.animate(withDuration: Interval, delay: 0.0,
                               usingSpringWithDamping: 0.2 + LeftFudgeFactor, initialSpringVelocity: 1.0,
                               options: .curveEaseOut, animations: {
                                self.LeftButton.alpha = 1.0
                                self.LeftButton.center.x = self.LastLeftX
                })
                let RightFudgeFactor = CGFloat.random(in: 0.0 ... 0.05)
                UIView.animate(withDuration: Interval, delay: 0.0,
                               usingSpringWithDamping: 0.2 + RightFudgeFactor, initialSpringVelocity: 1.0,
                               options: .curveEaseOut, animations: {
                                self.RightButton.alpha = 1.0
                                self.RightButton.center.x = self.LastRightX
                })
            }
            else
            {
                LastLeftX = LeftButton.center.x
                LastRightX = RightButton.center.x
                //print("LastLeftX: \(LastLeftX), LastRightX: \(LastRightX)")
                let NewInterval = TimeInterval(0.1)
                UIView.animate(withDuration: NewInterval, delay: 0.0, options: .curveEaseIn, animations: {
                    self.LeftButton.center.x = -30
                    self.RightButton.center.x = self.view.bounds.width + 30
                    self.LeftButton.alpha = 0.0
                    self.RightButton.alpha = 0.0
                })
                LeftButton.isEnabled = true
                RightButton.isEnabled = true
            }
            
        default:
            LeftButton.alpha = AnimateAction == .Show ? 1.0 : 0.0
            LeftButton.isEnabled = AnimateAction == .Show
            RightButton.alpha = AnimateAction == .Show ? 1.0 : 0.0
            RightButton.isEnabled = AnimateAction == .Show
        }
    }
    
    /// Animate the version number. The version number only animates "away" (or disappears) so no code is present to
    /// make it reappear once it is gone. The version number control is also removed and freed.
    ///
    /// - Parameters:
    ///   - Method: The method used to animated the version number.
    ///   - Duration: Duration of the animation.
    func AnimateVersionNumber(Method: Int, Duration: CGFloat)
    {
        print("Animating version number.")
        let Interval = TimeInterval(Duration)
        switch Method
        {
        case 0:
            //No animation or transition.
            if VersionLabelView == nil
            {
                return
            }
            HidingVersionNumber = true
            VersionLabelView.alpha = 0.0
            VersionLabelView.removeFromSuperview()
            VersionLabelView = nil
            
        case 1:
            //Alpha animation only.
            if VersionLabelView == nil
            {
                return
            }
            HidingVersionNumber = true
            UIView.animate(withDuration: Interval, animations:
                {
                    self.VersionLabelView.alpha = 0.0
            }, completion:
                {
                    _ in
                    self.VersionLabelView.removeFromSuperview()
                    self.VersionLabelView = nil
            })
            
        case 2:
            //Alpha and motion animation.
            if VersionLabelView == nil
            {
                return
            }
            HidingVersionNumber = true
            UIView.animate(withDuration: Interval, delay: 0.0, options: .curveEaseIn, animations:
                {
                    self.VersionLabelView.center.y = self.VersionLabelView.center.y + 50.0
                    self.VersionLabelView.alpha = 0.0
                    self.VersionLabelView.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
            },
                           completion:
                { _ in
                    self.VersionLabelView.removeFromSuperview()
                    self.VersionLabelView = nil
            })
            
        default:
            if VersionLabelView == nil
            {
                return
            }
            HidingVersionNumber = true
            VersionLabelView.alpha = 0.0
            VersionLabelView.removeFromSuperview()
            VersionLabelView = nil
        }
    }
    
    func InitializeUIElementLocations()
    {
        LastTimeY = TimeTextView.center.y
        LastLeftX = LeftButton.center.x
        LastRightX = RightButton.center.x
        print("TimeTextView.center=\(TimeTextView.center), .frame=\(TimeTextView.frame)")
        print("LeftButton=\(LeftButton.center), .frame=\(LeftButton.frame)")
        print("RightButton=\(RightButton.center), .frame=\(RightButton.frame)")
    }
    
    /// The last Y location of the textual time.
    var LastTimeY: CGFloat = 53.0
    
    /// The last X location of the left menu button.
    var LastLeftX: CGFloat = 7.0
    
    /// The last X location of the right menu button.
    var LastRightX: CGFloat = 320.0
    
    /// Handle screen size transitions, eg, rotations/orientation of the device.
    ///
    /// - Parameters:
    ///   - size: New screen size.
    ///   - coordinator: Passed along to the super class.
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator)
    {
        super.viewWillTransition(to: size, with: coordinator)
        UpdateTimeTextPosition(size)
        UpdateBackgroundSizes(size)
        CurrentClock?.UpdateViewPort(NewWidth: Int(size.width), NewHeight: Int(size.height))
        #if false
        ScreenWidth = size.width
        ScreenHeight = size.height
        NotTransitioned = true
        UpdateClockPosition(ScreenSize: size)
        #endif
    }
    
    private var WasPortrait: Bool? = nil
    private var OldScreenWidth: Int = -1
    private var OldScreenHeight: Int = -1
    private var OldTextLocation: Int = -1
    
    /// Update the position and size of the text time based on device orientation and user settings. If no device orientation
    /// changes have been made, no action is taken.
    ///
    /// - Parameter ScreenSize: Screen size.
    func UpdateTimeTextPosition(_ ScreenSize: CGSize)
    {
        var IsPortrait = false
        if ScreenSize.width > ScreenSize.height
        {
            IsPortrait = false
        }
        else
        {
            IsPortrait = true
        }
        var TextLocation = _Settings.integer(forKey: Setting.Key.TimeLocation)
        if TextLocation < 0 || TextLocation > 1
        {
            TextLocation = 0
        }
        
        let NotchOffset = CGFloat(_Settings.integer(forKey: Setting.Key.NotchOffset))
        let TextMargin = CGFloat(_Settings.integer(forKey: Setting.Key.TextMargins))
        let ClockSize = GetClockViewSize(ScreenSize)
        let HalfClock: CGFloat = ClockSize.width / 2.0
        let ClockTop = (ScreenSize.height / 2.0) - HalfClock
        let ClockBottom = ClockTop + ClockSize.height
        let ClockLeft = (ScreenSize.width / 2.0) - HalfClock
        let ClockRight = ClockLeft + ClockSize.width
        let Margins: CGFloat = CGFloat(_Settings.integer(forKey: Setting.Key.UIMargins))
        var TextWidth: CGFloat = 0.0
        var TextHeight: CGFloat = 0.0
        var TextX: CGFloat = 0.0
        var TextY: CGFloat = 0.0
        if IsPortrait
        {
            if TextLocation == 0
            {
                //Portrait mode top.
                TextWidth = ScreenSize.width - (Margins * 2.0)
                TextHeight = ClockTop - (Margins + TextMargin + NotchOffset)
                TextX = Margins
                TextY = Margins
            }
            else
            {
                //Portrait mode bottom.
                TextWidth = ScreenSize.width - (Margins * 2.0)
                TextHeight = ScreenSize.height - (ClockBottom + Margins + TextMargin)
                TextX = Margins
                TextY = ClockBottom + TextMargin
            }
        }
        else
        {
            if TextLocation == 0
            {
                //Landscape mode left.
                TextWidth = ClockLeft - (Margins + TextMargin + NotchOffset)
                TextHeight = ScreenSize.height - (Margins * 2.0)
                TextX = Margins
                TextY = Margins
            }
            else
            {
                //Landscape mode right.
                TextWidth = ScreenSize.width - (ClockRight + Margins + TextMargin)
                TextHeight = ScreenSize.height - (Margins * 2.0)
                TextX = ClockRight + TextMargin
                TextY = Margins
            }
        }
        let TextFrame: CGRect = CGRect(x: TextX, y: TextY, width: TextWidth, height: TextHeight)
        //print("New text frame: \(TextFrame), Portrait mode: \(IsPortrait), Text location: \(TextLocation)")
        TimeTextView.frame = TextFrame
        TimeTextView.bounds = CGRect(x: 0, y: 0, width: TextWidth, height: TextHeight)
    }
    
    func GetClockViewSize(_ ScreenSize: CGSize) -> CGSize
    {
        var Smallest = CGFloat(min(ScreenSize.width, ScreenSize.height))
        Smallest = Smallest - CGFloat(_Settings.integer(forKey: Setting.Key.UIMargins))
        return CGSize(width: Smallest, height: Smallest)
    }
    
    /// Update the position of the clock on the screen. Should be called in response to orientation changes.
    ///
    /// - Parameter ScreenSize: Size of the screen after the orientation change takes place.
    func UpdateClockPosition(ScreenSize: CGSize)
    {
        let Smallest = GetClockViewSize(ScreenSize)
        let SmallestHalf = Smallest.width / 2.0
        let NewFrame = CGRect(x: (ScreenSize.width / 2.0) - SmallestHalf,
                              y: (ScreenSize.height / 2.0) - SmallestHalf,
                              width: Smallest.width,
                              height: Smallest.height)
        ClockViewPort.frame = NewFrame
        ClockViewPort.bounds = CGRect(x: 0, y: 0, width: Smallest.width, height: Smallest.height)
        ViewPortBounds = ClockViewPort.bounds
        ViewPortFrame = ClockViewPort.frame
        UIApplication.shared.keyWindow!.bringSubviewToFront(ClockViewPort)
    }
    
    /// Update the background frames and bounds. Should be called when the device orientation changes.
    ///
    /// - Parameter ScreenSize: New screen size.
    func UpdateBackgroundSizes(_ ScreenSize: CGSize)
    {
        let NewFrame = CGRect(x: 0, y: 0, width: ScreenSize.width, height: ScreenSize.height)
        Background.Gradient.frame = NewFrame
        Background.Gradient.bounds = NewFrame
    }
    
    /// Current width of the screen. Initially populated in viewDidLoad and then maintained in viewWillTransition.
    var ScreenWidth: CGFloat? = nil
    /// Current height of the screen. Initially populated in viewDidLoad and then maintained in viewWillTransition.
    var ScreenHeight: CGFloat? = nil
    
    /// Dumps all filter names in CIFilter to the debug window.
    func DumpFilters()
    {
        let list = CIFilter.filterNames(inCategory: nil)
        for item in list
        {
            print(item)
        }
    }
    
    /// Flag that indicates whether the debug outline is shown around the time text and the barcode.
    var DoShowDebugOutline = false
    
    /// Toggle the outline for the main barcode and the time text.
    func DoToggleDebugOutline()
    {
        DoShowDebugOutline.toggle()
        DoSetOutline(To: DoShowDebugOutline)
    }
    
    /// Shows or hides an outline around certain objects on the screen.
    ///
    /// - Parameter To: True shows the outline, false hides the outline.
    func DoSetOutline(To: Bool)
    {
        ClockViewPort.layer.borderColor = To ? UIColor.red.cgColor : UIColor.clear.cgColor
        ClockViewPort.layer.borderWidth = To ? 2.0 : 0.0
        TimeTextView.layer.borderColor = To ? UIColor.yellow.cgColor : UIColor.clear.cgColor
        TimeTextView.layer.borderWidth = To ? 2.0 : 0.0
        if RightButton != nil
        {
            RightButton.layer.borderColor = To ? UIColor.blue.cgColor : UIColor.clear.cgColor
            RightButton.layer.borderWidth = To ? 2.0 : 0.0
        }
        if LeftButton != nil
        {
            LeftButton.layer.borderColor = To ? UIColor.blue.cgColor : UIColor.clear.cgColor
            LeftButton.layer.borderWidth = To ? 2.0 : 0.0
        }
    }
    
    /// Update the barcode, which ever is showing. Also check for actions to perform periodically.
    @objc func PeriodicUpdateUI()
    {
        let Now = Date()
        let Cal = Calendar.current
        let Seconds = Cal.component(.second, from: Now)
        let Minute = Cal.component(.minute, from: Now)
        Background.UpdateBackgroundColors()
        UpdateTextColors(Seconds: Seconds)
        //UpdateFancyText(Now)
        
        if Minute != LastMinute
        {
            //Check for things to do every minute.
            LastMinute = Minute
        }
        if Seconds != LastSecond
        {
            //Check for things to do every second
            LastSecond = Seconds
            CheckForDarkMode(Now)
        }
        if DidSettingChanged(_Settings.bool(forKey: Setting.Key.Debug.EnableBarcodeColorTests))
        {
            HandleBarcodeColorTests()
        }
    }
    
    func HandleBarcodeColorTests()
    {
        if CurrentClock == nil
        {
            return
        }
        if !(CurrentClock?.IsVectorBased)!
        {
            return
        }
        let Enable = _Settings.bool(forKey: Setting.Key.Debug.EnableBarcodeColorTests)
        if Enable
        {
            let Velocity = _Settings.integer(forKey: Setting.Key.Debug.BarcodeColorTestVelocity)
            var TestTime = TimeInterval(1.0)
            switch Velocity
            {
            case 0:
                TestTime = TimeInterval(1.0)
                
            case 1:
                let Nodes: Int = (CurrentClock?.VectorNodeCount)!
                print("Found \(Nodes) vector nodes.")
                TestTime = TimeInterval(1.0 / Double(Nodes))
                print("Test time: \(TestTime)")
                
            case 2:
                TestTime = TimeInterval(0.5)
                
            case 3:
                TestTime = TimeInterval(0.1)
                
            default:
                TestTime = TimeInterval(1.0)
            }
            BarcodeColorTestTimer = Timer.scheduledTimer(timeInterval: TestTime, target: self,
                                                         selector: #selector(HandleBarcodeColorTestTick), userInfo: nil, repeats: true)
        }
        else
        {
            BarcodeColorTestTimer?.invalidate()
            BarcodeColorTestTimer = nil
        }
    }
    
    @objc func HandleBarcodeColorTestTick()
    {
        
    }
    
    var BarcodeColorTestTimer: Timer? = nil
    
    func DidSettingChanged(_ NewValue: Bool) -> Bool
    {
        if OldEnableBarcodeColorTests == nil
        {
            OldEnableBarcodeColorTests = NewValue
            return true
        }
        if OldEnableBarcodeColorTests == NewValue
        {
            return false
        }
        OldEnableBarcodeColorTests = NewValue
        return true
    }
    
    var OldEnableBarcodeColorTests: Bool? = nil
    
    /// Determines if the passed date/time is within the user-specified dark mode time.
    ///
    /// - Parameters:
    ///   - Now: The time to verify against the user-specified dark mode time.
    ///   - DidTransition: Set to true if we're transitioning from one mode to another (eg, dark to non-dark, or non-dark to dark).
    /// - Returns: True if the passed date is in the user-specified dark mode time, false if not.
    func IsInDarkModeRange(_ Now: Date, DidTransition: inout Bool) -> Bool
    {
        let StartTime = _Settings.string(forKey: Setting.Key.DarkModeStartTime)
        let StartDate = Utility.SimpleStringToDate(StartTime!)
        let Duration = _Settings.integer(forKey: Setting.Key.DarkModeDuration)
        //print("\(Now), StartDate: \(StartDate!), Duration: \(Duration)")
        if Utility.InRange(Start: StartDate!, Duration: Duration, TestFor: Now)
        {
            //See if we're transitioning from not in dark mode to in dark mode
            if !InDarkMode
            {
                DidTransition = true
            }
            else
            {
                DidTransition = false
            }
            InDarkMode = true
            return true
        }
        else
        {
            //See if we're transitioning from in dark mode to not in dark mode
            if InDarkMode
            {
                DidTransition = true
            }
            else
            {
                DidTransition = false
            }
            InDarkMode = false
            return false
        }
    }
    
    /// Holds the last minute - used for minute-based events.
    var LastMinute: Int = -1
    
    /// Holds the last second - used for second-based events.
    var LastSecond: Int = -1
    
    /// Status that indicates whether the program is in dark mode or not.
    var InDarkMode: Bool = false
    
    var VaryingColor: UIColor!
    
    func UpdateTextColors(Seconds: Int)
    {
        
    }
    
    /// Variant levels for saturation and brightness for when in dark mode.
    let Variations = [0.75, 0.60, 0.40, 0.25]
    
    /// Create an array of text attributes that can be applied to an attributed string that include attributes for stroked text.
    ///
    /// - Parameters:
    ///   - Font: The font of the text.
    ///   - InteriorColor: The interior (fill) color of the text.
    ///   - StrokeColor: The stroke (exterior) color of the text.
    ///   - StrokeThickness: The thickness of the text.
    /// - Returns: Array of attributes that can be applied to an attributed string.
    func MakeOutlineTextAttributes(Font: UIFont, InteriorColor: UIColor, StrokeColor: UIColor, StrokeThickness: Int) -> [NSAttributedString.Key : Any]
    {
        let VColor: UIColor = (Background.BGColor1?.Color())!
        let FinalForegroundColor = Utility.FinalizeColor(InteriorColor, BaseColor: /*VaryingColor*/VColor, OfType: .TextInterior)
        let FinalOutlineColor = Utility.FinalizeColor(StrokeColor, BaseColor: /*VaryingColor*/VColor, OfType: .TextOutline)
        return [
            NSAttributedString.Key.foregroundColor: FinalForegroundColor,//InteriorColor,
            NSAttributedString.Key.strokeColor: FinalOutlineColor,//StrokeColor,
            NSAttributedString.Key.strokeWidth: -StrokeThickness,
            NSAttributedString.Key.font: Font
        ]
    }
    
    /// Create an array of text attributes that will be applied to an attributed string.
    ///
    /// - Parameters:
    ///   - Font: The font of the text.
    ///   - InteriorColor: The interior (fill) color of the text.
    /// - Returns: Array of attributes that can be applied to an attributed string.
    func MakeTextAttributes(Font: UIFont, InteriorColor: UIColor) -> [NSAttributedString.Key : Any]
    {
        let VColor: UIColor = (Background.BGColor1?.Color())!
        let FinalForegroundColor = Utility.FinalizeColor(InteriorColor, BaseColor: /*VaryingColor*/VColor, OfType: .TextInterior)
        return [
            NSAttributedString.Key.foregroundColor: FinalForegroundColor,//InteriorColor,
            NSAttributedString.Key.font: Font
        ]
    }
    
    public func OverWriteTimeText(_ WithString: String, DoLock: Bool)
    {
        UpdateFancyText(Date(), WithOverriddenText: WithString)
        DoLockOverriddenText = DoLock
    }
    
    var DoLockOverriddenText: Bool = false
    
    /// Update the time text.
    ///
    /// - Parameter Now: The time to use to update the text.
    func UpdateFancyText(_ Now: Date, WithOverriddenText: String = "")
    {
        #if true
        if !_Settings.bool(forKey: Setting.Key.ShowTextualTime)
        {
            return
        }
        if TimeTextView == nil
        {
            return
        }
        if DoLockOverriddenText
        {
            return
        }
        TimeFormatter.GetDisplayTime(Date(), Output: TimeTextView)
        #else
        if !_Settings.bool(forKey: Setting.Key.ShowTextualTime)
        {
            return
        }
        if TimeTextView == nil
        {
            return
        }
        if DoLockOverriddenText
        {
            return
        }
        let Cal = Calendar.current
        var Hour = Cal.component(.hour, from: Now)
        var AddAMPM = false
        var IsAM = false
        if !_Settings.bool(forKey: Setting.Key.Use24HourTime)
        {
            if Hour <= 12
            {
                IsAM = true
            }
            Hour = Hour % 12
            if _Settings.bool(forKey: Setting.Key.ShowAMPM)
            {
                AddAMPM = true
            }
        }
        let HourS = String(Hour)
        let Minute = Cal.component(.minute, from: Now)
        var MinuteS = String(Minute)
        if Minute < 10
        {
            MinuteS = "0" + MinuteS
        }
        let Second = Cal.component(.second, from: Now)
        var SecondS = String(Second)
        if Second < 10
        {
            SecondS = "0" + SecondS
        }
        var Message = HourS + ":" + MinuteS
        if _Settings.bool(forKey: Setting.Key.ShowSecondsInString)
        {
            Message = Message + ":" + SecondS
        }
        if AddAMPM
        {
            Message = Message + " " + String(IsAM ? Cal.amSymbol : Cal.pmSymbol)
        }
        
        //Calculate the font size and the position of the text. Both depend on the orientation of the device as well as the
        //type of device.
        let IsPad = UIDevice.current.userInterfaceIdiom == .pad
        var ClockFontName = "Avenir-Black"
//        if let FontName = _Settings.string(forKey: Setting.Key.TimeFontName)
        if let FontName = _Settings.string(forKey: Setting.Key.Text.FontName)
        {
            ClockFontName = FontName
        }
        #if true
        var Template = "00:00"
        if _Settings.bool(forKey: Setting.Key.ShowSecondsInString)
        {
            Template = Template + ":00"
        }
        if _Settings.bool(forKey: Setting.Key.ShowAMPM)
        {
            Template = Template + " AM"
        }
        if !WithOverriddenText.isEmpty
        {
            Template = WithOverriddenText
        }
        #if true
        //https://stackoverflow.com/questions/29914628/resize-text-to-fit-a-label-in-swift
        //https://stackoverflow.com/questions/8812192/how-to-set-font-size-to-fill-uilabel-height
        TimeTextView.adjustsFontSizeToFitWidth = true
        TimeTextView.minimumScaleFactor = 0.1
        TimeTextView.lineBreakMode = .byClipping
        TimeTextView.numberOfLines = _Settings.bool(forKey: Setting.Key.LandscapeTimeFitsSpace) ? 0 : 1
        var FontSize: CGFloat = 200.0
        #else
        var FontSize: CGFloat = Utility.RecommendedFontSize(HorizontalConstraint: TimeTextView.frame.width,
                                                            VerticalConstraint: TimeTextView.frame.height,
                                                            TheString: Template,
                                                            FontName: ClockFontName)
        #endif
        //print("Recommended font size: \(FontSize)")
        #else
        var FontSize: CGFloat = IsPad ? 110.0 : 80.0
        if !IsPad && AddAMPM
        {
            FontSize = 60.0
        }
        #endif
        if NotTransitioned
        {
            if ScreenWidth! > ScreenHeight!
            {
                #if true
                TimeTextView.adjustsFontSizeToFitWidth = true
                TimeTextView.minimumScaleFactor = 0.1
                TimeTextView.lineBreakMode = .byClipping
                TimeTextView.numberOfLines = _Settings.bool(forKey: Setting.Key.LandscapeTimeFitsSpace) ? 0 : 1
                FontSize = 200.0
                #else
                //In landscape mode.
                #if true
                //print("Frame width: \(TimeTextView.frame.width), Frame height: \(TimeTextView.frame.height)")
                FontSize = Utility.RecommendedFontSize(HorizontalConstraint: TimeTextView.frame.width,
                                                       VerticalConstraint: TimeTextView.frame.height,
                                                       TheString: Template,
                                                       FontName: ClockFontName)
                //print("Landscape mode font size: \(FontSize)")
                #else
                FontSize = IsPad ? 90.0 : 60.0
                #endif
                #endif
                if !IsPad
                {
                    let HFrame: CGRect = CGRect(x: 0.0/*InitialTimeTextFrame.minX*/, y: 20.0 /*15.0*/, width: ScreenWidth!, height: InitialTimeTextFrame.height)
                    TimeTextView.frame = HFrame
                }
            }
            else
            {
                //In portrait mode.
                if !IsPad
                {
                    TimeTextView.frame = InitialTimeTextFrame
                    //                print("TimeTextView.frame = \(TimeTextView.frame)")
                }
            }
            NotTransitioned = false
        }
        
        var Attributes: [NSAttributedString.Key: Any]!
        //print("Final FontSize: \(FontSize)")
        let TheFont = UIFont(name: ClockFontName, size: FontSize)
        
        if _Settings.bool(forKey: Setting.Key.ShowTextOutline)
        {
            var Thickness = _Settings.integer(forKey: Setting.Key.TextStrokeThickness)
            if Thickness < 1
            {
                Thickness = 2
                _Settings.set(Thickness, forKey: Setting.Key.TextStrokeThickness)
            }
            let OutlineColor = ExteriorColorForTimeText(Now)
            let InsideColor = InteriorColorForTimeText(Now)
            Attributes = MakeOutlineTextAttributes(Font: TheFont!,
                                                   InteriorColor: InsideColor,
                                                   StrokeColor: OutlineColor,
                                                   StrokeThickness: Thickness)
        }
        else
        {
            let InsideColor = InteriorColorForTimeText(Now)
            Attributes = MakeTextAttributes(Font: TheFont!, InteriorColor: InsideColor)
        }
        if !WithOverriddenText.isEmpty
        {
            Message = WithOverriddenText
        }
        else
        {
            //If the user set the rather obscure setting for time to fill vertial space when in landscape mode
            //and we're actually in landscape mode, break up the time by colons and insert new lines at each
            //colon and reassemble.
            if _Settings.bool(forKey: Setting.Key.LandscapeTimeFitsSpace) && !Utility.InPortraitOrientation()
            {
                let Parts = Message.split(separator: ":")
                Message = ""
                var Count = 0
                for SomePart in Parts
                {
                    var TextColon = ""
                    var EOL = ""
                    if Count < Parts.count - 1
                    {
                        TextColon = ":"
                        EOL = "\n"
                    }
                    Message = Message + String(SomePart) + TextColon + EOL
                    Count = Count + 1
                }
            }
        }
        TimeTextString = NSMutableAttributedString(string: Message, attributes: Attributes)
        TimeTextView.attributedText = TimeTextString
        /// TODO: Replace with proper key.
        if _Settings.bool(forKey: "BackgroundIsGradient")
        {
            TimeTextView.layer.zPosition = 1001
        }
        if _Settings.bool(forKey: Setting.Key.ShowTextShadow)
        {
            var ShadowSize = CGFloat(_Settings.double(forKey: Setting.Key.ShadowSize))
            if ShadowSize == 0.0
            {
                ShadowSize = 3.0
                _Settings.set(ShadowSize, forKey: Setting.Key.ShadowSize)
            }
            TimeTextView.layer.shadowColor = UIColor.black.cgColor
            TimeTextView.layer.shadowOffset = CGSize(width: ShadowSize, height: ShadowSize)
            TimeTextView.layer.shadowOpacity = 0.85
        }
        else
        {
            TimeTextView.layer.shadowColor = UIColor.clear.cgColor
            TimeTextView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
            TimeTextView.layer.shadowOpacity = 0.0
        }
        #endif
    }
    
    var NotTransitioned = true
    
    /// Returns the internal (fill) color for text based on the time and user settings.
    ///
    /// - Parameter Now: The time used to determine the color.
    /// - Returns: Color for the internal fill for text.
    func InteriorColorForTimeText(_ Now: Date) -> UIColor
    {
        switch _Settings.integer(forKey: Setting.Key.TextColor)
        {
        case 0:
            //Variable color - set to black just to have something to return.
            return UIColor.black
            
        case 1:
            //black
            return UIColor.black
            
        case 2:
            //white
            return UIColor.white
            
        default:
            return UIColor.black
        }
    }
    
    /// Returns the stroke/outline color for text based on time and user settings.
    ///
    /// - Parameter Now: The time used to determine the color.
    /// - Returns: Color for the stroke/outline for text.
    func ExteriorColorForTimeText(_ Now: Date) -> UIColor
    {
        switch _Settings.integer(forKey: Setting.Key.OutlineColor)
        {
        case 0:
            //Variable color - set to black just to have something to return.
            return UIColor.black
            
        case 1:
            //black
            return UIColor.black
            
        case 2:
            //white
            return UIColor.white
            
        default:
            return UIColor.black
        }
    }
    
    /// Mutable string to show time text.
    var TimeTextString: NSMutableAttributedString!
    
    /// Return the appropriate foreground color for the barcode.
    ///
    /// - Returns: Color to use as the foreground of the barcode.
    func MakeBarcodeForegroundColor() -> CIColor
    {
        let VColor = Background.BGColor1?.Color()
        let CodeColor = Utility.FinalizeColor(/*VaryingColor*/VColor!, BaseColor: UIColor.clear, OfType: .Barcode)
        return CIColor(color: CodeColor)
    }
    
    /// Return a user-specified color for the foreground element.
    ///
    /// - Returns: Color for the foreground element.
    func MakeBarcodeForegroundColor2() -> CIColor
    {
        var VColor: UIColor = UIColor.black
        switch _Settings.integer(forKey: Setting.Key.BarcodeForegroundColorMethod)
        {
        case 0:
            VColor = (Background.BGColor1?.Color())!
            
        case 1:
            VColor = UIColor.black
            
        case 2:
            VColor = UIColor.white
            
        case 3:
            VColor = _Settings.uicolor(forKey: Setting.Key.ElementForegroundColor)!
            
        default:
            VColor = UIColor.black
        }
        let BCColor = Utility.FinalizeForegroundColor(BaseColor: VColor, InDarkMode: _Settings.bool(forKey: Setting.Key.InDarkMode))
        return CIColor(color: BCColor)
    }
    
    /// Handle the view appearing. Hide the system status bar.
    ///
    /// - Parameter animated: Animation flag.
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        if _Settings.bool(forKey: Setting.Key.HideStatusBar)
        {
            print("Hiding status bar in MainUICode.")
            let StatusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
            StatusBar.isHidden = true
        }
    }
    
    /// Handle the view disappearing. Update system status bar visibility.
    ///
    /// - Parameter animated: Animation flag.
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        if _Settings.bool(forKey: Setting.Key.HideStatusBar)
        {
            let StatusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
            StatusBar.isHidden = false
        }
    }
    
    /// Handle a notification from the container view that the left-side panel is collapsing. For us,
    /// we rotate the left menu item back to its home position.
    func HandleLeftPanelCollapsing()
    {
        RotateButton(LeftButton, Degrees: 0.0)
    }
    
    /// Handle a notification from the container view that the right-side panel is collapsing. For us,
    /// we rotate the right menu item back to its home position.
    func HandleRightPanelCollapsing()
    {
        RotateButton(RightButton, Degrees: 0.0)
    }
    
    /// Rotate the passed button the specified number of degrees.
    ///
    /// - Parameters:
    ///   - Button: The button to rotate.
    ///   - Degrees: Number of degrees to rotate by. Set to 0.0 to rotate the button back to its original position.
    func RotateButton(_ Button: UIButton, Degrees: Double)
    {
        let Radians = CGFloat(Degrees) * CGFloat.pi / 180.0
        var Duration = _Settings.double(forKey: Setting.Key.ButtonRotationDuration)
        switch Duration
        {
        case 0.0:
            //No rotation, return
            return
            
        case 0.01:
            Duration = 0.0
            
        default:
            break
        }
        
        UIView.animate(withDuration: Duration, delay: 0.0,
                       usingSpringWithDamping: 0.65, initialSpringVelocity: 3,
                       options: .curveEaseInOut, animations:
            {
                Button.transform = CGAffineTransform(rotationAngle: Radians)
        })
    }
    
    /// Handle user touches on the left menu button. Button is rotated to help indicate the next action.
    ///
    /// - Parameter sender: The button that was pressed.
    @IBAction func HandleLeftButtonPressed(_ sender: Any)
    {
        RotateButton(sender as! UIButton, Degrees: 180.0)
        delegate?.ToggleLeftPanel!()
    }
    
    /// Handle user touches on the right menu button. Button is rotated to help indicate the next action.
    ///
    /// - Parameter sender: The button that was pressed.
    @IBAction func HandleRightButtonPressed(_ sender: Any)
    {
        RotateButton(sender as! UIButton, Degrees: -180.0)
        delegate?.ToggleRightPanel!()
    }
    
    /// Map of clocks to the amount of time (in seconds) they have been run.
    var ClockDurations = [UUID: Int]()
    
    /// Map of clocks to the number of instances they were run.
    var ClockInstanceExecutions = [UUID: Int]()
    
    /// Currently displaying clock.
    var CurrentClock: ClockProtocol? = nil
    
    /// Set the clock to display.
    ///
    /// - Parameter ClockID: ID of the clock to display.
    func SetClock(ClockID: UUID)
    {
        print("Setting clock to \(ClockID)")
        if ClockID == PreviousClockID
        {
            print("Trying to set clock to same clock ID - ignoring.")
            return
        }
        PreviousClockID = ClockID
        if let TheClock = RunTimeClockList![ClockID]
        {
            CurrentClock?.SetClockState(ToRunning: false, Animation: 0)
            CurrentClock = TheClock
            CurrentClock?.SetClockState(ToRunning: true, Animation: 0)
            _Settings.set(ClockID, forKey: Setting.Key.DisplayClock)
        }
        else
        {
            print("Did not find clock \(ClockID.uuidString) in clock list.")
        }
    }
    
    /// The ID of the previous clock. Used to prevent unnecessary instantiation.
    var PreviousClockID: UUID = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
    
    /// Given an ID, return the associated clock.
    ///
    /// - Parameter ID: The ID of the clock to return.
    /// - Returns: The clock whose ID is passed to us. Nil if not found.
    func GetClock(ID: UUID) -> ClockProtocol?
    {
        if let TheClock = RunTimeClockList![ID]
        {
            return TheClock
        }
        return nil
    }
    
    var OldViewPort: CGRect = CGRect.zero
    
    /// Create the clock list.
    func CreateClocks()
    {
        /*
         if OldViewPort != CGRect.zero
         {
         ClockViewPort.frame = OldViewPort
         ClockViewPort.bounds = OldViewPort
         }
         */
        RunTimeClockList = [UUID: ClockProtocol]()
        #if true
        let ViewingSize = UIScreen.main.bounds.size
        #else
        let ViewingSize = CGSize(width: ClockViewPort.frame.width, height: ClockViewPort.frame.height)
        #endif
        
        let BC128 = Barcode128Clock(SurfaceSize: ViewingSize)
        BC128.delegate = self
        RunTimeClockList![BC128.ClockID] = BC128
        
        let BCAztec = BarcodeAztecClock(SurfaceSize: ViewingSize)
        BCAztec.delegate = self
        RunTimeClockList![BCAztec.ClockID] = BCAztec
        
        let BCPDF = BarcodePDF417Clock(SurfaceSize: ViewingSize)
        BCPDF.delegate = self
        RunTimeClockList![BCPDF.ClockID] = BCPDF
        
        let BCQRCode = BarcodeQRClock(SurfaceSize: ViewingSize)
        BCQRCode.delegate = self
        RunTimeClockList![BCQRCode.ClockID] = BCQRCode
        
        let BCQR3DCode = BarcodeQRClock3D(SurfaceSize: ViewingSize)
        BCQR3DCode.delegate = self
        RunTimeClockList![BCQR3DCode.ClockID] = BCQR3DCode
        
        let RGC = RadialGradientClock(SurfaceSize: ViewingSize)
        RGC.delegate = self
        RunTimeClockList![RGC.ClockID] = RGC
        
        let Polar = PolarTextClock(SurfaceSize: ViewingSize)
        Polar.delegate = self
        RunTimeClockList![Polar.ClockID] = Polar
        
        let Pharma = Barcode1DClock(SurfaceSize: ViewingSize, BarcodeType: .Pharmacode)
        Pharma.delegate = self
        RunTimeClockList![Pharma.ClockID] = Pharma
        
        let POSTNET = Barcode1DClock(SurfaceSize: ViewingSize, BarcodeType: .POSTNET)
        POSTNET.delegate = self
        RunTimeClockList![POSTNET.ClockID] = POSTNET
        
        #if false
        let BCDM = BarcodeDataMatrixClock(SurfaceSize: ViewingSize)
        BCDM.delegate = self
        RunTimeClockList![BCDM.ClockID] = BCDM
        #endif
        
        let InitialClockType = _Settings.uuid(forKey: Setting.Key.DisplayClock)
        if let TheClock = RunTimeClockList![InitialClockType]
        {
            CurrentClock = TheClock
        }
        else
        {
            CurrentClock = BC128
            _Settings.set(BC128.ClockID, forKey: Setting.Key.DisplayClock)
        }
    }
    
    #if DEBUG
    var GridLayer: CAShapeLayer? = nil
    
    func ShowDebugGrid(_ ShowGrid: Bool, CalledFrom: String)
    {
        print("ShowDebugGrid(\(ShowGrid)), Called from \(CalledFrom)")
        if ShowGrid
        {
            if GridLayer != nil
            {
                return
            }
            
            print("Making grid layer")
            GridLayer = MakeGridLayer()
            if GridLayer != nil
            {
                view.layer.addSublayer(GridLayer!)
            }
        }
        else
        {
            if GridLayer == nil
            {
                return
            }
            GridLayer!.removeFromSuperlayer()
            GridLayer = nil
        }
    }
    
    /// Redraw the grid layer. Call when the orientation of the device changes. If the grid is not showing,
    /// no action is taken.
    func RedrawDebugGrid()
    {
        if GridLayer == nil
        {
            return
        }
        GridLayer!.removeFromSuperlayer()
        GridLayer = MakeGridLayer()
        if GridLayer != nil
        {
            view.layer.addSublayer(GridLayer!)
        }
    }
    
    /// Make a layer of grid lines and a transparent background.
    ///
    /// - Returns: Layer with grid lines. Nil if there is nothing to do.
    func MakeGridLayer() -> CAShapeLayer?
    {
        if !_Settings.bool(forKey: Setting.Key.Debug.ShowMinorGridLines) && _Settings.bool(forKey: Setting.Key.Debug.ShowMajorGridLines)
        {
            return nil
        }
        let Layer = CAShapeLayer()
        Layer.zPosition = 1000
        Layer.backgroundColor = UIColor.clear.cgColor
        let Width = UIScreen.main.bounds.width
        let Height = UIScreen.main.bounds.height
        Layer.frame = CGRect(x: 0, y: 0, width: Width, height: Height)
        
        var MinorGrid: CAShapeLayer? = nil
        if _Settings.bool(forKey: Setting.Key.Debug.ShowMinorGridLines)
        {
            let lc = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.4).cgColor
            MinorGrid = MakeGrid(Gap: _Settings.integer(forKey: Setting.Key.Debug.DebugMinorGridInterval),
                                 LineColor: lc,
                                 //                                 LineColor: (_Settings.uicolor(forKey: Setting.Key.Debug.DebugMinorGridLineColor)?.cgColor)!,
                Width: Width, Height: Height)
            MinorGrid?.zPosition = 100
        }
        var MajorGrid: CAShapeLayer? = nil
        if _Settings.bool(forKey: Setting.Key.Debug.ShowMajorGridLines)
        {
            let lc = UIColor(red: 0.9, green: 0.9, blue: 0.1, alpha: 0.5).cgColor
            MajorGrid = MakeGrid(Gap: _Settings.integer(forKey: Setting.Key.Debug.DebugMajorGridInterval),
                                 LineColor: lc,
                                 //                                 LineColor: (_Settings.uicolor(forKey: Setting.Key.Debug.DebugMajorGridLineColor)?.cgColor)!,
                Width: Width, Height: Height)
            MajorGrid?.zPosition = 200
        }
        if let MinorGrid = MinorGrid
        {
            Layer.addSublayer(MinorGrid)
        }
        if let MajorGrid = MajorGrid
        {
            Layer.addSublayer(MajorGrid)
        }
        
        return Layer
    }
    
    func MakeGrid(Gap: Int, LineColor: CGColor, Width: CGFloat, Height: CGFloat) -> CAShapeLayer
    {
        let Layer = CAShapeLayer()
        Layer.backgroundColor = UIColor.clear.cgColor
        Layer.frame = CGRect(x: 0, y: 0, width: Width, height: Height)
        let Lines = UIBezierPath()
        
        for X in 0 ..< Int(Width)
        {
            if X % Gap != 0
            {
                continue
            }
            Lines.move(to: CGPoint(x: CGFloat(X), y: 0))
            Lines.addLine(to: CGPoint(x: CGFloat(X), y: Height))
        }
        
        for Y in 0 ..< Int(Height)
        {
            if Y % Gap != 0
            {
                continue
            }
            Lines.move(to: CGPoint(x: 0, y: CGFloat(Y)))
            Lines.addLine(to: CGPoint(x: Width, y: CGFloat(Y)))
        }
        
        Layer.path = Lines.cgPath
        Layer.lineWidth = 2
        Layer.strokeColor = LineColor
        
        return Layer
    }
    #endif
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        let CurrentType = ClockTypeForSettings
        switch segue.identifier
        {
        case "ToPolarTextClockSettings":
            let Dest = segue.destination as? PolarClockSettingsNav
            Dest?.FromClock(CurrentType!)
            Dest?.MainDelegate = self
            
        case "ToQRCode3DSettings":
            let Dest = segue.destination as? QRCode3DSettingsNav
            Dest?.FromClock(CurrentType!)
            Dest?.MainDelegate = self
            
        case "ToQRCodeSettings":
            let Dest = segue.destination as? QRCodeSettingsNav
            Dest?.FromClock(CurrentType!)
            Dest?.MainDelegate = self
            
        case "ToCode128Settings":
            let Dest = segue.destination as? Code128SettingsNav
            Dest?.FromClock(CurrentType!)
            Dest?.MainDelegate = self
            
        case "ToAztecCodeSettings":
            let Dest = segue.destination as? AztecSettingsNav
            Dest?.FromClock(CurrentType!)
            Dest?.MainDelegate = self
            
        case "ToRadialGradientClockSettings":
            let Dest = segue.destination as? RadialGradientSettingsNav
            Dest?.FromClock(CurrentType!)
            Dest?.MainDelegate = self
            
        case "ToOneDBarcodeSettings":
            let Dest = segue.destination as? OneDBarcodeNav
            Dest?.FromClock(CurrentType!)
            Dest?.MainDelegate = self
            
        default:
            break
        }
        super.prepare(for: segue, sender: self)
    }
    
    var ClockTypeForSettings: PanelActions? = nil
    
    /// Run settings for the specified clock.
    ///
    /// - Parameter ID: ID of the clock to run settings for.
    public func RunSettingsForClock(ID: UUID)
    {
        if let TheClock = RunTimeClockList![ID]
        {
            print("Will run settings for \(ID)")
            if let SegueID = TheClock.SettingsSegueID()
            {
                ClockTypeForSettings = TheClock.GetClockType()
                performSegue(withIdentifier: SegueID, sender: self)
            }
            else
            {
                print("No segue ID provided.")
            }
        }
        else
        {
            print("No clock for ID \(ID)")
        }
    }
    
    /// Contains a dictionary of clocks keyed by their IDs.
    var RunTimeClockList: [UUID: ClockProtocol]? = nil
    
    /// View where clocks are displayed.
    @IBOutlet weak var ClockViewPort: UIView!
    /// Reference to the time text view control.
    @IBOutlet weak var TimeTextView: UILabel!
    /// Reference to the background view where the colors are shifted.
    @IBOutlet weak var BackgroundView: UIView!
    /// Center view controller delegate.
    var delegate: CenterViewControllerDelegate? = nil
    /// Right-side menu button.
    @IBOutlet weak var RightButton: UIButton!
    /// Left-side menu button.
    @IBOutlet weak var LeftButton: UIButton!
    /// Version data label.
    @IBOutlet weak var VersionDataLabel: UILabel!
    /// The view where the version label lives.
    @IBOutlet weak var VersionLabelView: UIView!
}

extension UIImageView
{
    func DropShadow()
    {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 3, height: 3)
        self.layer.shadowRadius = 3.0
        self.layer.shadowOpacity = 0.85
        self.layer.masksToBounds = false
        print("self.bounds = \(self.bounds)")
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
    }
}

// MARK: - Extension for side panel events.
extension MainUICode: SidePanelViewControllerDelegate
{
    /// Get an action from the side panel.
    ///
    /// - Parameter PanelAction: The action the user selected.
    func ActionTaken(PanelAction: PanelActions)
    {
        switch PanelAction
        {
        case PanelActions.NoAction:
            break
            
        case PanelActions.ClosePanel:
            delegate?.CollapseSidePanels?()
            
        case PanelActions.StopClock:
            SetClockState(ToRunning: false)
            
        case PanelActions.StartClock:
            SetClockState(ToRunning: true)
            
        default:
            break
        }
    }
    
    /// Set the run state of the main UI and clock. Both the text time and the clock are affected by
    /// setting the state. Background color animation will continue executing, however.
    ///
    /// - Parameter ToRunning: Set to true to put the clocks into the run state, false to stop the clocks.
    func SetClockState(ToRunning: Bool)
    {
        if ToRunning
        {
            //Start the timer for the textual clock.
            StartMainTimer()
            CurrentClock?.SetClockState(ToRunning: true, Animation: 0)
        }
        else
        {
            //Stop the timer for the textual clock.
            if MainTimer != nil
            {
                MainTimer.invalidate()
                MainTimer = nil
            }
            CurrentClock?.SetClockState(ToRunning: false, Animation: 0)
        }
    }
    
    /// Handle clock selection events from the left-side panel.
    ///
    /// - Parameter ClockID: ID of the clock the user selected.
    func SelectClockType(ClockID: UUID)
    {
        SetClock(ClockID: ClockID)
    }
}
