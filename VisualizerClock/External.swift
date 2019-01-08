//
//  ExternalScreen.swift
//  Visualizer Clock
//
//  Created by Stuart Rankin on 11/17/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Manages external windows/screens, if any exist.
/// - Notes: http://tutorials.tinyappco.com/Swift/AdditionalScreen
class External
{
    /// Initialize the class to a known state.
    public static func Initialize()
    {
        ExScreen = nil
        ExWindow = nil
    }
    
    /// Add a new external screen. This function will also make it visible.
    ///
    /// - Parameter NewScreen: The new screen to add.
    public static func AddScreen(_ NewScreen: UIScreen)
    {
        ExScreen = NewScreen
        ExWindow = UIWindow(frame: NewScreen.bounds)
        ExWindow?.isHidden = false
        print("External screen added: size\(NewScreen.bounds)")
    }
    
    /// Holds the new screen.
    private static var ExScreen: UIScreen? = nil
    
    /// Holds the window for the new screen.
    private static var ExWindow: UIWindow? = nil
    
    public static func RemoveScreen()
    {
        ExScreen = nil
        print("External screen removed.")
    }
    
    /// Get the external screen. Nil if no external screen available (or not set).
    public static var Screen: UIScreen?
    {
        get
        {
            return ExScreen
        }
    }
    
    /// Get the window for the external screen. Nil if no external screen available
    /// (or not set).
    public static var Window: UIWindow?
    {
        get
        {
            return ExWindow
        }
    }
    
    /// Called when the resolution of the external screen changes.
    ///
    /// - Parameter UpdatedScreen: Screen with newly updated resolution.
    public static func ScreenChanged(_ UpdatedScreen: UIScreen)
    {
        print("External screen changed.")
        AddScreen(UpdatedScreen)
    }
    
    /// Returns a value indicating whether or not an external screen is available
    /// for use.
    public static var HasExternalScreen: Bool
    {
        get
        {
            return ExScreen != nil
        }
    }
}
