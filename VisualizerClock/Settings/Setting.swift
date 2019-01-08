//
//  SettingsHelper.swift
//  BarcodeTest
//
//  Created by Stuart Rankin on 8/12/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Helper data for settings.
class Setting: NSObject
{
    private static let InitializationFile = "Initialized.txt"
    
    /// Initialize the Setting class.
    ///
    /// - Parameter EnableChangeCounts: If true, setting changes are tracked.
    public static func Initialize(EnableChangeCounts: Bool = true)
    {
        OneTimeInitialization()
        if EnableChangeCounts
        {
            SettingUpdateTable = [String: (Int, Date)]()
            Observer = SettingsObserver()
        }
    }
    
    /// Returns an initialization record based on the sentinel settings file in the file structure.
    ///
    /// - Returns: Initialization record. The properties of the returned record are populated if the
    ///            file contains parsable data. Nil on error.
    public static func GetInitializationRecord () -> InitializationRecord?
    {
        let InitContents = FileUtility.FileContents(FileName: InitializationFile)
        if InitContents.isEmpty
        {
            return nil
        }
        let IR = InitializationRecord()
        if let Ver = XMLF.AttributeDouble(InitContents, Name: "Version")
        {
            IR.Version = Ver
        }
        if let BuildNum = XMLF.AttributeInt(InitContents, Name: "Build")
        {
            IR.BuildNumber = BuildNum
        }
        if let BuildID = XMLF.AttributeString(InitContents, Name: "BuildID")
        {
            IR.BuildID = UUID(uuidString: BuildID)!
        }
        if let BuildDate = XMLF.AttributeString(InitContents, Name: "BuildDate")
        {
            var DayComponent: String = ""
            var MonthComponent: String = ""
            var YearComponent: String = ""
            var HourComponent: String = ""
            var MinuteComponent: String = ""
            let Parts = BuildDate.split(separator: ",")
            var IsValid = true
            if Parts.count == 2
            {
                let DComponents = String(Parts.first!).split(separator: " ")
                if DComponents.count == 3
                {
                    DayComponent = String(DComponents[0])
                    MonthComponent = String(DComponents[1])
                    YearComponent = String(DComponents[2])
                }
                else
                {
                    IsValid = false
                }
                let TimeComponents = String(Parts.last!).split(separator: ":")
                if TimeComponents.count == 2
                {
                    HourComponent = String(TimeComponents[0])
                    MinuteComponent = String(TimeComponents[1])
                }
                else
                {
                    IsValid = false
                }
                
                if IsValid
                {
                    var Components = DateComponents()
                    Components.minute = Int(MinuteComponent)
                    Components.hour = Int(HourComponent)
                    Components.year = Int(YearComponent)
                    Components.day = Int(DayComponent)
                    Components.month = Utility.EnglishMonths.index(of: MonthComponent)
                    let Cal = Calendar.current
                    IR.BuildDate = Cal.date(from: Components)!
                }
            }
        }
        return IR
    }
    
    /// Write the Versioning XML contents to the intialization file in the Documents directory. This file
    /// serves as a sentinel that allows other code to determine if this is the first time the app has
    /// been run since initialization or not.
    private static func WriteInitializationFile()
    {
        let InitializedText = Versioning.EmitXML()
        FileUtility.WriteString(InitializedText, FileName: InitializationFile)
    }
    
    /// Hold the contents of the initialization file.
    private static var _InitializationContents: String = ""
    /// Get the contents of the initialization file. If no file found and not created or on error, empty string is returned.
    /// Additionally, if called before Setting.Initialize() is called, an empty string is returned.
    public static var InitializationContents: String
    {
        get
        {
            return _InitializationContents
        }
    }
    
    /// See if the initialization file exists in the Documents directory.
    ///
    /// - Returns: True if the file exists, false if not.
    private static func InitializationFileExists() -> Bool
    {
        let WasInitialized = FileUtility.FileExistsInDocuments(FileName: InitializationFile)
        if WasInitialized
        {
            _InitializationContents = FileUtility.FileContents(FileName: InitializationFile)
            #if DEBUG
            print("\(_InitializationContents)")
            #endif
        }
        return WasInitialized
    }
    
    /// Perform one-time initialization (first time run after being installed). To determine whether this is the
    /// first time being run since installation, we check for the existence of a file in the app's Documents
    /// directory. If the file exists, we assume this is _not_ the first time, and so defaults are not written
    /// to user settings. If the file does _not_ exists, we create it and write defaults to user settings.
    private static func OneTimeInitialization()
    {
        #if true
        //See if the initialization file exists. If it does, return without doing anything. If it doesn't,
        //write it and set default values for user settings.
        if InitializationFileExists()
        {
            #if DEBUG
            print("Found initialization file.")
            #endif
            return
        }
        else
        {
            #if DEBUG
            print("No initialization file found - creating file and setting user setting defaults.")
            #endif
            WriteInitializationFile()
        }
        #else
        if _Settings.bool(forKey: Setting.Key.WasRunPreviously)
        {
            //Already ran this at first instantiation - don't need to run again (and actually it would annoy the user if
            //this code ran again).
            return
        }
        
        print("Running one-time settings initialization.")
        #endif
        //Guard against resetting values with each run.
        _Settings.set(true, forKey: Setting.Key.WasRunPreviously)
        let Now = Date()
        let TheTime = Utility.MakeTimeString(TheDate: Now, IncludeSeconds: true)
        let TheDate = Utility.MakeDateStringFrom(Now)
        _Settings.set("\(TheDate), \(TheTime)", forKey: Setting.Key.InitializeTimeStamp)
        
        let IsSmall = UIScreen.main.bounds.size.width <= 320.0 ? true : false
        _Settings.set(IsSmall, forKey: Setting.Key.Device.IsSmallDevice)
        
        let Model = Utility.GetUserDeviceName()
        var NotchOffset: Int = 0
        if Utility.IsNotchedDevice(Model)
        {
            NotchOffset = 40
        }
        
        _Settings.set(true, forKey: Setting.Key.IncludeSeconds)
        _Settings.set(NotchOffset, forKey: Setting.Key.NotchOffset)
        _Settings.set(0, forKey: Setting.Key.PanelBackgroundType)
        _Settings.set(UIColor.white, forKey: Setting.Key.PanelBackgroundStaticColor)
        _Settings.set(0, forKey: Setting.Key.PanelBackgroundPattern)
        _Settings.set(UIColor(hue: 0.0, saturation: 0.0, brightness: 0.98, alpha: 1.0),
                      forKey: Setting.Key.PanelBackgroundPatternColor1)
        _Settings.set(UIColor.white, forKey: Setting.Key.PanelBackgroundPatternColor2)
        _Settings.set(1, forKey: Setting.Key.PanelBackgroundChangingColorVelocity)
        _Settings.set(UIColor.white, forKey: Setting.Key.PanelBackgroundChangeColor1)
        _Settings.set(UIColor.red, forKey: Setting.Key.PanelBackgroundChangeColor2)
        _Settings.set(true, forKey: Setting.Key.ShowTextualTime)
        
        _Settings.set(1, forKey: Setting.Key.LastCreatedBarcodeGroup)
        _Settings.set(0, forKey: Setting.Key.LastCreatedBarcodeType)
        
        _Settings.set(40, forKey: Setting.Key.UIMargins)
        _Settings.set(5, forKey: Setting.Key.TextMargins)
        _Settings.set(0, forKey: Setting.Key.TimeLocation)
        _Settings.set(UIColor.blue, forKey: Setting.Key.ElementForegroundColor)
        _Settings.set(true, forKey: Setting.Key.ShowSillyMessages)
        _Settings.set(2, forKey: Setting.Key.UIDynamicMethod)
        _Settings.set(true, forKey: Setting.Key.ShowSecondsInString)
        _Settings.set(true, forKey: Setting.Key.Use24HourTime)
        _Settings.set("18:00", forKey: Setting.Key.DarkModeStartTime)
        _Settings.set(60 * 60 * 12, forKey: Setting.Key.DarkModeDuration)
        _Settings.set(true, forKey: Setting.Key.DarkModeChangeBrightness)
        _Settings.set(1, forKey: Setting.Key.DarkModeRelativeBrightness)
        _Settings.set(false, forKey: Setting.Key.DarkModeChangeSaturation)
        _Settings.set(1, forKey: Setting.Key.DarkModeRelativeSaturation)
        _Settings.set(0.9, forKey: Setting.Key.StandardBGBrightness)
        _Settings.set(1.0, forKey: Setting.Key.StandardBGSaturation)
        _Settings.set(false, forKey: Setting.Key.HideStatusBar)
        _Settings.set(true, forKey: Setting.Key.StayAwake)
        _Settings.set(true, forKey: Setting.Key.UseScreenFormatting)
        _Settings.set(2, forKey: Setting.Key.OutlineColor)
        _Settings.set(1, forKey: Setting.Key.TextColor)
        _Settings.set(3.0, forKey: Setting.Key.ShadowSize)
        _Settings.set(2, forKey: Setting.Key.TextStrokeThickness)
        _Settings.set(false, forKey: Setting.Key.InDarkMode)
        _Settings.set(true, forKey: Setting.Key.MenuButtonShowing)
        _Settings.set(0.35, forKey: Setting.Key.ButtonRotationDuration)
        _Settings.set(true, forKey: Setting.Key.HideStatusBar)
        _Settings.set(1, forKey: Setting.Key.BarcodeForegroundColorMethod)
        _Settings.set(1.0, forKey: Setting.Key.Background.ColorDirection)
        _Settings.set(true, forKey: Setting.Key.ShowVersionOnMainScreen)
        _Settings.set(0.05, forKey: Setting.Key.BackgroundColors.BGColor1Hue)
        _Settings.set(0.9, forKey: Setting.Key.BackgroundColors.BGColor1Sat)
        _Settings.set(0.9, forKey: Setting.Key.BackgroundColors.BGColor1Bri)
        _Settings.set(false, forKey: Setting.Key.BackgroundColors.BGColor1IsGrayscale)
        _Settings.set(0.25, forKey: Setting.Key.BackgroundColors.BGColor2Hue)
        _Settings.set(0.9, forKey: Setting.Key.BackgroundColors.BGColor2Sat)
        _Settings.set(0.9, forKey: Setting.Key.BackgroundColors.BGColor2Bri)
        _Settings.set(false, forKey: Setting.Key.BackgroundColors.BGColor2IsGrayscale)
        _Settings.set(0.45, forKey: Setting.Key.BackgroundColors.BGColor3Hue)
        _Settings.set(0.9, forKey: Setting.Key.BackgroundColors.BGColor3Sat)
        _Settings.set(0.9, forKey: Setting.Key.BackgroundColors.BGColor3Bri)
        _Settings.set(false, forKey: Setting.Key.BackgroundColors.BGColor3IsGrayscale)
        _Settings.set(0.5, forKey: Setting.Key.BackgroundColors.BGColor2Location)
        _Settings.set(true, forKey: Setting.Key.BackgroundColors.AnimateBGSample)
        _Settings.set(true, forKey: Setting.Key.TapRemovesVersion)
        _Settings.set(false, forKey: Setting.Key.Debug.ShowDebugGrid)
        _Settings.set(100, forKey: Setting.Key.Debug.DebugMajorGridInterval)
        _Settings.set(25, forKey: Setting.Key.Debug.DebugMinorGridInterval)
        _Settings.set(true, forKey: Setting.Key.Debug.ShowMajorGridLines)
        _Settings.set(true, forKey: Setting.Key.Debug.ShowMinorGridLines)
        _Settings.set(UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.4), forKey: Setting.Key.Debug.DebugMinorGridLineColor)
        _Settings.set(UIColor(red: 0.9, green: 0.9, blue: 0.1, alpha: 0.5), forKey: Setting.Key.Debug.DebugMajorGridLineColor)
        _Settings.set(60, forKey: Setting.Key.ImpatientDelay)
        _Settings.set(true, forKey: Setting.Key.EnableImpatientUI)
        _Settings.set(0.45, forKey: Setting.Key.ImpatientMenuButtonInterval)
        
        _Settings.set("AvenirNext-UltraLight", forKey: Setting.Key.Text.FontName)
        _Settings.set(false, forKey: Setting.Key.Text.BlinkColons)
        _Settings.set(false, forKey: Setting.Key.Text.OutlineText)
        _Settings.set(true, forKey: Setting.Key.Text.ShowSeconds)
        _Settings.set(false, forKey: Setting.Key.Text.ShowAMPM)
        _Settings.set(true, forKey: Setting.Key.Text.LandscapeTimeFitsSpace)
        _Settings.set(0, forKey: Setting.Key.Text.HighlightType)
        _Settings.set(0, forKey: Setting.Key.Text.ShadowType)
        _Settings.set(0, forKey: Setting.Key.Text.GlowType)
        _Settings.set(1, forKey: Setting.Key.Text.OutlineThickness)
        _Settings.set(UIColor.black, forKey: Setting.Key.Text.Color)
        _Settings.set(UIColor.white, forKey: Setting.Key.Text.OutlineColor)
        _Settings.set(UIColor.black, forKey: Setting.Key.Text.ShadowColor)
        _Settings.set(UIColor.yellow, forKey: Setting.Key.Text.GlowColor)
        _Settings.set(UIColor.gold, forKey: Setting.Key.Text.SampleBackground)
        
        _Settings.set(1, forKey: Setting.Key.BackgroundColors.BackgroundColorCount)
        _Settings.set(true, forKey: Setting.Key.BackgroundColors.BGColor1IsDynamic)
        _Settings.set(true, forKey: Setting.Key.BackgroundColors.BGColor2IsDynamic)
        
        _Settings.set(0, forKey: Setting.Key.Background.BGType)
        
        _Settings.set(true, forKey: Setting.Key.RadialGradient.ShowSeconds)
        _Settings.set(false, forKey: Setting.Key.RadialGradient.ShowClockHandValues)
        _Settings.set(true, forKey: Setting.Key.RadialGradient.ShowCenterDot)
        _Settings.set(true, forKey: Setting.Key.RadialGradient.CenterDotPulsates)
        _Settings.set(false, forKey: Setting.Key.RadialGradient.SmoothMotion)
        _Settings.set(true, forKey: Setting.Key.RadialGradient.ShowHourNumerals)
        _Settings.set(true, forKey: Setting.Key.RadialGradient.TappingTogglesNumerals)
        _Settings.set(1, forKey: Setting.Key.RadialGradient.NumeralAnimationStyle)
        _Settings.set(0, forKey: Setting.Key.RadialGradient.NumeralAnimationDelay)
        _Settings.set(false, forKey: Setting.Key.RadialGradient.EnableNumeralColorAnimation)
        _Settings.set(InitialCenterBlob, forKey: Setting.Key.RadialGradient.CenterBlobDefiniton)
        _Settings.set(InitialHourBlob, forKey: Setting.Key.RadialGradient.HourBlobDefiniton)
        _Settings.set(InitialMinuteBlob, forKey: Setting.Key.RadialGradient.MinuteBlobDefiniton)
        _Settings.set(InitialSecondBlob, forKey: Setting.Key.RadialGradient.SecondBlobDefiniton)
        _Settings.set(0, forKey: Setting.Key.RadialGradient.HandShape)
        _Settings.set(false, forKey: Setting.Key.RadialGradient.ShowRadialLine)
        _Settings.set(0, forKey: Key.RadialGradient.GradientFilter)
        _Settings.set(0, forKey: Key.RadialGradient.CompositeBlendMode)
        
        _Settings.set(true, forKey: Setting.Key.IncludeDate)
        
        _Settings.set(0, forKey: Setting.Key.QRCode.NodeStyle)
        _Settings.set(UIColor.black, forKey: Setting.Key.QRCode.NodeColor)
        _Settings.set(UIColor(red: 64.0 / 255.0, green: 98.0 / 255.0, blue: 201.0 / 255.0, alpha: 1.0),
                      forKey: Setting.Key.QRCode.HighlightColor)
        _Settings.set(1.0, forKey: Setting.Key.QRCode.NodeSizeMultiplier)
        
        _Settings.set(UIColor.black, forKey: Setting.Key.Aztec.NodeColor)
        _Settings.set(UIColor.yellow, forKey: Setting.Key.Aztec.HighlightColor)
        
        _Settings.set(0, forKey: Setting.Key.QRCode3D.NodeShape)
        _Settings.set(UIColor(hue: 0.56389, saturation: 0.45, brightness: 0.38, alpha: 1.0), forKey: Setting.Key.QRCode3D.NodeDiffuseColor)
        _Settings.set(UIColor(hue: 0.5778, saturation: 0.06, brightness: 1.0, alpha: 1.0), forKey: Setting.Key.QRCode3D.NodeSpecularColor)
        _Settings.set(UIColor.white, forKey: Setting.Key.QRCode3D.NodeLightingColor)
        _Settings.set(45, forKey: Setting.Key.QRCode3D.DesiredFrameRate)
        
        _Settings.set(false, forKey: Setting.Key.Code128.BarcodeStroked)
        _Settings.set(UIColor.white, forKey: Setting.Key.Code128.BarcodeStrokeColor)
        _Settings.set(UIColor.black, forKey: Setting.Key.Code128.BarcodeForegroundColor1)
        _Settings.set(UIColor(red: 64.0 / 255.0, green: 98.0 / 255.0, blue: 201.0 / 255.0, alpha: 1.0),
                      forKey: Setting.Key.Code128.BarcodeForegroundColor2)
        _Settings.set(1, forKey: Setting.Key.Code128.BarcodeShape)
        _Settings.set(0.1, forKey: Setting.Key.Code128.InnerRadius)
        _Settings.set(0.9, forKey: Setting.Key.Code128.OuterRadius)
        _Settings.set(0.5, forKey: Setting.Key.Code128.BarcodeHeight)
        
        _Settings.set(false, forKey: Setting.Key.Pharma.BarcodeStroked)
        _Settings.set(UIColor.white, forKey: Setting.Key.Pharma.BarcodeStrokeColor)
        _Settings.set(UIColor.black, forKey: Setting.Key.Pharma.BarcodeForegroundColor1)
        _Settings.set(UIColor(red: 64.0 / 255.0, green: 98.0 / 255.0, blue: 201.0 / 255.0, alpha: 1.0),
                      forKey: Setting.Key.Pharma.BarcodeForegroundColor2)
        _Settings.set(0, forKey: Setting.Key.Pharma.BarcodeShape)
        _Settings.set(0.1, forKey: Setting.Key.Pharma.InnerRadius)
        _Settings.set(0.9, forKey: Setting.Key.Pharma.OuterRadius)
        _Settings.set(0.5, forKey: Setting.Key.Pharma.BarcodeHeight)
        _Settings.set(false, forKey: Setting.Key.Pharma.ColorsVaryByThickness)
        _Settings.set(UIColor.yellow, forKey: Setting.Key.Pharma.ThickForeground)
        _Settings.set(UIColor.gold, forKey: Setting.Key.Pharma.ThinForeground)
        
        _Settings.set(false, forKey: Setting.Key.POSTNET.BarcodeStroked)
        _Settings.set(UIColor.white, forKey: Setting.Key.POSTNET.BarcodeStrokeColor)
        _Settings.set(UIColor.black, forKey: Setting.Key.POSTNET.BarcodeForegroundColor1)
        _Settings.set(UIColor(red: 64.0 / 255.0, green: 98.0 / 255.0, blue: 201.0 / 255.0, alpha: 1.0),
                      forKey: Setting.Key.POSTNET.BarcodeForegroundColor2)
        _Settings.set(UIColor.yellow, forKey: Setting.Key.POSTNET.LongForeground)
        _Settings.set(UIColor.orange, forKey: Setting.Key.POSTNET.ShortForeground)
        _Settings.set(false, forKey: Setting.Key.POSTNET.ColorsVaryOnLength)
        _Settings.set(0, forKey: Setting.Key.POSTNET.BarcodeShape)
        _Settings.set(0.1, forKey: Setting.Key.POSTNET.InnerRadius)
        _Settings.set(0.9, forKey: Setting.Key.POSTNET.OuterRadius)
        _Settings.set(0.5, forKey: Setting.Key.POSTNET.BarcodeHeight)
        _Settings.set(true, forKey: Setting.Key.POSTNET.IncludeCheckDigit)
        
        _Settings.set(true, forKey: Setting.Key.Orbit.ShowOrbitalPaths)
        _Settings.set(1, forKey: Setting.Key.Orbit.CenterTimeType)
        _Settings.set(true, forKey: Setting.Key.Orbit.ShowSecondObject)
        _Settings.set(0, forKey: Setting.Key.Orbit.CenterValue)
        _Settings.set(true, forKey: Setting.Key.Orbit.Is2D)
        _Settings.set(false, forKey: Setting.Key.Orbit.ShowRadialLines)
        
        _Settings.set(0, forKey: Setting.Key.Polar.PolarType)
        _Settings.set("AvenirNext-UltraLight", forKey: Setting.Key.Polar.Font)
        _Settings.set(0, forKey: Setting.Key.Polar.TextShadow)
        _Settings.set(0, forKey: Setting.Key.Polar.TextGlow)
        _Settings.set(0, forKey: Setting.Key.Polar.TextStroked)
        _Settings.set(UIColor.black, forKey: Setting.Key.Polar.TextColor)
        _Settings.set(UIColor.black, forKey: Setting.Key.Polar.ShadowColor)
        _Settings.set(UIColor.yellow, forKey: Setting.Key.Polar.GlowColor)
        _Settings.set(UIColor.white, forKey: Setting.Key.Polar.StrokeColor)
        _Settings.set(true, forKey: Setting.Key.Polar.Is2D)
        _Settings.set(false, forKey: Setting.Key.Polar.DigitText)
        _Settings.set(true, forKey: Setting.Key.Polar.Smooth)
        _Settings.set(false, forKey: Setting.Key.Polar.ShowPolarGrid)
        _Settings.set(UIColor.black, forKey: Setting.Key.Polar.PolarGridColor)
        
        _Settings.set(true, forKey: Setting.Key.TextClock.Is2D)
        
        _Settings.set(false, forKey: Setting.Key.Sounds.GlobalEnable)
        _Settings.set(true, forKey: Setting.Key.Sounds.UseGlobalSounds)
        _Settings.set(0, forKey: Setting.Key.Sounds.GlobalVolume)
    }
    
    static let InitialCenterBlob = "<Gradient Radius=\"30.0\" Grayscale=\"False\" Type=\"0\" Colors=\"4\">0.0;255,255,255/0.33;255,255,0/0.67;255,127,0/1.0;255,0,0</Gradient>"
    static let InitialHourBlob = "<Gradient Radius=\"70.0\" Grayscale=\"False\" Type=\"1\" Colors=\"4\">0.0;255,0,0/0.33;0,0,0/0.67;255,255,0/1.0;0,0,0</Gradient>"
    static let InitialMinuteBlob = "<Gradient Radius=\"64.0\" Grayscale=\"False\" Type=\"2\" Colors=\"3\">0.0;255,127,0/0.5;255,255,255/1.0;0,0,255</Gradient>"
    static let InitialSecondBlob = "<Gradient Radius=\"40.0\" Grayscale=\"False\" Type=\"3\" Colors=\"3\">0.0;255,255,0/0.5;255,127,0/1.0;255,0,0</Gradient>"
    
    /// Setting notification name.
    public static let NotificationName: NSNotification.Name = NSNotification.Name("SettingNotice")
    
    /// Send a notice/message related to settings.
    ///
    /// - Parameters:
    ///   - Key: Key name.
    ///   - Value: Value contents.
    public static func SendNotice(Key: String, Value: String)
    {
        var Notice: [String : Any] = [ : ]
        Notice["Key"] = Key
        Notice["Value"] = Value
        NotificationCenter.default.post(name: Setting.NotificationName, object: nil, userInfo: Notice)
    }
    
    /// Settings observer class. Need an instantiated class (not static) in order for KVO to work.
    private static var Observer: SettingsObserver? = nil
    
    /// Called by the setting observer class when it detects a change.
    ///
    /// - Parameter Key: The key that was changed.
    public static func UpdateSettingChangeCount(Key: String)
    {
        if let (LastCount, _) = SettingUpdateTable[Key]
        {
            let NewCount = LastCount + 1
            SettingUpdateTable[Key] = (NewCount, Date())
            return
        }
        SettingUpdateTable[Key] = (1, Date())
    }
    
    /// Reset the contents of the setting changed table.
    public static func ResetSettingChangeTable()
    {
        SettingUpdateTable.removeAll()
    }
    
    /// Setting change table.
    static var SettingUpdateTable: [String: (Int, Date)]!
    
    /// User defaults.
    static let _Settings = UserDefaults.standard
    
    /// Key names for UserDefaults. This removes the possibility of typos making hard-to-find bugs.
    struct Key
    {
        /// Key names for user settings for the radial gradient clock.
        struct RadialGradient
        {
            /// Boolean. Show or hide the second hand blob.
            static let ShowSeconds = "RadialGradientClock_ShowSeconds"
            /// Boolean. Show or hide numerals that are superimposed over the blob hands.
            static let ShowClockHandValues = "RadialGradientClock_ShowClockHandValues"
            /// Boolean. Show or hide the hour numerals.
            static let ShowHourNumerals = "RadialGradientClock_ShowHourNumerals"
            /// Boolean. Show or hide the center blob dot.
            static let ShowCenterDot = "RadialGradientClock_ShowCenterDot"
            /// Boolean. Enable or disable center blob pulsation.
            static let CenterDotPulsates = "RadialGradientClock_CenterDotPulsates"
            /// Boolean. Enable or disable smooth motion.
            static let SmoothMotion = "RadialGradientClock_UseSmoothMotion"
            /// Boolean. Enable or disable hiding hour numerals by tapping the screen.
            static let TappingTogglesNumerals = "RadialGradientClock_TappingTogglesNumerals"
            /// Integer. Determines the animation to use to hide or show hour numerals.
            static let NumeralAnimationStyle = "RadialGradientClock_NumeralAnimationStyle"
            /// Integer. Determines the delay between individual animations of each numeral. Index
            /// into a table with the actual delay values.
            static let NumeralAnimationDelay = "RadialGradientClock_NumeralAnimationDelay"
            /// Bool. Enable or disable color animation on clock hour numerals.
            static let EnableNumeralColorAnimation = "RadialGradientClock_EnableNumeralAnimation"
            /// String. Definition (in terms of colors and size) of the center radial blob.
            static let CenterBlobDefiniton = "RadialGradientClock_CenterBlobDefinition"
            /// String. Definition (in terms of colors and size) of the hour radial blob.
            static let HourBlobDefiniton = "RadialGradientClock_HourBlobDefinition"
            /// String. Definition (in terms of colors and size) of the minute radial blob.
            static let MinuteBlobDefiniton = "RadialGradientClock_MinuteBlobDefinition"
            /// String. Definition (in terms of colors and size) of the second radial blob.
            static let SecondBlobDefiniton = "RadialGradientClock_SecondBlobDefinition"
            /// Integer. Determines the shape of the hands of a radial gradient clock.
            static let HandShape = "RadialGradientClock_HandShape"
            /// Boolean: Determines if a radial line from the center to the hand is shown.
            static let ShowRadialLine = "RadialGradientClock_ShowRadialLine"
            /// Integer. Determines the filter to apply to radial gradients after final composition. 0 = None, 1 = grayscale, 2 = circular mask
            static let GradientFilter = "RadialGradientClock_GradientFilter"
            /// Integer. Determines the blend mode to use when compositing radial gradients.
            /// 0 = .plusLighter, 1 = .screen, 2 = .multiply, 3 = .colorDodge, 4 = .luminosity, 5 = .softLight
            static let CompositeBlendMode = "RadialGradientClock_CompositeBlendMode"
        }
        
        /// Key names for user settings for the QR code clock.
        struct QRCode
        {
            /// Integer. Determines the shape of each node in the QR code.
            static let NodeStyle = "QRCode_NodeStyle"
            /// Integer. Determines the shadows for nodes for the QR code.
            static let ShadowLevel = "QRCode_ShadowLevel"
            /// UIColor. The color of the nodes.
            static let NodeColor = "QRCode_NodeColor"
            /// Double. The multiplier for node sizes.
            static let NodeSizeMultiplier = "QRCode_NodeSizeMultiplier"
            /// UIColor. The highlight color for QR Code barcodes.
            static let HighlightColor = "QRCode_HighlightColor"
            /// Integer. Special effects type.
            static let SpecialEffects = "QRCode_SpecialEffects"
        }
        
        /// Key names for user settings for the 3D QR code clock.
        struct QRCode3D
        {
            /// Integer. Determines the shape of each node in the 3D QR code.
            static let NodeShape = "QRCode3D_NodeShape"
            /// UIColor. Diffuse node color.
            static let NodeDiffuseColor = "QRCode3D_NodeDiffuseColor"
            /// UIColor. Specular node color.
            static let NodeSpecularColor = "QRCode3D_NodeSpecularColor"
            /// UIColor. Color of the illuminating light.
            static let NodeLightingColor = "QRCode3D_NodeLightingColor"
            /// Boolean. If true, nodes rotate in animation.
            static let NodeRotationAnimation = "QRCode3D_NodeRotationAnimation"
            /// Integer. Desired frames per second.
            static let DesiredFrameRate = "QRCode3D_DesiredFrameRate"
            /// Integer. Determines antialiasing for 3D scenes.
            static let AntialiasingType = "QRCode3D_Antialiasing"
        }
        
        /// Key names for user settings for the Aztec barcode clock.
        struct Aztec
        {
            /// UIColor. Color of the Aztec barcode nodes.
            static let NodeColor = "Aztec_NodeColor"
            /// UIColor. Color of highlighted Aztec barcode nodes.
            static let HighlightColor = "Aztec_HighlightColor"
            /// Integer. Style of highlighting.
            static let HighlightStyle = "Aztec_HighlightStyle"
            /// Integer. Determines the shape of individual Aztec barcode nodes.
            static let NodeStyle = "Aztec_NodeStyle"
            /// Integer. Determines the shadow level for Aztec barcode nodes.
            static let ShadowLevel = "Aztec_ShadowLevel"
        }
        
        /// Key names for user settings for the Code 128 barcode clock.
        struct Code128
        {
            /// Integer. Determines the shape of the barcode. 0 = linear, 1 = circular, 2 = target
            static let BarcodeShape = "Code128_BarcodeShape"
            /// Double. Determines the height of the barcode in terms of percent of available space.
            static let BarcodeHeight = "Code128_BarcodeHeight"
            /// Boolean. Determines if barcode nodes are stroked.
            static let BarcodeStroked = "Code128_BarcodeIsStroked"
            /// UIColor. Color of the stroke fro stroked barcodes.
            static let BarcodeStrokeColor = "Code128_BarcodeStokeColor"
            /// UIColor. Standard foreground color for barcode nodes.
            static let BarcodeForegroundColor1 = "Code128_ForegroundColor1"
            /// UIColor. Highlight foreground color for barcode nodes.
            static let BarcodeForegroundColor2 = "Code128_ForegroundColor2"
            /// Integer. Determines the shadow effect (if any).
            static let ShadowEffect = "Code128_ShadowEffect"
            /// Integer. Determines the special effect.
            static let SpecialEffect = "Code128_SpecialEffect"
            /// Double. Inner radius of circular barcodes in percent available space.
            static let InnerRadius = "Code128_InnerRadius"
            /// Double. Outer radius of circular barcodes in percent available space. If linear barcode, determines height of
            /// the barcode in terms of percent of available space.
            static let OuterRadius = "Code128_OuterRadius"
            /// Integer. Determines if the heights of bars of the barcode vary in height along a sinusoidal line over time.
            static let WavyHeights = "Code128_WavyHeights"
        }
        
        /// Key names for user settings for the Pharmacode barcode clock.
        struct Pharma
        {
            /// Integer. Determines the shape of the barcode. 0 = linear, 1 = circular, 2 = target
            static let BarcodeShape = "Pharma_BarcodeShape"
            /// Double. Determines the height of the barcode in terms of percent of available space.
            static let BarcodeHeight = "Pharma_BarcodeHeight"
            /// Boolean. Determines if barcode nodes are stroked.
            static let BarcodeStroked = "Pharma_BarcodeIsStroked"
            /// UIColor. Color of the stroke fro stroked barcodes.
            static let BarcodeStrokeColor = "Pharma_BarcodeStokeColor"
            /// UIColor. Standard foreground color for barcode nodes.
            static let BarcodeForegroundColor1 = "Pharma_ForegroundColor1"
            /// UIColor. Highlight foreground color for barcode nodes.
            static let BarcodeForegroundColor2 = "Pharma_ForegroundColor2"
            /// Integer. Determines the shadow effect (if any).
            static let ShadowEffect = "Pharma_ShadowEffect"
            /// Integer. Determines the special effect.
            static let SpecialEffect = "Pharma_SpecialEffect"
            /// Double. Inner radius of circular barcodes in percent available space.
            static let InnerRadius = "Pharma_InnerRadius"
            /// Double. Outer radius of circular barcodes in percent available space. If linear barcode, determines height of
            /// the barcode in terms of percent of available space.
            static let OuterRadius = "Pharma_OuterRadius"
            /// Integer. Determines if the heights of bars of the barcode vary in height along a sinusoidal line over time.
            static let WavyHeights = "Pharma_WavyHeights"
            /// Boolean. Determines if digits are included as part of the barcode.
            static let IncludeDigits = "Pharma_IncludeDigits"
            /// Boolean. Determines if colors vary depending on the thickness of the bar.
            static let ColorsVaryByThickness = "Pharma_ColorsVaryByThickness"
            /// UIColor. The color of thick barcode lines (if ColorsVaryOnLength is true).
            static let ThickForeground = "Pharma_LongForeground"
            /// UIColor. The color of Thin barcode lines (if ColorsVaryOnLength is true).
            static let ThinForeground = "Pharma_ShortForeground"
        }
        
        /// Key names for user settings for the USPS POSTNET barcode clock.
        struct POSTNET
        {
            /// Integer. Determines the shape of the barcode. 0 = linear, 1 = circular, 2 = target
            static let BarcodeShape = "POSTNET_BarcodeShape"
            /// Double. Determines the height of the barcode in terms of percent of available space.
            static let BarcodeHeight = "POSTNET_BarcodeHeight"
            /// Boolean. Determines if barcode nodes are stroked.
            static let BarcodeStroked = "POSTNET_BarcodeIsStroked"
            /// UIColor. Color of the stroke fro stroked barcodes.
            static let BarcodeStrokeColor = "POSTNET_BarcodeStokeColor"
            /// UIColor. Standard foreground color for barcode nodes.
            static let BarcodeForegroundColor1 = "POSTNET_ForegroundColor1"
            /// UIColor. Highlight foreground color for barcode nodes.
            static let BarcodeForegroundColor2 = "POSTNET_ForegroundColor2"
            /// Integer. Determines the shadow effect (if any).
            static let ShadowEffect = "POSTNET_ShadowEffect"
            /// Integer. Determines the special effect.
            static let SpecialEffect = "POSTNET_SpecialEffect"
            /// Double. Inner radius of circular barcodes in percent available space.
            static let InnerRadius = "POSTNET_InnerRadius"
            /// Double. Outer radius of circular barcodes in percent available space. If linear barcode, determines height of
            /// the barcode in terms of percent of available space.
            static let OuterRadius = "POSTNET_OuterRadius"
            /// Integer. Determines if the heights of bars of the barcode vary in height along a sinusoidal line over time.
            static let WavyHeights = "POSTNET_WavyHeights"
            /// Boolean. Determines if the check digit is included.
            static let IncludeCheckDigit = "POSTNET_IncludeCheckDigit"
            /// UIColor. The color of long barcode lines (if ColorsVaryOnLength is true).
            static let LongForeground = "POSTNET_LongForeground"
            /// UIColor. The color of short barcode lines (if ColorsVaryOnLength is true).
            static let ShortForeground = "POSTNET_ShortForeground"
            /// Boolean. Determines if different colors are applied to long and short barcode lines.
            static let ColorsVaryOnLength = "POSTNET_ColorsVaryOnLength"
        }
        
        /// Key names for orbital clock attributes the user can change.
        struct Orbit
        {
            /// Boolean. Determines if orbital paths are shown.
            static let ShowOrbitalPaths = "Orbit_ShowOrbitalPaths"
            /// Integer. Determines the type of center type. 0 = Hour, 1 = Day, 2 = Week, 3 = Year. This also indirectly controls
            /// the number of objects drawn. 0 = Minute + Second, 1 = Hour + Minute + Second, 2 = Day + Hour + Minute + Second,
            /// 3 = Week + Day + Hour + Minute + Second.
            static let CenterTimeType = "Orbit_CenterTimeType"
            /// Boolean. Determines if the object representing seconds is shown. Overrides CenterTimeType.
            static let ShowSecondObject = "Orbit_ShowSecondObject"
            /// Integer. Determines whether to show a center value, and if so, what value. 0 = None, 1 = Percent of time type, 2 = Actual time type.
            static let CenterValue = "Orbit_CenterValue"
            /// Boolean. Determines if the view is 2D or 3D.
            static let Is2D = "Orbit_Is2D"
            /// Integer. Determines the type of orbital object. 0 = Circle/sphere, 1 = Radial gradient/glow, 2 = Percentage, 3 = Actual value
            static let ObjectTypes = "Orbit_ObjectTypes"
            /// Boolean. Show radial lines from child to parent objects.
            static let ShowRadialLines = "Orbit_ShowRadialLines"
        }
        
        /// Key names for polar clock attributes the user can change.
        struct Polar
        {
            /// Integer. Determines the type of polar clock. 0 = Lines, 1 = Radiant text, 2 = Arc text
            static let PolarType = "Polar_RadialType"
            /// String. Name of the font to use for text.
            static let Font = "Polar_RadialFont"
            /// Integer. Determines the type of shadow to use.
            static let TextShadow = "Polar_RadialTextShadow"
            /// Integer. Determines the type of glow to use.
            static let TextGlow = "Polar_RadialTextGlow"
            /// Integer. Determines if text is stroked.
            static let TextStroked = "Polar_TextIsStroked"
            /// UIColor. The color of the text.
            static let TextColor = "Polar_TextColor"
            /// UIColor. The color of the shadow.
            static let ShadowColor = "Polar_RadialShadowColor"
            /// UIColor. The color of the glow.
            static let GlowColor = "Polar_RadialGlowColor"
            /// UIColor. The color of the stroke for text.
            static let StrokeColor = "Polar_RadialStrokeColor"
            /// Boolean. Determines if the view is 2D or 3D.
            static let Is2D = "Polar_Is2D"
            /// Boolean. Determines if text consists of words or numeric digits.
            static let DigitText = "Polar_DigitText"
            /// Boolean. Sets smooth or discrete motion.
            static let Smooth = "Polar_Smooth"
            /// Boolean. Determines if a polar grid is shown.
            static let ShowPolarGrid = "Polar_ShowPolarGrid"
            /// UIColor. Color of the polar grid.
            static let PolarGridColor = "Polar_GridColor"
        }
        
        /// Key names for the text clock, which is mostly the normal textual time, just displayed bigger.
        struct TextClock
        {
            /// Boolean. Determines if the view is 2D or 3D.
            static let Is2D = "TextClock_Is2D"
        }
        
        /// Key names for device-related settings that probably don't change on a device-by-device level (eg, once they're set,
        /// they stay the same).
        struct Device
        {
            /// Integer. Set at initial install time. General information about the device size. If true, the device is
            /// small so certain adjustments may have to be made to the UI or display.
            static let IsSmallDevice = "IsSmallDevice"
        }
        
        /// Key names for sound-related settings.
        struct Sounds
        {
            /// Boolean. Enables or disables all sounds.
            static let GlobalEnable = "Sounds_GlobalEnable"
            /// Boolean. Determines if global or clock-specific sounds are used.
            static let UseGlobalSounds = "Sounds_UseGlobal"
            /// String. Name of the global tick-tock sound.
            static let GlobalTick = "Sounds_GlobalTick"
            /// Integer. Volume of global sounds.
            static let GlobalVolume = "Sounds_GlobalVolume"
        }
        
        /// Key names for textual time attributes.
        struct Text
        {
            /// String. Name of the font to display the time.
            static let FontName = "Text_FontName"
            /// Boolean. Determines if colons blink.
            static let BlinkColons = "Text_BlinkColons"
            /// Boolean. Deterimes if seconds are shown in the time.
            static let ShowSeconds = "Text_ShowSeconds"
            /// Boolean. Determines if the AM/PM indicator is shown in the time.
            static let ShowAMPM = "Text_ShowAMPM"
            /// Boolean. Determines if the text is stroked (eg, outlined).
            static let OutlineText = "Text_OutlineText"
            /// Boolean. Determines how to fit text when in landscape mode.
            static let LandscapeTimeFitsSpace = "Text_LandscapeFitsText"
            /// Integer. Determines the highlight type. 0 = none, 1 = shadow, 2 = glow.
            static let HighlightType = "Text_HighlightType"
            /// Integer. Determines the shadow type. 0 = none, 1 = light, 2 = medium, 3 = heavy.
            static let ShadowType = "Text_ShadowType"
            /// Integer. Determines the glow type. 0 = none, 1 = light, 2 = medium, 3 = heavy.
            static let GlowType = "Text_GlowType"
            /// UIColor. The color of the text.
            static let Color = "Text_Color"
            /// Integer. Thickness of the outline of stroked text.
            static let OutlineThickness = "Text_OutlineThickness"
            /// UIColor. The color of the stroke of the text (when enabled).
            static let OutlineColor = "Text_OutlineColor"
            /// UIColor. The color of the shadow of the text (when enabled).
            static let ShadowColor = "Text_ShadowColor"
            /// UIColor. The color of the glow of the text (when enabled).
            static let GlowColor = "Text_GlowColor"
            /// Boolean. Determines time style to use.
            static let Use24HourTime = "Text_Use24HourTime"
            /// UIColor. Color of the sample background.
            static let SampleBackground = "Text_SampleBackground"
        }
        
        /// Keys related to the background.
        struct Background
        {
            /// Integer. Determines the background type. 0 = Gradient.
            static let BGType = "Background_BGType"
            /// Integer. Determines how to create the background gradient.
            static let GradientVarianceType = "Background_GradientVarianceType"
            /// Integer. The period of time to finish one color cycle.
            static let ColorTimePeriod = "Background_TimePeriod"
            /// Integer. Determines the style to use for color backgrounds.
            static let BackgroundColorStyle = "Background_BackgroundColorStyle"
            /// Double. Hue variance for gradient color calculations.
            static let HueVariance = "Background_HueVariance"
            /// Double. Saturation variance for gradient color calculations.
            static let SaturationVariance = "Background_SaturationVariance"
            /// Double. Brightness variance for gradient color calculations.
            static let BrightnessVariance = "Background_BrightnessVariance"
            /// Boolean. Determines if colors cycle through the hue circle.
            static let ColorsChange = "Background_ChangeColors"
            /// Double. Angle offset to use for color calculations.
            static let AngleOffset = "Background_StartingAngle"
            /// Double. Determines the direction of the color changes: 1.0 for forward, -1.0 for backward.
            static let ColorDirection = "Background_ColorDirection"
        }
        
        /// Background color keys.
        struct BackgroundColors
        {
            /// Integer. Number of background colors.
            static let BackgroundColorCount = "BackgroundColorCount"
            /// Double. Background color 1 hue value.
            static let BGColor1Hue = "BGColor1Hue"
            /// Double. Background color 1 saturation value.
            static let BGColor1Sat = "BGColor1Sat"
            /// Double. Background color 1 brightness value.
            static let BGColor1Bri = "BGColor1Bri"
            /// Bool. Background color 1 is grayscale.
            static let BGColor1IsGrayscale = "BGColor1IsGrayscale"
            /// Integer. Background color 1 direction. 0 = forward, 1 = backward
            static let BGColor1Direction = "BGColor1Direction"
            /// Bool. Background color 1 changes over time.
            static let BGColor1IsDynamic = "BGColor1IsDynamic"
            /// Integer. Background color 1 time period.
            static let BGColor1TimePeriod = "BGColor1TimePeriod"
            /// Double. Background color 2 hue value.
            static let BGColor2Hue = "BGColor2Hue"
            /// Double. Background color 2 saturation value.
            static let BGColor2Sat = "BGColor2Sat"
            /// Double. Background color 2 brightness value.
            static let BGColor2Bri = "BGColor2Bri"
            /// Bool. Background color 2 is grayscale.
            static let BGColor2IsGrayscale = "BGColor2IsGrayscale"
            /// Integer. Background color 2 direction. 0 = forward, 1 = backward
            static let BGColor2Direction = "BGColor2Direction"
            /// Bool. Background color 2 changes over time.
            static let BGColor2IsDynamic = "BGColor2IsDynamic"
            /// Integer. Background color 2 time period.
            static let BGColor2TimePeriod = "BGColor2TimePeriod"
            /// Double. Relative location of the second (eg, middle) background color.
            static let BGColor2Location = "BGColor2Location"
            /// Double. Background color 3 hue value.
            static let BGColor3Hue = "BGColor3Hue"
            /// Double. Background color 3 saturation value.
            static let BGColor3Sat = "BGColor3Sat"
            /// Double. Background color 3 brightness value.
            static let BGColor3Bri = "BGColor3Bri"
            /// Bool. Background color 3 is grayscale.
            static let BGColor3IsGrayscale = "BGColor3IsGrayscale"
            /// Integer. Background color 3 direction. 0 = forward, 1 = backward
            static let BGColor3Direction = "BGColor3Direction"
            /// Bool. Background color 3 changes over time.
            static let BGColor3IsDynamic = "BGColor3IsDynamic"
            /// Integer. Background color 3 time period.
            static let BGColor3TimePeriod = "BGColor3TimePeriod"
            /// Bool. Background colors sample animated flag.
            static let AnimateBGSample = "AnimateBGSample"
        }
        
        /// UUID. The last clock type used.
        static let DisplayClock = "DisplayClock"
        /// Boolean. Show the time as text on the screen.
        static let ShowTextualTime = "ShowTextualTime"
        /// Boolean. Show silly messages when the app becomes and resigns active.
        static let ShowSillyMessages = "ShowSillyMessages"
        /// Boolean. Blink colons periodically.
        static let BlinkColons = "BlinkColons"
        /// Boolean. Show seconds in the text time.
        static let ShowSecondsInString = "SecondsInTimeString"
        
        /// Boolean. Stores a flag that indicates if the program has run previous to the current instantiation. Used to set initial flag values.
        static let WasRunPreviously = "WasRunPreviously"
        /// Boolean. If true, certain objects on the screen are outlined.
        static let OutlineObjects = "OutlineObjects"
        /// Boolean. Determines if hours are in 24 or 12 hour mode.
        static let Use24HourTime = "24HourTime"
        /// Boolean. Flag used to resume the state of time visibility.
        static let ShowingTime = "ShowingTime"
        /// Boolean. Stores the flag that determines whether the AM/PM indicator is shown on the text time.
        static let ShowAMPM = "ShowAMPM"
        /// Boolean. If true, the time in landscape mode stretches vertically to fit available space. If false, it does a best fit for available horizontal space.
        static let LandscapeTimeFitsSpace = "LandscapeTimeFitsSpace"
        /// Boolean. Determines if dark mode is enabled.
        static let EnableDarkMode = "EnableDarkMode"
        /// String. When to start dark mode if enabled, in seconds past midnight.
        static let DarkModeStartTime = "DarkModeStartTime"
        /// Integer. How long to stay in dark mode, in seconds, once it has started.
        static let DarkModeDuration = "DarkModeDuration"
        /// Boolean. Enable dark mode brightness variations.
        static let DarkModeChangeBrightness = "EnableDarkModeBrightness"
        /// Boolean. Enable dark mode saturation variations.
        static let DarkModeChangeSaturation = "EnableDarkModeSaturation"
        /// Double. Dark mode brightness variation level.
        static let DarkModeRelativeBrightness = "DarkModeRelativeBrightness"
        /// Double. Dark mode saturation variation level.
        static let DarkModeRelativeSaturation = "DarkModeRelativeSaturation"
        /// Double. Value for background color brightness used when not in dark mode.
        static let StandardBGBrightness = "StandardBGBrightness"
        /// Double. Value for background color saturation used when not in dark mode.
        static let StandardBGSaturation = "StandardBGSaturation"
        /// Boolean. Setting that tells the program to hide the system status bar or not.
        static let HideStatusBar = "HideStatusBar"
        /// Boolean. Setting that tells the program to stay awake if plugged into a power source.
        static let StayAwake = "StayAwake"
        /// Boolean. Setting for showing or hiding shadows under the textual time.
        static let ShowTextShadow = "ShowTimeTextShadow"
        /// Boolean. Determines if the textual time is outlined or not.
        static let ShowTextOutline = "ShowTimeTextOutline"
        /// Boolean. Use the same formatting for barcode encoding as the textual time.
        static let UseScreenFormatting = "UseScreenFormatting"
        /// Boolean. Include the date when encoding the barcode.
        static let IncludeDate = "IncludeDate"
        /// Boolean. Include the weekday with dates when encoding barcodes.
        static let IncludeWeekday = "IncludeWeekday"
        /// Boolean. Include seconds in the time when encoding barcodes.
        static let IncludeSeconds = "IncludeSeconds"
        /// Integer. Order of data in the encoded barcode.
        static let EncodingOrder = "EncodingOrder"
        /// Integer. Determines the color of textual outlines. 0 = varies, 1 = black, 2 = white
        static let OutlineColor = "OutlineColor"
        /// Double. The variance from the background the outline color is set to.
        static let OutlineColorVariance = "OutlineColorVariance"
        /// Integer. Determines the color of the text. 0 = varies, 1 = black, 2 = white
        static let TextColor = "TextColor"
        /// Double. The variance from the background the color text is set to.
        static let TextColorVariance = "TextColorVariance"
        /// Double. Determines the size of shadows when shadows are enabled.
        static let ShadowSize = "ShadowSize"
        /// Integer. Thickness of the outline of the text.
        static let TextStrokeThickness = "TextStrokeThickness"
        /// Boolean. "Global" that indicates we're current in dark mode.
        static let InDarkMode = "InDarkMode"
        /// Boolean. Flag that indicates text colors are non-standard variants.
        static let TextColorVarianceIsNonStandard = "NonStandardTextColorVariance"
        /// Double. Variant to use for color calculation for text if non-standard. This value should be clamped from 0.0 to 1.0.
        static let ManualTextColorVariance = "ManualTextColorVariance"
        /// Boolean. Flag that indicates outline colors are non-standard variants. This value should be clampled from 0.0 to 1.0.
        static let OutlineColorVarianceIsNonStandard = "OutlineColorVarianceIsNonStandard"
        /// Boolean. Variant to use for color calculation for outlines if non-standard.
        static let ManualOutlineColorVariance = "OutlineTextColorVariance"
        /// Integer. Determines how menu buttons behave: 0 = tapped, 1 = always visible, 2 = never visible
        static let MenuButtonBehavior = "MenuButtonBehavior"
        /// Boolean. Menu button visible state.
        static let MenuButtonShowing = "MenuButtonShowing"
        /// Double. Duration of the animation for button rotations.
        static let ButtonRotationDuration = "ButtonRotationDuration"
        /// Integer. How the UI objects appear or disappear: 0 = simple appear, 1 = fade in, 2 = animated
        static let UIDynamicMethod = "UIDynamicMethod"
        /// Integer. Determines how the barcode foreground color is generated.
        static let BarcodeForegroundColorMethod = "BarocdeForegroundColorMethod"
        /// Double. The hue variance for barcode foreground colors.
        static let BarcodeForegroundStandardVariance = "BarcodeForegroundStandardVariance"
        /// Boolean. Determines if the user-specified manual variance is used.
        static let BarcodeForegroundUseManualVariance = "BarcodeForegroundUseManualVariance"
        /// Double. The user-specified manual variance.
        static let BarcodeForegroundColorVariance = "BarcodeForegroundColorVariance"
        /// UIColor. Static, user-selected foreground color for various elements.
        static let ElementForegroundColor = "ElementForegroundColor"
        /// Integer. The last type of barcode created.
        static let LastCreatedBarcodeType = "LastCreatedBarcodeType"
        /// Integer. The last barcode group used for barcode creation.
        static let LastCreatedBarcodeGroup = "LastCreatedBarcodeGroup"
        /// String. The contents of the last barcode created.
        static let LastCreatedBarcodeContents = "LastCreatedBarcodeContents"
        /// Boolean. Run-time flag generated to reflect whether the app is running on a simulator or hardware.
        static let RunningOnSimulator = "RunningOnSimulator"
        
        /// Bool. Show the version number on the main screen for a brief time after start-up.
        static let ShowVersionOnMainScreen = "ShowVersionOnMainScreen"
        /// Bool. Enables tapping to remove the version display before the version fader times-out.
        static let TapRemovesVersion = "TapRemovesVersion"
        /// Int. Location of the time in relation to the the visualization of the time.
        static let TimeLocation = "TimeTextLocation"
        
        //Impatient UI.
        /// Bool. Determines if the UI is impatient or not.
        static let EnableImpatientUI = "EnableImpatientUI"
        /// Int. Number of seconds before the UI becomes impatient.
        static let ImpatientDelay = "ImpatientDelay"
        /// Double. Interval for menu button impatient displays.
        static let ImpatientMenuButtonInterval = "ImpatientMenuButtonInterval"
        
        //UI constants.
        /// Integer. Margins to maintain by the edges of the screen.
        static let UIMargins = "UIMargins"
        /// Integer. Margins for internal text clock.
        static let TextMargins = "TextMargins"
        /// Integer. Offset for the notch on some phones.
        static let NotchOffset = "NotchOffset"
        
        //Panel settings
        /// Integer. Type of background to display for panel backgrounds. Valid values are:
        /// 0 = Static color, 1 = dynamic color, 2 = static pattern, 3 = dynamic color pattern,
        /// 4 = moving pattern, 5 = moving pattern with dynamic colors
        static let PanelBackgroundType = "PanelBackgroundType"
        /// UIColor. Color to show in the background.
        static let PanelBackgroundStaticColor = "PanelBackgroundStaticColor"
        /// Integer. Background pattern. 0 = Checkerboard, 1 = vertical lines, 2 = horizontal lines,
        /// 3 = negative diagonal lines, 4 = positive diagonal lines, 5 = diamonds
        static let PanelBackgroundPattern = "PanelBackgroundPattern"
        /// UIColor. First color for panel patterns.
        static let PanelBackgroundPatternColor1 = "PanelBackgroundPatternColor1"
        /// UIColor. Second color for panel patterns.
        static let PanelBackgroundPatternColor2 = "PanelBackgroundPatternColor2"
        /// Integer. Relative velocity the color changes. 0 = fast, 1 = medium, 2 = slow
        static let PanelBackgroundChangingColorVelocity = "PanelBackgroundChangingColorVelocity"
        /// UIColor. First changing color.
        static let PanelBackgroundChangeColor1 = "PanelBackgroundChangeColor1"
        /// UIColor. Second changing color.
        static let PanelBackgroundChangeColor2 = "PanelBackgroundChangeColor2"
        /// Bool. If true, thin lines are drawn for lined patterns. Otherwise, if false, the largest line is drawn.
        static let PanelBackgroundHasThinLines = "PanelBackgroundHasThinLines"
        
        //Initialization settings.
        /// String. Time/date the settings were initialized the first time.
        static let InitializeTimeStamp = "InitializeTimeStamp"
        
        /// Debug settings.
        struct Debug
        {
            /// Bool. Show or hide the debug grid overlay.
            static let ShowDebugGrid = "ShowDebugGrid"
            /// Integer. Gap between major debug grid lines.
            static let DebugMajorGridInterval = "DebugGridInterval"
            /// Integer. Gap between minor debug grid lines.
            static let DebugMinorGridInterval = "DebugMinorGridInterval"
            /// UIColor. Minor debug grid line color.
            static let DebugMinorGridLineColor = "DebugGridShortColor"
            /// UIColor. Major debug grid line color.
            static let DebugMajorGridLineColor = "DebugGridLongColor"
            /// Bool. Show major grid lines if ShowDebugGrid is true.
            static let ShowMajorGridLines = "ShowMajorGridLines"
            /// Bool. Show minor grid lines if ShowDebugGrid if true.
            static let ShowMinorGridLines = "ShowMinorGridLines"
            /// UIColor. Color to use for certain barcode tests.
            static let BarcodeTestColor = "BarcodeTestColor"
            /// Bool. Enable testing of barcode colors.
            static let EnableBarcodeColorTests = "EnableBarcodeColorTests"
            static let BarcodeColorTestMotion = "BarcodeColorTestMotion"
            static let BarcodeColorTestVelocity = "BarcodeColorTestVelocity"
        }
    }
    
    public static let SettingGroups: [String: [String]] =
        [
            "Key": [""],
            "Debug": [Key.Debug.ShowDebugGrid, Key.Debug.DebugMajorGridInterval, Key.Debug.DebugMinorGridInterval,
                      Key.Debug.DebugMinorGridLineColor, Key.Debug.DebugMajorGridLineColor, Key.Debug.ShowMajorGridLines,
                      Key.Debug.ShowMinorGridLines, Key.Debug.BarcodeTestColor, Key.Debug.EnableBarcodeColorTests,
                      Key.Debug.BarcodeColorTestMotion, Key.Debug.BarcodeColorTestVelocity]
    ]
    
    /// Maps setting names to associated types and default values.
    private static let TypeMap: [(String, String, Any?)] =
        [
            (Key.DisplayClock, "UUID", UUID.Empty()),
            (Key.ShowTextualTime, "Bool", true),
            (Key.ShowSillyMessages, "Bool", true),
            (Key.UIMargins, "Int", 0),
            (Key.BlinkColons, "Bool", false),
            (Key.ShowSecondsInString, "Bool", true),
            (Key.WasRunPreviously, "Bool", false),
            (Key.OutlineObjects, "Bool", false),
            (Key.Use24HourTime, "Bool", false),
            (Key.ShowingTime, "Bool", true),
            (Key.ShowAMPM, "Bool", false),
            (Key.LandscapeTimeFitsSpace, "Bool", true),
            (Key.EnableDarkMode, "Bool", false),
            (Key.DarkModeStartTime, "String", ""),
            (Key.DarkModeDuration, "Int", 0),
            (Key.DarkModeChangeBrightness, "Bool", true),
            (Key.DarkModeChangeSaturation, "Bool", true),
            (Key.DarkModeRelativeBrightness, "Double", 0.5),
            (Key.DarkModeRelativeSaturation, "Double", 0.75),
            (Key.StandardBGBrightness, "Double", 1.0),
            (Key.StandardBGSaturation, "Double", 1.0),
            (Key.HideStatusBar, "Bool", true),
            (Key.StayAwake, "Bool", true),
            (Key.ShowTextShadow, "Bool", false),
            (Key.ShowTextOutline, "Bool", false),
            (Key.UseScreenFormatting, "Bool", false),
            (Key.IncludeDate, "Bool", false),
            (Key.IncludeSeconds, "Bool", true),
            (Key.IncludeWeekday, "Bool", false),
            (Key.EncodingOrder, "Int", 0),
            (Key.OutlineColor, "Int", 0),
            (Key.OutlineColorVariance, "Double", 0.5),
            (Key.TextColor, "Int", 0),
            (Key.TextColorVariance, "Double", 0.75),
            (Key.ShadowSize, "Double", 0.0),
            (Key.TextStrokeThickness, "Int", 1.0),
            (Key.InDarkMode, "Bool", false),
            (Key.TextColorVarianceIsNonStandard, "Bool", false),
            (Key.ManualTextColorVariance, "Double", 0.5),
            (Key.OutlineColorVarianceIsNonStandard, "Bool", false),
            (Key.ManualOutlineColorVariance, "Double", 0.5),
            (Key.MenuButtonBehavior, "Int", 0),
            (Key.MenuButtonShowing, "Bool", true),
            (Key.ButtonRotationDuration, "Double", 0.05),
            (Key.UIDynamicMethod, "Int", 0),
            (Key.BarcodeForegroundColorMethod, "Int", 0),
            (Key.BarcodeForegroundStandardVariance, "Double", 0.5),
            (Key.BarcodeForegroundUseManualVariance, "Bool", false),
            (Key.BarcodeForegroundColorVariance, "Double", 0.5),
            (Key.ElementForegroundColor, "UIColor", UIColor.white),
            (Key.LastCreatedBarcodeType, "Int", 0),
            (Key.LastCreatedBarcodeGroup, "Int", 0),
            (Key.LastCreatedBarcodeContents, "String", ""),
            (Key.RunningOnSimulator, "Bool", false),
            (Key.Background.ColorDirection, "Double", 1.0),
            (Key.ShowVersionOnMainScreen, "Bool", true),
            (Key.TapRemovesVersion, "Bool", true),
            (Key.TimeLocation, "Int", 0),
            (Key.InitializeTimeStamp, "String", true),
            (Key.TextMargins, "Int", 0),
            (Key.NotchOffset, "Int", 0),
            (Key.PanelBackgroundType, "Int", 0),
            (Key.PanelBackgroundStaticColor, "UIColor", UIColor.gray),
            (Key.PanelBackgroundPattern, "Int", 0),
            (Key.PanelBackgroundPatternColor1, "UIColor", UIColor.gray),
            (Key.PanelBackgroundPatternColor2, "UIColor", UIColor.darkGray),
            (Key.PanelBackgroundChangingColorVelocity, "Int", 0),
            (Key.PanelBackgroundChangeColor1, "UIColor", UIColor.white),
            (Key.PanelBackgroundChangeColor2, "UIColor", UIColor.black),
            (Key.PanelBackgroundHasThinLines, "Bool", true),
            (Key.EnableImpatientUI, "Bool", true),
            (Key.ImpatientDelay, "Int", 30.0),
            (Key.ImpatientMenuButtonInterval, "Double", 0.5),
            
            (Key.Background.BGType, "Int", 0),
            (Key.Background.GradientVarianceType, "Int", 0),
            (Key.Background.ColorTimePeriod, "Int", 0),
            (Key.Background.BackgroundColorStyle, "Int", 0),
            (Key.Background.HueVariance, "Double", 0.0),
            (Key.Background.SaturationVariance, "Double", 0.0),
            (Key.Background.BrightnessVariance, "Double", 0.0),
            (Key.Background.ColorsChange, "Bool", true),
            (Key.Background.AngleOffset, "Double", 45.0),
            
            (Key.BackgroundColors.BackgroundColorCount, "Int", 2),
            (Key.BackgroundColors.BGColor1Hue, "Double", 1.0 / 360.0),
            (Key.BackgroundColors.BGColor1Sat, "Double", 0.8),
            (Key.BackgroundColors.BGColor1Bri, "Double", 0.8),
            (Key.BackgroundColors.BGColor1IsGrayscale, "Bool", false),
            (Key.BackgroundColors.BGColor1Direction, "Int", 1.0),
            (Key.BackgroundColors.BGColor1IsDynamic, "Bool", true),
            (Key.BackgroundColors.BGColor1TimePeriod, "Int", 60),
            (Key.BackgroundColors.BGColor2Hue, "Double", 45.0 / 360.0),
            (Key.BackgroundColors.BGColor2Sat, "Double", 0.8),
            (Key.BackgroundColors.BGColor2Bri, "Double", 0.8),
            (Key.BackgroundColors.BGColor2IsGrayscale, "Bool", false),
            (Key.BackgroundColors.BGColor2Direction, "Int", 1.0),
            (Key.BackgroundColors.BGColor2IsDynamic, "Bool", true),
            (Key.BackgroundColors.BGColor2TimePeriod, "Int", 60),
            (Key.BackgroundColors.BGColor2Location, "Double", 0.5),
            (Key.BackgroundColors.BGColor3Hue, "Double", 90.0 / 360.0),
            (Key.BackgroundColors.BGColor3Sat, "Double", 0.8),
            (Key.BackgroundColors.BGColor3Bri, "Double", 0.8),
            (Key.BackgroundColors.BGColor3IsGrayscale, "Bool", false),
            (Key.BackgroundColors.BGColor3Direction, "Int", 1.0),
            (Key.BackgroundColors.BGColor3IsDynamic, "Bool", false),
            (Key.BackgroundColors.BGColor3TimePeriod, "Int", 60),
            (Key.BackgroundColors.AnimateBGSample, "Bool", true),
            
            (Key.Text.FontName, "String", "Avenir-Book"),
            (Key.Text.BlinkColons, "Bool", false),
            (Key.Text.OutlineText, "Bool", false),
            (Key.Text.HighlightType, "Int", 0),
            (Key.Text.ShadowType, "Int", 0),
            (Key.Text.GlowType, "Int", 0),
            (Key.Text.Color, "UIColor", UIColor.black),
            (Key.Text.OutlineColor, "UIColor", UIColor.white),
            (Key.Text.ShadowColor, "UIColor", UIColor.darkGray),
            (Key.Text.GlowColor, "UIColor", UIColor.white),
            (Key.Text.LandscapeTimeFitsSpace, "Bool", true),
            (Key.Text.OutlineThickness, "Int", 2.0),
            (Key.Text.ShowSeconds, "Bool", true),
            (Key.Text.ShowAMPM, "Bool", false),
            (Key.Text.Use24HourTime, "Bool", true),
            (Key.Text.SampleBackground, "UIColor", false),
            
            (Key.Debug.ShowDebugGrid, "Bool", false),
            (Key.Debug.DebugMajorGridInterval, "Int", 64),
            (Key.Debug.DebugMinorGridInterval, "Int", 16),
            (Key.Debug.DebugMajorGridLineColor, "UIColor", UIColor.red),
            (Key.Debug.DebugMinorGridLineColor, "UIColor", UIColor.yellow),
            (Key.Debug.ShowMajorGridLines, "Bool", true),
            (Key.Debug.ShowMinorGridLines, "Bool", true),
            (Key.Debug.BarcodeTestColor, "UIColor", UIColor.yellow),
            (Key.Debug.EnableBarcodeColorTests, "Bool", false),
            (Key.Debug.BarcodeColorTestMotion, "Int", false),
            (Key.Debug.BarcodeColorTestVelocity, "Int", 0),
            
            (Key.RadialGradient.CenterDotPulsates, "Bool", true),
            (Key.RadialGradient.NumeralAnimationStyle, "Int", 0),
            (Key.RadialGradient.ShowCenterDot, "Bool", true),
            (Key.RadialGradient.ShowClockHandValues, "Bool", false),
            (Key.RadialGradient.ShowHourNumerals, "Bool", false),
            (Key.RadialGradient.ShowSeconds, "Bool", true),
            (Key.RadialGradient.SmoothMotion, "Bool", true),
            (Key.RadialGradient.NumeralAnimationDelay, "Int", 0),
            (Key.RadialGradient.EnableNumeralColorAnimation, "Bool", true),
            (Key.RadialGradient.CenterBlobDefiniton, "String", InitialCenterBlob),
            (Key.RadialGradient.HourBlobDefiniton, "String", InitialHourBlob),
            (Key.RadialGradient.MinuteBlobDefiniton, "String", InitialMinuteBlob),
            (Key.RadialGradient.SecondBlobDefiniton, "String", InitialSecondBlob),
            (Key.RadialGradient.HandShape, "Int", 0),
            (Key.RadialGradient.ShowRadialLine, "Bool", false),
            (Key.RadialGradient.GradientFilter, "Int", 0),
            (Key.RadialGradient.CompositeBlendMode, "Int", 0),
            
            (Key.QRCode.NodeStyle, "Int", 0),
            (Key.QRCode.NodeColor, "UIColor", UIColor.black),
            (Key.QRCode.NodeSizeMultiplier, "Double", 1.0),
            (Key.QRCode.ShadowLevel, "Int", 0),
            (Key.QRCode.HighlightColor, "UIColor", UIColor.white),
            (Key.QRCode.SpecialEffects, "Int", 0),
            
            (Key.Aztec.NodeColor, "UIColor", UIColor.black),
            (Key.Aztec.HighlightColor, "UIColor", UIColor.white),
            (Key.Aztec.NodeStyle, "Int", 0),
            (Key.Aztec.ShadowLevel, "Int", 0),
            (Key.Aztec.HighlightStyle, "Int", 0),
            
            (Key.QRCode3D.NodeShape, "Int", 0),
            (Key.QRCode3D.NodeDiffuseColor, "UIColor", UIColor.white),
            (Key.QRCode3D.NodeSpecularColor, "UIColor", UIColor.green),
            (Key.QRCode3D.NodeLightingColor, "UIColor", UIColor.yellow),
            (Key.QRCode3D.NodeRotationAnimation, "Bool", true),
            (Key.QRCode3D.DesiredFrameRate, "Int", 60),
            (Key.QRCode3D.AntialiasingType, "Int", 0),
            
            (Key.Code128.BarcodeHeight, "Double", 0.9),
            (Key.Code128.BarcodeShape, "Int", 0),
            (Key.Code128.BarcodeStroked, "Bool", false),
            (Key.Code128.BarcodeStrokeColor, "UIColor", UIColor.white),
            (Key.Code128.BarcodeForegroundColor1, "UIColor", UIColor.black),
            (Key.Code128.BarcodeForegroundColor2, "UIColor", UIColor.white),
            (Key.Code128.ShadowEffect, "Int", 0),
            (Key.Code128.SpecialEffect, "Int", 0),
            (Key.Code128.InnerRadius, "Double", 0.3),
            (Key.Code128.OuterRadius, "Double", 0.9),
            (Key.Code128.WavyHeights, "Int", 0),
            
            (Key.Pharma.BarcodeHeight, "Double", 0.9),
            (Key.Pharma.BarcodeShape, "Int", 0),
            (Key.Pharma.BarcodeStroked, "Bool", false),
            (Key.Pharma.BarcodeStrokeColor, "UIColor", UIColor.white),
            (Key.Pharma.BarcodeForegroundColor1, "UIColor", UIColor.black),
            (Key.Pharma.BarcodeForegroundColor2, "UIColor", UIColor.white),
            (Key.Pharma.ShadowEffect, "Int", 0),
            (Key.Pharma.SpecialEffect, "Int", 0),
            (Key.Pharma.InnerRadius, "Double", 0.3),
            (Key.Pharma.OuterRadius, "Double", 0.9),
            (Key.Pharma.WavyHeights, "Int", 0),
            (Key.Pharma.IncludeDigits, "Bool", 0),
            (Key.Pharma.ColorsVaryByThickness, "Bool", false),
            (Key.Pharma.ThinForeground, "UIColor", UIColor.gold),
            (Key.Pharma.ThickForeground, "UIColor", UIColor.yellow),
            
            (Key.POSTNET.BarcodeHeight, "Double", 0.9),
            (Key.POSTNET.BarcodeShape, "Int", 0),
            (Key.POSTNET.BarcodeStroked, "Bool", false),
            (Key.POSTNET.BarcodeStrokeColor, "UIColor", UIColor.white),
            (Key.POSTNET.BarcodeForegroundColor1, "UIColor", UIColor.black),
            (Key.POSTNET.BarcodeForegroundColor2, "UIColor", UIColor.white),
            (Key.POSTNET.ShadowEffect, "Int", 0),
            (Key.POSTNET.SpecialEffect, "Int", 0),
            (Key.POSTNET.InnerRadius, "Double", 0.3),
            (Key.POSTNET.OuterRadius, "Double", 0.9),
            (Key.POSTNET.WavyHeights, "Int", 0),
            (Key.POSTNET.IncludeCheckDigit, "Bool", true),
            (Key.POSTNET.LongForeground, "UIColor", UIColor.yellow),
            (Key.POSTNET.ShortForeground, "UIColor", UIColor.orange),
            (Key.POSTNET.ColorsVaryOnLength, "Bool", false),
            
            (Key.Orbit.ShowOrbitalPaths, "Bool", false),
            (Key.Orbit.CenterTimeType, "Int", 0),
            (Key.Orbit.ShowSecondObject, "Bool", true),
            (Key.Orbit.CenterValue, "Int", 0),
            (Key.Orbit.Is2D, "Bool", true),
            (Key.Orbit.ObjectTypes, "Int", 0),
            (Key.Orbit.ShowRadialLines, "Bool", false),
            
            (Key.Polar.PolarType, "Int", 0),
            (Key.Polar.Font, "String", "Avenir-Book"),
            (Key.Polar.TextShadow, "Int", 0),
            (Key.Polar.TextGlow, "Int", 0),
            (Key.Polar.TextStroked, "Int", 0),
            (Key.Polar.ShadowColor, "UIColor", UIColor.darkGray),
            (Key.Polar.GlowColor, "UIColor", UIColor.white),
            (Key.Polar.StrokeColor, "UIColor", UIColor.white),
            (Key.Polar.Is2D, "Bool", true),
            (Key.Polar.DigitText, "Bool", true),
            (Key.Polar.Smooth, "Bool", true),
            (Key.Polar.TextColor, "UIColor", UIColor.black),
            (Key.Polar.ShowPolarGrid, "Bool", false),
            (Key.Polar.PolarGridColor, "UIColor", UIColor.yellow),
            
            (Key.Sounds.GlobalEnable, "Bool", true),
            (Key.Sounds.GlobalTick, "String", true),
            (Key.Sounds.UseGlobalSounds, "Bool", true),
            (Key.Sounds.GlobalVolume, "Int", 2),
            
            (Key.Device.IsSmallDevice, "Bool", false),
            ]
    
    /// Maps setting names to descriptions.
    private static let SettingAnnotationMap =
        [
            Key.DisplayClock: "The last clock type used.",
            Key.ShowTextualTime: "Show the time as text on the screen.",
            Key.ShowSillyMessages: "Show silly messages when the app resigns and becomes active.",
            Key.BlinkColons: "Blink colons periodically.",
            Key.ShowSecondsInString: "Show seconds in time text.",
            Key.WasRunPreviously: "Stores a flag that indicates if the program has run prior to the current instantiation.",
            Key.OutlineObjects: "If true, certain objects on the screen are outlined.",
            Key.Use24HourTime: "Determines if house are in 24 or 12 hour mode.",
            Key.ShowingTime: "Flag used to resume the state of time visibility.",
            Key.ShowAMPM: "Flag that determines whether the AM/PM indicator is shown on the text time.",
            Key.LandscapeTimeFitsSpace: "If true, the time in landscape mode stretches vertically to fit available space. If false, it does a best fit for available horizontal space.",
            Key.EnableDarkMode: "Determines if dark mode is enabled.",
            Key.DarkModeStartTime: "When to start dark mode if enabled, in seconds past midnight.",
            Key.DarkModeDuration: "How long to stay in dark mode, in seconds, once it has started.",
            Key.DarkModeChangeBrightness: "Enable dark mode brightness variations.",
            Key.DarkModeChangeSaturation: "Enable dark mode saturation variations.",
            Key.DarkModeRelativeBrightness: "Dark mode brightness variation level.",
            Key.DarkModeRelativeSaturation: "Dark mode saturation variation level.",
            Key.StandardBGBrightness: "Value for background color brightness used when not in dark mode.",
            Key.StandardBGSaturation: "Value for background color saturation used when not in dark mode.",
            Key.HideStatusBar: "Setting that tells the program to hide the system status bar.",
            Key.StayAwake: "Setting that tells the program to stay awake if plugged into a power source.",
            Key.ShowTextShadow: "Setting for showing or hiding shadows under the text time.",
            Key.ShowTextOutline: "Determines if the textual time is outlined (stroked) or not.",
            Key.UseScreenFormatting: "Use the same formatting for barcode encoding as the textual time.",
            Key.IncludeDate: "Include the date when encoding the barcode.",
            Key.IncludeSeconds: "Include seconds when encoding barcodes.",
            Key.IncludeWeekday: "Include the weekday when encoding barcodes.",
            Key.EncodingOrder: "Order of data in the encoded barcode.",
            Key.OutlineColor: "Degtermines the color of textual outlines.",
            Key.OutlineColorVariance: "The variance from the background the outline color is set to.",
            Key.TextColor: "Determines the color of the text.",
            Key.TextColorVariance: "The variance from the background the color text is set to.",
            Key.ShadowSize: "Determines the size of shadows when shadows are enabled.",
            Key.TextStrokeThickness: "Thickness of the outline of the text.",
            Key.InDarkMode: "Flag that indicates whether the program is currently in dark mode or not.",
            Key.TextColorVarianceIsNonStandard: "Flag that indicates text colors are non-standard variants.",
            Key.ManualTextColorVariance: "Variant to use for color calculation for text if non-standard.",
            Key.OutlineColorVarianceIsNonStandard: "Flag that indicates outline colors are non-standard variants.",
            Key.ManualOutlineColorVariance: "Variant to use for color calculation for outlines if non-standard.",
            Key.MenuButtonBehavior: "Determines how menu buttons show up.",
            Key.MenuButtonShowing: "Menu button visibility state.",
            Key.ButtonRotationDuration: "Duration of the animation for menu button rotations.",
            Key.UIDynamicMethod: "How the UI objects appear or disappear.",
            Key.BarcodeForegroundColorMethod: "Determines how the barcode foreground color is generated.",
            Key.BarcodeForegroundStandardVariance: "The hue variance for barcode foreground colors.",
            Key.BarcodeForegroundUseManualVariance: "Determines if the user-specified manual variance is used for barcode foregrounds.",
            Key.BarcodeForegroundColorVariance: "The user-specified manual variance.",
            Key.ElementForegroundColor: "User-selected, static color for foreground elements.",
            Key.LastCreatedBarcodeType: "Last barcode type created (not displayed - this is for barcode creation).",
            Key.LastCreatedBarcodeGroup: "The last barcode group used to create a barcode.",
            Key.LastCreatedBarcodeContents: "Last contents used for barcode creation.",
            Key.RunningOnSimulator: "Run-time flag that reports whether the program is on a simulator or actual hardware.",
            Key.Background.ColorDirection: "Direction color changes travel.",
            Key.ShowVersionOnMainScreen: "Show the version number on the main screen briefly after starting.",
            Key.TapRemovesVersion: "Enables the user to tap on the version number to hide it early.",
            Key.TimeLocation: "Location of the text on the screen. 0 = top or left, 1 = bottom or right.",
            Key.InitializeTimeStamp: "Time stamp for when initial settings were intiailizes.",
            Key.TextMargins: "Internal margins for text clock.",
            Key.NotchOffset: "Offset value for the notch present on some phones.",
            
            Key.Background.BGType: "The type of background to display.",
            Key.Background.GradientVarianceType: "Determines how to create the background gradient.",
            Key.Background.ColorTimePeriod: "The period of time to finish one color cycle.",
            Key.Background.BackgroundColorStyle: "Determines the style to use for color backgrounds.",
            Key.Background.HueVariance: "Hue variance for gradient color calculations.",
            Key.Background.SaturationVariance: "Saturation variance for color calculations.",
            Key.Background.BrightnessVariance: "Brightness variance for gradient color calculations.",
            Key.Background.ColorsChange: "Determines if colors cycle through the hue circle.",
            Key.Background.AngleOffset: "Angle offset to use for color calculations.",
            
            Key.BackgroundColors.BackgroundColorCount: "Number of background colors that are active.",
            Key.BackgroundColors.BGColor1Hue: "Background color 1 hue value.",
            Key.BackgroundColors.BGColor1Sat: "Background color 1 saturation value.",
            Key.BackgroundColors.BGColor1Bri: "Background color 1 brightness value.",
            Key.BackgroundColors.BGColor1IsGrayscale: "Background color 1 is grayscale.",
            Key.BackgroundColors.BGColor1Direction: "Background color 1 direction.",
            Key.BackgroundColors.BGColor1IsDynamic: "Background color 1 changes with time.",
            Key.BackgroundColors.BGColor1TimePeriod: "Background color 1 time period.",
            Key.BackgroundColors.BGColor2Hue: "Background color 2 hue value.",
            Key.BackgroundColors.BGColor2Sat: "Background color 2 saturation value.",
            Key.BackgroundColors.BGColor2Bri: "Background color 2 brightness value.",
            Key.BackgroundColors.BGColor2IsGrayscale: "Background color 2 is grayscale.",
            Key.BackgroundColors.BGColor2Direction: "Background color 2 direction.",
            Key.BackgroundColors.BGColor2IsDynamic: "Background color 2 changes with time.",
            Key.BackgroundColors.BGColor2TimePeriod: "Background color 2 time period.",
            Key.BackgroundColors.BGColor2Location: "Relative location of the middle color.",
            Key.BackgroundColors.BGColor3Hue: "Background color 3 hue value.",
            Key.BackgroundColors.BGColor3Sat: "Background color 3 saturation value.",
            Key.BackgroundColors.BGColor3Bri: "Background color 3 brightness value.",
            Key.BackgroundColors.BGColor3IsGrayscale: "Background color 3 is grayscale.",
            Key.BackgroundColors.BGColor3Direction: "Background color 3 direction.",
            Key.BackgroundColors.BGColor3IsDynamic: "Background color 3 changes with time.",
            Key.BackgroundColors.BGColor3TimePeriod: "Background color 3 time period.",
            Key.BackgroundColors.AnimateBGSample: "Animate background colors sample.",
            
            Key.Text.FontName: "Name of the font to use to draw the textual time.",
            Key.Text.BlinkColons: "Determines if colons in the time text blink.",
            Key.Text.OutlineText: "Determines if the time text is stroked (eg, outlined).",
            Key.Text.HighlightType: "Determines the type of highlighting.",
            Key.Text.ShadowType: "Determines the type of shadow to use.",
            Key.Text.GlowType: "Determines the type of glow to use.",
            Key.Text.Color: "The color of the time text.",
            Key.Text.OutlineColor: "The color of the outline if enabled.",
            Key.Text.ShadowColor: "The color of the shadow if enabled.",
            Key.Text.GlowColor: "The color of the glow if enabled.",
            Key.Text.LandscapeTimeFitsSpace: "Determines how to fit text in landscape mode.",
            Key.Text.OutlineThickness: "Thickness of the outline of the text (if enabled).",
            Key.Text.ShowSeconds: "Show or hide seconds in the time.",
            Key.Text.ShowAMPM: "Show or hide the AM/PM indicator.",
            Key.Text.Use24HourTime: "If true, 24-hour time is used. Otherwise, 12-hour time is used.",
            Key.Text.SampleBackground: "Color of the sample background for textual time visual attributes view controller.",
            
            Key.PanelBackgroundType: "Panel background type.",
            Key.PanelBackgroundStaticColor: "Panel background static color.",
            Key.PanelBackgroundPattern: "Panel background pattern type.",
            Key.PanelBackgroundPatternColor1: "Panel background pattern first color.",
            Key.PanelBackgroundPatternColor2: "Panel background pattern second color.",
            Key.PanelBackgroundChangingColorVelocity: "Relative rate at which colors change in the background panel.",
            Key.PanelBackgroundChangeColor1: "First changing color.",
            Key.PanelBackgroundChangeColor2: "Second changing color.",
            Key.PanelBackgroundHasThinLines: "Determines the thickness calculation of pattern lines.",
            Key.EnableImpatientUI: "Determines if the UI is impatient.",
            Key.ImpatientDelay: "Number of seconds before the UI becomes impatient.",
            Key.ImpatientMenuButtonInterval: "Interval for impatience display for menu buttons.",
            
            Key.Debug.ShowDebugGrid: "Determines if the debug grid overlay is shown or hidden.",
            Key.Debug.DebugMajorGridInterval: "Space between major debug grid lines.",
            Key.Debug.DebugMinorGridInterval: "Space between minor debug grid lines.",
            Key.Debug.DebugMinorGridLineColor: "Color of the minor debug grid lines.",
            Key.Debug.DebugMajorGridLineColor: "Color of the major debug grid lines.",
            Key.Debug.ShowMinorGridLines: "Show minor debug grid lines.",
            Key.Debug.ShowMajorGridLines: "Show major debug grid lines.",
            Key.Debug.BarcodeTestColor: "Color used for certain barcode tests.",
            Key.Debug.EnableBarcodeColorTests: "Enables testing of colors in barcodes.",
            Key.Debug.BarcodeColorTestMotion: "Determines type of motion test for barcode colors.",
            Key.Debug.BarcodeColorTestVelocity: "Determines velocity of motion test for barcode colors.",
            
            Key.RadialGradient.CenterDotPulsates: "Determines if the center blob pulsates.",
            Key.RadialGradient.NumeralAnimationStyle: "The style of animation of hide and show clock numerals.",
            Key.RadialGradient.ShowCenterDot: "Determines if the center dot/blob is visible.",
            Key.RadialGradient.ShowClockHandValues: "Determines if numbers are superimosed on clock hand blobs.",
            Key.RadialGradient.ShowHourNumerals: "Determines if hour numerals are shown on the clock.",
            Key.RadialGradient.ShowSeconds: "Determines if the second hand blob is shown.",
            Key.RadialGradient.SmoothMotion: "Determines if smooth motion is used.",
            Key.RadialGradient.NumeralAnimationDelay: "Index into a table of delay values used to determine time between starting animations.",
            Key.RadialGradient.EnableNumeralColorAnimation: "Determines if numeral color animation is enabled.",
            Key.RadialGradient.CenterBlobDefiniton: "Definition of the center blob.",
            Key.RadialGradient.HourBlobDefiniton: "Definition of the hour blob.",
            Key.RadialGradient.MinuteBlobDefiniton: "Definition of the minute blob.",
            Key.RadialGradient.SecondBlobDefiniton: "Definition of the second blob.",
            Key.RadialGradient.HandShape: "Determines the shape of the hands of the clock.",
            Key.RadialGradient.ShowRadialLine: "Determines if a radial line is shown from the center to the moving hand gradient.",
            Key.RadialGradient.GradientFilter: "Determines which, if any, filter to use on the gradient.",
            Key.RadialGradient.CompositeBlendMode: "Determines the blend mode to use when compositing radial gradients.",
            
            Key.QRCode.NodeStyle: "Determines the shape of each node in a QR code clock.",
            Key.QRCode.NodeColor: "The color to use to draw individual QR code nodes.",
            Key.QRCode.NodeSizeMultiplier: "Multiplier for QR node sizes.",
            Key.QRCode.ShadowLevel: "Shadow level for QR nodes - 0 = none, 1 = small, 2 = medium, 3 = large.",
            Key.QRCode.HighlightColor: "The color to use to highlight nodes that need to be highlighted for whatever reason.",
            Key.QRCode.SpecialEffects: "Special effects. 0 = none, 1 = Delta highlights.",
            
            Key.QRCode3D.NodeShape: "Shape of each node of a 3D QR code.",
            Key.QRCode3D.NodeDiffuseColor: "Diffuse color of 3D QR code nodes.",
            Key.QRCode3D.NodeSpecularColor: "Specular color of 3D QR code nodes.",
            Key.QRCode3D.NodeLightingColor: "Color of the light use to illuminate the QR code.",
            Key.QRCode3D.NodeRotationAnimation: "Determines if individual nodes use animation to rotate in place.",
            Key.QRCode3D.DesiredFrameRate: "Desired frame rate in frames/second.",
            Key.QRCode3D.AntialiasingType: "Type of antialiasing to use. 0 = none, 1 = 2x, and 2 = 4x.",
            
            Key.Code128.BarcodeShape: "The shape of the Code 128 barcode.",
            Key.Code128.BarcodeHeight: "The relative height of the Code 128 barcode.",
            Key.Code128.BarcodeStrokeColor: "The color of stroked nodes when stroking barcodes is enabled.",
            Key.Code128.BarcodeStroked: "Determines if barcode nodes are stroked.",
            Key.Code128.BarcodeForegroundColor1: "Normal barcode node color.",
            Key.Code128.BarcodeForegroundColor2: "Color used to attract attention for barcode nodes.",
            Key.Code128.ShadowEffect: "Determines the shadow effect. 0 = none, 1 = light, 2 = medium, 3 = heavy.",
            Key.Code128.SpecialEffect: "Determines the special effect. 0 = none, 1 = Delta highlights, 2 = Sweep highlight.",
            Key.Code128.InnerRadius: "Inner radius of circular barcodes in percent available space.",
            Key.Code128.OuterRadius: "Outer radius of circular barcodes or size of linear barcodes in percent available space.",
            Key.Code128.WavyHeights: "Determines if heights vary over time. 0 = no varying, 1 = light, 2 = moderate, 3 = a lot.",
            
            Key.Pharma.BarcodeShape: "The shape of the Pharmacode barcode.",
            Key.Pharma.BarcodeHeight: "The relative height of the Pharmacode barcode.",
            Key.Pharma.BarcodeStrokeColor: "The color of stroked nodes when stroking barcodes is enabled.",
            Key.Pharma.BarcodeStroked: "Determines if barcode nodes are stroked.",
            Key.Pharma.BarcodeForegroundColor1: "Normal barcode node color.",
            Key.Pharma.BarcodeForegroundColor2: "Color used to attract attention for barcode nodes.",
            Key.Pharma.ShadowEffect: "Determines the shadow effect. 0 = none, 1 = light, 2 = medium, 3 = heavy.",
            Key.Pharma.SpecialEffect: "Determines the special effect. 0 = none, 1 = Delta highlights, 2 = Sweep highlight.",
            Key.Pharma.InnerRadius: "Inner radius of circular barcodes in percent available space.",
            Key.Pharma.OuterRadius: "Outer radius of circular barcodes or size of linear barcodes in percent available space.",
            Key.Pharma.WavyHeights: "Determines if heights vary over time. 0 = no varying, 1 = light, 2 = moderate, 3 = a lot.",
            Key.Pharma.IncludeDigits: "Determines if digits are displayed with the barcode.",
            Key.Pharma.ColorsVaryByThickness: "Determines if barcodes have colors based on their thickness.",
            Key.Pharma.ThinForeground: "The color of thin barcodes.",
            Key.Pharma.ThickForeground: "The color of thick barcodes.",
            
            Key.POSTNET.BarcodeShape: "The shape of the POSTNET barcode.",
            Key.POSTNET.BarcodeHeight: "The relative height of the POSTNET barcode.",
            Key.POSTNET.BarcodeStrokeColor: "The color of stroked nodes when stroking barcodes is enabled.",
            Key.POSTNET.BarcodeStroked: "Determines if barcode nodes are stroked.",
            Key.POSTNET.BarcodeForegroundColor1: "Normal barcode node color.",
            Key.POSTNET.BarcodeForegroundColor2: "Color used to attract attention for barcode nodes.",
            Key.POSTNET.ShadowEffect: "Determines the shadow effect. 0 = none, 1 = light, 2 = medium, 3 = heavy.",
            Key.POSTNET.SpecialEffect: "Determines the special effect. 0 = none, 1 = Delta highlights, 2 = Sweep highlight.",
            Key.POSTNET.InnerRadius: "Inner radius of circular barcodes in percent available space.",
            Key.POSTNET.OuterRadius: "Outer radius of circular barcodes or size of linear barcodes in percent available space.",
            Key.POSTNET.WavyHeights: "Determines if heights vary over time. 0 = no varying, 1 = light, 2 = moderate, 3 = a lot.",
            Key.POSTNET.IncludeCheckDigit: "Determines if the check digit is included in the barcode.",
            Key.POSTNET.LongForeground: "Color of long bars if enabled.",
            Key.POSTNET.ShortForeground: "Color of short bars if enabled.",
            Key.POSTNET.ColorsVaryOnLength: "Determines if long and short bars have different colors.",
            
            Key.Aztec.NodeColor: "The color of an Aztec barcode node.",
            Key.Aztec.ShadowLevel: "Shadow level for Aztec nodes - 0 = none, 1 = small, 2 = medium, 3 = large",
            Key.Aztec.NodeStyle: "Determines the shape of each node in an Aztec barcode clock.",
            Key.Aztec.HighlightColor: "The color of highlighted nodes in an Aztec barcode.",
            Key.Aztec.HighlightStyle: "How to highlight Aztec barcode nodes.",
            
            Key.Orbit.ShowOrbitalPaths: "Determines if orbital paths are shown in the clock.",
            Key.Orbit.CenterTimeType: "The center time object, which determines the number of child objects.",
            Key.Orbit.ShowSecondObject: "Determines if the second object is shown.",
            Key.Orbit.CenterValue: "Determines what, if anything, to show in the center in terms of value text.",
            Key.Orbit.Is2D: "Sets the display mode to either 2D or 3D.",
            Key.Orbit.ObjectTypes: "The type of child object to show.",
            Key.Orbit.ShowRadialLines: "Show or hide radial lines from child to parent objects.",
            
            Key.Polar.PolarType: "The type of polar clock.",
            Key.Polar.Font: "The font name to use for text when in polar text mode.",
            Key.Polar.TextShadow: "Determines how shadows are drawn with text.",
            Key.Polar.TextGlow: "Determines how glow is drawn with text.",
            Key.Polar.TextStroked: "Determines how letter strokes are drawn on text.",
            Key.Polar.ShadowColor: "The color of the shadow.",
            Key.Polar.GlowColor: "The color of the glow.",
            Key.Polar.StrokeColor: "The color of the stroke.",
            Key.Polar.Is2D: "Determines if the scene is in 2D or 3D.",
            Key.Polar.DigitText: "Determines if polar text consists of words or numeric digits.",
            Key.Polar.Smooth: "If true, smoth motion is used. Otherwise discrete motion is used.",
            Key.Polar.TextColor: "The color of the text.",
            Key.Polar.ShowPolarGrid: "Determines if a polar grid is shown.",
            Key.Polar.PolarGridColor: "Color of the polar grid.",
            
            Key.TextClock.Is2D: "Determines if the text clock is shown in 2D or 3D mode.",
            
            Key.Sounds.GlobalEnable: "Enables or disables all sounds emitted by this app.",
            Key.Sounds.GlobalVolume: "Volume of global sounds.",
            Key.Sounds.GlobalTick: "Name (as in file name) of the global tick sound.",
            Key.Sounds.UseGlobalSounds: "Determines if global sounds are used instead of clock-specific sounds.",
            
            Key.Device.IsSmallDevice: "Determines if the device is small from a screen resolution standpoint. If small, certain views may use alternative controllers."
    ]
    
    /// Return annotation for a given setting key.
    ///
    /// - Parameter ForSetting: Setting key whose annotation will be returned.
    /// - Returns: The annotation for the specified key on success, error message on failure.
    public static func GetAnnotation(ForSetting: String) -> String
    {
        if let Annotation = SettingAnnotationMap[ForSetting]
        {
            return Annotation
        }
        return "no annotation available"
    }
    
    /// Return a list of setting keys.
    ///
    /// - Returns: List of all setting keys.
    public static func KeysInList() -> [String]
    {
        var KeyList = [String]()
        for (Key, _, _) in TypeMap
        {
            KeyList.append(Key)
        }
        return KeyList
    }
    
    /// Return a list of all types in the settings list.
    ///
    /// - Returns: Types of settings.
    public static func GetSettingTypes() -> [String]
    {
        var SettingTypes = Set<String>()
        for (_, TypeName, _) in TypeMap
        {
            SettingTypes.insert(TypeName)
        }
        return Array(SettingTypes)
    }
    
    /// Return a list of all settings for a given type.
    ///
    /// - Parameter TypeOf: The type of setting to return.
    /// - Returns: List of settings for the passed type.
    public static func SettingsFor(TypeOf: String) -> [String]
    {
        var Results = [String]()
        for (Name, TypeName, _) in TypeMap
        {
            if TypeName == TypeOf
            {
                Results.append(Name)
            }
        }
        return Results
    }
    
    /// Return the default value for the specified key.
    ///
    /// - Parameter Key: The name of the key whose default value and type are returned.
    /// - Returns: A tuple consisting of the type name and default value (cast to Any?) on success,
    ///            nil if the key was not found.
    public static func DefaultFor(Key: String) -> (String, Any?)?
    {
        for (KeyName, TypeName, DefaultValue) in TypeMap
        {
            if Key == KeyName
            {
                return (TypeName, DefaultValue)
            }
        }
        return nil
    }
    
    /// Sets a value in the user defaults database to the appropriate type and value.
    ///
    /// - Parameters:
    ///   - Key: Name of the key to set.
    ///   - TypeName: Type of the value to set.
    ///   - Value: Value to set.
    /// - Returns: True on success, false on failure, mostly because of an unknown type.
    private static func DoSet(Key: String, TypeName: String, Value: Any?) -> Bool
    {
        switch TypeName
        {
        case "Bool":
            UserDefaults.standard.set(Value as! Bool, forKey: Key)
            
        case "Int":
            UserDefaults.standard.set(Value as! Int, forKey: Key)
            
        case "Double":
            UserDefaults.standard.set(Value as! Double, forKey: Key)
            
        case "UIColor":
            UserDefaults.standard.set(Value as! UIColor, forKey: Key)
            
        case "UUID":
            UserDefaults.standard.set(Value as! UUID, forKey: Key)
            
        case "String":
            UserDefaults.standard.set(Value as! String, forKey: Key)
            
        default:
            return false
        }
        return true
    }
    
    /// Reset the given settings key to its default value.
    ///
    /// - Parameter Key: The key whose value will be reset to default.
    /// - Returns: True on success, false on failure.
    public static func Reset(Key: String) -> Bool
    {
        if let (TypeName, DefaultValue) = DefaultFor(Key: Key)
        {
            let OK = DoSet(Key: Key, TypeName: TypeName, Value: DefaultValue)
            return OK
        }
        else
        {
            return false
        }
    }
    
    /// Reset the keys in the passed list of keys.
    ///
    /// - Parameter Keys: List of keys to reset.
    /// - Returns: True on success, false on failure.
    public static func Reset(Keys: [String]) -> Bool
    {
        for Key in Keys
        {
            let OK = Reset(Key: Key)
            if !OK
            {
                print("Failed at key: \(Key)")
                return false
            }
        }
        return true
    }
    
    /// Reset a group of keys as defined by the passed key group name.
    ///
    /// - Parameter KeyGroup: Name of the group of keys to reset.
    /// - Returns: True on success, false on failure.
    public static func ResetGroup(KeyGroup: String) -> Bool
    {
        if let KeyList = SettingGroups[KeyGroup]
        {
            return Reset(Keys: KeyList)
        }
        else
        {
            return false
        }
    }
    
    /// Reset all settings to default values.
    ///
    /// - Returns: True on success, false on failure.
    public static func ResetAll() -> Bool
    {
        for GroupName in SettingGroups
        {
            let OK = ResetGroup(KeyGroup: GroupName.key)
            if !OK
            {
                print("Failed group: \(GroupName)")
                return false
            }
        }
        return true
    }
    
    /// Dump the value of an individual setting, cast to a string.
    ///
    /// - Parameters:
    ///   - ForKey: Name of the setting key.
    ///   - AndType: Type of the setting.
    /// - Returns: Value of the setting (cast to a string).
    public static func DumpSetting(ForKey: String, AndType: String) -> String?
    {
        switch AndType
        {
        case "UUID":
            let UValue = _Settings.uuid(forKey: ForKey)
            return UValue.uuidString
            
        case "Int":
            let IValue = _Settings.integer(forKey: ForKey)
            return String(IValue)
            
        case "Double":
            let DValue = _Settings.double(forKey: ForKey)
            return String(DValue)
            
        case "String":
            if let SValue = _Settings.string(forKey: ForKey)
            {
                return SValue
            }
            return ""
            
        case "Bool":
            let Flag = _Settings.bool(forKey: ForKey)
            return String(Flag)
            
        case "UIColor":
            if let UValue = _Settings.uicolor(forKey: ForKey)
            {
                return Utility.PrintHSBColor(UValue)
            }
            return ""
            
        default:
            return "Unknown: \"\(AndType)\""
        }
    }
    
    /// Dump all settings to a list of tuples.
    ///
    /// - Parameter Excluding: List of types to exclude. Set to nil (or don't specify) to dump all types.
    /// - Returns: List of dumped settings, each as a tuple. Item 1 is the type, item 2 is the setting key name, and
    ///            item 3 is the setting value cast to a string.
    public static func DumpSettings(Excluding: [String]? = nil) -> [(String,String,String)]
    {
        var Results = [(String,String,String)]()
        let KnownTypes = GetSettingTypes()
        var LookForTypes = [String]()
        if let Excluding = Excluding
        {
            LookForTypes = KnownTypes.filter{Excluding.contains($0)}
        }
        else
        {
            LookForTypes = KnownTypes
        }
        for SomeType in LookForTypes
        {
            let TypeSettings = SettingsFor(TypeOf: SomeType)
            for TheSetting in TypeSettings
            {
                var SettingValue = DumpSetting(ForKey: TheSetting, AndType: SomeType)
                if SettingValue == nil
                {
                    SettingValue = "not found"
                }
                Results.append((SomeType, TheSetting, SettingValue!))
            }
        }
        return Results
    }
    
    // MARK: - Functions used by background color settings.
    
    private static func GetHueKey(ForIndex: Int) -> String?
    {
        switch ForIndex
        {
        case 1:
            return Key.BackgroundColors.BGColor1Hue
            
        case 2:
            return Key.BackgroundColors.BGColor2Hue
            
        case 3:
            return Key.BackgroundColors.BGColor3Hue
            
        default:
            return nil
        }
    }
    
    private static func GetSaturationKey(ForIndex: Int) -> String?
    {
        switch ForIndex
        {
        case 1:
            return Key.BackgroundColors.BGColor1Sat
            
        case 2:
            return Key.BackgroundColors.BGColor2Sat
            
        case 3:
            return Key.BackgroundColors.BGColor3Sat
            
        default:
            return nil
        }
    }
    
    private static func GetBrightnessKey(ForIndex: Int) -> String?
    {
        switch ForIndex
        {
        case 1:
            return Key.BackgroundColors.BGColor1Bri
            
        case 2:
            return Key.BackgroundColors.BGColor2Bri
            
        case 3:
            return Key.BackgroundColors.BGColor3Bri
            
        default:
            return nil
        }
    }
    
    private static func GetDirectionKey(ForIndex: Int) -> String?
    {
        switch ForIndex
        {
        case 1:
            return Key.BackgroundColors.BGColor1Direction
            
        case 2:
            return Key.BackgroundColors.BGColor2Direction
            
        case 3:
            return Key.BackgroundColors.BGColor3Direction
            
        default:
            return nil
        }
    }
    
    private static func GetIsDynamicKey(ForIndex: Int) -> String?
    {
        switch ForIndex
        {
        case 1:
            return Key.BackgroundColors.BGColor1IsDynamic
            
        case 2:
            return Key.BackgroundColors.BGColor2IsDynamic
            
        case 3:
            return Key.BackgroundColors.BGColor3IsDynamic
            
        default:
            return nil
        }
    }
    
    private static func GetTimePeriodKey(ForIndex: Int) -> String?
    {
        switch ForIndex
        {
        case 1:
            return Key.BackgroundColors.BGColor1TimePeriod
            
        case 2:
            return Key.BackgroundColors.BGColor2TimePeriod
            
        case 3:
            return Key.BackgroundColors.BGColor3TimePeriod
            
        default:
            return nil
        }
    }
    
    private static func GetGrayscaleKey(ForIndex: Int) -> String?
    {
        switch ForIndex
        {
        case 1:
            return Key.BackgroundColors.BGColor1IsGrayscale
            
        case 2:
            return Key.BackgroundColors.BGColor2IsGrayscale
            
        case 3:
            return Key.BackgroundColors.BGColor3IsGrayscale
            
        default:
            return nil
        }
    }
    
    /// Load a background color from settings.
    ///
    /// - Parameter For: Determines which color to load.
    /// - Returns: Loaded background color on success, nil on failure.
    public static func GetBackgroundColor(For: Int) -> BackgroundColors?
    {
        var Index = For
        if Index < 1
        {
            Index = 1
        }
        if Index > 3
        {
            Index = 3
        }
        let BGColors = BackgroundColors()
        BGColors.ColorIndex = Index
        if let HueKey = GetHueKey(ForIndex: Index)
        {
            BGColors.Hue = CGFloat(_Settings.double(forKey: HueKey))
        }
        else
        {
            return nil
        }
        if let SaturationKey = GetSaturationKey(ForIndex: Index)
        {
            BGColors.Saturation = CGFloat(_Settings.double(forKey: SaturationKey))
        }
        else
        {
            return nil
        }
        if let BrightnessKey = GetBrightnessKey(ForIndex: Index)
        {
            BGColors.Brightness = CGFloat(_Settings.double(forKey: BrightnessKey))
        }
        else
        {
            return nil
        }
        if let DirectionKey = GetDirectionKey(ForIndex: Index)
        {
            BGColors.Direction = _Settings.integer(forKey: DirectionKey)
        }
        else
        {
            return nil
        }
        if let IsDynamicKey = GetIsDynamicKey(ForIndex: Index)
        {
            BGColors.IsDynamic = _Settings.bool(forKey: IsDynamicKey)
        }
        else
        {
            return nil
        }
        if let TimePeriodKey = GetTimePeriodKey(ForIndex: Index)
        {
            BGColors.TimePeriod = _Settings.integer(forKey: TimePeriodKey)
        }
        else
        {
            return nil
        }
        if let GrayscaleKey = GetGrayscaleKey(ForIndex: Index)
        {
            BGColors.IsGrayscale = _Settings.bool(forKey: GrayscaleKey)
        }
        else
        {
            return nil
        }
        return BGColors
    }
    
    /// Save the contents of a background color to user settings.
    ///
    /// - Parameter BGColor: The background color to save.
    /// - Returns: True on success, false on failure.
    @discardableResult public static func SetBackgroundColor(With BGColor: BackgroundColors) -> Bool
    {
        if !BGColor.IsDirty
        {
            return true
        }
        let Index = BGColor.ColorIndex
        print("SetBackgroundColor: Index=\(Index)")
        if BGColor.HueChanged
        {
            if let HueKey = GetHueKey(ForIndex: Index)
            {
                _Settings.set(BGColor.Hue, forKey: HueKey)
            }
            else
            {
                return false
            }
        }
        if BGColor.SaturationChanged
        {
            if let SatKey = GetSaturationKey(ForIndex: Index)
            {
                _Settings.set(BGColor.Saturation, forKey: SatKey)
            }
            else
            {
                return false
            }
        }
        if BGColor.BrightnessChanged
        {
            if let BriKey = GetBrightnessKey(ForIndex: Index)
            {
                _Settings.set(BGColor.Brightness, forKey: BriKey)
            }
            else
            {
                return false
            }
        }
        if BGColor.DirectionChanged
        {
            if let DirKey = GetDirectionKey(ForIndex: Index)
            {
                _Settings.set(BGColor.Direction, forKey: DirKey)
            }
            else
            {
                return false
            }
        }
        if BGColor.IsDynamicChanged
        {
            if let DynKey = GetIsDynamicKey(ForIndex: Index)
            {
                _Settings.set(BGColor.IsDynamic, forKey: DynKey)
            }
            else
            {
                return false
            }
        }
        if BGColor.TimePeriodChanged
        {
            if let PeriodKey = GetTimePeriodKey(ForIndex: Index)
            {
                _Settings.set(BGColor.TimePeriod, forKey: PeriodKey)
            }
            else
            {
                return false
            }
        }
        if BGColor.IsGrayscaleChanged
        {
            if let GrayscaleKey = GetGrayscaleKey(ForIndex: Index)
            {
                _Settings.set(BGColor.IsGrayscale, forKey: GrayscaleKey)
            }
            else
            {
                return false
            }
        }
        let Value = "\(BGColor.ColorIndex)"
        SendNotice(Key: "BGColorChanged", Value: Value)
        return true
    }
    
    // MARK: Observing functions.
    
    public static func AddObserver(_ observer: NSObject, selector TheSelector: Selector, Paths: [String])
    {
        NotificationCenter.default.addObserver(observer, selector: TheSelector,
                                               name: UserDefaults.didChangeNotification, object: nil)
        for KeyPath in Paths
        {
            observer.addObserver(observer, forKeyPath: KeyPath, options: NSKeyValueObservingOptions.new, context: nil)
        }
    }
    
    public static func RemoveObservers(_ from: NSObject, Paths: [String], RemoveNotification: Bool = true)
    {
        if RemoveNotification
        {
            NotificationCenter.default.removeObserver(from, name: UserDefaults.didChangeNotification, object: nil)
        }
        for KeyPath in Paths
        {
            from.removeObserver(from, forKeyPath: KeyPath)
        }
    }
}

// MARK: - UserDefaults extension to implement getting and saving non-standard types. Types added: UUID, UIColor.
extension UserDefaults
{
    /// Determines if a particular key is present in user defaults.
    ///
    /// - Parameter KeyName: The name of the key to determine is present or not.
    /// - Returns: True if the key is present, false if not.
    func KeyIsPresent(_ KeyName: String) -> Bool
    {
        return self.object(forKey: KeyName) != nil
    }
    
    /// Sets the value of the specified default key to the specified UUID value.
    ///
    /// - Parameters:
    ///   - Value: The UUID value to store in the defaults database.
    ///   - defaultName: The key with which to associate the value.
    func set(_ Value: UUID, forKey defaultName: String)
    {
        let stemp = Value.uuidString
        set(stemp, forKey: defaultName)
    }
    
    /// Returns the UUID associated with the specified key.
    ///
    /// - Parameter defaultName: A key in the current user's defaults database.
    /// - Returns: The UUID associated with the specified key. Returns an empty UUID if the default does not exist or the stored value
    ///            cannot be converted.
    func uuid(forKey defaultName: String) -> UUID
    {
        let EmptyUUID: UUID = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
        if !KeyExists(key: defaultName)
        {
            return EmptyUUID
        }
        if let scratch = string(forKey: defaultName)
        {
            return UUID(uuidString: scratch)!
        }
        return EmptyUUID
    }
    
    /// Sets the value of the specified default key to the specified UIColor value.
    ///
    /// - Parameters:
    ///   - Value: The UIColor value to store in the defaults database.
    ///   - defaultName: The key with which to associate the value.
    func set(_ Value: UIColor, forKey defaultName: String)
    {
        let stemp = Utility.ToHexString(Value, IncludeAlpha: true)
        set(stemp, forKey: defaultName)
    }
    
    /// Set the same color value to a set of keys. All keys must point to settings of the same type.
    ///
    /// - Parameters:
    ///   - Value: The UIColor value to store in the defaults database.
    ///   - forKeys: List of keys. The passed color will be stored in all settings pointed to by this list.
    func set(_ Value: UIColor, forKeys: [String])
    {
        if forKeys.isEmpty
        {
            return
        }
        for Key in forKeys
        {
            set(Value, forKey: Key)
        }
    }
    
    /// Returns the UIColor associated with the specified key.
    ///
    /// - Parameter defaultName: A key in the current user's defaults database.
    /// - Returns: The UIColor associated with the specified key. Returns an nil if the default does not exist or the stored value
    ///            cannot be converted.
    func uicolor(forKey defaultName: String) -> UIColor?
    {
        if !KeyExists(key: defaultName)
        {
            //print("Cannot find \"\(defaultName)\"")
            return nil
        }
        if let scratch = string(forKey: defaultName)
        {
            if let FinalColor = Utility.FromHex2(HexString: scratch)
            {
                return FinalColor
            }
            //print("Error converting \"\(scratch)\" to color.")
            return nil
        }
        //print("Error retrieving value for string \"\(defaultName)\"")
        return nil
    }
    
    /// Determines if the current user's defaults database contains the specified key.
    ///
    /// - Parameter key: The key to search for in the user's defaults database.
    /// - Returns: True if the key was found, false if not.
    func KeyExists(key: String) -> Bool
    {
        return object(forKey: key) != nil
    }
    
    /// Set the same integer value to a set of keys. All keys must point to settings of the same type.
    ///
    /// - Parameters:
    ///   - Value: The integer value to store in the defaults database.
    ///   - forKeys: List of keys. The passed color will be stored in all settings pointed to by this list.
    func set(_ Value: Int, forKeys: [String])
    {
        if forKeys.isEmpty
        {
            return
        }
        for Key in forKeys
        {
            set(Value, forKey: Key)
        }
    }
    
    /// Set the same double value to a set of keys. All keys must point to settings of the same type.
    ///
    /// - Parameters:
    ///   - Value: The double value to store in the defaults database.
    ///   - forKeys: List of keys. The passed color will be stored in all settings pointed to by this list.
    func set(_ Value: Double, forKeys: [String])
    {
        if forKeys.isEmpty
        {
            return
        }
        for Key in forKeys
        {
            set(Value, forKey: Key)
        }
    }
    
    /// Set the same CGFloat value to a set of keys. All keys must point to settings of the same type.
    ///
    /// - Parameters:
    ///   - Value: The CGFloat value to store in the defaults database.
    ///   - forKeys: List of keys. The passed color will be stored in all settings pointed to by this list.
    func set(_ Value: CGFloat, forKeys: [String])
    {
        if forKeys.isEmpty
        {
            return
        }
        for Key in forKeys
        {
            set(Value, forKey: Key)
        }
    }
    
    /// Set the same string value to a set of keys. All keys must point to settings of the same type.
    ///
    /// - Parameters:
    ///   - Value: The string value to store in the defaults database.
    ///   - forKeys: List of keys. The passed color will be stored in all settings pointed to by this list.
    func set(_ Value: String, forKeys: [String])
    {
        if forKeys.isEmpty
        {
            return
        }
        for Key in forKeys
        {
            set(Value, forKey: Key)
        }
    }
    
    /// Set the same boolean value to a set of keys. All keys must point to settings of the same type.
    ///
    /// - Parameters:
    ///   - Value: The boolean value to store in the defaults database.
    ///   - forKeys: List of keys. The passed color will be stored in all settings pointed to by this list.
    func set(_ Value: Bool, forKeys: [String])
    {
        if forKeys.isEmpty
        {
            return
        }
        for Key in forKeys
        {
            set(Value, forKey: Key)
        }
    }
}
