//
//  BarcodeVector.swift
//  Visualizer Clock
//
//  Created by Stuart Rankin on 9/17/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit
import SpriteKit

/// Returns raw bitmap data as "vectors" that can be easily manipulated and displayed.
class BarcodeVector
{
    let _Settings = UserDefaults.standard
    
    /// Initializer.
    init()
    {
    }
    
    /// Initializer.
    ///
    /// - Parameters:
    ///   - Bitmap: Bitmap data, one Int per barcode node.
    ///   - Width: Width of the bitmap data.
    ///   - Height: Height of the bitmap data.
    init(Bitmap: [[Int]], Width: Int, Height: Int)
    {
        SetRawData(Bitmap: Bitmap, Width: Width, Height: Height)
    }
    
    /// Set bitmap data. Call if empty initializer used.
    ///
    /// - Parameters:
    ///   - Bitmap: Bitmap data, one Int per barcode node.
    ///   - Width: Width of the bitmap data.
    ///   - Height: Height of the bitmap data.
    public func SetRawData(Bitmap: [[Int]], Width: Int, Height: Int)
    {
        RawData = Bitmap
        BitmapWidth = Width
        BitmapHeight = Height
    }
    
    /// Width of the bitmap in nodes.
    private var BitmapWidth: Int = 0
    /// Height of the bitmap in nodes.
    private var BitmapHeight: Int = 0
    /// Map of the barcode in nodes.
    private var RawData: [[Int]]? = nil
    
    /// Reset the bitmap data.
    public func Reset()
    {
        RawData?.removeAll()
        RawData = nil
        BitmapWidth = 0
        BitmapHeight = 0
    }
    
    /// Create a node shape layer. Each node in a barcode gets its own shape layer.
    ///
    /// - Parameters:
    ///   - Frame: The frame of the returned shape layer. Should be as large as the parent UIView.
    ///   - NodeRect: The rectangle where the node will be drawn. This should be the final size and position of the node within the
    ///               final barcode.
    ///   - NodeShape: The shape of the node to draw. 0 = Square, 1 = Rounded Rectangle, 2 = Circle
    ///   - Foreground: The foreground (eg, node) color. If nil, random colors are used.
    ///   - Final: The final color of the node if present. If present, the color is animated to the Foreground color.
    ///   - AnimationDuration: The duration of the animation.
    /// - Returns: Shape layer with the node.
    private func CreateNodeLayer(Frame: CGRect, NodeRect: CGRect, NodeShape: Int = 0, Foreground: UIColor? = nil,
                                 Final: UIColor? = nil, AnimationDuration: Double = 0.5) -> CAShapeLayer
    {
        let Layer = CAShapeLayer()
        Layer.frame = Frame
        Layer.bounds = Frame
        Layer.backgroundColor = UIColor.clear.cgColor
        if let Foreground = Foreground
        {
            Layer.fillColor = Foreground.cgColor
        }
        else
        {
            Layer.fillColor = Utility.RandomColor(HueRange: 0.0 ... 360.0, Saturation: 0.70, Brightness: 0.65)!.cgColor
        }
        
        switch NodeShape
        {
        case 0:
            let Square = UIBezierPath(rect: NodeRect)
            Layer.path = Square.cgPath
            
        case 1:
            let Rounded = UIBezierPath(roundedRect: NodeRect, cornerRadius: 2.0)
            Layer.path = Rounded.cgPath
            
        case 2:
            let Circle = UIBezierPath(ovalIn: NodeRect)
            Layer.path = Circle.cgPath
            
        default:
            let PixelRect = NodeRect
            Layer.path = CGPath(rect: PixelRect, transform: nil)
        }
        
        if let FinalColor = Final
        {
            let Anim = CABasicAnimation(keyPath: "fillColor")
            Anim.toValue = FinalColor.cgColor
            Anim.duration = CFTimeInterval(AnimationDuration)
            Anim.repeatCount = 0
            Anim.isRemovedOnCompletion = false
            Anim.fillMode = CAMediaTimingFillMode.forwards
            Anim.autoreverses = false
            Layer.add(Anim, forKey: nil)
        }
        
        return Layer
    }
    
    var ColorVariator: Int = -1
    let ColorMax = 360
    let ColorStep = 5
    
    /// Create a node shape layer. Each node in a barcode gets its own shape layer.
    ///
    /// - Parameters:
    ///   - Frame: The frame of the returned shape layer. Should be as large as the parent UIView.
    ///   - Foreground: The foreground (eg, node) color. If nil, random colors are used.
    ///   - Final: The final color of the node if present. If present, the color is animated to the Foreground color.
    ///   - Path: Path that describes the location and size of the node.
    ///   - NodeShape: Determines the shape of the node to draw.
    /// - Returns: Shape layer with the node.
    private func CreateNodeLayer(Frame: CGRect, Foreground: UIColor? = nil, Final: UIColor? = nil, Path: CGPath,
                                 NodeShape: Int = 0) -> CAShapeLayer
    {
        let Layer = CAShapeLayer()
        Layer.frame = Frame
        Layer.bounds = Frame
        Layer.backgroundColor = UIColor.clear.cgColor
        if let Foreground = Foreground
        {
            Layer.fillColor = Foreground.cgColor
        }
        else
        {
            Layer.fillColor = Utility.RandomColor(HueRange: 0.0 ... 360.0, Saturation: 0.70, Brightness: 0.65)!.cgColor
        }
        if _Settings.bool(forKey: Setting.Key.Code128.BarcodeStroked)
        {
            Layer.strokeColor = _Settings.uicolor(forKey: Setting.Key.Code128.BarcodeStrokeColor)?.cgColor
        }
        Layer.path = Path
        
        if let FinalColor = Final
        {
            let Anim = CABasicAnimation(keyPath: "fillColor")
            Anim.isRemovedOnCompletion = false
            Anim.fillMode = CAMediaTimingFillMode.forwards
            Anim.toValue = FinalColor.cgColor
            Anim.duration = CFTimeInterval(1.0)
            Anim.repeatCount = 0
            Anim.autoreverses = false
            Layer.add(Anim, forKey: nil)
        }
        
        return Layer
    }
    
    private func CreateNodeLayer(Frame: CGRect, Center: CGPoint, OuterRadius: CGFloat, InnerRadius: CGFloat,
                                 Foreground: UIColor? = nil, FadeTo: UIColor? = nil,
                                 InnerColor: UIColor = UIColor.clear) -> CAShapeLayer
    {
        let Layer = CAShapeLayer()
        Layer.frame = Frame
        Layer.bounds = Frame
        Layer.backgroundColor = UIColor.clear.cgColor
        Layer.fillColor = UIColor.clear.cgColor
        #if false
        let FinalRect = Frame
        #else
        let FinalRect = CGRect(x: Center.x - OuterRadius, y: Center.y - OuterRadius,
                               width: OuterRadius * 2.0, height: OuterRadius * 2.0)
        #endif
        if let Foreground = Foreground
        {
            Layer.strokeColor = Foreground.cgColor
        }
        else
        {
            Layer.strokeColor = Utility.RandomColor(HueRange: 0.0 ... 360.0, Saturation: 0.70, Brightness: 0.65)!.cgColor
        }
        if _Settings.bool(forKey: Setting.Key.Code128.BarcodeStroked)
        {
            Layer.strokeColor = _Settings.uicolor(forKey: Setting.Key.Code128.BarcodeStrokeColor)?.cgColor
        }
        Layer.lineWidth = OuterRadius - InnerRadius
        let Circle = UIBezierPath(ovalIn: FinalRect)
        Layer.path = Circle.cgPath
        
        if let FinalColor = FadeTo
        {
            let Anim = CABasicAnimation(keyPath: "strokeColor")
            Anim.isRemovedOnCompletion = false
            Anim.fillMode = CAMediaTimingFillMode.forwards
            Anim.toValue = FinalColor.cgColor
            Anim.duration = CFTimeInterval(0.5)
            Anim.repeatCount = 0
            Anim.autoreverses = false
            Layer.add(Anim, forKey: nil)
        }
        
        return Layer
    }
    
    /// Create a node shape layer. Each node in a barcode gets its own shape layer. In this case, the node is defined by the
    /// four points in Points.
    ///
    /// - Parameters:
    ///   - Frame: The frame definition for the layer.
    ///   - Points: The points to draw. There must be four points in this list.
    ///   - Foreground: The foreground color of the shape. If not present, a random color is used.
    ///   - FadeTo: If present, the target animation color. If not present, no animation occurs.
    /// - Returns: Shape layer with the drawn shape.
    private func CreateNodeLayer(Frame: CGRect, Points: [CGPoint], Foreground: UIColor? = nil,
                                 FadeTo: UIColor? = nil) -> CAShapeLayer?
    {
        if Points.count != 4
        {
            return nil
        }
        let Layer = CAShapeLayer()
        Layer.frame = Frame
        Layer.bounds = Frame
        Layer.backgroundColor = UIColor.clear.cgColor
        if let Foreground = Foreground
        {
            Layer.fillColor = Foreground.cgColor
        }
        else
        {
            Layer.fillColor = Utility.RandomColor(HueRange: 0.0 ... 360.0, Saturation: 0.70, Brightness: 0.65)!.cgColor
        }
        if _Settings.bool(forKey: Setting.Key.Code128.BarcodeStroked)
        {
            Layer.strokeColor = _Settings.uicolor(forKey: Setting.Key.Code128.BarcodeStrokeColor)?.cgColor
        }
        let Lines = UIBezierPath()
        Lines.move(to: Points[0])
        Lines.addLine(to: Points[1])
        Lines.addLine(to: Points[2])
        Lines.addLine(to: Points[3])
        Lines.addLine(to: Points[0])
        Layer.path = Lines.cgPath
        
        if let FinalColor = FadeTo
        {
            let Anim = CABasicAnimation(keyPath: "fillColor")
            Anim.isRemovedOnCompletion = false
            Anim.fillMode = CAMediaTimingFillMode.forwards
            Anim.toValue = FinalColor.cgColor
            Anim.duration = CFTimeInterval(1.0)
            Anim.repeatCount = 0
            Anim.autoreverses = false
            Layer.add(Anim, forKey: nil)
        }
        
        return Layer
    }
    
    /// Dump the contents of the bitmap to the console.
    public func DumpBitmap()
    {
        if RawData == nil
        {
            print("Raw data is nil - nothing to dump.")
        }
        let ColumnCount = "0123456789"
        let ColumnRepeats = (BitmapWidth / 10)
        var ColumnHeader = ""
        for _ in 0 ... ColumnRepeats
        {
            ColumnHeader = ColumnHeader + ColumnCount
        }
        ColumnHeader = "     " + ColumnHeader
        print(ColumnHeader)
        for Row in 0 ... BitmapHeight - 1
        {
            var ColumnString = String(format: "%03d", Row) + ": "
            for Column in 0 ... BitmapWidth - 1
            {
                ColumnString = ColumnString + String(RawData![Row][Column])
            }
            print(ColumnString)
        }
    }
    
    /// Scan the preset barcode data to derive a list of what pixels are on and off.
    ///
    /// - Parameter ScanRow: The scan row to use. If out of range, 0 is used.
    /// - Returns: List of on and off columns along with the size of each column.
    public func ScanRasterBarcode(ScanRow: Int) -> [(Bool, Int)]
    {
        var CurrentValue: Bool = false
        var Results: [(Bool,Int)] = [(Bool,Int)]()
        Results.append((false,0))
        var ArrayIndex = 0
        let Scan =  ScanRow > BitmapHeight || ScanRow < 0 ? 0 : ScanRow
        for Column in 0 ... BitmapWidth - 1
        {
            let DrawPixel = RawData![Scan][Column] > 0
            if Column == 0
            {
                CurrentValue = DrawPixel
                Results[0] = (CurrentValue, 0)
            }
            else
            {
                if DrawPixel != CurrentValue
                {
                    CurrentValue = DrawPixel
                    ArrayIndex = ArrayIndex + 1
                    Results.append((CurrentValue, 0))
                }
            }
            Results[ArrayIndex].1 = Results[ArrayIndex].1 + 1
        }
        return Results
    }
    
    /// Create a view to display from the previously set barcode bitmap data. This function assumes the barcode is a one-dimensional
    /// code (eg, not a QR or Aztec or similar). This function is mostly good for barcodes similar to Code 128 with no embellishments.
    ///
    /// - Parameters:
    ///   - Foreground: Foreground color. This is the color of the node of the bitmap.
    ///   - Background: Background color.
    ///   - ViewWidth: Width of the target view.
    ///   - ViewHeight: Height of the target view.
    ///   - TopMargin: Margin at the top where no drawing will take place.
    ///   - LeftMargin: Margin at the left where no drawing will take place.
    ///   - BottomMargin: Margin at the bottom where no drawing will take place.
    ///   - RightMargin: Margin at the right where no drawing will take place.
    ///   - ScanRow: The row to scan for shape information. If the passed scan row value is invalid (eg, out of bounds), 0 is used.
    ///   - FinalCenter: The final center of where to draw the barcode.
    ///   - PreviousResults: Previous results for delta calculations.
    ///   - HighlightFX: Determines which, if any, highlighting to apply to the barcode.
    /// - Returns: UIView with probably lots of CAShapeLayers that represents a barcode.
    public func MakeView1D(Foreground: UIColor, Background: UIColor, Highlight: UIColor, ViewWidth: Int, ViewHeight: Int,
                           TopMargin: Int? = nil, LeftMargin: Int? = nil, BottomMargin: Int? = nil,
                           RightMargin: Int? = nil, ScanRow: Int = 0, FinalCenter: CGFloat? = nil,
                           PreviousResults: inout [Int]?, HighlightFX: Int = 0) -> UIView?
    {
        if RawData == nil
        {
            print("Raw data is nil.")
            return nil
        }
        
        RingForeground = Foreground
        RingHighlight = UIColor.yellow
        
        let ViewFrame = CGRect(x: 0, y: 0, width: ViewWidth, height: ViewHeight)
        let MainView = UIView(frame: ViewFrame)
        MainView.bounds = ViewFrame
        MainView.backgroundColor = UIColor.clear
        
        let Margin_Top = TopMargin == nil ? 0 : TopMargin!
        let Margin_Left = LeftMargin == nil ? 0 : LeftMargin!
        let Margin_Bottom = BottomMargin == nil ? 0 : BottomMargin!
        let Margin_Right = RightMargin == nil ? 0 : RightMargin!
        
        let EffectiveWidth = Int(ViewFrame.width) - (Margin_Right - Margin_Left)
        
        PixelLayer = CAShapeLayer()
        PixelLayer.frame = ViewFrame
        PixelLayer.bounds = ViewFrame
        PixelLayer.backgroundColor = UIColor.clear.cgColor
        MainView.layer.addSublayer(PixelLayer)
        
        let HPixelSize: CGFloat = CGFloat(EffectiveWidth) / CGFloat(BitmapWidth)
        var LayerCount = 0
        
        let Results = ScanRasterBarcode(ScanRow: ScanRow)
        
        //Get the delta between the previous barcode and the current barcode.
        let VisCount = Results.filter({$0.0}).map({return $0.1})
        var Delta = [Bool]()
        //Initialize the delta map.
        for _ in 0 ..< VisCount.count
        {
            Delta.append(false)
        }
        if PreviousResults == nil
        {
            //No previous results - set the current results as the previous results. Since
            //the delta map has already been initialized to all false, no other action is
            //needed.
            PreviousResults = [Int]()
            for Count in VisCount
            {
                PreviousResults?.append(Count)
            }
        }
        else
        {
            for Index in 0 ..< VisCount.count
            {
                Delta[Index] = VisCount[Index] != PreviousResults?[Index]
                PreviousResults?[Index] = VisCount[Index]
            }
        }
        
        var Accumulator: CGFloat = 0.0
        let BarcodeHeight = CGFloat(ViewHeight - (Margin_Top + Margin_Bottom))
        let BarcodeHeightHalf = BarcodeHeight / 2.0
        var TopOfBarcode: CGFloat = 0.0
        if FinalCenter == nil
        {
            TopOfBarcode = (UIScreen.main.bounds.height / 2.0) - BarcodeHeightHalf
        }
        else
        {
            TopOfBarcode = FinalCenter! - BarcodeHeightHalf
        }
        
        var VisIndex = 0
        for (Value, Count) in Results
        {
            let Start = Accumulator
            let End = Accumulator + (CGFloat(Count) * HPixelSize)
            Accumulator = Accumulator + (CGFloat(Count) * HPixelSize)
            if !Value
            {
                continue
            }
            let Width = CGFloat(End - Start)
            let Left = CGFloat(Margin_Left) + Start
            let PixelRect = CGRect(x: Left, y: TopOfBarcode, width: Width, height: BarcodeHeight)
            #if true
            var NodeLayer: CAShapeLayer!
            if Delta[VisIndex] && HighlightFX == 1
            {
                NodeLayer = CreateNodeLayer(Frame: ViewFrame, Foreground: Highlight, Final: Foreground,
                                            Path: CGPath(rect: PixelRect, transform: nil))
            }
            else
            {
                NodeLayer = CreateNodeLayer(Frame: ViewFrame, Foreground: Foreground, Final: nil,
                                            Path: CGPath(rect: PixelRect, transform: nil))
            }
            #else
            var NodeLayer = CreateNodeLayer(Frame: ViewFrame, Foreground: Foreground,
                                            Path: CGPath(rect: PixelRect, transform: nil))
            #endif
            ApplyShadow(Level: _Settings.integer(forKey: Setting.Key.Code128.ShadowEffect), Layer: &NodeLayer)
            NodeLayer!.setValue(LayerCount, forKey: "Tag")
            PixelLayer.addSublayer(NodeLayer)
            LayerCount = LayerCount + 1
            VisIndex = VisIndex + 1
        }
        
        if HighlightFX == 2
        {
            if FXTimer != nil
            {
                FXTimer?.invalidate()
                FXTimer = nil
            }
            PreviousIndex = -1
            LastVisibleIndex = -1
            var Interval = 1.0 / Double(VisCount.count)
            Interval = Interval * 0.85
            FXTimer = Timer.scheduledTimer(timeInterval: TimeInterval(Interval), target: self,
                                           selector: #selector(Barcode1DHighlight), userInfo: nil,
                                           repeats: true)
        }
        
        _LastNodeCount = LayerCount
        return MainView
    }
    
    public func MakeView1D(_ Handle: VectorHandle) -> UIView?
    {
        if RawData == nil
        {
            print("Raw data is nil.")
            return nil
        }
        
        RingForeground = Handle.Foreground
        RingHighlight = Handle.HighlightColor
        
        let ViewFrame = CGRect(x: 0, y: 0, width: Handle.ViewWidth, height: Handle.ViewHeight)
        let MainView = UIView(frame: ViewFrame)
        MainView.bounds = ViewFrame
        MainView.backgroundColor = UIColor.clear
        
        let EffectiveWidth = Handle.EffectiveWidth
        
        PixelLayer = CAShapeLayer()
        PixelLayer.frame = ViewFrame
        PixelLayer.bounds = ViewFrame
        PixelLayer.backgroundColor = UIColor.clear.cgColor
        MainView.layer.addSublayer(PixelLayer)
        
        let HPixelSize: CGFloat = CGFloat(EffectiveWidth) / CGFloat(BitmapWidth)
        var LayerCount = 0
        
        Handle.RasterScanData1D = ScanRasterBarcode(ScanRow: Handle.ScanRow)
        let Delta = Handle.GetDelta1D()
        
        var UnitLength: Int = 0
        TotalVisibleRingNodeCount = Handle.RasterScanData1D!.count
        IsVisibleCount = 0
        for (IsVisible, Count) in Handle.RasterScanData1D!
        {
            IsVisibleCount = IsVisibleCount + (IsVisible ? 1 : 0)
            UnitLength = UnitLength + Count
        }
        
        var Accumulator: CGFloat = 0.0
        let (Top, _, Bottom, _) = Handle.EffectiveMargins()
        let BarcodeHeight = CGFloat(Handle.ViewHeight - (Top + Bottom))
        let BarcodeHeightHalf = BarcodeHeight / 2.0
        var TopOfBarcode: CGFloat = 0.0
        if Handle.FinalCenter == nil
        {
            TopOfBarcode = (UIScreen.main.bounds.height / 2.0) - BarcodeHeightHalf
        }
        else
        {
            TopOfBarcode = Handle.FinalCenter! - BarcodeHeightHalf
        }
        
        var VisIndex = 0
        let (_, LeftMargin, _, _) = Handle.EffectiveMargins()
        for (Value, Count) in Handle.RasterScanData1D!
        {
            let Start = Accumulator
            let End = Accumulator + (CGFloat(Count) * HPixelSize)
            Accumulator = Accumulator + (CGFloat(Count) * HPixelSize)
            if !Value
            {
                continue
            }
            let Width = CGFloat(End - Start)
            let Left = CGFloat(LeftMargin) + Start
            let PixelRect = CGRect(x: Left, y: TopOfBarcode, width: Width, height: BarcodeHeight)
            var NodeLayer: CAShapeLayer!
            if Delta![VisIndex] && Handle.HighlightStyle == 1
            {
                NodeLayer = CreateNodeLayer(Frame: ViewFrame, Foreground: Handle.HighlightColor, Final: Handle.Foreground,
                                            Path: CGPath(rect: PixelRect, transform: nil))
            }
            else
            {
                NodeLayer = CreateNodeLayer(Frame: ViewFrame, Foreground: Handle.Foreground, Final: nil,
                                            Path: CGPath(rect: PixelRect, transform: nil))
            }
            ApplyShadow(Level: Handle.ShadowLevel, Layer: &NodeLayer)
            NodeLayer!.setValue(LayerCount, forKey: "Tag")
            PixelLayer.addSublayer(NodeLayer)
            LayerCount = LayerCount + 1
            VisIndex = VisIndex + 1
        }
        
        if Handle.HighlightStyle == 2
        {
            if FXTimer != nil
            {
                FXTimer?.invalidate()
                FXTimer = nil
            }
            PreviousIndex = -1
            LastVisibleIndex = -1
            var Interval = 1.0 / Double(Handle.VisibleNodeCount)
            Interval = Interval * 0.85
            FXTimer = Timer.scheduledTimer(timeInterval: TimeInterval(Interval), target: self,
                                           selector: #selector(Barcode1DHighlight), userInfo: nil,
                                           repeats: true)
        }
        
        _LastNodeCount = LayerCount
        return MainView
    }
    
    /// Apply the proper shadow size to the passed layer.
    ///
    /// - Parameters:
    ///   - Level: The level of the shadow.
    ///   - Layer: The layer to apply the shadow to. (Set Level to 0 for no shadow.)
    func ApplyShadow(Level: Int, Layer: inout CAShapeLayer)
    {
        if Level == 0
        {
            return
        }
        var Offset: CGSize!
        var Opacity: Float = 0.0
        var Radius: CGFloat = 0.0
        var Color = UIColor.black
        switch Level
        {
        case 1:
            Offset = CGSize(width: 2, height: 2)
            Opacity = 0.5
            Radius = 0.5
            Color = UIColor.darkGray
            
        case 2:
            Offset = CGSize(width: 3, height: 3)
            Opacity = 0.5
            Radius = 1.0
            Color = UIColor.black
            
        case 3:
            Offset = CGSize(width: 5, height: 5)
            Opacity = 0.5
            Radius = 2.0
            Color = UIColor.black
            
        default:
            Offset = CGSize(width: 2, height: 2)
            Opacity = 0.5
            Radius = 0.5
            Color = UIColor.black
        }
        
        Layer.shadowColor = Color.cgColor
        Layer.shadowOffset = Offset
        Layer.shadowOpacity = Opacity
        Layer.shadowRadius = Radius
    }
    
    var RingForeground: UIColor = UIColor.black
    var RingHighlight: UIColor = UIColor.blue
    var TotalVisibleRingNodeCount: Int = 0
    var IsVisibleCount: Int = 0
    
    /// Scans a preset 1D barcode and converts it to a ring barcode.
    ///
    /// - Parameters:
    ///   - Foreground1: First foreground color.
    ///   - Foreground2: Second foreground color.
    ///   - PercentForeground1: Percent of the barcode nodes that use the first color. The remainder will use the second color.
    ///   - ViewPort: Size of the view port.
    ///   - ViewWidth: Width of the view.
    ///   - ViewHeight: Height of the view.
    ///   - OuterRadius: Outer radius of the ring barcode.
    ///   - InnerRadius: Inner radius of the ring barcode. The inner radius is considered the base length of the barcode.
    ///   - PreviousResults: Pointer to an array of integers that holds the previous result. Should be set to nil on first call
    ///                      to this function.
    ///   - ScanRow: The row in the raster barcode to scan. If invalid, 0 will be used.
    ///   - HighlightFX: Determines if special effects highlighting occurs.
    /// - Returns: UIView with the ring barcode.
    public func MakeView1DRing(Foreground1: UIColor, Foreground2: UIColor, PercentForeground1: Double,
                               ViewPort: CGSize, ViewWidth: Int, ViewHeight: Int,
                               OuterRadius: CGFloat, InnerRadius: CGFloat,
                               PreviousResults: inout [Int]?,
                               ScanRow: Int = 0, HighlightFX: Int = 0) -> UIView?
    {
        if RawData == nil
        {
            print("Raw data is nil.")
            return nil
        }
        RingForeground = Foreground1
        RingHighlight = Foreground2
        let ViewFrame = CGRect(x: 0, y: 0, width: ViewWidth, height: ViewHeight)
        let MainView = UIView(frame: ViewFrame)
        MainView.bounds = ViewFrame
        MainView.backgroundColor = UIColor.clear
        
        PixelLayer = CAShapeLayer()
        PixelLayer.frame = ViewFrame
        PixelLayer.bounds = ViewFrame
        PixelLayer.backgroundColor = UIColor.clear.cgColor
        MainView.layer.addSublayer(PixelLayer)
        
        var LayerCount = 0
        
        let Results = ScanRasterBarcode(ScanRow: ScanRow)
        
        //Get the delta between the previous barcode and the current barcode.
        let VisCount = Results.filter({$0.0}).map({return $0.1})
        var Delta = [Bool]()
        //Initialize the delta map.
        for _ in 0 ..< VisCount.count
        {
            Delta.append(false)
        }
        if PreviousResults == nil
        {
            //No previous results - set the current results as the previous results. Since
            //the delta map has already been initialized to all false, no other action is
            //needed.
            PreviousResults = [Int]()
            for Count in VisCount
            {
                PreviousResults?.append(Count)
            }
        }
        else
        {
            for Index in 0 ..< VisCount.count
            {
                Delta[Index] = VisCount[Index] != PreviousResults?[Index]
                PreviousResults?[Index] = VisCount[Index]
            }
        }
        
        var UnitLength: Int = 0
        TotalVisibleRingNodeCount = Results.count
        IsVisibleCount = 0
        for (IsVisible, Count) in Results
        {
            IsVisibleCount = IsVisibleCount + (IsVisible ? 1 : 0)
            UnitLength = UnitLength + Count
        }
        
        let UnitMultiplier = 360.0 / CGFloat(UnitLength)
        
        var Accumulator: CGFloat = 0.0
        let Center = CGPoint(x: ViewPort.width / 2.0, y: ViewPort.height / 2.0)
        
        var LayerIndex = 0
        var VisIndex = 0
        for (Value, Count) in Results
        {
            if !Value
            {
                Accumulator = Accumulator + (CGFloat(Count) * UnitMultiplier)
                continue
            }
            let InnerPoint1 = MakePoint(Radius: InnerRadius, Angle: Accumulator, Center: Center)
            let OuterPoint1 = MakePoint(Radius: OuterRadius, Angle: Accumulator, Center: Center)
            Accumulator = Accumulator + (CGFloat(Count) * UnitMultiplier)
            let InnerPoint2 = MakePoint(Radius: InnerRadius, Angle: Accumulator, Center: Center)
            let OuterPoint2 = MakePoint(Radius: OuterRadius, Angle: Accumulator, Center: Center)
            
            var NodeLayer: CAShapeLayer!
            if Delta[VisIndex] && HighlightFX == 1
            {
                NodeLayer = CreateNodeLayer(Frame: ViewFrame, Points:[InnerPoint1,InnerPoint2,OuterPoint2,OuterPoint1],
                                            Foreground: Foreground2, FadeTo: Foreground1)
            }
            else
            {
                NodeLayer = CreateNodeLayer(Frame: ViewFrame, Points: [InnerPoint1,InnerPoint2,OuterPoint2,OuterPoint1],
                                            Foreground: Foreground1)
            }
            
            if NodeLayer != nil
            {
                ApplyShadow(Level: _Settings.integer(forKey: Setting.Key.Code128.ShadowEffect), Layer: &NodeLayer!)
                NodeLayer!.setValue(LayerIndex, forKey: "Tag")
                LayerIndex = LayerIndex + 1
                PixelLayer.addSublayer(NodeLayer!)
                LayerCount = LayerCount + 1
            }
            VisIndex = VisIndex + 1
        }
        
        _LastNodeCount = LayerCount
        if HighlightFX == 2
        {
            if FXTimer != nil
            {
                FXTimer?.invalidate()
                FXTimer = nil
            }
            PreviousIndex = -1
            LastVisibleIndex = -1
            var Interval = 1.0 / CGFloat(IsVisibleCount)
            Interval = Interval * 0.85
            FXTimer = Timer.scheduledTimer(timeInterval: TimeInterval(Interval), target: self,
                                           selector: #selector(Barcode1DHighlight), userInfo: nil,
                                           repeats: true)
        }
        return MainView
    }
    
    public func MakeView1DRing(_ Handle: VectorHandle) -> UIView?
    {
        if RawData == nil
        {
            print("Raw data is nil.")
            return nil
        }
        RingForeground = Handle.Foreground
        RingHighlight = Handle.HighlightColor
        let ViewFrame = CGRect(x: 0, y: 0, width: Handle.ViewWidth, height: Handle.ViewHeight)
        let MainView = UIView(frame: ViewFrame)
        MainView.bounds = ViewFrame
        MainView.backgroundColor = UIColor.clear
        
        PixelLayer = CAShapeLayer()
        PixelLayer.frame = ViewFrame
        PixelLayer.bounds = ViewFrame
        PixelLayer.backgroundColor = UIColor.clear.cgColor
        MainView.layer.addSublayer(PixelLayer)
        
        var LayerCount = 0
        
        Handle.RasterScanData1D = ScanRasterBarcode(ScanRow: Handle.ScanRow)
        let Delta = Handle.GetDelta1D()
        
        var UnitLength: Int = 0
        TotalVisibleRingNodeCount = Handle.RasterScanData1D!.count
        IsVisibleCount = 0
        for (IsVisible, Count) in Handle.RasterScanData1D!
        {
            IsVisibleCount = IsVisibleCount + (IsVisible ? 1 : 0)
            UnitLength = UnitLength + Count
        }
        
        let UnitMultiplier = 360.0 / CGFloat(UnitLength)
        
        var Accumulator: CGFloat = 0.0
        let (Top, _, Bottom, _) = Handle.EffectiveMargins()
        let BarcodeHeight = CGFloat(Handle.ViewHeight - (Top + Bottom))
        let BarcodeHeightHalf = BarcodeHeight / 2.0
        var TopOfBarcode: CGFloat = 0.0
        var Center: CGPoint!
        if Handle.FinalCenter == nil
        {
            Center = CGPoint(x: UIScreen.main.bounds.width / 2.0, y: UIScreen.main.bounds.height / 2.0)
        }
        else
        {
            TopOfBarcode = Handle.FinalCenter! - BarcodeHeightHalf
            Center = CGPoint(x: Handle.ViewWidth / 2, y: Handle.ViewHeight / 2 + Int(TopOfBarcode))
        }
        
        var LayerIndex = 0
        var VisIndex = 0
        for (Value, Count) in Handle.RasterScanData1D!
        {
            if !Value
            {
                Accumulator = Accumulator + (CGFloat(Count) * UnitMultiplier)
                continue
            }
            let InnerPoint1 = MakePoint(Radius: CGFloat(Handle.InnerRadius), Angle: Accumulator, Center: Center)
            let OuterPoint1 = MakePoint(Radius: CGFloat(Handle.OuterRadius), Angle: Accumulator, Center: Center)
            Accumulator = Accumulator + (CGFloat(Count) * UnitMultiplier)
            let InnerPoint2 = MakePoint(Radius: CGFloat(Handle.InnerRadius), Angle: Accumulator, Center: Center)
            let OuterPoint2 = MakePoint(Radius: CGFloat(Handle.OuterRadius), Angle: Accumulator, Center: Center)
            
            var NodeLayer: CAShapeLayer!
            if Delta![VisIndex] && Handle.HighlightStyle == 1
            {
                NodeLayer = CreateNodeLayer(Frame: ViewFrame, Points:[InnerPoint1,InnerPoint2,OuterPoint2,OuterPoint1],
                                            Foreground: Handle.HighlightColor, FadeTo: Handle.Foreground)
            }
            else
            {
                NodeLayer = CreateNodeLayer(Frame: ViewFrame, Points: [InnerPoint1,InnerPoint2,OuterPoint2,OuterPoint1],
                                            Foreground: Handle.Foreground)
            }
            
            if NodeLayer != nil
            {
                ApplyShadow(Level: Handle.ShadowLevel, Layer: &NodeLayer!)
                NodeLayer!.setValue(LayerIndex, forKey: "Tag")
                LayerIndex = LayerIndex + 1
                PixelLayer.addSublayer(NodeLayer!)
                LayerCount = LayerCount + 1
            }
            VisIndex = VisIndex + 1
        }
        
        _LastNodeCount = LayerCount
        if Handle.HighlightStyle == 2
        {
            if FXTimer != nil
            {
                FXTimer?.invalidate()
                FXTimer = nil
            }
            PreviousIndex = -1
            LastVisibleIndex = -1
            var Interval = 1.0 / CGFloat(IsVisibleCount)
            Interval = Interval * 0.85
            FXTimer = Timer.scheduledTimer(timeInterval: TimeInterval(Interval), target: self,
                                           selector: #selector(Barcode1DHighlight), userInfo: nil,
                                           repeats: true)
        }
        return MainView
    }
    
    /// Create a 1D barcode shaped like a target.
    ///
    /// - Parameter Handle: Handle that describes how to draw the barcode.
    /// - Returns: Barcode embedded in the returned UIView on success, nil on failure.
    public func MakeView1DTarget(_ Handle: VectorHandle) -> UIView?
    {
        if RawData == nil
        {
            print("Raw data is nil.")
            return nil
        }
        RingForeground = Handle.Foreground
        RingHighlight = Handle.HighlightColor
        let ViewFrame = CGRect(x: 0, y: 0, width: Handle.ViewWidth, height: Handle.ViewHeight)
        let MainView = UIView(frame: ViewFrame)
        MainView.bounds = ViewFrame
        MainView.backgroundColor = UIColor.clear
        
        PixelLayer = CAShapeLayer()
        PixelLayer.frame = ViewFrame
        PixelLayer.bounds = ViewFrame
        PixelLayer.backgroundColor = UIColor.clear.cgColor
        MainView.layer.addSublayer(PixelLayer)
        
        var LayerCount = 0
        
        Handle.RasterScanData1D = ScanRasterBarcode(ScanRow: Handle.ScanRow)
        let Delta = Handle.GetDelta1D()
        
        var UnitLength: Int = 0
        TotalVisibleRingNodeCount = Handle.RasterScanData1D!.count
        IsVisibleCount = 0
        for (IsVisible, Count) in Handle.RasterScanData1D!
        {
            IsVisibleCount = IsVisibleCount + (IsVisible ? 1 : 0)
            UnitLength = UnitLength + Count
        }
        
        let (Top, _, Bottom, _) = Handle.EffectiveMargins()
        let BarcodeHeight = CGFloat(Handle.ViewHeight - (Top + Bottom))
        let BarcodeHeightHalf = BarcodeHeight / 2.0
        var TopOfBarcode: CGFloat = 0.0
        var Center: CGPoint!
        if Handle.FinalCenter == nil
        {
            Center = CGPoint(x: UIScreen.main.bounds.width / 2.0, y: UIScreen.main.bounds.height / 2.0)
        }
        else
        {
            TopOfBarcode = Handle.FinalCenter! - BarcodeHeightHalf
            Center = CGPoint(x: Handle.ViewWidth / 2, y: Handle.ViewHeight / 2 + Int(TopOfBarcode))
        }
        let Offset = Top + Bottom
        let UnitMultiplier = CGFloat(Handle.ViewHeight - Offset) / CGFloat(UnitLength)
        
        var LayerIndex = 0
        var VisIndex = 0
        var Accumulator: CGFloat = 0.0
        for (Value, Count) in Handle.RasterScanData1D!
        {
            if !Value
            {
                Accumulator = Accumulator + (CGFloat(Count) * UnitMultiplier)
                continue
            }
            let InnerRadius = CGFloat(VisIndex == 0 ? 0.0 : Accumulator) / 2.0
            Accumulator = Accumulator + (CGFloat(Count) * UnitMultiplier)
            let OuterRadius = Accumulator / 2.0
            
            var NodeLayer: CAShapeLayer!
            if Delta![VisIndex] && Handle.HighlightStyle == 1
            {
                NodeLayer = CreateNodeLayer(Frame: ViewFrame, Center: Center, OuterRadius: OuterRadius, InnerRadius: InnerRadius,
                                            Foreground: Handle.HighlightColor, FadeTo: Handle.Foreground)
            }
            else
            {
                NodeLayer = CreateNodeLayer(Frame: ViewFrame, Center: Center, OuterRadius: OuterRadius, InnerRadius: InnerRadius,
                                            Foreground: Handle.Foreground)
            }
            
            if NodeLayer != nil
            {
                ApplyShadow(Level: _Settings.integer(forKey: Setting.Key.Code128.ShadowEffect), Layer: &NodeLayer!)
                NodeLayer!.setValue(LayerIndex, forKey: "Tag")
                LayerIndex = LayerIndex + 1
                PixelLayer.addSublayer(NodeLayer!)
                LayerCount = LayerCount + 1
            }
            VisIndex = VisIndex + 1
        }
        
        _LastNodeCount = LayerCount
        if Handle.HighlightStyle == 2
        {
            if FXTimer != nil
            {
                FXTimer?.invalidate()
                FXTimer = nil
            }
            PreviousIndex = -1
            LastVisibleIndex = -1
            var Interval = 1.0 / CGFloat(IsVisibleCount)
            Interval = Interval * 0.85
            FXTimer = Timer.scheduledTimer(timeInterval: TimeInterval(Interval), target: self,
                                           selector: #selector(Barcode1DHighlight), userInfo: nil,
                                           repeats: true)
        }
        return MainView
    }
    
    /// Get a shape layer from the PixelLayer by tag ID.
    ///
    /// - Parameter Tag: The ID of the tab associated with the layer to be returned.
    /// - Returns: The layer with the passed Tag ID on success, nil if not found.
    func GetLayerByTag(_ Tag: Int) -> CAShapeLayer?
    {
        var TaggedLayer: CAShapeLayer? = nil
        PixelLayer!.sublayers!.forEach{
            let RawTag = $0.value(forKey: "Tag")
            let TagValue = RawTag as! Int
            if TagValue == Tag
            {
                TaggedLayer = $0 as? CAShapeLayer
            }
        }
        return TaggedLayer
    }
    
    /// Highlight part of the barcode.
    @objc func Barcode1DHighlight()
    {
        #if false
        if PreviousIndex > -1
        {
            let PreviousLayer = GetLayerByTag(PreviousIndex)
            PreviousLayer?.fillColor = RingForeground.cgColor
        }
        PreviousIndex = LastVisibleIndex
        #endif
        LastVisibleIndex = LastVisibleIndex + 1
        if LastVisibleIndex > IsVisibleCount
        {
            FXTimer?.invalidate()
            FXTimer = nil
            return
        }
        let CurrentLayer = GetLayerByTag(LastVisibleIndex)
        CurrentLayer?.fillColor = RingHighlight.cgColor
    }
    
    var PreviousIndex = -1
    var LastVisibleIndex = 0
    
    var FXTimer: Timer? = nil
    var PixelLayer: CAShapeLayer!
    
    /// Convert from a polar coordinate to a cartesian coordinate.
    ///
    /// - Parameters:
    ///   - Radius: Radial length of the point.
    ///   - Angle: Angle of the point (in degrees).
    ///   - Center: Center of the coordinate universe.
    /// - Returns: Cartesian point calculated from the passed polar coordinate.
    func MakePoint(Radius: CGFloat, Angle: CGFloat, Center: CGPoint) -> CGPoint
    {
        let RadialAngle: CGFloat = Angle * .pi / 180.0
        let X: CGFloat = (Radius * cos(RadialAngle)) + Center.x
        let Y: CGFloat = (Radius * sin(RadialAngle)) + Center.y
        return CGPoint(x: X, y: Y)
    }
    
    /// Create a view to display from the previously set barcode bitmap data.
    ///
    /// - Parameters:
    ///   - Foreground: Foreground color. This is the color of the node of the bitmap.
    ///   - Background: Background color.
    ///   - Highlight: Highlight color.
    ///   - ViewWidth: Width of the target view.
    ///   - ViewHeight: Height of the target view.
    ///   - TopMargin: Margin at the top where no drawing will take place.
    ///   - LeftMargin: Margin at the left where no drawing will take place.
    ///   - BottomMargin: Margin at the bottom where no drawing will take place.
    ///   - RightMargin: Margin at the right where no drawing will take place.
    ///   - HighlightSFX: Determines the highlighting to show.
    ///   - NodeShape: Shape of individual nodes.
    /// - Returns: UIView with probably lots of CAShapeLayers that represents a barcode.
    public func MakeView(Foreground: UIColor, Background: UIColor, Highlight: UIColor,
                         ViewWidth: Int, ViewHeight: Int,
                         TopMargin: Int? = nil, LeftMargin: Int? = nil, BottomMargin: Int? = nil,
                         RightMargin: Int? = nil, HighlightSFX: Int = 0,
                         NodeShape: Int = 0, Previous: inout [[Int]]?) -> UIView?
    {
        if RawData == nil
        {
            print("Raw data is nil.")
            return nil
        }
        
        var BCount = 0
        var Delta = [[Bool]](repeating: [Bool](repeating: false, count: BitmapWidth), count: BitmapHeight)
        if Previous == nil
        {
            Previous = RawData
        }
        else
        {
            for Row in 0 ... BitmapHeight - 1
            {
                for Column in 0 ... BitmapWidth - 1
                {
                    let NewPixel = RawData![(BitmapHeight - 1) - Row][Column]
                    let PreviousPixel = Previous![(BitmapHeight - 1) - Row][Column]
                    let IsDelta = NewPixel != PreviousPixel
                    Delta[(BitmapHeight - 1) - Row][Column] = IsDelta
                    if IsDelta
                    {
                        BCount = BCount + 1
                    }
                }
            }
            Previous = RawData
        }
        
        let ViewFrame = CGRect(x: 0, y: 0, width: ViewWidth, height: ViewHeight)
        let MainView = UIView(frame: ViewFrame)
        MainView.bounds = ViewFrame
        MainView.backgroundColor = Background
        
        let Margin_Top = TopMargin == nil ? 0 : TopMargin!
        let Margin_Left = LeftMargin == nil ? 0 : LeftMargin!
        let Margin_Bottom = BottomMargin == nil ? 0 : BottomMargin!
        let Margin_Right = RightMargin == nil ? 0 : RightMargin!
        
        let EffectiveWidth = Int(ViewFrame.width) - (Margin_Right - Margin_Left)
        let EffectiveHeight = Int(ViewFrame.height) - (Margin_Bottom - Margin_Top)
        //print("EffectiveWidth: \(EffectiveWidth), EffectiveHeight: \(EffectiveHeight)")
        
        PixelLayer = CAShapeLayer()
        PixelLayer.frame = ViewFrame
        PixelLayer.bounds = ViewFrame
        PixelLayer.backgroundColor = UIColor.clear.cgColor
        MainView.layer.addSublayer(PixelLayer)
        
        let HPixelSize: CGFloat = CGFloat(EffectiveWidth) / CGFloat(BitmapWidth)
        let VPixelSize: CGFloat = CGFloat(EffectiveHeight) / CGFloat(BitmapHeight)
        var LayerCount = 0
        
        for Row in 0 ... BitmapHeight - 1
        {
            for Column in 0 ... BitmapWidth - 1
            {
                let DrawPixel = RawData![(BitmapHeight - 1) - Row][Column] > 0
                if DrawPixel
                {
                    let PixelRect = CGRect(x: (CGFloat(Margin_Left) + (CGFloat(Column) * HPixelSize)), y: (CGFloat(Margin_Top) + (CGFloat(Row) * VPixelSize)),
                                           width: HPixelSize, height: VPixelSize)
                    var HighlightValue: UIColor? = nil
                    var StartingColor = Foreground
                    if Delta[(BitmapHeight - 1) - Row][Column] && HighlightSFX == 1
                    {
                        StartingColor = Highlight
                        HighlightValue = Foreground
                    }
                    var NodeLayer = CreateNodeLayer(Frame: ViewFrame, NodeRect: PixelRect, NodeShape: NodeShape,
                                                    Foreground: StartingColor, Final: HighlightValue)
                    PixelLayer.addSublayer(NodeLayer)
                    LayerCount = LayerCount + 1
                    ApplyShadow(Level: _Settings.integer(forKey: Setting.Key.QRCode.ShadowLevel), Layer: &NodeLayer)
                }
            }
        }
        
        _LastNodeCount = LayerCount
        return MainView
    }
    
    /// Create a view from a 2D barcode whose data is in the passed vector handle.
    ///
    /// - Parameter Handle: Vector handle with information on how to create and display the barcode.
    /// - Returns: UIView with the barcode.
    public func MakeView2D(_ Handle: VectorHandle) -> UIView?
    {
        if !Handle.HasData
        {
            print("Raw data is nil.")
            return nil
        }
        
        let Delta = Handle.GetDelta()
        
        let ViewFrame = CGRect(x: 0, y: 0, width: Handle.ViewWidth, height: Handle.ViewHeight)
        let MainView = UIView(frame: ViewFrame)
        MainView.bounds = ViewFrame
        MainView.backgroundColor = Handle.Background
        
        Handle.MakePixelLayer(Frame: ViewFrame, Bounds: ViewFrame, BackgroundColor: Handle.Background)
        MainView.layer.addSublayer(Handle.PixelLayer)
        
        let HPixelSize: CGFloat = CGFloat(Handle.EffectiveWidth) / CGFloat(Handle.BitmapWidth)
        let VPixelSize: CGFloat = CGFloat(Handle.EffectiveHeight) / CGFloat(Handle.BitmapHeight)
        Handle.LayerCount = 0
        let (Margin_Top, Margin_Left, _, _) = Handle.EffectiveMargins()
        
        for Row in 0 ... Handle.BitmapHeight - 1
        {
            for Column in 0 ... Handle.BitmapWidth - 1
            {
                let DrawPixel = Handle.RawData![(Handle.BitmapHeight - 1) - Row][Column] > 0
                if DrawPixel
                {
                    let PixelRect = CGRect(x: (CGFloat(Margin_Left) + (CGFloat(Column) * HPixelSize)), y: (CGFloat(Margin_Top) + (CGFloat(Row) * VPixelSize)),
                                           width: HPixelSize, height: VPixelSize)
                    var HighlightValue: UIColor? = nil
                    var StartingColor = Handle.Foreground
                    if Delta![(Handle.BitmapHeight - 1) - Row][Column] && Handle.HighlightStyle == 1
                    {
                        StartingColor = Handle.HighlightColor
                        HighlightValue = Handle.Foreground
                    }
                    var NodeLayer = CreateNodeLayer(Frame: ViewFrame, NodeRect: PixelRect, NodeShape: Handle.NodeShape,
                                                    Foreground: StartingColor, Final: HighlightValue)
                    Handle.PixelLayer.addSublayer(NodeLayer)
                    Handle.LayerCount = Handle.LayerCount + 1
                    ApplyShadow(Level: Handle.ShadowLevel, Layer: &NodeLayer)
                }
            }
        }
        
        return MainView
    }
    
    // MARK: 3D barcode handle functions.
    
    /// Create a new 3D handle for drawing barcodes.
    ///
    /// - Parameters:
    ///   - Width: Width of the frame.
    ///   - Height: Height of the frame.
    /// - Returns: Newly created barcode vector handle. The view has been created by this function.
    public func Make3DHandle(Width: Int, Height: Int) -> BarcodeVectorHandle
    {
        let Handle = BarcodeVectorHandle(Width: Width, Height: Height)
        let Frame = CGRect(origin: CGPoint.zero, size: Handle.ViewSize)
        Handle.View3D = Create3DScene(Frame: Frame)
        Handle.View3D?.frame = Frame
        Handle.View3D?.bounds = Frame
        return Handle
    }
    
    /// Close the 3D handle such that it can no longer be used. Once the handle is closed, reusing it will cause an
    /// assertion failure if running with DEBUG defined.
    ///
    /// - Parameter Handle: The handle to close.
    public static func Close3DHandle(Handle: inout BarcodeVectorHandle)
    {
        Handle.Close()
    }
    
    // MARK: Draw 3D bar codes.
    
    /// Creates a 3D view to display barcodes.
    ///
    /// - Parameters:
    ///   - Foreground: Foreground color.
    ///   - Background: Background color.
    ///   - Handle: 3D barcode view handle.
    /// - Returns: View to use to display the barcod ein 3D.
    public func MakeView3D(Foreground: UIColor, Background: UIColor, Handle: inout BarcodeVectorHandle) -> SCNView?
    {
        assert(RawData != nil, "Raw data is nil in MakeView3D.")
        
        let ViewFrame = CGRect(origin: CGPoint.zero, size: Handle.ViewSize)
        
        let Margin_Top = Handle.TopMargin
        let Margin_Left = Handle.LeftMargin
        let Margin_Bottom = Handle.BottomMargin
        let Margin_Right = Handle.RightMargin
        
        let EffectiveWidth = Int(ViewFrame.width) - (Margin_Right - Margin_Left)
        let EffectiveHeight = Int(ViewFrame.height) - (Margin_Bottom - Margin_Top)
        
        let Divisor = min(EffectiveWidth, EffectiveHeight)
        let Dividend = min(BitmapWidth, BitmapHeight)
        let HPixelSize: CGFloat = CGFloat(Divisor) / CGFloat(Dividend)
        let VPixelSize: CGFloat = CGFloat(Divisor) / CGFloat(Dividend)
        var LayerCount = 0
        
        //Remove the previous barcode's nodes.
        Handle.RemoveChildNodes()
        
        for Row in 0 ... BitmapHeight - 1
        {
            for Column in 0 ... BitmapWidth - 1
            {
                let DrawPixel = RawData![(BitmapHeight - 1) - Row][Column] > 0
                if DrawPixel
                {
                    let PixelRect = CGRect(x: (CGFloat(Margin_Left) + (CGFloat(Column) * HPixelSize)), y: (CGFloat(Margin_Top) + (CGFloat(Row) * VPixelSize)),
                                           width: HPixelSize, height: VPixelSize)
                    Add3DNode(NodeRect: PixelRect, BoxName: String(LayerCount), Handle: &Handle)
                    LayerCount = LayerCount + 1
                }
            }
        }
        
        _LastNodeCount = LayerCount
        return Handle.View3D
    }
    
    /// Holds the most recent number of nodes generated.
    private var _LastNodeCount: Int = 0
    /// Get the number of nodes generated from the most recent call to MakeView.
    public var LastNodeCount: Int
    {
        get
        {
            return _LastNodeCount
        }
    }
    
    //http://sketchytech.blogspot.com/2014/11/swift-drawing-regular-polygons-with.html
    
    // MARK: 3D functions.
    
    /// Create a 3D scene and return it in an SCNView.
    ///
    /// - Parameter Frame: Size of the SCNView returned.
    /// - Returns: SCNView set up for display the QR Code in 3D.
    private func Create3DScene(Frame: CGRect) -> SCNView
    {
        let Scene = SCNScene()
        ClockSceneView = SCNView()
        ClockSceneView.frame = Frame
        ClockSceneView.scene = Scene
        ClockSceneView.antialiasingMode = .multisampling4X
        
        Scene.rootNode.addChildNode(MakeCamera())
        Scene.rootNode.addChildNode(MakeOmniLight())
        
        ClockSceneView.backgroundColor = UIColor.clear
        
        return ClockSceneView
    }
    
    /// Adds a QR Code node to the passed 3D scene.
    ///
    /// - Parameters:
    ///   - NodeRect: The rectangle of the node.
    ///   - BoxName: Name of the box.
    ///   - ToScene: The scene where the node will be added.
    private func Add3DNode(NodeRect: CGRect, BoxName: String, Handle: inout BarcodeVectorHandle)
    {
        let Box = SCNBox(width: NodeRect.width, height: NodeRect.height, length: 10.0, chamferRadius: 1.0)
        Box.name = BoxName
        #if true
        Box.firstMaterial?.diffuse.contents = UIColor.red
        #else
        Box.firstMaterial?.diffuse.contents = Utility.RandomColor(HueRange: 0 ... 359, Saturation: 0.9, Brightness: 0.8)
        #endif
        let BoxNode = SCNNode(geometry: Box)
        BoxNode.name = BarcodeVectorHandle.BoxNodeName
        Handle.AddNode(BoxNode)
    }
    
    var OmniLightNode: SCNNode!
    var OmniLight: SCNLight!
    
    /// Create and return an omni light for a 3D scene.
    ///
    /// - Returns: Omni light node for a 3D scene.
    private func MakeOmniLight() -> SCNNode
    {
        OmniLight = SCNLight()
        OmniLight.type = SCNLight.LightType.omni
        OmniLight.color = UIColor.white
        OmniLightNode = SCNNode()
        OmniLightNode.light = OmniLight
        OmniLightNode.position = SCNVector3(x: -10, y: 10, z: 5)
        return OmniLightNode
    }
    
    var ClockCamera: SCNCamera!
    var CameraNode: SCNNode!
    
    /// Create and return a camera for a 3D scene.
    ///
    /// - Returns: Camera node for a 3D scene.
    private func MakeCamera() -> SCNNode
    {
        ClockCamera = SCNCamera()
        ClockCamera.fieldOfView = 90.0
        CameraNode = SCNNode()
        CameraNode.camera = ClockCamera
        CameraNode.position = SCNVector3(x: 0, y: 0, z: 10)
        return CameraNode
    }
    
    var ClockSceneView: SCNView!
}
