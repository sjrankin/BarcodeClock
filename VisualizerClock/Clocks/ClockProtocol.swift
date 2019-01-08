//
//  ClockProtocol.swift
//  Barcode Clock
//
//  Created by Stuart Rankin on 9/12/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Protocol for clocks.
protocol ClockProtocol: class
{
    /// Update the clock for the passed time.
    ///
    /// - Parameter NewTime: The new time to update the clock to.
    func UpdateTime(NewTime: Date)
    
    /// Get the ID of the clock.
    var ClockID: UUID {get}
    
    /// Get the name of the clock.
    var ClockName: String {get}
    
    /// Set the run state of the clock.
    ///
    /// - Parameter ToRunning: If true, the clock is running. If false, the clock is stopped.
    /// - Parameter Animation: Determines starting or ending animation. Set to 0 for no animation. All other
    ///                        values are clock-dependent.
    func SetClockState(ToRunning: Bool, Animation: Int)
    
    /// Get the running state of the clock.
    var IsRunning: Bool {get}
    
    /// Update the viewport area in which we draw clocks. Generally called on initialization and
    /// when the orientation of the device changes.
    ///
    /// - Parameters:
    ///   - NewWidth: New viewport width.
    ///   - NewHeight: New viewport height.
    func UpdateViewPort(NewWidth: Int, NewHeight: Int)
    
    /// Returns the number of seconds this clock was displayed.
    ///
    /// - Returns: Number of seconds the clock was displayed.
    func SecondsDisplayed() -> Int
    
    /// Main UI needs to call this when moving to a different clock.
    func FinishedWithClock()
    
    /// Get the valid flag for the clock.
    var IsValid: Bool {get}
    
    /// Get the flag that indicates the clock can update colors asynchronously.
    var CanUpdateColorsAsynchronously: Bool {get}
    
    /// Sets the foreground color of the clock (where it makes sense) to the passed color, asynchronously.
    ///
    /// - Parameter Color: New foreground color.
    func SetForegroundColorAsynchronously(_ Color: UIColor)
    
    /// Enables or disables usage of asynchronously colors.
    var UpdateColorsAsynchronously: Bool {get set}
    
    /// Gets the number of vector nodes generated.
    var VectorNodeCount: Int {get}
    
    /// Update the specified nodes with associated colors.
    ///
    /// - Parameter Data: List of tuples. First item is the node index (0-based) and the second item is the color to
    ///                   apply to the node. If there are insufficient nodes in the bitmap, excess node data will be ignored.
    func UpdateNodeColors(_ Data: [(Int, UIColor)])
    
    /// Used to determine if a given clock is vector based or non-vector based. If non-vector based,
    /// some functions in the protocol will not have any effect if called.
    var IsVectorBased: Bool {get}
    
    /// Gets the full-screen flag.
    var IsFullScreen: Bool {get}
    
    /// Get or set the flag that enables clocks to accept taps.
    var HandlesTaps: Bool {get set}
    
    /// The user tapped the screen - the main UI passed it along to the clock.
    ///
    /// -Parameter At: Where the tap occurred in the clock view.
    func WasTapped(At: CGPoint)
    
    /// Run clock-specific settings.
    func RunClockSettings()
    
    /// Get the segue ID of the settings view controller.
    ///
    /// - Returns: ID of the settings view controller. Nil if none available.
    func SettingsSegueID() -> String?
    
    /// Get the type of clock.
    func GetClockType() -> PanelActions
    
    /// Optional way to notify a clock of changed settings. Most clocks pay attention
    /// to settings themselves and will not implement this function.
    ///
    /// - Parameter Changed: Optional list of changed settings.
    func ChangedSettings(_ Changed: [String])
}

