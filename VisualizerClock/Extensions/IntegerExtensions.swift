//
//  IntegerExtensions.swift
//  Barcode Clock
//
//  Created by Stuart Rankin on 8/22/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Extensions for the Int type.
extension Int
{
    /// Clamp an Int to a range, inclusive.
    ///
    /// - Parameters:
    ///   - Min: Minimum value for the Int.
    ///   - Max: Maximum value for the Int.
    /// - Returns: A value between (and including) Min:Max.
    func Clamp(_ Min: Int, _ Max: Int) -> Int
    {
        if self >= Min && self <= Max
        {
            return self
        }
        if self < Min
        {
            return Min
        }
        return Max
    }
}
