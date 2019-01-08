//
//  BackgroundColors.swift
//  Barcode Clock
//
//  Created by Stuart Rankin on 8/27/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class BackgroundColors
{
    /// Get the dirty flag for the class. If any color setting saved here changed, true is
    /// returned. Otherwise, false is returned.
    public var IsDirty: Bool
    {
        get
        {
            return HueChanged || SaturationChanged || BrightnessChanged ||
                   DirectionChanged || IsDynamicChanged || TimePeriodChanged ||
                   IsGrayscaleChanged
        }
    }
    
    /// Clear the dirty flag.
    public func ClearDirtyFlag()
    {
        HueChanged = false
        SaturationChanged = false
        BrightnessChanged = false
        DirectionChanged = false
        IsDynamicChanged = false
        TimePeriodChanged = false
        IsGrayscaleChanged = false
    }
    
    private var _ColorIndex: Int = 1
    /// Get or set the color index value.
    public var ColorIndex: Int
    {
        get
        {
            return _ColorIndex
        }
        set
        {
            _ColorIndex = newValue
        }
    }
    
    /// Create a UIColor from the color components.
    ///
    /// - Parameter IsInDarkMode: If true, the returned color is modified for dark mode.
    /// - Returns: UIColor created from the current color components.
    public func Color(IsInDarkMode: Bool = false) -> UIColor
    {
        var TheColor: UIColor!
        if IsGrayscale
        {
            TheColor = UIColor(white: Brightness, alpha: 1.0)
        }
        else
        {
            TheColor = UIColor(hue: Hue, saturation: Saturation, brightness: Brightness, alpha: 1.0)
        }
        return TheColor
    }
    
    /// Return the string equivalent of the color.
    ///
    /// - Returns: String equivalent of the values of the color (in HSB).
    public func ToString() -> String
    {
        if IsGrayscale
        {
            return Utility.PrintGrayscaleColor(Color())
        }
        else
        {
            return Utility.PrintHSBColor(Color())
        }
    }
    
    public var IsGrayscaleChanged: Bool = false
    private var _IsGrayscale: Bool = false
    /// Get or set the grayscale flag.
    public var IsGrayscale: Bool
    {
        get
        {
            return _IsGrayscale
        }
        set
        {
            _IsGrayscale = newValue
            IsGrayscaleChanged = true
        }
    }
    
    public var HueChanged: Bool = false
    private var _Hue: CGFloat = 0.0
    /// Get or set the hue of the color.
    public var Hue: CGFloat
    {
        get
        {
            return _Hue
        }
        set
        {
            _Hue = newValue
            HueChanged = true
        }
    }
    
    public var SaturationChanged: Bool = false
    private var _Saturation: CGFloat = 0.0
    /// Get or set the saturation of the color.
    public var Saturation: CGFloat
    {
        get
        {
            return _Saturation
        }
        set
        {
            _Saturation = newValue
            SaturationChanged = true
        }
    }
    
    public var BrightnessChanged: Bool = false
    private var _Brightness: CGFloat = 0.0
    /// Get or set the brightness of the color. When in Grayscale mode, sets the white level.
    public var Brightness: CGFloat
    {
        get
        {
            return _Brightness
        }
        set
        {
            _Brightness = newValue
            BrightnessChanged = true
        }
    }
    
    public var DirectionChanged: Bool = false
    private var _Direction: Int = 0
    /// Get or set the color direction for when it changes.
    public var Direction: Int
    {
        get
        {
            return _Direction
        }
        set
        {
            _Direction = newValue
            DirectionChanged = true
        }
    }
    
    public var IsDynamicChanged: Bool = false
    private var _IsDynamic: Bool = true
    /// Get or set the dynamic setting (eg, color changes) for the color.
    public var IsDynamic: Bool
    {
        get
        {
            return _IsDynamic
        }
        set
        {
            _IsDynamic = newValue
            IsDynamicChanged = true
        }
    }
    
    public var TimePeriodChanged: Bool = false
    private var _TimePeriod: Int = 0
    /// Get or set the time period for the color.
    public var TimePeriod: Int
    {
        get
        {
            return _TimePeriod
        }
        set
        {
            _TimePeriod = newValue
            TimePeriodChanged = true
        }
    }
    
    /// Move the color to a new time. Color's hue is the base hue and the time percent for the
    /// time period is added to the base for the result. If the color isn't dynamic, the base color is returned.
    ///
    /// - Parameter ToTime: Determines the offset to add to the base hue.
    /// - Returns: New color based on the base color hue and the time and the time period.
    public func MoveColor(ToTime: Date) -> UIColor
    {
        if !IsDynamic
        {
            return Color()
        }
        let PeriodPercent = Times.Percent(Period: TimePeriod, Now: ToTime)
        var WorkingHue = (Hue * 360.0) + CGFloat(PeriodPercent * 360.0)
        WorkingHue = fmod(WorkingHue, 360.0)
        WorkingHue = WorkingHue / 360.0
        if Direction == 1
        {
            WorkingHue = 1.0 - WorkingHue
        }
        let Final = UIColor(hue: WorkingHue, saturation: Saturation, brightness: Brightness, alpha: 1.0)
        return Final
    }
    
    /// Move the brightness to a new time. The brightness is the sum of the base brightness and the time percent
    /// for the time period. If the color isn't dynamic, the base brightness/whiteness is returned.
    ///
    /// - Parameter ToTime: Determines the offset to add to the base hue.
    /// - Returns: New grayscale color based on the base brightness and the time and the time period.
    public func MoveBrightness(ToTime: Date) -> UIColor
    {
        if !IsDynamic
        {
            return Color()
        }
        let PeriodPercent = Times.Percent(Period: TimePeriod, Now: ToTime)
        var WorkingBrightness = Brightness + CGFloat(PeriodPercent)
        WorkingBrightness = fmod(WorkingBrightness, 1.0)
        if Direction == 1
        {
            WorkingBrightness = 1.0 - WorkingBrightness
        }
        let Final = UIColor(white: WorkingBrightness, alpha: 1.0)
        return Final
    }
    
    /// Move the color to a new time. The actual property moved depends on the grayscale flag.
    ///
    /// - Parameter ToTime: Determines the offset to add to the base.
    /// - Returns: New color based on the base property and the time and the color's time period.
    public func Move(ToTime: Date) -> UIColor
    {
        if IsGrayscale
        {
            return MoveBrightness(ToTime: ToTime)
        }
        else
        {
            return MoveColor(ToTime: ToTime)
        }
    }
}
