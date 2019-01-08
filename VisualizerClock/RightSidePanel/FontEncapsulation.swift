//
//  FontEncapsulation.swift
//  Barcode Clock
//
//  Created by Stuart Rankin on 8/23/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Encapsulates a font.
public class FontEncapsulation
{
    /// Initialize the font encapsulation.
    ///
    /// - Parameters:
    ///   - Name: Name of the font (that can be passed to UIFont).
    ///   - FullName: Full name of the font to be displayed.
    ///   - Selected: Selection flag.
    init(Name: String, FullName: String, Selected: Bool)
    {
        LocalName = Name
        LocalFullName = FullName
        LocalSelected = Selected
    }
    
    private var LocalName: String = ""
    /// Name of the font (used in UIFont).
    public var FontName: String
    {
        get
        {
            return LocalName
        }
        set(NewName)
        {
            LocalName = NewName
        }
    }
    
    private var LocalFullName: String = ""
    /// Name of the font used for display purposes.
    public var FullFontName: String
    {
        get
        {
            return LocalFullName
        }
        set(NewName)
        {
            LocalFullName = NewName
        }
    }
    
    private var LocalSelected: Bool = false
    /// Font selected flag.
    public var IsSelected: Bool
    {
        get
        {
            return LocalSelected
        }
        set(NewSelected)
        {
            LocalSelected = NewSelected
        }
    }
}
