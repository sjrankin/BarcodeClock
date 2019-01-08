//
//  Extensions.swift
//  Visualizer Clock
//
//  Created by Stuart Rankin on 10/14/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Extensions to CGPoint.
extension CGPoint
{
    /// Returns the distance (in unitless values) between the implicit, self point, and From.
    ///
    /// - Parameter From: Other point to calculate distance from this point.
    /// - Returns: Distance between this point and the other point.
    func Distance(From: CGPoint) -> Double
    {
        var Term1: CGFloat = self.x - From.x
        Term1 = Term1 * Term1
        var Term2: CGFloat = self.y - From.y
        Term2 = Term2 * Term2
        return sqrt(Double(Term1 + Term2))
    }
    
    /// Returns the distance (in unitless values) between the implicit self point, and from (X, Y).
    ///
    /// - Parameters:
    ///   - X: Horizontal coordinate.
    ///   - Y: Vertical coordinate.
    /// - Returns: Distance between this point and the other point.
    func Distance(_ X: Int, _ Y: Int) -> Double
    {
        return self.Distance(From: CGPoint(x: X, y: Y))
    }
    
    /// Returns the distance (in unitless values) between the implicit self point, and from (X, Y).
    ///
    /// - Parameters:
    ///   - X: Horizontal coordinate.
    ///   - Y: Vertical coordinate.
    /// - Returns: Distance between this point and the other point.
    func Distance(_ X: CGFloat, _ Y: CGFloat) -> Double
    {
        return self.Distance(From: CGPoint(x: X, y: Y))
    }
    
    /// Returns the distance (in unitless values) between the implicit self point, and from (X, Y).
    ///
    /// - Parameters:
    ///   - X: Horizontal coordinate.
    ///   - Y: Vertical coordinate.
    /// - Returns: Distance between this point and the other point.
    func IntDistance(_ X: Int, _ Y: Int) -> Int
    {
        var Term1: Int = Int(self.x) - X
        Term1 = Term1 * Term1
        var Term2: Int = Int(self.y) - Y
        Term2 = Term2 * Term2
        return Int(sqrt(Double(Term1 + Term2)))
    }
}

extension CGFloat
{
    static func Denormalize(_ Normal: CGFloat, _ Extent: UInt8) -> UInt8
    {
        let Result: UInt8 = UInt8(CGFloat(Extent) * Normal)
        return Result > Extent ? Extent : Result
    }
    
    static func Denormalize(_ Normal: CGFloat) -> UInt8
    {
        return Denormalize(Normal, 0xff)
    }
    
    static func Clamp(_ Value: CGFloat, _ From: CGFloat, _ To: CGFloat) -> CGFloat
    {
        var Min = From
        var Max = To
        if Min > Max
        {
            swap(&Min, &Max)
        }
        if Value < Min
        {
            return Min
        }
        if Value > Max
        {
            return Max
        }
        return Value
    }
    
    static func ClampNormal(_ Value: CGFloat) -> CGFloat
    {
        return CGFloat.Clamp(Value, 0.0, 1.0)
    }
}

extension UIColor
{
    /// Given a UIColor, return the alpha red, green, and blue component parts.
    /// - Parameter SourceColor: The color whose component parts will be returned.
    /// - Returns: Tuple in the order: Alpha, Red, Green, Blue.
    public static func GetARGB(_ SourceColor: UIColor) -> (CGFloat, CGFloat, CGFloat, CGFloat)
    {
        let Red = UnsafeMutablePointer<CGFloat>.allocate(capacity: 1)
        Red.initialize(to: 0.0)
        let Green = UnsafeMutablePointer<CGFloat>.allocate(capacity: 1)
        Green.initialize(to: 0.0)
        let Blue = UnsafeMutablePointer<CGFloat>.allocate(capacity: 1)
        Blue.initialize(to: 0.0)
        let Alpha = UnsafeMutablePointer<CGFloat>.allocate(capacity: 1)
        Alpha.initialize(to: 0.0)
        
        SourceColor.getRed(Red, green: Green, blue: Blue, alpha: Alpha)
        
        let FinalRed = Red.move()
        let FinalGreen = Green.move()
        let FinalBlue = Blue.move()
        let FinalAlpha = Alpha.move()
        
        Red.deallocate()
        Green.deallocate()
        Blue.deallocate()
        Alpha.deallocate()
        
        return (FinalAlpha, FinalRed, FinalGreen, FinalBlue)
    }
}

extension Int
{
    @discardableResult static func Increment(_ Value: inout Int) -> Int
    {
        Value = Value + 1
        return Value
    }
    
    @discardableResult static func Decrement(_ Value: inout Int) -> Int
    {
        Value = Value - 1
        return Value
    }
    
    @discardableResult static func Reset(_ Value: inout Int) -> Int
    {
        Value = 0
        return Value
    }
}

extension String: Error
{
    
}
