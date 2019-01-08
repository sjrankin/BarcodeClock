//
//  FontManager.swift
//  Barcode Clock
//
//  Created by Stuart Rankin on 8/23/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics

/// Manages the list of fonts installed in the system (not custom fonts).
public class FontManager
{
    private static var LocalFullNames: [String: String]? = nil
    /// Get the dictionary of full font names. The key is the font name, and the value is the full font name.
    public static var FullNames: [String: String]?
    {
        get
        {
            return LocalFullNames
        }
    }
    
    private static var LocalFonts: [String]? = nil
    /// Get a list of all installed fonts.
    public static var CurrentFonts: [String]?
    {
        get
        {
            return LocalFonts
        }
    }
    
    /// Given a font name (in ugly style), return a nice-looking font name.
    ///
    /// - Parameter FontName: Name of the font whose full name will be returned.
    /// - Returns: Full name (in human-readable fashion) of the font.
    public static func GetFullFontName(_ FontName: String) -> String
    {
        let CName = FontName as CFString
        let Font = CGFont(CName)
        if Font == nil
        {
            return ""
        }
        let Final: String = (Font?.fullName)! as String
        return Final
    }
    
    /// Given a pretty font name, return it's ugly font name equivalent.
    ///
    /// - Parameter FullFontName: The pretty font name.
    /// - Returns: The equivalent ugly font name. Nil on error or not found.
    public static func GetUglyFontName(_ FullFontName: String) -> String?
    {
        for (FontName, LongFontName) in LocalFullNames!
        {
            if LongFontName == FullFontName
            {
                return FontName
            }
        }
        return nil
    }
    
    /// Load the fonts from the system.
    private static func DoLoadFonts()
    {
        if LocalFonts == nil
        {
            LocalFonts = [String]()
        }
        LocalFonts?.removeAll()
        if LocalFullNames == nil
        {
            LocalFullNames = [String: String]()
        }
        LocalFullNames?.removeAll()
    }
    
    /// Load the fonts from the system. If ForceReload is true, fonts always reloaded, otherwise, if fonts were previously
    /// loaded, no action will be taken.
    ///
    /// - Parameter ForceReload: Determines if fonts will be forcibly reloaded.
    public static func LoadFonts(ForceReload: Bool = false)
    {
        if ForceReload
        {
            DoLoadFonts()
        }
        else
        {
            if LocalFonts == nil
            {
                DoLoadFonts()
            }
        }
        let AllNames = UIFont.familyNames
        for Family in AllNames
        {
            let FontNames = UIFont.fontNames(forFamilyName: Family)
            for Name in FontNames
            {
                LocalFonts?.append(Name)
                LocalFullNames?[Name] = GetFullFontName(Name)
            }
        }
        LocalFonts?.sort()
        return
    }
    
    /// Returns a list of all loaded fonts. If fonts haven't been loaded, LoadFonts is called.
    ///
    /// - Returns: List of all loaded fonts.
    public static func GetAvailableFonts() -> [String]
    {
        if LocalFonts == nil
        {
            let _ = LoadFonts(ForceReload: true)
        }
        return CurrentFonts!
    }
}
