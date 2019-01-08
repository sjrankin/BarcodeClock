//
//  TimeFormatter.swift
//  Visualizer Clock
//
//  Created by Stuart Rankin on 11/29/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class TimeFormatter
{
    static let _Settings = UserDefaults.standard
    
    /// Sets the current time in the user-specified content and visual formats in the passed
    /// UILabel. User settings form the source for the options used here.
    ///
    /// - Parameters:
    ///   - Now: The time to display.
    ///   - Output: Where to display the time, eg, where the output is placed.
    public static func GetDisplayTime(_ Now: Date, Output: UILabel)
    {
        let Cal = Calendar.current
        var Hour = Cal.component(.hour, from: Now)
        var AddAMPM = false
        var IsAM = false
        if !_Settings.bool(forKey: Setting.Key.Text.Use24HourTime)
        {
            if Hour <= 12
            {
                IsAM = true
            }
            Hour = Hour % 12
            if Hour == 0
            {
                Hour = 12
            }
            if _Settings.bool(forKey: Setting.Key.Text.ShowAMPM)
            {
                AddAMPM = true
            }
        }
        var HourS = String(Hour)
        if _Settings.bool(forKey: Setting.Key.Text.Use24HourTime)
        {
            if Hour < 10
            {
                HourS = "0" + HourS
            }
        }
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
        if _Settings.bool(forKey: Setting.Key.Text.ShowSeconds)
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
        if let FontName = _Settings.string(forKey: Setting.Key.Text.FontName)
        {
            ClockFontName = FontName
        }
        var Template = "00:00"
        if _Settings.bool(forKey: Setting.Key.Text.ShowSeconds)
        {
            Template = Template + ":00"
        }
        if _Settings.bool(forKey: Setting.Key.Text.ShowAMPM)
        {
            Template = Template + " AM"
        }
        
        //https://stackoverflow.com/questions/29914628/resize-text-to-fit-a-label-in-swift
        //https://stackoverflow.com/questions/8812192/how-to-set-font-size-to-fill-uilabel-height
        Output.adjustsFontSizeToFitWidth = true
        Output.minimumScaleFactor = 0.1
        Output.lineBreakMode = .byClipping
        Output.numberOfLines = _Settings.bool(forKey: Setting.Key.Text.LandscapeTimeFitsSpace) ? 0 : 1
        var FontSize: CGFloat = 200.0
        
        var Attributes: [NSAttributedString.Key: Any]!
        let TheFont = UIFont(name: ClockFontName, size: FontSize)
        
        if _Settings.bool(forKey: Setting.Key.Text.OutlineText)
        {
            var Thickness = _Settings.integer(forKey: Setting.Key.TextStrokeThickness)
            if Thickness < 1
            {
                Thickness = 2
                _Settings.set(Thickness, forKey: Setting.Key.TextStrokeThickness)
            }
            let OutlineColor = _Settings.uicolor(forKey: Setting.Key.Text.OutlineColor)
            let InsideColor = _Settings.uicolor(forKey: Setting.Key.Text.Color)
            Attributes = MakeOutlineTextAttributes(Font: TheFont!,
                                                   InteriorColor: InsideColor!,
                                                   StrokeColor: OutlineColor!,
                                                   StrokeThickness: Thickness)
        }
        else
        {
            let InsideColor = _Settings.uicolor(forKey: Setting.Key.Text.Color)
            Attributes = MakeTextAttributes(Font: TheFont!, InteriorColor: InsideColor!)
        }
        
        //If the user set the rather obscure setting for time to fill vertial space when in landscape mode
        //and we're actually in landscape mode, break up the time by colons and insert new lines at each
        //colon and reassemble.
        if _Settings.bool(forKey: Setting.Key.Text.LandscapeTimeFitsSpace) && !Utility.InPortraitOrientation()
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
        
        let OutputString = NSMutableAttributedString(string: Message, attributes: Attributes)
        Output.attributedText = OutputString
        
        switch _Settings.integer(forKey: Setting.Key.Text.HighlightType)
        {
        case 0:
            //No highlighting.
            Output.layer.shadowColor = UIColor.clear.cgColor
            Output.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
            Output.layer.shadowOpacity = 0.0
            
        case 1:
            //Shadow highlighting.
            let (ShadowColor, ShadowSize, ShadowOpacity, ShadowRadius) = GetShadowData(Level: _Settings.integer(forKey: Setting.Key.Text.ShadowType))
            Output.layer.shadowColor = ShadowColor.cgColor
            Output.layer.shadowOffset = ShadowSize
            Output.layer.shadowRadius = ShadowRadius
            Output.layer.shadowOpacity = ShadowOpacity
            Output.backgroundColor = UIColor.clear
            
        case 2:
            //Glow highlighting.
            //https://www.hackingwithswift.com/example-code/calayer/how-to-make-a-uiview-glow-using-shadowcolor
            let Level = _Settings.integer(forKey: Setting.Key.Text.GlowType)
            let (GlowColor, GlowSize, GlowOpacity, GlowRadius) = GetGlowData(Level: Level)
            Output.layer.shadowColor = GlowColor.cgColor
            Output.layer.shadowOffset = GlowSize
            Output.layer.shadowRadius = GlowRadius
            Output.layer.shadowOpacity = GlowOpacity
            //Output.layer.masksToBounds = false
            //let ColorValue = Utility.ColorToString(GlowColor)
            //print("Glow(\(Level)): \(ColorValue), \(GlowOpacity), \(GlowRadius)")
            
        default:
            //Defaults to no highlighting.
            Output.layer.shadowColor = UIColor.clear.cgColor
            Output.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
            Output.layer.shadowOpacity = 0.0
        }
    }
    
    /// Create an array of text attributes that can be applied to an attributed string that include attributes for stroked text.
    ///
    /// - Parameters:
    ///   - Font: The font of the text.
    ///   - InteriorColor: The interior (fill) color of the text.
    ///   - StrokeColor: The stroke (exterior) color of the text.
    ///   - StrokeThickness: The thickness of the text.
    /// - Returns: Array of attributes that can be applied to an attributed string.
    private static func MakeOutlineTextAttributes(Font: UIFont, InteriorColor: UIColor, StrokeColor: UIColor, StrokeThickness: Int) -> [NSAttributedString.Key : Any]
    {
        return [
            NSAttributedString.Key.foregroundColor: InteriorColor,
            NSAttributedString.Key.strokeColor: StrokeColor,
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
    private static func MakeTextAttributes(Font: UIFont, InteriorColor: UIColor) -> [NSAttributedString.Key : Any]
    {
        return [
            NSAttributedString.Key.foregroundColor: InteriorColor,
            NSAttributedString.Key.font: Font
        ]
    }
    
    private static func GetShadowData(Level: Int) -> (UIColor, CGSize, Float, CGFloat)
    {
        var Radius: CGFloat = 0.0
        var Opacity: Float = 0.0
        var Size = CGSize.zero
        let Color = _Settings.uicolor(forKey: Setting.Key.Text.ShadowColor)
        switch Level
        {
        case 0:
            break
            
        case 1:
            Radius = 0.5
            Opacity = 0.4
            Size = CGSize(width: 2, height: 2)
            
        case 2:
            Radius = 1.0
            Opacity = 0.5
            Size = CGSize(width: 3, height: 3)
            
        case 3:
            Radius = 2.0
            Opacity = 0.6
            Size = CGSize(width: 5, height: 5)
            
        default:
            break
        }
        
        return (Color!, Size, Opacity, Radius)
    }
    
    private static func GetGlowData(Level: Int) -> (UIColor, CGSize, Float, CGFloat)
    {
        var Radius: CGFloat = 0.0
        var Opacity: Float = 0.0
        let Size = CGSize.zero
        let Color = _Settings.uicolor(forKey: Setting.Key.Text.GlowColor)
        switch Level
        {
        case 0:
            break
            
        case 1:
            Radius = 2
            Opacity = 1
            
        case 2:
            Radius = 4
            Opacity = 1
            
        case 3:
            Radius = 7
            Opacity = 1
            
        default:
            break
        }
        
        return (Color!, Size, Opacity, Radius)
    }
}
