//
//  PredefinedColors.swift
//  Visualizer Clock
//
//  Created by Stuart Rankin on 11/6/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class PredefinedColors
{
    /// Ways to order predefined colors.
    ///
    /// - Name: Alphabetical by name.
    /// - NameList: Alphabetical by name but ungrouped.
    /// - Hue: By hue group.
    /// - Brightness: By brightness level.
    /// - Palette: Alphabetical by palette.
    public enum ColorOrders
    {
        case Name
        case NameList
        case Hue
        case Brightness
        case Palette
    }
    
    /// Return a list of color groups defined and ordered by the passed color order.
    ///
    /// - Parameter Order: Order of the colors. Also defines the type of color groups returned.
    /// - Returns: List of color groups.
    public static func ColorsInOrder(_ Order: ColorOrders) -> [PredefinedColorGroup]
    {
        switch Order
        {
        case .Name:
            return GetNameSortedColors()
            
        case .NameList:
            return GetNameSortedColorsUngrouped()
            
        case .Hue:
            return GetHueSortedColors()
            
        case .Brightness:
            return GetBrightnessSortedColors()
            
        case .Palette:
            return GetPaletteSortedColors()
        }
    }
    
    /// Return a color with the specified ID.
    ///
    /// - Parameter ID: ID of the color to return.
    /// - Returns: The color with the specified ID if found, nil if no color with the ID found.
    public static func ColorByID(_ ID: UUID) -> PredefinedColor?
    {
        for Color in PredefinedColorTable.Colors
        {
            if Color.ID == ID
            {
                return Color
            }
        }
        return nil
    }
    
    /// Holds the range for hue descriptions.
    static let HueRanges =
        [
            (355, 360, "Red", "355° - 10°"),
            (0, 10, "Red", "355° - 10°"),
            (11, 20, "Red-Orange", "11° - 20°"),
            (21, 40, "Orange & Brown", "21° - 40°"),
            (41, 50, "Orange-Yellow", "41° - 50°"),
            (51, 60, "Yellow", "51° - 60°"),
            (61, 80, "Yellow-Green", "61° - 80°"),
            (81, 140, "Green", "81° - 140°"),
            (141, 169, "Green-Cyan", "141° - 169°"),
            (170, 200, "Cyan", "170° - 200°"),
            (201, 220, "Cyan-Blue", "201° - 220°"),
            (221, 240, "Blue", "221° - 240°"),
            (241, 280, "Blue-Magenta", "241° - 280°ß"),
            (281, 320, "Magenta", "281° - 320°"),
            (321, 330, "Magenta-Pink", "321° - 330°"),
            (331, 345, "Pink", "331° - 345°"),
            (346, 355, "Pink-Red", "346° - 355°")
    ]
    
    /// Return the largest delta in the list of passed numbers.
    ///
    /// - Parameter Numbers: List of integers.
    /// - Returns: Largest delta in the list.
    private static func MaxDelta(_ Numbers: [CGFloat]) -> CGFloat
    {
        var Biggest: CGFloat = -1000000.0
        var Smallest: CGFloat = 1000000.0
        for Index in 0 ..< Numbers.count
        {
            if Numbers[Index] > Biggest
            {
                Biggest = Numbers[Index]
            }
            if Numbers[Index] < Smallest
            {
                Smallest = Numbers[Index]
            }
        }
        return abs(Biggest - Smallest)
    }
    
    /// Return the largest delta in the list of passed numbers.
    ///
    /// - Parameter Numbers: List of integers.
    /// - Returns: Largest delta in the list.
    private static func MaxDelta(_ Numbers: [Int]) -> Int
    {
        var Biggest: Int = -1000000
        var Smallest: Int = 1000000
        for Index in 0 ..< Numbers.count
        {
            if Numbers[Index] > Biggest
            {
                Biggest = Numbers[Index]
            }
            if Numbers[Index] < Smallest
            {
                Smallest = Numbers[Index]
            }
        }
        return abs(Biggest - Smallest)
    }
    
    private static func IsMonochromatic(_ TheColor: UIColor) -> Bool
    {
        let (R, G, B) = Utility.GetRGB(TheColor)
        let Delta = MaxDelta([R, G, B])
        return Delta == 0
    }
    
    /// Returns the starting range value for a given hue.
    ///
    /// - Parameter HueValue: The hue whose starting range value will be returned. Assumed to be normalized.
    /// - Returns: Starting hue range for the hue (see also HueRanges).
    private static func HueStartingRange(_ HueValue: Double) -> Double
    {
        let Hue = HueValue * 360.0
        let IHue = Int(Hue)
        for Range in HueRanges
        {
            if IHue >= Range.0 && IHue <= Range.1
            {
                return Double(Range.0)
            }
        }
        return -1.0
    }
    
    /// Return the name and range (as a string) of the hue passed to us.
    ///
    /// - Parameter HueValue: The hue value (normalized).
    /// - Returns: Tuple in the order name, range. If not found, "??","??" is returned.
    private static func GetHueGroupName(_ HueValue: Double) -> (String, String)
    {
        let Hue = HueValue * 360.0
        let IHue = Int(Hue)
        for Range in HueRanges
        {
            if IHue >= Range.0 && IHue <= Range.1
            {
                return (Range.2, Range.3)
            }
        }
        return ("??", "??")
    }
    
    /// Return a list of sorted color groups. Sorted by hue.
    ///
    /// - Returns: List of predefined color groups, sorted by hue.
    private static func GetHueSortedColors() -> [PredefinedColorGroup]
    {
        var Results = [PredefinedColorGroup]()
        
        for Color in PredefinedColorTable.Colors
        {
            if IsMonochromatic(Color.Color)
            {
                print("Found monochromatic color \(Color.ColorName)")
                let HueGroup = GroupWithName("Monochrome", Groups: Results)
                if HueGroup == nil
                {
                    let NewGroup = PredefinedColorGroup()
                    NewGroup.SortValue = -500.0
                    NewGroup.GroupName = "Monochrome"
                    NewGroup.GroupSubTitle = ""
                    NewGroup.OrderedBy = .Hue
                    NewGroup.GroupColors.append(Color)
                    Results.append(NewGroup)
                }
                else
                {
                    let HGroup = GroupWithName("Monochrome", Groups: Results)
                    if HGroup != nil
                    {
                        HGroup?.GroupColors.append(Color)
                    }
                }
                continue
            }
            let (HueGroupName, SubGroupName) = GetHueGroupName(Color.Hue)
            let HueGroup = GroupWithName(HueGroupName, Groups: Results)
            if HueGroup != nil
            {
                let HGroup = GroupWithName(HueGroupName, Groups: Results)
                if HGroup != nil
                {
                    HGroup?.GroupColors.append(Color)
                }
            }
            else
            {
                let NewGroup = PredefinedColorGroup()
                NewGroup.SortValue = HueStartingRange(Color.Hue)
                NewGroup.GroupName = HueGroupName
                NewGroup.GroupSubTitle = SubGroupName
                NewGroup.OrderedBy = .Hue
                NewGroup.GroupColors.append(Color)
                Results.append(NewGroup)
            }
        }
        
        Results.sort{$0.SortValue < $1.SortValue}
        for Result in Results
        {
            if Result.GroupName == "Monochrome"
            {
                Result.GroupColors.sort{$0.Brightness < $1.Brightness}
            }
            else
            {
            Result.GroupColors.sort{$0.Hue < $1.Hue}
            }
        }
        
        return Results
    }

    /// Create a brightness group name.
    ///
    /// - Parameter Value: Value of the brightness.
    /// - Returns: Name of a brightness group.
    private static func MakeBrightnessGroupName(_ Value: Double) -> String
    {
        var Working = Value
        Working = min(1.0, Working)
        Working = max(0.0, Working)
        let IWork = Int(Working * 10.0)
        switch IWork
        {
        case 0:
            return "0.0"
            
        case 1:
            return "0.1"
            
        case 2:
            return "0.2"
            
        case 3:
            return "0.3"
            
        case 4:
            return "0.4"
            
        case 5:
            return "0.5"
            
        case 6:
            return "0.6"
            
        case 7:
            return "0.7"
            
        case 8:
            return "0.8"
            
        case 9:
            return "0.9"
            
        case 10:
            return "1.0"
            
        default:
            return "???"
        }
    }
    
    /// Return a list of sorted color groups. Sorted by brightness.
    ///
    /// - Returns: List of predefined color groups, sorted by brightness.
    private static func GetBrightnessSortedColors() -> [PredefinedColorGroup]
    {
        var Results = [PredefinedColorGroup]()
        
        for Color in PredefinedColorTable.Colors
        {
            let BGroupName = MakeBrightnessGroupName(Color.Brightness)
            let BrightnessGroup = GroupWithName(BGroupName, Groups: Results)
            if BrightnessGroup != nil
            {
                let BGroup = GroupWithName(BGroupName, Groups: Results)
                if BGroup != nil
                {
                    BGroup?.GroupColors.append(Color)
                }
            }
            else
            {
                let NewGroup = PredefinedColorGroup()
                NewGroup.GroupName = BGroupName
                NewGroup.OrderedBy = .Brightness
                NewGroup.GroupColors.append(Color)
                Results.append(NewGroup)
            }
        }
        
        Results.sort{$0.GroupName < $1.GroupName}
        for Result in Results
        {
            Result.GroupColors.sort{$0.Brightness < $1.Brightness}
        }
        
        return Results
    }
    
    /// Determines if the list of groups contains the passed color name.
    ///
    /// - Parameters:
    ///   - Name: Name of the color to search for.
    ///   - Groups: List of groups to search for the passed name.
    /// - Returns: True if the name exists somewhere in the list of groups, false if not.
    private static func ContainsName(_ Name: String, Groups: [PredefinedColorGroup]) -> Bool
    {
        for Group in Groups
        {
            if Group.GroupName == Name
            {
                return true
            }
        }
        return false
    }
    
    /// Returns a predefined color group that contains a color with the passed name.
    ///
    /// - Parameters:
    ///   - Name: Name of the color to search for.
    ///   - Groups: List of pre-defined color groups to search.
    /// - Returns: The first pre-defined color group with the passed name if found, nil if nothing found.
    private static func GroupWithName(_ Name: String, Groups: [PredefinedColorGroup]) -> PredefinedColorGroup?
    {
        for Group in Groups
        {
            if Group.GroupName == Name
            {
                return Group
            }
        }
        return nil
    }
    
    /// Return a list of sorted color groups. Sorted by palette name.
    ///
    /// - Returns: List of predefined color groups, sorted by palette name.
    private static func GetPaletteSortedColors() -> [PredefinedColorGroup]
    {
        var Results = [PredefinedColorGroup]()
        
        for Color in PredefinedColorTable.Colors
        {
            let PaletteName = Color.Palette
            let PaletteGroup = GroupWithName(PaletteName, Groups: Results)
            if PaletteGroup != nil
            {
                PaletteGroup?.GroupColors.append(Color)
            }
            else
            {
                let NewGroup = PredefinedColorGroup()
                NewGroup.GroupName = PaletteName
                NewGroup.OrderedBy = .Palette
                NewGroup.GroupColors.append(Color)
                Results.append(NewGroup)
            }
        }
        
        Results.sort{$0.GroupName.lowercased() < $1.GroupName.lowercased()}
        for Result in Results
        {
            Result.GroupColors.sort{$0.ColorName < $1.ColorName}
        }
        
        return Results
    }
    
    /// Return a list of sorted color groups. Sorted by color name. (Returned list of pre-defined colors is sorted by
    /// pre-defined color group name.)
    ///
    /// - Returns: List of predefined color groups, sorted by color name.
    private static func GetNameSortedColors() -> [PredefinedColorGroup]
    {
        var Results = [PredefinedColorGroup]()
        
        for Color in PredefinedColorTable.Colors
        {
            var Added = false
            let Initial = Color.FirstLetter
            for Result in Results
            {
                if Result.GroupName == Initial
                {
                    Added = true
                    Result.GroupColors.append(Color)
                    continue
                }
            }
            if !Added
            {
                let NewGroup = PredefinedColorGroup()
                NewGroup.GroupName = Initial
                NewGroup.OrderedBy = .Name
                NewGroup.GroupColors.append(Color)
                Results.append(NewGroup)
            }
        }
        Results.sort{$0.GroupName < $1.GroupName}
        for Result in Results
        {
            Result.GroupColors.sort{$0.ColorName < $1.ColorName}
        }
        for Result in Results
        {
            let FirstColorName: String = (Result.GroupColors.first?.ColorName)!
            let LastColorName: String = (Result.GroupColors.last?.ColorName)!
            let SubTitle = "\(FirstColorName) - \(LastColorName)"
            Result.GroupSubTitle = SubTitle
        }
        return Results
    }
    
    /// Return all colors sorted by name. All colors are in one color group in the returned array.
    ///
    /// - Returns: Array with one entry with all color names, sorted by primary name.
    private static func GetNameSortedColorsUngrouped() -> [PredefinedColorGroup]
    {
        var Results = [PredefinedColorGroup]()
        let Sole = PredefinedColorGroup()
        
        for Color in PredefinedColorTable.Colors
        {
            Sole.GroupColors.append(Color)
        }
        
        Sole.GroupColors.sort{$0.ColorName < $1.ColorName}
        
        Results.append(Sole)
        return Results
    }
    
    /// Given a color, return the name of the color, if any. If more than one color matches the passed color, the first color
    /// found will have its name returned.
    ///
    /// - Parameter Color: The color whose name will be returned.
    /// - Returns: The name of the passed color if found, nil if no name for the passed color is available.
    public static func NameFrom(Color: UIColor) -> String?
    {
        for SomeColor in PredefinedColorTable.Colors
        {
            if SomeColor.SameColor(Color)
            {
                return SomeColor.ColorName
            }
        }
        return nil
    }
    
    /// Return all names for the passed color, if any. If more than on color matches the passed color, the first color
    /// found will be used as the source for the returned names.
    ///
    /// - Parameter Color: The color whose names will be returned.
    /// - Returns: Array of names for the color. If the returned array is empty, no colors were found that matched the passed
    ///            color. The first name is the primary name and subsquent names are alternative names.
    public static func NamesFrom(Color: UIColor) -> [String]
    {
        for Color in PredefinedColorTable.Colors
        {
            if Color.SameColor(Color.Color)
            {
                if !Color.AlternativeName.isEmpty
                {
                    return [Color.ColorName, Color.AlternativeName]
                }
                else
                {
                    return [Color.ColorName]
                }
            }
        }
        return [String]()
    }
    
    /// Given a color name, return its color value.
    ///
    /// - Parameters:
    ///   - Name: The name of the color. Spaces are relevant. Case sensitive search.
    ///   - SearchAlternativeNames: If true, alternative names are searched as well as the primary name.
    /// - Returns: If found, the color value for the name. If not found, nil is returned.
    public static func ColorFrom(Name: String, SearchAlternativeNames: Bool = true) -> UIColor?
    {
        for Color in PredefinedColorTable.Colors
        {
            if Color.ColorName == Name
            {
                return Color.Color
            }
            if SearchAlternativeNames
            {
                if Color.AlternativeName == Name
                {
                    return Color.Color
                }
            }
        }
        return nil
    }
    
    /// Determines if the passed name exists as a color name (or optionally, an alternative name) in the set of predefined colors.
    ///
    /// - Parameters:
    ///   - Name: Name of the color to search for. Spaces are relevant.
    ///   - SearchAlternativeNames: If true, alternative names are searched as well as the primary name.
    ///   - IgnoreAlpha: If true, searching is case insensitive. Otherwise, case is sensitive.
    /// - Returns: True if the passed name exists as a color name (or alternative), false if not.
    public static func ColorNameExists(Name: String, SearchAlternativeNames: Bool = true, IgnoreAlpha: Bool = true) -> Bool
    {
        for Color in PredefinedColorTable.Colors
        {
            if IgnoreAlpha
            {
                if Color.ColorName.caseInsensitiveCompare(Name) == .orderedSame
                {
                    return true
                }
                if SearchAlternativeNames
                {
                    if !Color.AlternativeName.isEmpty
                    {
                        if Color.AlternativeName.caseInsensitiveCompare(Name) == .orderedSame
                        {
                            return true
                        }
                    }
                }
            }
            else
            {
                if Color.ColorName == Name
                {
                    return true
                }
                if SearchAlternativeNames
                {
                    if Color.AlternativeName == Name
                    {
                        return true
                    }
                }
            }
        }
        return false
    }
}
