//
//  SettingHandle.swift
//  Visualizer Clock
//
//  Created by Stuart Rankin on 12/24/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Provides a translation layer between clocks with a common setting dialog
/// and mutliple settings. In other words, multiple types of clocks can use the
/// same, common setting dialog with a layer of indirection hidden from both
/// the setting dialog and the settings system. (The cost is the need to define
/// the linkages between multiple settings and a common set of settings.) All
/// settings written to the handle are saved immediately in the settings systm.
class SettingHandle
{
    /// Initializer.
    ///
    /// - Parameter FromClock: Indicates the clock that will supply the settings indirection map.
    ///                        Invalid clocks cause run-time errors.
    init(FromClock: PanelActions)
    {
        PopulateMap(FromClock)
    }
    
    let _Settings = UserDefaults.standard
    
    /// Holds a map between clock-specific and settings dialog-specific settings.
    var KeyMap: [String: String] = [String: String]()
    
    /// Populate the settings indirection map from the specified clock.
    ///
    /// - Parameter FromClock: Determines which clock will supply the settings indirection map. If an invalid
    ///                        clock is supplied, a fatal error is generated.
    func PopulateMap(_ FromClock: PanelActions)
    {
        switch FromClock
        {
        case PanelActions.SwitchToPharmaCode:
            if let IMap = Barcode1DClock.GetIndirectionMap(FromClock: FromClock)
            {
                KeyMap = IMap
            }
            else
            {
                fatalError("Error getting settings indirection map form Barcode1DClock.")
            }
            
        case PanelActions.SwitchToPOSTNET:
            if let IMap = Barcode1DClock.GetIndirectionMap(FromClock: FromClock)
            {
                KeyMap = IMap
            }
            else
            {
                fatalError("Error getting settings indirection map form Barcode1DClock.")
            }
            
        default:
            fatalError("Incorrect clock specified to retrieve a setting indirection map: \(FromClock)")
        }
    }
    
    /// Determines if the specified key exists.
    ///
    /// - Parameter Key: The key to determine existence in the settings indirection map.
    /// - Returns: True if the key exists, false if not.
    func HasSetting(Key: String) -> Bool
    {
        return KeyMap[Key] != nil
    }
    
    /// Get the clock-specific key given the general settings key.
    ///
    /// - Parameter ForGeneralKey: The general key for which a clock-specific key will be returned.
    /// - Returns: The clock-specific key on success, nil if not found.
    func GetLocalKey(ForGeneralKey: String) -> String?
    {
        if let LocalKey = KeyMap[ForGeneralKey]
        {
            return LocalKey
        }
        return nil
    }
    
    /// Get an integer from user settings. A fatal error is generated if no key is found.
    ///
    /// - Parameter Key: The general, settings key.
    /// - Returns: The clock-specific settings key.
    func Get(Key: String) -> Int
    {
        if let FinalKey = GetLocalKey(ForGeneralKey: Key)
        {
            return _Settings.integer(forKey: FinalKey)
        }
        fatalError("Error getting local key for \(Key)")
    }
    
    /// Sets an integer value to the clock-specific settings given the general settings key. A fatal error
    /// will occur if the clock-specific key cannot be found.
    ///
    /// - Parameters:
    ///   - Value: The value to save.
    ///   - Key: The general, settings key.
    func Set(_ Value: Int, Key: String)
    {
        if let FinalKey = GetLocalKey(ForGeneralKey: Key)
        {
            _Settings.set(Value, forKey: FinalKey)
            return
        }
        fatalError("Error getting local key for \(Key)")
    }
    
    /// Get a sstring from user settings. A fatal error is generated if no key is found.
    ///
    /// - Parameter Key: The general, settings key.
    /// - Returns: The clock-specific settings key.
    func Get(Key: String) -> String
    {
        if let FinalKey = GetLocalKey(ForGeneralKey: Key)
        {
            return _Settings.string(forKey: FinalKey)!
        }
        fatalError("Error getting local key for \(Key)")
    }
    
    /// Sets a string value to the clock-specific settings given the general settings key. A fatal error
    /// will occur if the clock-specific key cannot be found.
    ///
    /// - Parameters:
    ///   - Value: The value to save.
    ///   - Key: The general, settings key.
    func Set(_ Value: String, Key: String)
    {
        if let FinalKey = GetLocalKey(ForGeneralKey: Key)
        {
            _Settings.set(Value, forKey: FinalKey)
            return
        }
        fatalError("Error getting local key for \(Key)")
    }
    
    /// Get a boolean from user settings. A fatal error is generated if no key is found.
    ///
    /// - Parameter Key: The general, settings key.
    /// - Returns: The clock-specific settings key.
    func Get(Key: String) -> Bool
    {
        if let FinalKey = GetLocalKey(ForGeneralKey: Key)
        {
            return _Settings.bool(forKey: FinalKey)
        }
        fatalError("Error getting local key for \(Key)")
    }
    
    /// Sets a boolean value to the clock-specific settings given the general settings key. A fatal error
    /// will occur if the clock-specific key cannot be found.
    ///
    /// - Parameters:
    ///   - Value: The value to save.
    ///   - Key: The general, settings key.
    func Set(_ Value: Bool, Key: String)
    {
        if let FinalKey = GetLocalKey(ForGeneralKey: Key)
        {
            _Settings.set(Value, forKey: FinalKey)
            return
        }
        fatalError("Error getting local key for \(Key)")
    }
    
    
    /// Get a double from user settings. A fatal error is generated if no key is found.
    ///
    /// - Parameter Key: The general, settings key.
    /// - Returns: The clock-specific settings key.
    func Get(Key: String) -> Double
    {
        if let FinalKey = GetLocalKey(ForGeneralKey: Key)
        {
            return _Settings.double(forKey: FinalKey)
        }
        fatalError("Error getting local key for \(Key)")
    }
    
    /// Sets a Double value to the clock-specific settings given the general settings key. A fatal error
    /// will occur if the clock-specific key cannot be found.
    ///
    /// - Parameters:
    ///   - Value: The value to save.
    ///   - Key: The general, settings key.
    func Set(_ Value: Double, Key: String)
    {
        if let FinalKey = GetLocalKey(ForGeneralKey: Key)
        {
            _Settings.set(Value, forKey: FinalKey)
            return
        }
        fatalError("Error getting local key for \(Key)")
    }
    
    /// Get a UUID from user settings. A fatal error is generated if no key is found.
    ///
    /// - Parameter Key: The general, settings key.
    /// - Returns: The clock-specific settings key.
    func Get(Key: String) -> UUID
    {
        if let FinalKey = GetLocalKey(ForGeneralKey: Key)
        {
            return _Settings.uuid(forKey: FinalKey)
        }
        fatalError("Error getting local key for \(Key)")
    }
    
    /// Sets a UUID value to the clock-specific settings given the general settings key. A fatal error
    /// will occur if the clock-specific key cannot be found.
    ///
    /// - Parameters:
    ///   - Value: The value to save.
    ///   - Key: The general, settings key.
    func Set(_ Value: UUID, Key: String)
    {
        if let FinalKey = GetLocalKey(ForGeneralKey: Key)
        {
            _Settings.set(Value, forKey: FinalKey)
            return
        }
        fatalError("Error getting local key for \(Key)")
    }
    
    /// Get a UIColor from user settings. A fatal error is generated if no key is found.
    ///
    /// - Parameter Key: The general, settings key.
    /// - Returns: The clock-specific settings key.
    func Get(Key: String) -> UIColor
    {
        if let FinalKey = GetLocalKey(ForGeneralKey: Key)
        {
            return _Settings.uicolor(forKey: FinalKey)!
        }
        fatalError("Error getting local key for \(Key)")
    }
    
    /// Sets a UIColor value to the clock-specific settings given the general settings key. A fatal error
    /// will occur if the clock-specific key cannot be found.
    ///
    /// - Parameters:
    ///   - Value: The value to save.
    ///   - Key: The general, settings key.
    func Set(_ Value: UIColor, Key: String)
    {
        if let FinalKey = GetLocalKey(ForGeneralKey: Key)
        {
            _Settings.set(Value, forKey: FinalKey)
            return
        }
        fatalError("Error getting local key for \(Key)")
    }
}

/// Contains a set of constants used as general-purpose, setting-specific keys for values. These constants
/// are used as Keys in a Key-Value table to the actual, clock-specific setting string (set at run-time). Not
/// all clocks support all keys. This can be used to alter the user interface at run-time.
class SettingKey
{
    /// The shape of the barcode.
    static let BarcodeShape = "BarcodeShape"
    /// Determines the shape of the barcode node.
    static let BarcodeNodeShape = "NodeShape"
    /// The proportional height of the barcode.
    static let BarcodeHeight = "BarcodeHeight"
    /// The outer radius of the barcode when circular.
    static let BarcodeOuterRadius = "BarcodeOuterRadius"
    /// The inner radius of the barcode when circular.
    static let BarcodeInnerRadius = "BarcodeInnerRadius"
    /// Special effects flags.
    static let SpecialEffects = "SpecialEffects"
    /// Shadow level value.
    static let Shadows = "Shadows"
    /// Way heights flags.
    static let WavyHeights = "WavyHeights"
    /// Determines if the barcode is stroked or not.
    static let BarcodeStroked = "BarcodeStroked"
    /// Color to use to stroke the barcode.
    static let BarcodeStrokeColor = "BarcodeStrokeColor"
    /// Color of barcode nodes.
    static let BarcodeForegroundColor = "ForegroundColor"
    /// Attention color for barcodes.
    static let BarcodeAttentionColor = "AttentionColor"
    /// Include digits in the barcode for those barcodes that support them.
    static let IncludeDigits = "IncludeDigits"
    /// Include a check digit for those barcodes that support them.
    static let IncludeCheckDigits = "IncludeCheckDigits"
    /// The color of long bars in barcodes, if enabled.
    static let LongBarColor = "LongBarColor"
    /// The color of short bars in barcodes, if enabled.
    static let ShortBarColor = "ShortBarColor"
    /// Enable or disable varying colors base on bar size.
    static let ColorsVaryOnLength = "ColorsVaryOnLength"
}

