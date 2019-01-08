//
//  ColorView.swift
//  Visualizer Clock
//
//  Created by Stuart Rankin on 11/10/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class ColorView: UIView
{
    convenience init(_ VColor: UIColor)
    {
        self.init()
        Initialize()
        Color = VColor
    }
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        Initialize()
    }
    
    init(frame: CGRect, _ VColor: UIColor)
    {
        super.init(frame: frame)
        Initialize()
        Color = VColor
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    var ColorLayer: CALayer!
    
    func Initialize()
    {
        let Rect = self.frame
        ColorLayer = CALayer()
        ColorLayer.zPosition = 1000
        self.layer.addSublayer(ColorLayer)
    }
    
    private var _Color: UIColor = UIColor.clear
    public var Color: UIColor
    {
        get
        {
            return _Color
        }
        set
        {
            _Color = newValue
            UpdateView()
        }
    }
    
    func UpdateView()
    {
        setNeedsDisplay()
        ColorLayer.backgroundColor = Color.cgColor
        if _ShowMarchingAnts
        {
            AddMarchingAnts()
        }
        else
        {
            if MarchingLayer != nil
            {
                MarchingLayer.removeAnimation(forKey: "lineDashPhase")
                MarchingLayer.removeAnimation(forKey: "lineWidth")
                MarchingLayer.removeAnimation(forKey: "strokeColor")
                MarchingLayer.removeFromSuperlayer()
                MarchingLayer = nil
            }
        }
    }
    
    var MarchingLayer: CAShapeLayer!
    
    private func AddMarchingAnts()
    {
        MarchingLayer = MakeMarchingAnts()
        MarchingLayer.zPosition = 1000
        self.layer.addSublayer(MarchingLayer)
    }
    
    private func MakeMarchingAnts() -> CAShapeLayer
    {
        let Layer = CAShapeLayer()
        Layer.strokeColor = UIColor.red.cgColor
        Layer.fillColor = UIColor.clear.cgColor
        Layer.lineWidth = 3
        Layer.lineCap = .round
        Layer.lineDashPattern = [6, 6]
        
        let Path = CGMutablePath()
        let P1 = CGPoint(x: 0, y: 0)
        let P2 = CGPoint(x: self.frame.width, y: 0)
        let P3 = CGPoint(x: self.frame.width, y: self.frame.height)
        let P4 = CGPoint(x: 0, y: self.frame.height)
        Path.addLines(between: [P1, P2, P3, P4, P1])
        Layer.path = Path
        
        let AnimatedAnts = CABasicAnimation(keyPath: "lineDashPhase")
        AnimatedAnts.fromValue = 0
        AnimatedAnts.toValue = Layer.lineDashPattern?.reduce(0) {$0 + $1.intValue}
        AnimatedAnts.duration = 0.5
        AnimatedAnts.repeatCount = Float.greatestFiniteMagnitude
        Layer.add(AnimatedAnts, forKey: "MarchingAnts")
        
        let AnimatedWidth = CABasicAnimation(keyPath: "lineWidth")
        AnimatedWidth.fromValue = 0.1
        AnimatedWidth.toValue = 3
        AnimatedWidth.duration = 0.75
        AnimatedWidth.autoreverses = true
        AnimatedWidth.repeatCount = Float.greatestFiniteMagnitude
        Layer.add(AnimatedWidth, forKey: "AnimatedWidth")
        
        let AnimatedColor = CABasicAnimation(keyPath: "strokeColor")
        AnimatedColor.fromValue = UIColor.red.cgColor
        AnimatedColor.toValue = UIColor.blue.cgColor
        AnimatedColor.duration = 1.5
        AnimatedColor.autoreverses = true
        AnimatedColor.repeatCount = Float.greatestFiniteMagnitude
        Layer.add(AnimatedColor, forKey: "AnimatedColor")
        
        return Layer
    }
    
    private var _ShowMarchingAnts: Bool = false
    public var ShowMarchingAnts: Bool
    {
        get
        {
            return _ShowMarchingAnts
        }
        set
        {
            _ShowMarchingAnts = false
            UpdateView()
        }
    }
    
    /// Draw checkerboard pattern.
    ///
    /// - Parameters:
    ///   - Rect: Where to draw the checkerboard pattern.
    ///   - PatternSize: Overall size of the initial checkerboard pattern. From this, the entire checkerboard pattern
    ///                  will be built.
    func DrawCheckerboard(_ Rect: CGRect, PatternSize: CGFloat = 32)
    {
        let Context = UIGraphicsGetCurrentContext()!
        Context.setFillColor(UIColor.black.cgColor)
        Context.fill(Rect)
        let DrawSize = CGSize(width: PatternSize, height: PatternSize)
        UIGraphicsBeginImageContextWithOptions(DrawSize, true, 0.0)
        let DrawingContext = UIGraphicsGetCurrentContext()!
        UIColor.black.setFill()
        DrawingContext.fill(CGRect(x: 0, y: 0, width: DrawSize.width, height: DrawSize.height))
        
        let PatternPath = UIBezierPath()
        UIColor.white.setFill()
        
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
