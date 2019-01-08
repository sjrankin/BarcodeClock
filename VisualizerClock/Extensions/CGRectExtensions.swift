//
//  CGRectExtensions.swift
//  Visualizer Clock
//
//  Created by Stuart Rankin on 12/27/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

extension CGRect
{
    /// Create a new CGRect with the passed size and origin from the Source CGRect.
    ///
    /// - Parameters:
    ///   - Source: CGRect whose origin will be used for the new CGRect.
    ///   - WithSize: The size to apply to the new CGRect
    init(_ Source: CGRect, WithSize: CGSize)
    {
        self.init()
        self.size = WithSize
        self.origin = Source.origin
    }
    
    /// Create a new CGRect with the passed origin and size from the Source CGRect.
    ///
    /// - Parameters:
    ///   - Source: CGRect whose size will be used for the new CGRect.
    ///   - WithOrigin: The origin to apply to the new CGRect
    init(_ Source: CGRect, WithOrigin: CGPoint)
    {
        self.init()
        self.size = Source.size
        self.origin = WithOrigin
    }
    
    /// Create a new CGRect with the passed origin and size.
    ///
    /// - Parameters:
    ///   - Origin: Point describing the origin.
    ///   - width: Width of the CGRect.
    ///   - height: Height of the CGRect.
    init(Origin: CGPoint, width: CGFloat, height: CGFloat)
    {
        self.init()
        self.origin = Origin
        self.size = CGSize(width: width, height: height)
    }
    
    /// Create a new CGRect with the passed origin and size.
    ///
    /// - Parameters:
    ///   - x: The origin's horizontal component.
    ///   - y: The origin's vertical component.
    ///   - Size: The size of the CGRect.
    init(x: CGFloat, y: CGFloat, Size: CGSize)
    {
        self.init()
        self.size = Size
        self.origin = CGPoint(x: x, y: y)
    }
    
    /// Create a new CGRect with the specified origin. The size is set to CGSize.zero.
    ///
    /// - Parameters:
    ///   - x: Horizontal component of the origin.
    ///   - y: Vertical component of the origin.
    init(x: CGFloat, y: CGFloat)
    {
        self.init()
        self.origin = CGPoint(x: x, y: y)
        self.size = CGSize.zero
    }
    
    /// Create a new CGRect with the specified origin. The size is set to CGSize.zero.
    ///
    /// - Parameter Origin: Origin of the CGRect.
    init(Origin: CGPoint)
    {
        self.init()
        self.origin = Origin
        self.size = CGSize.zero
    }
    
    /// Create a new CGRect with the specified size. The origin is set to CGPoint.zero.
    ///
    /// - Parameters:
    ///   - width: Width of the CGRect.
    ///   - height: Height of the CGRect
    init(width: CGFloat, height: CGFloat)
    {
        self.init()
        self.origin = CGPoint.zero
        self.size = CGSize(width: width, height: height)
    }
    
    /// Create a new CGRect with the specified size. The origin is set to CGPoint.zero.
    ///
    /// - Parameter Size: Size of the CGRect.
    init(Size: CGSize)
    {
        self.init()
        self.origin = CGPoint.zero
        self.size = Size
    }
    
    /// Returns a string description of the CGRect with optional rounding of values.
    ///
    /// - Parameters:
    ///   - Rect: The CGRect to print.
    ///   - Places: Number of places for the values. Defaults to 0.
    /// - Returns: String description of the passed CGRect.
    static func Print(_ Rect: CGRect, Places: Int = 0) -> String
    {
        let xs = Utility.Round(Rect.origin.x, ToPlaces: Places)
        let ys = Utility.Round(Rect.origin.y, ToPlaces: Places)
        let ws = Utility.Round(Rect.size.width, ToPlaces: Places)
        let hs = Utility.Round(Rect.size.width, ToPlaces: Places)
        return "(\(xs), \(ys), \(ws), \(hs))"
    }
    
    /// Takes a source rectangle and adjusts its size by an additive factor then returns a new rectangle.
    ///
    /// - Parameters:
    ///   - Source: Source rectangle. Unchanged by this function call.
    ///   - By: Value to add (whether positive or negative) to the size (both width and height).
    /// - Returns: New rectangle with an adjusted size.
    static func AdjustSize(_ Source: CGRect, By: CGFloat = 0) -> CGRect
    {
        return CGRect.AdjustOriginAndSize(Source, OriginBy: 0.0, SizeBy: By)
    }
    
    /// Takes a source rectangle and adjusts its origina and size by an additive factor then returns a new
    /// rectangle with the new coordinates.
    ///
    /// - Parameters:
    ///   - Source: Source rectangle. Unchanged by this function call.
    ///   - OriginBy: Value to add to the origin.
    ///   - SizeBy: Value to add to the size.
    /// - Returns: New rectangle with the adjusted origin and size.
    static func AdjustOriginAndSize(_ Source: CGRect, OriginBy: CGFloat, SizeBy: CGFloat) -> CGRect
    {
        return CGRect(x: Source.minX + OriginBy, y: Source.minY + OriginBy,
                      width: Source.width + SizeBy, height: Source.height + SizeBy)
    }
}
