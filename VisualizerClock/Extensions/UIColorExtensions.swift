//
//  UIColorExtensions.swift
//  Visualizer Clock
//
//  Created by Stuart Rankin on 9/27/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

//https://medium.com/ios-os-x-development/ios-extend-uicolor-with-custom-colors-93366ae148e6
extension UIColor
{
    /// Create a UIColor with the unnormalized RGB values. Alpha is set to 1.0.
    ///
    /// - Parameters:
    ///   - red: Red value (between 0 and 255).
    ///   - green: Green value (between 0 and 255).
    ///   - blue: Blue value (between 0 and 255).
    convenience init(red: Int, green: Int, blue: Int)
    {
        self.init(red: CGFloat(Utility.ForceToValidRange(red, ValidRange: 0...255)),
                  green: CGFloat(Utility.ForceToValidRange(green, ValidRange: 0...255)),
                  blue: CGFloat(Utility.ForceToValidRange(blue, ValidRange: 0...255)),
                  alpha: 1.0)
    }
    
    /// Create a UIColor with the lower 24-bits of the passed integer. Alpha is set to 1.0.
    ///
    /// - Parameter Hex: Numeric color value. Only the lower 24-bits are used. The colors are in rrggbb order.
    convenience init(Hex: Int)
    {
        self.init(red: (Hex) >> 16 & 0xff, green: (Hex >> 8) & 0xff, blue: Hex & 0xff)
    }
    
    /// Return a desaturated color based on the source color.
    ///
    /// - Parameter Source: Color that will be desaturated (eg, saturation set to 0.0).
    /// - Returns: Desaturated version of the passed color.
    public static func Desaturated(_ Source: UIColor) -> UIColor
    {
        var Hue: CGFloat = 0.0
        var Saturation: CGFloat = 0.0
        var Brightness: CGFloat = 0.0
        var Alpha: CGFloat = 0.0
        Source.getHue(&Hue, saturation: &Saturation, brightness: &Brightness, alpha: &Alpha)
        return UIColor(hue: Hue, saturation: 0.0, brightness: Brightness, alpha: Alpha)
    }
    
    /// Return a grayscale color based on the source color.
    ///
    /// - Parameter Source: Color that will be grayscaled.
    /// - Returns: Grayscale version of the passed color.
    public static func Grayscale(_ Source: UIColor) -> UIColor
    {
        var Red: CGFloat = 0.0
        var Green: CGFloat = 0.0
        var Blue: CGFloat = 0.0
        var Alpha: CGFloat = 0.0
        Source.getRed(&Red, green: &Green, blue: &Blue, alpha: &Alpha)
        let Gray = (Red * 0.3 + Green * 0.59 + Blue * 0.11)
        return UIColor(red: Gray, green: Gray, blue: Gray, alpha: Alpha)
    }
    
    /// Pretty print a color.
    ///
    /// - Parameters:
    ///   - Color: The color to pretty print.
    ///   - ColorEditorColorSpaces: The color space the returned string is in.
    /// - Returns: String representation of the color in the appropriate color space (as determined by InColorSpace).
    public static func PrettyPrint(_ Color: UIColor, _ InColorSpace: ColorEditorColorSpaces = .RGB) -> String
    {
        var Final = ""
        switch InColorSpace
        {
        case .HSB:
            let (h, s, b) = Utility.GetHSB(SourceColor: Color)
            let Hue = Utility.Round(h, ToPlaces: 2)
            let Sat = Utility.Round(s, ToPlaces: 2)
            let Bri = Utility.Round(b, ToPlaces: 2)
            let HueS = String(Double(Hue))
            let SatS = String(Double(Sat))
            let BriS = String(Double(Bri))
            Final = "(\(HueS),\(SatS),\(BriS))"
            
        case .CMYK:
            let (c, m, y, k) = Utility.ToCMYK(Color)
            let Cyan = Utility.Round(c, ToPlaces: 2)
            let Magenta = Utility.Round(m, ToPlaces: 2)
            let Yellow = Utility.Round(y, ToPlaces: 2)
            let Black = Utility.Round(k, ToPlaces: 2)
            Final = "(\(Cyan),\(Magenta),\(Yellow),\(Black))"
            
        case .RGB:
            fallthrough
        case .RGBA:
            let (r, g, b, a) = Utility.GetARGB(SourceColor: Color)
            let Red: Int = Int(r * 255.0)
            let Green: Int = Int(g * 255.0)
            let Blue: Int = Int(b * 255.0)
            let Alpha: Int = Int(a * 255.0)
            if InColorSpace == .RGBA
            {
                Final = "(\(Red),\(Green),\(Blue),\(Alpha))"
            }
            else
            {
                Final = "(\(Red),\(Green),\(Blue))"
            }
        }
        return Final
    }
    
    struct FlatColor
    {
        struct Green
        {
            static let Fern = UIColor(Hex: 0x6abb72)
            static let MountainMeadow = UIColor(Hex: 0x3abb9d)
            static let ChateauGreen = UIColor(Hex: 0x4da664)
            static let PersianGreen = UIColor(Hex: 0x2ca786)
        }
        
        struct Blue
        {
            static let PictonBlue = UIColor(Hex: 0x5CADCF)
            static let Mariner = UIColor(Hex: 0x3585C5)
            static let CuriousBlue = UIColor(Hex: 0x4590B6)
            static let Denim = UIColor(Hex: 0x2F6CAD)
            static let Chambray = UIColor(Hex: 0x485675)
            static let BlueWhale = UIColor(Hex: 0x29334D)
        }
        
        struct Violet
        {
            static let Wisteria = UIColor(Hex: 0x9069B5)
            static let BlueGem = UIColor(Hex: 0x533D7F)
        }
        
        struct Yellow
        {
            static let Energy = UIColor(Hex: 0xF2D46F)
            static let Turbo = UIColor(Hex: 0xF7C23E)
        }
        
        struct Orange
        {
            static let NeonCarrot = UIColor(Hex: 0xF79E3D)
            static let Sun = UIColor(Hex: 0xEE7841)
        }
        
        struct Red
        {
            static let TerraCotta = UIColor(Hex: 0xE66B5B)
            static let Valencia = UIColor(Hex: 0xCC4846)
            static let Cinnabar = UIColor(Hex: 0xDC5047)
            static let WellRead = UIColor(Hex: 0xB33234)
        }
        
        struct Gray
        {
            static let AlmondFrost = UIColor(Hex: 0xA28F85)
            static let WhiteSmoke = UIColor(Hex: 0xefefef)
            static let Iron = UIColor(Hex: 0xD1D5D8)
            static let IronGray = UIColor(Hex: 0x75706B)
        }
    }
}
