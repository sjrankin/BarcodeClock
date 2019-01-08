//
//  MainUIProtocol.swift
//  Barcode Clock
//
//  Created by Stuart Rankin on 9/12/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Protocol for the main UI - provides ways for child clocks to talk with the UI.
protocol MainUIProtocol: class
{
    /// Called by the clock with a new view to display.
    ///
    /// - Parameter ID: The clock that wants to update the main view.
    /// - Parameter WithView: The view to display.
    func UpdateMainView(ID: UUID, WithView: UIView)
    
    /// Called by the clock when it starts to prepare a new view to display.
    ///
    /// - Parameter ID: ID of the clock that is starting an update.
    func PreparingClockUpdate(ID: UUID)
    
    /// Called by the clock after it is done with updating and displaying (via UpdateMainView) a clock.
    ///
    /// - Parameter ID: ID of the clock that finished the update.
    func FinishedClockUpdate(ID: UUID)
    
    /// Called when a clock is started.
    ///
    /// - Parameter ID: ID of the clock that started.
    func ClockStarted(ID: UUID)
    
    /// Called when a clock is stopped (eg, paused or removed from view).
    ///
    /// - Parameter ID: ID of the slock that stopped.
    func ClockStopped(ID: UUID)
    
    /// Called when a clock is shut down or removed.
    ///
    /// - Parameter ID: ID of the clock that was removed.
    func ClockClosed(ID: UUID)
    
    /// Allows calling clocks to show or hide the textual time.
    ///
    /// - Parameter IsOn: If true, the time is displayed. If false, the time is hidden. User settings override this function.
    func TextClockDisplay(IsOn: Bool)
    
    /// Determines if we are in dark mode or not based on user settings.
    ///
    /// - Parameter Now: The date/time to check to see if we're in dark mode.
    func CheckForDarkMode(_ Now: Date)
    
    /// Should be called every one second.
    ///
    /// - Parameter ID: ID of the clock that called.
    /// - Parameter Time: The time the tick was called.
    func OneSecondTick(ID: UUID, Time: Date)
    
    /// Should bed called if the background changes somehow.
    ///
    /// - Parameter From: The name of the caller of this function. Used for debugging purposes.
    func BackgroundChange(From: String)
    
    /// The clock was tapped but didn't want to handle it.
    ///
    /// - Parameter ID: ID of the clock that passed the tap to the main UI.
    func TapFromClock(_ ID: UUID)
    
    /// Notification from a clock that it handled a tap. There is no necessary action for the UI to perform.
    ///
    /// - Parameter ID: ID of the clock that handled the tap.
    func HandledTapInClock(_ ID: UUID)
    
    /// Run the settings for the clock with the specified ID.
    func RunSettingsForClock(ID: UUID)
    
    /// Broadcast settings changes to a specific clock.
    ///
    /// - Parameters:
    ///   - ToClock: ID of the clock to broadcast changes to.
    ///   - Changes: List of settings keys whose values were changed. May be nil.
    /// - Returns: True on success, false on failure (due to not finding the clock).
    @discardableResult func BroadcastChanges(ToClock: UUID, _ Changes: [String]) -> Bool
    
    /// Broadcast settings changes to all clocks.
    ///
    /// - Parameter Changes: List of settings keys whose values were changed. May be nil.
    func BroadcastChanges(_ Changes: [String])
}
