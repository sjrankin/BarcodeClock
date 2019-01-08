//
//  VectorHandle.swift
//  Visualizer Clock
//
//  Created by Stuart Rankin on 12/18/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit
import Accelerate

/// Handle for the creation of barcode vector objects.
class VectorHandle
{
    /// Default initializer.
    init()
    {
    }
    
    /// Initializer.
    ///
    /// - Parameters:
    ///   - Bitmap: Raw bitmap to vectorize.
    ///   - Width: Width of the raw bitmap in pixels.
    ///   - Height: Height of the raw bitmap in pixels.
    init(Bitmap: [[Int]], Width: Int, Height: Int)
    {
        RawData = Bitmap
        BitmapWidth = Width
        BitmapHeight = Height
    }
    
    /// Reset the bitmap to nil and dimensions to zero.
    public func Reset()
    {
        RawData?.removeAll()
        RawData = nil
        BitmapWidth = 0
        BitmapHeight = 0
        PreviousData?.removeAll()
        PreviousData = nil
    }
    
    /// Synonym for Reset.
    public func Close()
    {
        Reset()
    }
    
    private var _BitmapWidth: Int = 0
    /// Get or set the width of the bitmap to vectorize.
    public var BitmapWidth: Int
    {
        get
        {
            return _BitmapWidth
        }
        set
        {
            _BitmapWidth = newValue
        }
    }
    
    private var _BitmapHeight: Int = 0
    /// Get or set the height of the bitmap to vectorize.
    public var BitmapHeight: Int
    {
        get
        {
            return _BitmapHeight
        }
        set
        {
            _BitmapHeight = newValue
        }
    }
    
    private var _RawData: [[Int]]? = nil
    /// Get or set the bitmap's raw data (eg, pixels). This is the bitmap that will
    /// be vectorized.
    public var RawData: [[Int]]?
    {
        get
        {
            return _RawData
        }
        set
        {
            _RawData = newValue
        }
    }
    
    private var _PreviousData: [[Int]]? = nil
    /// Get or set the previous data for a 2D bitmap. Used to determine deltas between
    /// a sequence of barcodes.
    public var PreviousData: [[Int]]?
    {
        get
        {
            return _PreviousData
        }
        set
        {
            _PreviousData = newValue
        }
    }
    
    private var _PreviousData1D: [Int]? = nil
    /// Get or set the previous data for a 1D bitmap. Used to determine deltas between a
    /// sequence of barcodes.
    public var PreviousData1D: [Int]?
    {
        get
        {
            return _PreviousData1D
        }
        set
        {
            _PreviousData1D = newValue
        }
    }
    
    /// Clear previous data. Used when the dimensions of sequential bitmaps change.
    public func ClearPreviousData(_ FromWhere: String = "")
    {
        print("Clearing previous data from \(FromWhere).")
        _PreviousData?.removeAll()
        _PreviousData = nil
        _PreviousData1D?.removeAll()
        _PreviousData1D = nil
    }
    
    /// Returns the delta values between two 2D barcodes of the same type between sequential runs.
    ///
    /// - Returns: Array of boolean values that indicate if a delta is in a given position. The structure of the array is
    ///            the same as the original bitmap (in terms of width and height). If an entry is true, there is a delta
    ///            in that position. If false, no delta. Nil is returned if there is no original data.
    public func GetDelta() -> [[Bool]]?
    {
        _DeltaCount = 0
        if !HasData
        {
            print("No data detected.")
            return nil
        }
        var Delta = [[Bool]](repeating: [Bool](repeating: false, count: BitmapWidth), count: BitmapHeight)
        if PreviousData == nil
        {
            print("Setting previous data to current data.")
            PreviousData = RawData
        }
        else
        {
            for Row in 0 ... BitmapHeight - 1
            {
                for Column in 0 ... BitmapWidth - 1
                {
                    let NewPixel = RawData![(BitmapHeight - 1) - Row][Column]
                    let PreviousPixel = PreviousData![(BitmapHeight - 1) - Row][Column]
                    let IsDelta = NewPixel != PreviousPixel
                    Delta[(BitmapHeight - 1) - Row][Column] = IsDelta
                    _DeltaCount = _DeltaCount + Int(IsDelta ? 1 : 0)
                }
            }
            PreviousData = RawData
        }
        return Delta
    }
    
    /// Return the delta between two 1D barcodes in sequence.
    ///
    /// - Returns: Array of booleans - true if a given node is different, false if not. Nil returned
    ///            on error.
    public func GetDelta1D() -> [Bool]?
    {
        _DeltaCount = 0
        //Get the delta between the previous barcode and the current barcode.
        let VisCount = RasterScanData1D!.filter({$0.0}).map({return $0.1})
        var Delta = [Bool]()
        //Initialize the delta map.
        for _ in 0 ..< VisCount.count
        {
            Delta.append(false)
        }
        if PreviousData1D == nil
        {
            //No previous results - set the current results as the previous results. Since
            //the delta map has already been initialized to all false, no other action is
            //needed.
            PreviousData1D = [Int]()
            for Count in VisCount
            {
                PreviousData1D?.append(Count)
            }
        }
        else
        {
            for Index in 0 ..< VisCount.count
            {
                let IsDelta = VisCount[Index] != PreviousData1D?[Index]
                _DeltaCount = _DeltaCount + Int(IsDelta ? 1 : 0)
                Delta[Index] = VisCount[Index] != PreviousData1D?[Index]
                PreviousData1D?[Index] = VisCount[Index]
            }
        }
        _VisibleNodeCount = VisCount.count
        return Delta
    }
    
    private var _VisibleNodeCount: Int = 0
    public var VisibleNodeCount: Int
    {
        get
        {
            return _VisibleNodeCount
        }
    }
    
    private var _RasterScanData1D: [(Bool, Int)]? = nil
    /// Get or set 1D raster scan data.
    public var RasterScanData1D: [(Bool, Int)]?
    {
        get
        {
            return _RasterScanData1D
        }
        set
        {
            _RasterScanData1D = newValue
        }
    }
    
    #if false
    public func GetDelta2() -> [[Bool]]?
    {
        _DeltaCount = 0
        if !HasData
        {
            print("No data detected.")
            return nil
        }
        let Delta = [[Bool]](repeating: [Bool](repeating: false, count: BitmapWidth), count: BitmapHeight)
        if PreviousData == nil
        {
            print("Setting previous data to current data.")
            PreviousData = RawData
        }
        else
        {
            let FlatRaw: [Double] = RawData!.flatMap{$0.compactMap{Double($0)}}
            let FlatPrevious: [Double] = PreviousData!.flatMap{$0.compactMap{Double($0)}}
            var Result = [Double](repeating: 0.0, count: FlatRaw.count)
            vDSP_vsubD(FlatRaw, 1, FlatPrevious, 1, &Result, 1, vDSP_Length(FlatRaw.count))
            var c = 0
            for Value in Result
            {
                if Value != 0
                {
                    c = c + 1
                }
            }
            print("Found \(c) deltas")
            PreviousData = RawData
        }
        return Delta
    }
    #endif
    
    /// Holds the previous gapless barcode data.
    private var PreviousGaplessData: [Int]? = nil
    
    /// Reset gapless data.
    public func ResetGaplessData()
    {
        PreviousGaplessData?.removeAll()
        PreviousGaplessData = nil
    }
    
    /// Return the delta between the passed gapless barcode vector data and the previous barcode
    /// data.
    ///
    /// - Parameter NewVector: The new vector of the gapless barcode.
    /// - Returns: Array of booleans - true indicates a delta and false indicates no delta.
    public func GetGaplessDelta(NewVector: [Int]) -> [Bool]?
    {
        if PreviousGaplessData != nil
        {
            if NewVector.count != PreviousGaplessData?.count
            {
                ResetGaplessData()
                PreviousGaplessData = NewVector
                return nil
            }
        }
        var Delta = [Bool](repeating: false, count: NewVector.count)
        if PreviousGaplessData == nil
        {
            PreviousGaplessData = NewVector
            return Delta
        }
        var Count = 0
        for Index in 0 ..< NewVector.count
        {
            Delta[Index] = PreviousGaplessData![Index] != NewVector[Index]
            Count = Count + Int(Delta[Index] ? 1 : 0)
        }
        _DeltaCount = Count
        return Delta
    }
    
    private var _DeltaCount: Int = 0
    /// Returns the number of different pixels in a sequence of barcode bitmap. Cleared everytime
    /// GetDelta is called.
    public var DeltaCount: Int
    {
        get
        {
            return _DeltaCount
        }
    }
    
    /// Determines if the bitmap is present (eg, set by a caller).
    public var HasData: Bool
    {
        get
        {
            return RawData != nil
        }
    }
    
    private var _PixelLayer: CAShapeLayer!
    /// Get or set the shape layer used to hold pixels.
    public var PixelLayer: CAShapeLayer
    {
        get
        {
            return _PixelLayer
        }
        set
        {
            _PixelLayer = newValue
        }
    }
    
    public func MakePixelLayer(Frame: CGRect, Bounds: CGRect, BackgroundColor: UIColor)
    {
        PixelLayer = CAShapeLayer()
        PixelLayer.frame = Frame
        PixelLayer.bounds = Bounds
        PixelLayer.backgroundColor = BackgroundColor.cgColor
    }
    
    private var _LayerCount: Int = 0
    /// Get or set the last number of nodes created for a vectorized bitmap.
    public var LayerCount: Int
    {
        get
        {
            return _LayerCount
        }
        set
        {
            _LayerCount = newValue
        }
    }
    
    private var _ClockSceneView: SCNView!
    /// Get or set the clock scene view. For 3D generation.
    public var ClockSceneView: SCNView
    {
        get
        {
            return _ClockSceneView
        }
        set
        {
            _ClockSceneView = newValue
        }
    }
    
    private var _ClockCamera: SCNCamera!
    /// Get or set the clock's camera. For 3D generation.
    public var ClockCamera: SCNCamera
    {
        get
        {
            return _ClockCamera
        }
        set
        {
            _ClockCamera = newValue
        }
    }
    
    private var _CameraNode: SCNNode!
    /// Get or set the camera's node. For 3D generation.
    public var CameraNode: SCNNode
    {
        get
        {
            return _CameraNode
        }
        set
        {
            _CameraNode = newValue
        }
    }
    
    private var _OmniLightNode: SCNNode!
    /// Get or set the omni light's node. For 3D generation.
    public var OmniLightNode: SCNNode
    {
        get
        {
            return _OmniLightNode
        }
        set
        {
            _OmniLightNode = newValue
        }
    }
    
    private var _OmniLight: SCNLight!
    /// Get or set the omni light. For 3D generation.
    public var OmniLight: SCNLight
    {
        get
        {
            return _OmniLight
        }
        set
        {
            _OmniLight = newValue
        }
    }
    
    private var _Background: UIColor = UIColor.clear
    /// Get or set the background color.
    public var Background: UIColor
    {
        get
        {
            return _Background
        }
        set
        {
            _Background = newValue
        }
    }
    
    private var _NodeColor: UIColor = UIColor.black
    /// Get or set the color of the node.
    public var Foreground: UIColor
    {
        get
        {
            return _NodeColor
        }
        set
        {
            _NodeColor = newValue
        }
    }
    
    private var _HighlightColor: UIColor = UIColor.yellow
    /// Get or set the color used to highlight nodes.
    public var HighlightColor: UIColor
    {
        get
        {
            return _HighlightColor
        }
        set
        {
            _HighlightColor = newValue
        }
    }
    
    private var _HighlightStyle: Int = 0
    /// Get or set the value used to indicate the style of highlighting.
    public var HighlightStyle: Int
    {
        get
        {
            return _HighlightStyle
        }
        set
        {
            _HighlightStyle = newValue
        }
    }
    
    private var _NodeShape: Int = 0
    /// Get or set the value used to determine node shape, for those barcodes that support
    /// different shapes.
    public var NodeShape: Int
    {
        get
        {
            return _NodeShape
        }
        set
        {
            _NodeShape = newValue
        }
    }
    
    private var _BarcodeShape: Int = 0
    /// Get or set the overall shape of the barcode.
    public var BarcodeShape: Int
    {
        get
        {
            return _BarcodeShape
        }
        set
        {
            _BarcodeShape = newValue
        }
    }
    
    private var _UseLongAxis: Bool = false
    /// Used to determine which axis to use.
    public var UseLongAxis: Bool
    {
        get
        {
            return _UseLongAxis
        }
        set
        {
            _UseLongAxis = newValue
        }
    }
    
    private var _ScanRow: Int = 0
    /// Get or set the row to scan for pixels. Useful for one dimensional barcodes.
    public var ScanRow: Int
    {
        get
        {
            return _ScanRow
        }
        set
        {
            _ScanRow = newValue
        }
    }
    
    private var _WaveEffects: Int = 0
    /// Get or set a value determining how wave effects look.
    public var WaveEffects: Int
    {
        get
        {
            return _WaveEffects
        }
        set
        {
            _WaveEffects = newValue
        }
    }
    
    private var _ShadowLevel: Int = 0
    /// Get or set the shadow level.
    public var ShadowLevel: Int
    {
        get
        {
            return _ShadowLevel
        }
        set
        {
            _ShadowLevel = newValue
        }
    }
    
    private var _HeightMultiplier: Double = 1.0
    /// Get or set the height multiplier.
    public var HeightMultiplier: Double
    {
        get
        {
            return _HeightMultiplier
        }
        set
        {
            _HeightMultiplier = newValue
        }
    }
    
    private var _ViewWidth: Int = 0
    /// Get or set the width of the target view.
    public var ViewWidth: Int
    {
        get
        {
            return _ViewWidth
        }
        set
        {
            _ViewWidth = newValue
        }
    }
    
    private var _ViewHeight: Int = 0
    /// Get or set the height of the target view.
    public var ViewHeight: Int
    {
        get
        {
            return _ViewHeight
        }
        set
        {
            _ViewHeight = newValue
        }
    }
    
    private var _TopMargin: Int? = nil
    /// Get or set the top margin. If nil, no margin present.
    public var TopMargin: Int?
    {
        get
        {
            return _TopMargin
        }
        set
        {
            _TopMargin = newValue
        }
    }
    
    private var _LeftMargin: Int? = nil
    /// Get or set the left margin. If nil, no margin present.
    public var LeftMargin: Int?
    {
        get
        {
            return _LeftMargin
        }
        set
        {
            _LeftMargin = newValue
        }
    }
    
    private var _BottomMargin: Int? = nil
    /// Get or set the bottom margin. If nil, no margin present.
    public var BottomMargin: Int?
    {
        get
        {
            return _BottomMargin
        }
        set
        {
            _BottomMargin = newValue
        }
    }
    
    private var _RightMargin: Int? = nil
    /// Get or set the right margin. If nil, no margin present.
    public var RightMargin: Int?
    {
        get
        {
            return _RightMargin
        }
        set
        {
            _RightMargin = newValue
        }
    }
    
    /// Return the effective margins. All values are actual and not nullable. If no margin value was set,
    /// that particular value is returned as a 0.
    ///
    /// - Returns: Margin values in a tuple in the order (Top, Left, Bottom, Right).
    public func EffectiveMargins() -> (Int, Int, Int, Int)
    {
        return (TopMargin == nil ? 0 : TopMargin!, LeftMargin == nil ? 0 : LeftMargin!,
                BottomMargin == nil ? 0 : BottomMargin!, RightMargin == nil ? 0 : RightMargin!)
    }
    
    /// Get the effective width (defined as the width of the view minus the horizontal margins).
    public var EffectiveWidth: Int
    {
        get
        {
            let (_, Left, _, Right) = EffectiveMargins()
            return ViewWidth - (Right - Left)
        }
    }
    
    /// Get the effective height (defined as the height of the view minus the vertical margins).
    public var EffectiveHeight: Int
    {
        get
        {
            let (Top, _, Bottom, _) = EffectiveMargins()
            return ViewHeight - (Bottom - Top)
        }
    }
    
    private var _InnerRadius: Double = 0.3
    /// Get or set the inner radius for circular barcodes.
    public var InnerRadius: Double
    {
        get
        {
            return _InnerRadius
        }
        set
        {
            _InnerRadius = newValue
        }
    }
    
    private var _OuterRadius: Double = 0.9
    /// Get or set the outer radius for circular barcodes.
    public var OuterRadius: Double
    {
        get
        {
            return _OuterRadius
        }
        set
        {
            _OuterRadius = newValue
        }
    }
    
    private var _IncludeCheckDigit: Bool = true
    /// Get or set the include check digit for those barcodes that allow them.
    public var IncludeCheckDigit: Bool
    {
        get
        {
            return _IncludeCheckDigit
        }
        set
        {
            _IncludeCheckDigit = newValue
        }
    }
    
    private var _ShowDigits: Bool = false
    /// Get or set the show digits flag for barcodes that support them.
    public var ShowDigits: Bool
    {
        get
        {
            return _ShowDigits
        }
        set
        {
            _ShowDigits = newValue
        }
    }
    
    private var _FinalCenter: CGFloat? = nil
    /// Get or set the final center.
    public var FinalCenter: CGFloat?
    {
        get
        {
            return _FinalCenter
        }
        set
        {
            _FinalCenter = newValue
        }
    }
    
    private var _TargetCenter: CGPoint? = nil
    /// Get or set the target's center point.
    public var TargetCenter: CGPoint?
    {
        get
        {
            return _TargetCenter
        }
        set
        {
            _TargetCenter = newValue
        }
    }
    
    private var _LongColor: UIColor? = nil
    /// Get or set the color for long items.
    public var LongColor: UIColor?
    {
        get
        {
            return _LongColor
        }
        set
        {
            _LongColor = newValue
        }
    }
    
    private var _ShortColor: UIColor? = nil
    /// Get or set the color for short items.
    public var ShortColor: UIColor?
    {
        get
        {
            return _ShortColor
        }
        set
        {
            _ShortColor = newValue
        }
    }
    
    private var _VaryColorByLength: Bool = false
    /// That flag that indicates colors should be varied by length
    public var VaryColorByLength: Bool
    {
        get
        {
            return _VaryColorByLength
        }
        set
        {
            _VaryColorByLength = newValue
        }
    }
    
    private var _EnablePrint: Bool = true
    public var EnablePrint: Bool
    {
        get
        {
            return _EnablePrint
        }
        set
        {
            _EnablePrint = newValue
        }
    }
    
    private var _PrintPrefix: String? = nil
    public var PrintPrefix: String?
    {
        get
        {
            return _PrintPrefix
        }
        set
        {
            _PrintPrefix = newValue
        }
    }
    
    public func fprint(_ Raw: String)
    {
        if EnablePrint
        {
            if let Prefix = PrintPrefix
            {
                print("\(Prefix): \(Raw)")
            }
            else
            {
                print(Raw)
            }
        }
    }
    
    private var _ShowBorder: Bool = false
    public var ShowBorder: Bool
    {
        get
        {
            return _ShowBorder
        }
        set
        {
            _ShowBorder = newValue
        }
    }
    
    private var _BorderColor: UIColor = UIColor.red
    public var BorderColor: UIColor
    {
        get
        {
            return _BorderColor
        }
        set
        {
            _BorderColor = newValue
        }
    }
    
    private var _BorderThickness: CGFloat = 0.5
    public var BorderThickness: CGFloat
    {
        get
        {
            return _BorderThickness
        }
        set
        {
            _BorderThickness = newValue
        }
    }
    
    private var _ColorGradientClock: CARadialGradientLayer2? = nil
    /// Holds the color gradient layer for those clocks that need one.
    public var ColorGradientClock: CARadialGradientLayer2?
    {
        get
        {
            return _ColorGradientClock
        }
        set
        {
            _ColorGradientClock = newValue
        }
    }
    
    private var _ColorGradientClock2: CARadialGradientLayer3? = nil
    /// Holds the color gradient layer for those clocks that need one.
    public var ColorGradientClock2: CARadialGradientLayer3?
    {
        get
        {
            return _ColorGradientClock2
        }
        set
        {
            _ColorGradientClock2 = newValue
        }
    }
    
    private var _RadialBlendMode: Int = 0
    /// Get or set the blend mode for radial gradients.
    public var RadialBlendMode: Int
    {
        get
        {
            return 0
        }
        set
        {
            _RadialBlendMode = newValue
        }
    }
    
    public var _GradientFilter: Int = 0
    /// Get or set the gradient filter to use for radial gradient compositing.
    public var GradientFilter: Int
    {
        get
        {
            return _GradientFilter
        }
        set
        {
            _GradientFilter = newValue
        }
    }
    
    private var _RadialGradientShape: Int = 0
    public var RadialGradientShape: Int
    {
        get
        {
            return _RadialGradientShape
        }
        set
        {
            _RadialGradientShape = newValue
        }
    }
    
    private var _CenterAnchor: Bool = false
    public var CenterAnchor: Bool
    {
        get
        {
            return _CenterAnchor
        }
        set
        {
            _CenterAnchor = newValue
        }
    }
    
    #if false
    private var _ColorGradientList = [RadialGradientDescriptor]()
    /// Get or set the list of gradients to use in a gradial gradient layer.
    public var ColorGradientList: [RadialGradientDescriptor]
    {
        get
        {
            return _ColorGradientList
        }
        set
        {
            _ColorGradientList = newValue
        }
    }
    
    public func GetGradient(For: RadialGradientDescriptor.RadialGradientTypes) -> RadialGradientDescriptor?
    {
        for Gradient in ColorGradientList
        {
            if Gradient.GradientType == For
            {
                return Gradient
            }
        }
        return nil
    }
    
    public func LoadRadialGradient(GradientType: RadialGradientDescriptor.RadialGradientTypes,
                                   SettingKey: String, Frame: CGRect, Bounds: CGRect)
    {
        let Raw = UserDefaults.standard.string(forKey: SettingKey)
        let Parsed = RadialGradientDescriptor.ParseRawColorNode(Raw!)
        let RadialDistance = CGFloat((Parsed?.1)!)
        let HalfX = Frame.width / 2.0
        let HalfY = Frame.height / 2.0
        let Location = CGPoint(x: HalfX, y: HalfY - RadialDistance)
        var GCList = [UIColor]()
        for (_, Color, _, _) in (Parsed?.3)!
        {
            GCList.append(Color)
        }
        do
        {
        let FinalGradient = try RadialGradientDescriptor(Frame: Frame, Bounds: Bounds, Location: Location, Description: Raw!, OuterAlphaValue: 0.1)
        FinalGradient.GradientType = GradientType
        _ColorGradientList.append(FinalGradient)
        }
        catch
        {
            fatalError("Error returned from RadialGradientDescriptor.")
        }
    }
    
    public func LoadRadialGradients(Frame: CGRect, Bounds: CGRect)
    {
        _ColorGradientList.removeAll()
        LoadRadialGradient(GradientType: .Center, SettingKey: Setting.Key.RadialGradient.CenterBlobDefiniton,
                           Frame: Frame, Bounds: Bounds)
    }
    #endif
    
    // MARK: Factory methods.
    
    /// Factory method to make new vector handles.
    public static func Make() -> VectorHandle?
    {
        return VectorHandle()
    }
}
