//
//  ClockProtocol2.swift
//  Visualizer Clock
//
//  Created by Stuart Rankin on 1/2/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Protocol for clocks.
protocol ClockProtocol2: class
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
    
    /// Get or set the flag that enables clocks to accept taps.
    var HandlesTaps: Bool {get set}
    
    /// The user tapped the screen - the main UI passed it along to the clock.
    ///
    /// -Parameter At: Where the tap occurred in the clock view.
    func WasTapped(At: CGPoint)
    
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
    
    /// Get or set the delegate to the Main UI.
    var MainDelegate: MainUIProtocol? {get set}
}

