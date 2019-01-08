//
//  ClockSettingsProtocol.swift
//  Visualizer Clock
//
//  Created by Stuart Rankin on 12/23/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation

protocol ClockSettingsProtocol
{
    /// Set by the caller to let the settings code know the type of clock.
    func FromClock(_ ClockType: PanelActions)
    
    /// Get or set the delegate to the main UI.
    var MainDelegate: MainUIProtocol? {get set}
}
