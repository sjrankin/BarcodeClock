//
//  ActiveBackgroundView.swift
//  Visualizer Clock
//
//  Created by Stuart Rankin on 9/26/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Provides an "active" background view.
class ActiveBackgroundView: UIView
{
    let _Settings = UserDefaults.standard
    
    /// Light color - assign default value.
    @IBInspectable var LightColor: UIColor = UIColor.lightGray
    /// Dark color - assign default value.
    @IBInspectable var DarkColor: UIColor = UIColor.darkGray
    /// Pattern size - assign default value.
    @IBInspectable var PatternSize: CGFloat = 20.0
    
    /// Perform draw operations in the specified rectangle. What is drawn and how is defined in user settings.
    ///
    /// - Parameter Rect: Where to draw.
    override func draw(_ Rect: CGRect)
    {
        DarkColor = _Settings.uicolor(forKey: Setting.Key.PanelBackgroundPatternColor1)!
        LightColor = _Settings.uicolor(forKey: Setting.Key.PanelBackgroundPatternColor2)!
        
        switch _Settings.integer(forKey: Setting.Key.PanelBackgroundType)
        {
        case 0:
            //static color
            let StaticColor = _Settings.uicolor(forKey: Setting.Key.PanelBackgroundStaticColor)
            DrawStaticColor(Rect, WithColor: StaticColor!)
            
        case 1:
            //dynamic color
            DrawDynamicColor(Rect)
            
        case 2:
            //static pattern
            DrawPattern(Rect, PatternIndex: _Settings.integer(forKey: Setting.Key.PanelBackgroundPattern))
            
        case 3:
            //dynamic color pattern
            fallthrough
        case 4:
            //moving pattern
            fallthrough
        case 5:
            //moving pattern with dynamic colors
            fallthrough
        default:
            //If somehow we end up here, draw a white background.
            DrawStaticColor(Rect, WithColor: UIColor.white)
        }
        //DrawOriginal(Rect)
    }
    
    /// Draw a static, unchanging color.
    ///
    /// - Parameters:
    ///   - Rect: Where to draw the color.
    ///   - WithColor: The color to draw.
    func DrawStaticColor(_ Rect: CGRect, WithColor: UIColor)
    {
        let StaticColor = _Settings.uicolor(forKey: Setting.Key.PanelBackgroundStaticColor)
        //        print("Drawing static panel background color \(Utility.ColorToString(StaticColor!))")
        let Context = UIGraphicsGetCurrentContext()!
        Context.setFillColor(StaticColor!.cgColor)
        Context.fill(Rect)
    }
    
    /// Draw dynamic colors. The dynamic colors to draw are in the user settings.
    ///
    /// - Parameter Rect: Where to draw.
    func DrawDynamicColor(_ Rect: CGRect)
    {
        
    }
    
    /// Draw a pattern.
    ///
    /// - Parameters:
    ///   - Rect: Where to draw the pattern.
    ///   - PatternIndex: Determines which pattern to draw.
    func DrawPattern(_ Rect: CGRect, PatternIndex: Int)
    {
        switch(PatternIndex)
        {
        case 0:
            //checkerboard
            DrawCheckerboard(Rect, AnimateColors: false)
            
        case 1:
            //vertical lines
            DrawVerticalLines(Rect, AnimateColors: false)
            
        case 2:
            //horizontal lines
            DrawHorizontalLines(Rect, AnimateColors: false)
            
        case 3:
            //negative diagonal lines
            break
            
        case 4:
            //positive diagonal lines
            break
            
        case 5:
            //diamonds
            DrawDiamond(Rect, AnimateColors: false)
            
        default:
            print("Unrecognized pattern - drawing white background.")
            DrawStaticColor(Rect, WithColor: UIColor.white)
        }
    }
    
    /// Draw horizontal line pattern. Line attributes are obtained from user settings.
    ///
    /// - Parameters:
    ///   - Rect: Where to draw the horizontal lines.
    ///   - AnimateColors: Determines if colors are animated.
    func DrawHorizontalLines(_ Rect: CGRect, AnimateColors: Bool = false)
    {
        let Context = UIGraphicsGetCurrentContext()!
        Context.setFillColor(DarkColor.cgColor)
        Context.fill(Rect)
        let DrawSize = CGSize(width: PatternSize, height: PatternSize)
        UIGraphicsBeginImageContextWithOptions(DrawSize, true, 0.0)
        let DrawingContext = UIGraphicsGetCurrentContext()!
        DarkColor.setFill()
        DrawingContext.fill(CGRect(x: 0, y: 0, width: DrawSize.width, height: DrawSize.height))
        
        let PatternPath = UIBezierPath()
        LightColor.setFill()
        
        if _Settings.bool(forKey: Setting.Key.PanelBackgroundHasThinLines)
        {
            //Thin lines work best with pattern sizes evenly divisible by 4.
            for Y in 0 ..< Int(DrawSize.height)
            {
                if Y % 4 == 0
                {
                    PatternPath.move(to: CGPoint(x: 0, y: CGFloat(Y)))
                    PatternPath.addLine(to: CGPoint(x: DrawSize.width, y: CGFloat(Y)))
                    PatternPath.addLine(to: CGPoint(x: DrawSize.width, y: CGFloat(Y) + 1))
                    PatternPath.addLine(to: CGPoint(x: 0, y: CGFloat(Y) + 1))
                    PatternPath.addLine(to: CGPoint(x: 0, y: CGFloat(Y)))
                }
            }
        }
        else
        {
            var HeightOffset: CGFloat = 0.0
            if Int(DrawSize.height) % 2 == 0
            {
                HeightOffset = 1
            }
            let LineHeight = CGFloat(Int(DrawSize.height / 2) + Int(HeightOffset))
            
            PatternPath.move(to: CGPoint(x: 0, y: 0))
            PatternPath.addLine(to: CGPoint(x: DrawSize.width, y:0))
            PatternPath.addLine(to: CGPoint(x: DrawSize.width, y: LineHeight))
            PatternPath.addLine(to: CGPoint(x: 0, y: LineHeight))
            PatternPath.addLine(to: CGPoint(x: 0, y:0))
        }
        
        PatternPath.fill()
        let Image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        UIColor(patternImage: Image).setFill()
        Context.fill(Rect)
    }
    
    /// Draw vertical line pattern. Line attributes are obtained from user settings.
    ///
    /// - Parameters:
    ///   - Rect: Where to draw the vertical lines.
    ///   - AnimateColors: Determines if colors are animated.
    func DrawVerticalLines(_ Rect: CGRect, AnimateColors: Bool = false)
    {
        let Context = UIGraphicsGetCurrentContext()!
        Context.setFillColor(DarkColor.cgColor)
        Context.fill(Rect)
        let DrawSize = CGSize(width: PatternSize, height: PatternSize)
        UIGraphicsBeginImageContextWithOptions(DrawSize, true, 0.0)
        let DrawingContext = UIGraphicsGetCurrentContext()!
        DarkColor.setFill()
        DrawingContext.fill(CGRect(x: 0, y: 0, width: DrawSize.width, height: DrawSize.height))
        
        let PatternPath = UIBezierPath()
        LightColor.setFill()
        
        if _Settings.bool(forKey: Setting.Key.PanelBackgroundHasThinLines)
        {
            //Thin lines work best with pattern sizes evenly divisible by 4.
            for X in 0 ..< Int(DrawSize.width)
            {
                if X % 4 == 0
                {
                    PatternPath.move(to: CGPoint(x: CGFloat(X), y: 0))
                    PatternPath.addLine(to: CGPoint(x: CGFloat(X), y: DrawSize.height))
                    PatternPath.addLine(to: CGPoint(x: CGFloat(X) + 1, y: DrawSize.height))
                    PatternPath.addLine(to: CGPoint(x: CGFloat(X) + 1, y: 0))
                    PatternPath.addLine(to: CGPoint(x: CGFloat(X), y: 0))
                }
            }
        }
        else
        {
            var WidthOffset: CGFloat = 0.0
            if Int(DrawSize.width) % 2 == 0
            {
                WidthOffset = 1
            }
            let LineWidth = CGFloat(Int(DrawSize.width / 2) + Int(WidthOffset))
            
            PatternPath.move(to: CGPoint(x: 0, y: 0))
            PatternPath.addLine(to: CGPoint(x: 0, y: DrawSize.height))
            PatternPath.addLine(to: CGPoint(x: LineWidth, y: DrawSize.height))
            PatternPath.addLine(to: CGPoint(x: LineWidth, y: 0))
            PatternPath.addLine(to: CGPoint(x: 0, y: 0))
        }
        
        PatternPath.fill()
        let Image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        UIColor(patternImage: Image).setFill()
        Context.fill(Rect)
    }
    
    /// Draw diamond pattern. Line attributes are obtained from user settings.
    ///
    /// - Parameters:
    ///   - Rect: Where to draw the diamond pattern.
    ///   - AnimateColors: Determines if colors are animated.
    func DrawDiamond(_ Rect: CGRect, AnimateColors: Bool = false)
    {
        let Context = UIGraphicsGetCurrentContext()!
        Context.setFillColor(DarkColor.cgColor)
        Context.fill(Rect)
        let DrawSize = CGSize(width: PatternSize, height: PatternSize)
        UIGraphicsBeginImageContextWithOptions(DrawSize, true, 0.0)
        let DrawingContext = UIGraphicsGetCurrentContext()!
        DarkColor.setFill()
        DrawingContext.fill(CGRect(x: 0, y: 0, width: DrawSize.width, height: DrawSize.height))
        
        let PatternPath = UIBezierPath()
        LightColor.setFill()
        
        var WidthOffset: CGFloat = 0.0
        if Int(DrawSize.width) % 2 == 0
        {
            WidthOffset = -1
        }
        var HeightOffset: CGFloat = 0.0
        if Int(DrawSize.height) % 2 == 0
        {
            HeightOffset = -1
        }
        let HMiddle = (DrawSize.width / 2) + WidthOffset
        let VMiddle = (DrawSize.height / 2) + HeightOffset
        PatternPath.move(to: CGPoint(x: HMiddle, y: 0))
        PatternPath.addLine(to: CGPoint(x: DrawSize.width + WidthOffset, y: VMiddle))
        PatternPath.addLine(to: CGPoint(x: HMiddle, y: DrawSize.height + HeightOffset))
        PatternPath.addLine(to: CGPoint(x: 0, y: VMiddle))
        PatternPath.addLine(to: CGPoint(x: HMiddle, y: 0))
        
        PatternPath.fill()
        let Image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        UIColor(patternImage: Image).setFill()
        Context.fill(Rect)
    }
    
    /// Draw checkerboard pattern. Line attributes are obtained from user settings.
    ///
    /// - Parameters:
    ///   - Rect: Where to draw the checkerboard pattern.
    ///   - AnimateColors: Determines if colors are animated.
    func DrawCheckerboard(_ Rect: CGRect, AnimateColors: Bool = false)
    {
        let Context = UIGraphicsGetCurrentContext()!
        Context.setFillColor(DarkColor.cgColor)
        Context.fill(Rect)
        let DrawSize = CGSize(width: PatternSize, height: PatternSize)
        UIGraphicsBeginImageContextWithOptions(DrawSize, true, 0.0)
        let DrawingContext = UIGraphicsGetCurrentContext()!
        DarkColor.setFill()
        DrawingContext.fill(CGRect(x: 0, y: 0, width: DrawSize.width, height: DrawSize.height))
        
        let PatternPath = UIBezierPath()
        LightColor.setFill()
        
        //Upper left
        PatternPath.move(to: CGPoint(x: DrawSize.width / 2, y: DrawSize.height / 2))
        PatternPath.addLine(to: CGPoint(x: 0, y: DrawSize.height / 2))
        PatternPath.addLine(to: CGPoint(x: 0, y: 0))
        PatternPath.addLine(to: CGPoint(x: DrawSize.width / 2, y: 0))
        PatternPath.addLine(to: CGPoint(x: DrawSize.width / 2, y: DrawSize.height / 2))
        
        //Lower right
        PatternPath.move(to: CGPoint(x: DrawSize.width / 2, y: DrawSize.height / 2))
        PatternPath.addLine(to: CGPoint(x: DrawSize.width, y: DrawSize.height / 2))
        PatternPath.addLine(to: CGPoint(x: DrawSize.width, y: DrawSize.height))
        PatternPath.addLine(to: CGPoint(x: DrawSize.width / 2, y: DrawSize.height))
        PatternPath.addLine(to: CGPoint(x: DrawSize.width / 2, y: DrawSize.height / 2))
        
        PatternPath.fill()
        let Image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        UIColor(patternImage: Image).setFill()
        Context.fill(Rect)
    }
}
