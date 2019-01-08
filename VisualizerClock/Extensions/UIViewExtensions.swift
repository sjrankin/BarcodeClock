//
//  UIViewExtensions.swift
//  Visualizer Clock
//
//  Created by Stuart Rankin on 12/24/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Extensions for UIView.
extension UIView
{
    /// Center a child view in a parent view. The child view is the UIView against which this function is called, for example,
    ///     ChildView.CenterIn(ParentView)
    /// - Parameter Other: The parent view the child will be centered in.
    func CenterIn(_ Other: UIView)
    {
        let OtherCenter = CGPoint(x: Other.bounds.width / 2.0, y: Other.bounds.height / 2.0)
        let ThisCenter = CGPoint(x: self.bounds.width / 2.0, y: self.bounds.height / 2.0)
        let NewX = OtherCenter.x - ThisCenter.x
        let NewY = OtherCenter.y - ThisCenter.y
        self.frame = CGRect(x: NewX, y: NewY, width: self.frame.width, height: self.frame.height)
    }
    
    /// Center a child view in a parent view. The child view is the UIView against which this function is called, for example,
    ///     ChildView.CenterIn(ParentView)
    /// - Parameter Other: The parent view the child will be centered in.
    /// - Parameter FinalX: Final horizontal position. Provided for debugging purposes.
    /// - Parameter FinalY: Final vertical position. Provided for debugging purposes.
    func CenterIn(_ Other: UIView, FinalX: inout CGFloat, FinalY: inout CGFloat)
    {
        let OtherCenter = CGPoint(x: Other.frame.width / 2.0, y: Other.frame.height / 2.0)
        let ThisCenter = CGPoint(x: self.frame.width / 2.0, y: self.frame.height / 2.0)
        let NewX = OtherCenter.x - ThisCenter.x
        let NewY = OtherCenter.y - ThisCenter.y
        FinalX = NewX
        FinalY = NewY
        self.frame = CGRect(x: NewX, y: NewY, width: self.frame.width, height: self.frame.height)
    }
}
