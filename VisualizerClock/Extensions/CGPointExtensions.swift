//
//  CGPointExtensions.swift
//  Visualizer Clock
//
//  Created by Stuart Rankin on 12/27/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Extensions for CGPoint.
extension CGPoint
{
    /// Initializer for polar coordinates.
    ///
    /// - Parameters:
    ///   - Angle: Angle of the point.
    ///   - Radius: Radial distance of the point.
    init(Angle: CGFloat, Radius: CGFloat)
    {
        self.init()
        let Cartesian = CGPoint.ToCartesian(Angle: Angle, Radius: Radius)
        x = Cartesian.x
        y = Cartesian.y
    }
    
    /// Converts the instance value to polar coordinates.
    ///
    /// - Returns: Polar coordinates in a tuple in the order of (theta, radial distance).
    func ToPolar() -> (CGFloat, CGFloat)
    {
        return CGPoint.ToPolar(self)
    }
    
    /// Converts the passed value to polar coordinates.
    ///
    /// - Returns: Polar coordinates in a tuple in the order of (theta, radial distance).
    static func ToPolar(_ Point: CGPoint) -> (CGFloat, CGFloat)
    {
        let R = sqrt(Double((Point.x * Point.x) + (Point.y * Point.y)))
        let Theta = atan2(Point.y, Point.x)
        return (CGFloat(Theta), CGFloat(R))
    }
    
    /// Creates a new point from the passed polar coordinates.
    ///
    /// - Parameters:
    ///   - Angle: Angle (in degrees) of the point.
    ///   - Radius: Radial distance of the point.
    /// - Returns: Point (in cartesian equivalent) of the passed polar coordinate.
    static func ToCartesian(Angle: CGFloat, Radius: CGFloat) -> CGPoint
    {
        let Radians = Angle * CGFloat.pi / 180.0
        let X = -Radius * cos(Radians)
        let Y = -Radius * sin(Radians)
        return CGPoint(x: X, y: Y)
    }
    
    /// Returns a string description of the passed CGPoint.
    ///
    /// - Parameters:
    ///   - Point: The CGPoint to return as a string.
    ///   - Places: Number of places for each value. Default is 0.
    /// - Returns: String description of the passed CGPoint.
    static func Print(_ Point: CGPoint, Places: Int = 0) -> String
    {
        let xs = Utility.Round(Point.x, ToPlaces: Places)
        let ys = Utility.Round(Point.y, ToPlaces: Places)
        return "(\(xs), \(ys))"
    }
}
