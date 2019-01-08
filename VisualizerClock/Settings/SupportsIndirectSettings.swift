//
//  SupportsIndirectSettings.swift
//  Visualizer Clock
//
//  Created by Stuart Rankin on 12/24/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation

protocol SupportsIndirectSettings
{
    static func GetIndirectionMap(FromClock: PanelActions) -> [String: String]?
}
