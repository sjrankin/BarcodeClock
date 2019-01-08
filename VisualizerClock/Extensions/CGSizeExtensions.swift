//
//  CGSize.swift
//  Visualizer Clock
//
//  Created by Stuart Rankin on 12/27/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// CGSize extensions.
extension CGSize
{
    /// Divides the instance width and height both by 2.0 and returns a new point.
    func Half() -> CGSize
    {
        return CGSize(width: self.width / 2.0, height: self.height / 2.0)
    }
    
    /// Returns the delta between this instance point and the other point (self - Other).
    func DeltaWith(Other: CGSize) -> CGSize
    {
        return CGSize(width: self.width - Other.width, height: self.height - Other.height)
    }
    
    /// Returns the delta of half of the instance point and half of the other point ((self * 0.5) - (Other * 0.5)).
    func HalfDeltaWith(Other: CGSize) -> CGSize
    {
        #if false
        let OtherHalf = Other.Half()
        let ThisHalf = self.Half()
        return CGSize(width: ThisHalf.width - OtherHalf.width, height: ThisHalf.height - OtherHalf.width)
        #else
        let First = self * 0.5
        let Second = Other * 0.5
        return First - Second
        #endif
    }
    
    /// Converts the passed size into a CGPoint with width as x and height as y.
    ///
    /// - Parameter SomeSize: The size to convert.
    /// - Returns: New CGPoint in the form CGPoint(x: width, y: height).
    static func ToPoint(_ SomeSize: CGSize) -> CGPoint
    {
        return CGPoint(x: SomeSize.width, y: SomeSize.height)
    }
    
    /// Add two sizes together.
    ///
    /// - Parameters:
    ///   - First: The first size.
    ///   - Second: the second size.
    /// - Returns: New size in the form CGSize(width: First.width + Second.width, height: First.height + Second.height).
    static func +(_ First: CGSize, _ Second: CGSize) -> CGSize
    {
        return CGSize(width: First.width + Second.width, height: First.height + Second.height)
    }
    
    /// Add a constant value to both the height and width of the passed size.
    ///
    /// - Parameters:
    ///   - First: Source size.
    ///   - Constant: Constant to add.
    /// - Returns: New size in the form CGSize(width: First.width + Constant, height: First.height + Constant).
    static func +(_ First: CGSize, _ Constant: CGFloat) -> CGSize
    {
        return CGSize(width: First.width + Constant, height: First.height + Constant)
    }
    
    /// Subtract two sizes from each other.
    ///
    /// - Parameters:
    ///   - First: The first size.
    ///   - Second: the second size.
    /// - Returns: New size in the form CGSize(width: First.width - Second.width, height: First.height - Second.height).
    static func -(_ First: CGSize, _ Second: CGSize) -> CGSize
    {
        return CGSize(width: First.width - Second.width, height: First.height - Second.height)
    }
    
    /// Subtract a constant value from both the height and width of the passed size.
    ///
    /// - Parameters:
    ///   - First: Source size.
    ///   - Constant: Constant to subtract.
    /// - Returns: New size in the form CGSize(width: First.width - Constant, height: First.height - Constant).
    static func -(_ First: CGSize, _ Constant: CGFloat) -> CGSize
    {
        return CGSize(width: First.width - Constant, height: First.height - Constant)
    }
    
    /// Multiple two sizes together.
    ///
    /// - Parameters:
    ///   - First: The first size.
    ///   - Second: the second size.
    /// - Returns: New size in the form CGSize(width: First.width * Second.width, height: First.height * Second.height).
    static func *(_ First: CGSize, _ Second: CGSize) -> CGSize
    {
        return CGSize(width: First.width * Second.width, height: First.height * Second.height)
    }
    
    /// Multiple a constant value to both the height and width of the passed size.
    ///
    /// - Parameters:
    ///   - First: Source size.
    ///   - Constant: Constant to multiply.
    /// - Returns: New size in the form CGSize(width: First.width * Constant, height: First.height * Constant).
    static func *(_ First: CGSize, _ Constant: CGFloat) -> CGSize
    {
        return CGSize(width: First.width * Constant, height: First.height * Constant)
    }
    
    /// Returns a string description of the passed CGSize.
    ///
    /// - Parameters:
    ///   - Size: The CGSize structure to print.
    ///   - Places: Number of places for the values. Defaults to 0.
    /// - Returns: String description of the passed CGSize.
    static func Print(_ Size: CGSize, Places: Int = 0) -> String
    {
        let ws = Utility.Round(Size.width, ToPlaces: Places)
        let hs = Utility.Round(Size.height, ToPlaces: Places)
        return "(\(ws), \(hs))"
    }
}
