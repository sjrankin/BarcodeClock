//
//  Versioning.swift
//  Barcode Clock
//
//  Created by Stuart Rankin on 8/27/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Contains versioning and copyright information. The contents of this file are automatically updated with each
/// build by the VersionUpdater utility.
public class Versioning
{
    /// Major version number.
    public static let MajorVersion: String = "1"
    
    /// Minor version number.
    public static let MinorVersion: String = "0"
    
    /// Potential version suffix.
    public static let VersionSuffix: String = ""
    
    /// Returns a standard-formatted version string in the form of "Major.Minor" with optional
    /// version suffix.
    ///
    /// - Parameter IncludeVersionSuffix: If true and the VersionSuffix value is non-empty, the contents
    ///                                   of VersionSuffix will be appended (with a leading space) to the
    ///                                   returned string.
    /// - Returns: Standard version string.
    public static func MakeVersionString(IncludeVersionSuffix: Bool = false) -> String
    {
        var Final = "Version \(MajorVersion).\(MinorVersion)"
        if IncludeVersionSuffix
        {
            if !VersionSuffix.isEmpty
            {
                Final = Final + " " + VersionSuffix
            }
        }
        return Final
    }
    
    /// Build number.
    public static let Build: Int = 3216
    
    /// Build increment.
    private static let BuildIncrement = 1
    
    /// Build ID.
    public static let BuildID: String = "4096E650-66C8-4008-94B3-595922BFA3B8"
    
    /// Build date.
    public static let BuildDate: String = "6 January 2019"
    
    /// Build Time.
    public static let BuildTime: String = "18:02"
    
    /// Return a standard build string.
    ///
    /// - Returns: Standard build string.
    public static func MakeBuildString() -> String
    {
        let Final = "Build \(Build), \(BuildDate) \(BuildTime)"
        return Final
    }
    
    /// Copyright years.
    public static let CopyrightYears = [2018]
    
    /// Legal holder of the copyright.
    public static let CopyrightHolder = "Stuart Rankin"
    
    /// Returns copyright text.
    ///
    /// - Returns: Program copyright text.
    public static func CopyrightText() -> String
    {
        var Years = Versioning.CopyrightYears
        var CopyrightYears = ""
        if Years.count > 1
        {
            Years = Years.sorted()
            let FirstYear = Years.first
            let LastYear = Years.last
            CopyrightYears = "\(FirstYear!) - \(LastYear!)"
        }
        else
        {
            CopyrightYears = String(describing: Years[0])
        }
        let CopyrightTextString = "Copyright © \(CopyrightYears) \(CopyrightHolder)"
        return CopyrightTextString
    }
    
    /// Return an XML-formatted key-value pair string.
    ///
    /// - Parameters:
    ///   - Key: The key part of the key-value pair.
    ///   - Value: The value part of the key-value pair.
    /// - Returns: XML-formatted key-value pair string.
    private static func MakeKVP(_ Key: String, _ Value: String) -> String
    {
        let KVP = "\(Key)=\"\(Value)\""
        return KVP
    }
    
    /// Emit version information as an XML string.
    ///
    /// - Returns: XML string with version information.
    public static func EmitXML() -> String
    {
        var Emit = "<Version "
        Emit = Emit + MakeKVP("Version", MajorVersion + "." + MinorVersion) + " "
        Emit = Emit + MakeKVP("Build", String(describing: Build)) + " "
        Emit = Emit + MakeKVP("BuildDate", BuildDate + ", " + BuildTime) + " "
        Emit = Emit + MakeKVP("BuildID", BuildID)
        Emit = Emit + ">\n"
        Emit = Emit + "  " + CopyrightText() + "\n"
        Emit = Emit + "</Version>"
        return Emit
    }
}
