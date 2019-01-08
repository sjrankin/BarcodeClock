//
//  InitializationRecord.swift
//  Visualizer Clock
//
//  Created by Stuart Rankin on 11/2/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Provides a means to communicate the settings initialization record.
public class InitializationRecord
{
    /// Holds the build number.
    private var _BuildNumber: Int = 0
    /// Get or set the build number.
    public var BuildNumber: Int
    {
        get
        {
            return _BuildNumber
        }
        set
        {
            _BuildNumber = newValue
        }
    }
    
    /// Holds the build ID.
    private var _BuildID: UUID = UUID()
    /// Get or set the build ID.
    public var BuildID: UUID
    {
        get
        {
            return _BuildID
        }
        set
        {
            _BuildID = newValue
        }
    }
    
    /// Holds the build date.
    private var _BuildDate = Date()
    /// Get or set the build date.
    public var BuildDate: Date
    {
        get
        {
            return _BuildDate
        }
        set
        {
            _BuildDate = newValue
        }
    }
    
    /// Holds the version number.
    private var _Version: Double = 0.0
    /// Get or set the version number.
    public var Version: Double
    {
        get
        {
            return _Version
        }
        set
        {
            _Version = newValue
        }
    }
}
