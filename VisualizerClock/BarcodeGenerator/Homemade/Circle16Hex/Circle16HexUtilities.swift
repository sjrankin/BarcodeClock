//
//  Circle16HexUtilities.swift
//  Barcode Clock
//
//  Created by Stuart Rankin on 9/5/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

public class C16Utility
{
    /// Returns the number of set bits in the passed 64-bit number.
    ///
    /// - Parameter Number: The number whose number of set bits will be returned.
    /// - Returns: Number of set bits in the passed UInt64 value.
    public static func CountSetBits(_ Number: UInt64) -> Int
    {
        let Bits = MemoryLayout<UInt64>.size * 8
        var Count: Int = 0
        var Mask: UInt64 = 1
        for _ in 0 ... Bits
        {
            if Number & Mask != 0
            {
                Count = Count + 1
            }
            Mask <<= 1
        }
        return Count
    }
}
