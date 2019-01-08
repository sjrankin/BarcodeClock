//
//  SettingProtocol.swift
//  Visualizer Clock
//
//  Created by Stuart Rankin on 11/4/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation

protocol SettingProtocol
{
    /// Allows child view controllers to set key/value pair data in the parent.
    ///
    /// - Parameters:
    ///   - Key: Key description.
    ///   - Value: Value.
    func DoSet(Key: String, Value: Any?)
}
