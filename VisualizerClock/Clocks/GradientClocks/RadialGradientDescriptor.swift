//
//  RadialGradientDescriptor.swift
//  GradientTestBed
//
//  Created by Stuart Rankin on 10/10/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Describes and draws and maintains a radial gradient surface.
class RadialGradientDescriptor: CAGradientLayer
{
    var ClearColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.0)
    
    /// Types of radial gradients.
    ///
    /// - Center: Gradient intended to be used as the center dot.
    /// - Second: Gradient intended to be used as the second hand.
    /// - Minute: Gradient intended to be used as the minute hand.
    /// - Hour: Gradient intended to be used as the hour hand.
    enum RadialGradientTypes
    {
        case Center
        case Second
        case Minute
        case Hour
        case Other
    }
    
    /// Create a radial gradient surface.
    ///
    /// - Parameters:
    ///   - Frame: Frame rectangle to use.
    ///   - Bounds: Bounds rectangle to use.
    ///   - Location: Location of the gradient.
    ///   - Radial: Radius of the gradient.
    ///   - RadialColors: List of colors that make up the gradient.
    init(Frame: CGRect, Bounds: CGRect, Location: CGPoint, Radial: CGFloat, RadialColors: [UIColor]? = nil)
    {
        super.init()
        Center = Location
        Radius = Radial
        if let RadialColors = RadialColors
        {
            Colors = RadialColors
        }
        frame = Frame
        bounds = Bounds
        needsDisplayOnBoundsChange = true
    }
    
    /// Create a radial gradient surface.
    ///
    /// - Parameters:
    ///   - Frame: Frame rectangle to use.
    ///   - Bounds: Bounds rectangle to use.
    ///   - Location: Location of the gradient.
    ///   - GradientRadius: Radius of the gradient.
    ///   - RadialColors: List of colors in the gradient.
    ///   - OuterAlphaValue: Outer alpha value to assist in blending with the background.
    ///   - AlphaDistance: Alpha radial distance in percent of overall radius.
    ///   - CenterAnchor: Center of the radial is anchored flag.
    ///   - TheCenter: Center of the radial.
    init(Frame: CGRect, Bounds: CGRect, Location: CGPoint, GradientRadius: CGFloat, RadialColors: [UIColor],
         OuterAlphaValue: CGFloat, AlphaDistance: CGFloat = 0.1, CenterAnchor: Bool = false, TheCenter: CGPoint? = nil)
    {
        super.init()
        AnchorInCenter = CenterAnchor
        if AnchorInCenter
        {
            if let TheCenter = TheCenter
            {
                CenterPoint = TheCenter
            }
            else
            {
                AnchorInCenter = false
            }
        }
        Center = Location
        Radius = GradientRadius
        Colors = RadialColors
        frame = Frame
        bounds = Bounds
        OuterAlpha = OuterAlphaValue
        OuterAlphaDistance = AlphaDistance
        EnableOuterAlpha = true
        needsDisplayOnBoundsChange = true
        
        borderWidth = 1.0
        borderColor = UIColor.red.cgColor
    }
    
    /// Create a radial gradient surface.
    ///
    /// - Parameters:
    ///   - Frame: Frame rectangle to use.
    ///   - Bounds: Bounds rectangle to use.
    ///   - Location: Location of the gradient.
    ///   - Description: Raw string description (most likely from user settings) of the list of colors. Also contains the
    ///                  overall radius of the gradient.
    ///   - OuterAlphaValue: Outer alpha value to assist in blending with the background.
    ///   - AlphaDistance: Alpha radial distance in percent of overall radius.
    ///   - CenterAnchor: Center of the radial is anchored flag.
    ///   - TheCenter: Center of the radial.
    /// - Throws: Throws an error message if Description is not properly formed or is empty.
    init(Frame: CGRect, Bounds: CGRect, Location: CGPoint, Description: String,
         OuterAlphaValue: CGFloat, AlphaDistance: CGFloat = 0.1, CenterAnchor: Bool = false,
         TheCenter: CGPoint? = nil) throws
    {
        super.init()
        if Description.isEmpty
        {
            throw "No string description for radial colors."
        }
        AnchorInCenter = CenterAnchor
        if AnchorInCenter
        {
            if let TheCenter = TheCenter
            {
                CenterPoint = TheCenter
            }
            else
            {
                AnchorInCenter = false
            }
        }
        Center = Location
        frame = Frame
        bounds = Bounds
        
        var ColorList = [UIColor]()
        let Raw = XMLF.NodeContents(Description)
        var RadialRadius = XMLF.AttributeDouble(Description, Name: "Radius")
        if UIDevice.current.userInterfaceIdiom == .pad
        {
            RadialRadius = RadialRadius! * 1.8
        }
        let IsInGrayscale = XMLF.AttributeBool(Description, Name: "Grayscale")
        IsGrayscale = IsInGrayscale!
        let Parts = Raw.split(separator: "/")
        for Part in Parts
        {
            let OneColor = String(Part).split(separator: ";")
            let RawColor = String(OneColor[1])
            let ColorComponents = RawColor.split(separator: ",")
            let cred = String(ColorComponents[0])
            let cgreen = String(ColorComponents[1])
            let cblue = String(ColorComponents[2])
            let iRed: Int = Int(cred)!
            let iGreen: Int = Int(cgreen)!
            let iBlue: Int = Int(cblue)!
            let Red: CGFloat = CGFloat(iRed)
            let Green: CGFloat = CGFloat(iGreen)
            let Blue: CGFloat = CGFloat(iBlue)
            let GColor = UIColor(red: Red / 255.0, green: Green / 255.0, blue: Blue / 255.0, alpha: 1.0)
            ColorList.append(GColor)
        }
        
        Radius = CGFloat(RadialRadius!)
        Colors = ColorList
        OuterAlpha = OuterAlphaValue
        OuterAlphaDistance = AlphaDistance
        EnableOuterAlpha = true
        needsDisplayOnBoundsChange = true
    }
    
    var AnchorInCenter: Bool = false
    var CenterPoint: CGPoint? = nil
    
    /// Init.
    required override init ()
    {
        super.init()
        needsDisplayOnBoundsChange = true
    }
    
    /// Init.
    ///
    /// - Parameter aDecoder: See iOS documentation.
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    /// Init.
    ///
    /// - Parameter layer: See iOS documentation.
    required override init(layer: Any)
    {
        super.init(layer: layer)
    }
    
    private var _GradientType: RadialGradientTypes = .Other
    /// Get or set the intended use for this radial gradient.
    public var GradientType: RadialGradientTypes
    {
        get
        {
            return _GradientType
        }
        set
        {
            _GradientType = newValue
        }
    }
    
    private var _IsGrayscale: Bool = false
    /// Get or set the grayscale flag.
    public var IsGrayscale: Bool
    {
        get
        {
            return _IsGrayscale
        }
        set
        {
            _IsGrayscale = newValue
        }
    }
    
    /// Serialize a radial gradient into an XML fragment.
    ///
    /// - Parameters:
    ///   - Radius: The radius of the gradient.
    ///   - IsGrayscale: Determines if the gradient is rendered in grayscale or color.
    ///   - Colors: The list of colors in the gradient along with their positions.
    /// - Returns: XML fragment string describing the gradient.
    public static func SerializeRadial(Radius: Double, IsGrayscale: Bool, Colors: [(Double, UIColor, Bool, UUID)]) -> String
    {
        var stemp = "<Gradient Radius=\"\(Radius)\" Grayscale=\"\(IsGrayscale)\" Colors=\"\(Colors.count)\">"
        var Index = 0
        for Color in Colors
        {
            let (R, G, B) = Utility.GetRGB(Color.1)
            var sub = "\(Color.0);"
            sub = sub + "\(R),\(G),\(B)"
            if Index < Colors.count - 1
            {
                sub = sub + "/"
            }
            stemp = stemp + sub
            Index = Index + 1
        }
        stemp = stemp + "</Gradient>"
        return stemp
    }
    
    /// Parse a color node (most likely from user settings) in to data other functions can use.
    ///
    /// - Parameter Node: The string description of the color node in string format.
    /// - Returns: On success, tuple with the contents: (Number of colors, radius of gradient, is grayscale flag,
    ///            list of (normalized color position, color, convenience bool, gradient stop ID)). Nil returned on error.
    public static func ParseRawColorNode(_ Node: String) -> (Int, Double, Bool, [(Double, UIColor, Bool, UUID)])?
    {
        if Node.isEmpty
        {
            print("Empty node.")
            return nil
        }
        let NodeTitle = XMLF.NodeTitle(Node)
        if NodeTitle != "Gradient"
        {
            print("Invalid node found: \(NodeTitle)")
            return nil
        }
        var FinalColorCount: Int = 0
        if let ColorCount = XMLF.AttributeInt(Node, Name: "Colors")
        {
            FinalColorCount = ColorCount
        }
        else
        {
            print("No color count found.")
            return nil
        }
        var FinalRadius: Double = 0.0
        if let GradientRadius = XMLF.AttributeDouble(Node, Name: "Radius")
        {
            FinalRadius = GradientRadius
        }
        else
        {
            print("No radius found.")
            return nil
        }
        var FinalIsGrayscale: Bool = false
        if let IsGrayscale = XMLF.AttributeBool(Node, Name: "Grayscale")
        {
            FinalIsGrayscale = IsGrayscale
        }
        else
        {
            print("No grayscale flag found.")
            return nil
        }
        
        let RawContents = XMLF.NodeContents(Node)
        if RawContents.isEmpty
        {
            print("Node is empty.")
            return nil
        }
        let ContentParts = RawContents.split(separator: "/")
        if ContentParts.count != FinalColorCount
        {
            print("Defined colors not equal to color count - using number of defined colors.")
            FinalColorCount = ContentParts.count
        }
        var ColorList = [(Double, UIColor, Bool, UUID)]()
        
        for Part in ContentParts
        {
            let SubParts = String(Part).split(separator: ";")
            if SubParts.count != 2
            {
                print("Invalid color found. Incorrect number of sub-parts.")
                return nil
            }
            var GLoc: Double = 0.0
            if let GL = Double(String(SubParts[0]))
            {
                GLoc = GL
            }
            else
            {
                print("Badly formed color location found.")
                return nil
            }
            var FinalColor = UIColor.clear
            if let GColor = MakeColor(String(SubParts[1]))
            {
                FinalColor = GColor
            }
            else
            {
                print("Error making color.")
                return nil
            }
            ColorList.append((GLoc, FinalColor, false, UUID()))
        }
        
        return (FinalColorCount, FinalRadius, FinalIsGrayscale, ColorList)
    }
    
    /// Converts a string-based color description to an actual color.
    ///
    /// - Parameter Raw: Color description in the form of a string. Valid formats are: rrr,ggg,bbb and rrr,ggg,bbb,aaa where rrr, ggg
    ///                  bbb, and aaa are integers. All successfully converted integers are clampled to 0 to 255.
    /// - Returns: UIColor based on the raw string on success, nil returned on bad format.
    private static func MakeColor(_ Raw: String) -> UIColor?
    {
        if Raw.isEmpty
        {
            return nil
        }

        let Parts = Raw.split(separator: ",")
        if Parts.count < 3
        {
            return nil
        }
        if Parts.count > 4
        {
            return nil
        }
        
        var iRed: Int = 0
        if let ir = Int(String(Parts[0]))
        {
            iRed = min(max(ir, 0), 255)
        }
        else
        {
            return nil
        }
        
        var iGreen: Int = 0
        if let ig = Int(String(Parts[1]))
        {
            iGreen = min(max(ig, 0), 255)
        }
        else
        {
            return nil
        }
        
        var iBlue: Int = 0
        if let ib = Int(String(Parts[2]))
        {
            iBlue = min(max(ib, 0), 255)
        }
        else
        {
            return nil
        }
        
        var iAlpha: Int = 255
        if Parts.count == 4
        {
            if let ia = Int(String(Parts[4]))
            {
                iAlpha = min(max(ia, 0), 255)
            }
            else
            {
                return nil
            }
        }
        let Red: CGFloat = CGFloat(iRed) / 255.0
        let Green: CGFloat = CGFloat(iGreen) / 255.0
        let Blue: CGFloat = CGFloat(iBlue) / 255.0
        let Alpha: CGFloat = CGFloat(iAlpha) / 255.0
        return UIColor(red: Red, green: Green, blue: Blue, alpha: Alpha)
    }
    
    private var _EnableOuterAlpha: Bool = false
    public var EnableOuterAlpha: Bool
    {
        get
        {
            return _EnableOuterAlpha
        }
        set
        {
            if newValue == _EnableOuterAlpha
            {
                return
            }
            _EnableOuterAlpha = newValue
            setNeedsDisplay()
        }
    }
    
    private var _OuterAlpha: CGFloat = -1.0
    public var OuterAlpha: CGFloat
    {
        get
        {
            return _OuterAlpha
        }
        set
        {
            if newValue == _OuterAlpha
            {
                return
            }
            _OuterAlpha = newValue
            setNeedsDisplay()
        }
    }
    
    private var _OuterAlphaDistance: CGFloat = -1.0
    public var OuterAlphaDistance: CGFloat
    {
        get
        {
            return _OuterAlphaDistance
        }
        set
        {
            if newValue == _OuterAlphaDistance
            {
                return
            }
            _OuterAlphaDistance = newValue
            setNeedsDisplay()
        }
    }
    
    /// Given a UIColor, return the alpha red, green, and blue component parts.
    /// - Parameter SourceColor: The color whose component parts will be returned.
    /// - Returns: Tuple in the order: Alpha, Red, Green, Blue.
    func GetARGB(_ SourceColor: UIColor) -> (CGFloat, CGFloat, CGFloat, CGFloat)
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
        
        //Clean up.
        Red.deallocate()
        Green.deallocate()
        Blue.deallocate()
        Alpha.deallocate()
        
        return (FinalAlpha, FinalRed, FinalGreen, FinalBlue)
    }
    
    public func SetGeneralBackgroundColor(_ BGColor: UIColor)
    {
        let (_,R,G,B) = GetARGB(BGColor)
        ClearColor = UIColor(red: R, green: G, blue: B, alpha: 0.0)
    }
    
    private var _ID: UUID = UUID()
    /// Get or set the ID of the radial gradient.
    public var ID: UUID
    {
        get
        {
            return _ID
        }
        set
        {
            _ID = newValue
        }
    }
    
    private var _Colors = [UIColor.red, UIColor.yellow]
    /// Get or set the list of colors that make up the radial gradient.
    public var Colors: [UIColor]
    {
        get
        {
            return _Colors
        }
        set
        {
            _Colors.removeAll()
            _Colors = newValue
            _GColors.removeAll()
            for Color in _Colors
            {
                _GColors.append(Color.cgColor as Any)
            }
        }
    }
    
    /// Holds the array of colors to use as the gradient, from inner-most to outer-most.
    private var _GColors = [UIColor.red.cgColor as Any, UIColor.yellow.cgColor as Any]
    /// Get or set the array of colors that make up the gradient. Colors must be CGColors cast to Any. First color is
    /// inner-most color of the gradient, and last color is the outer-most color of the gradient.
    public var GradientColors: [Any]
    {
        get
        {
            return _GColors
        }
        set
        {
            _GColors = newValue
        }
    }
    
    /// Holds the center of the radial gradient.
    private var _Center: CGPoint = CGPoint(x: 0, y: 0)
    /// Get or set the center point of the radial gradient.
    public var Center: CGPoint
    {
        get
        {
            return _Center
        }
        set
        {
            _Center = newValue
        }
    }
    
    /// Holds the radius of the radial gradient.
    private var _Radius: CGFloat = 100.0
    /// Get or set the radius of the radial gradient.
    public var Radius: CGFloat
    {
        get
        {
            return _Radius
        }
        set
        {
            _Radius = newValue
        }
    }
    
    private var _ShowWork: Bool = false
    public var ShowWork: Bool
    {
        get
        {
            return _ShowWork
        }
        set
        {
            _ShowWork = newValue
            setNeedsDisplay()
        }
    }
    
    public func Locations0() -> [CGFloat]
    {
        var Results = [CGFloat]()
        if EnableOuterAlpha
        {
            if Colors.last != ClearColor
            {
                _Colors.append(ClearColor)
                _GColors.append(ClearColor.cgColor as Any)
            }
            let AlphaZone = Radius * OuterAlphaDistance
            let Step = CGFloat((Radius - AlphaZone) / CGFloat(Colors.count))
            for i in 0 ..< Colors.count - 1
            {
                let ColorStep = Step * CGFloat(i) / Radius
                Results.append(ColorStep)
            }
            Results.append(1.0)
        }
        else
        {
            for i in 0 ..< GradientColors.count
            {
                let Scratch: CGFloat = CGFloat(i) / CGFloat(Colors.count)
                Results.append(Scratch)
            }
        }
        return Results
    }
    
    private var _ColorStops: [CGFloat]? = nil
    public var ColorStops: [CGFloat]?
    {
        get
        {
            return _ColorStops
        }
        set
        {
            _ColorStops = newValue
        }
    }
    
    public func Locations1() -> [CGFloat]
    {
        if ColorStops != nil
        {
            return ColorStops!
        }
        return Locations0()
    }
    
    public func GradientRegion() -> CGRect
    {
        return CGRect(x: Center.x - Radius,
                      y: frame.height - (Center.y + Radius),
                      width: (Radius * 2),
                      height: (Radius * 2))
    }
    
    public func SetCenters()
    {
        
    }
    
    private var _AsFunnel: Bool = false
    public var AsFunnel: Bool
    {
        get
        {
            return _AsFunnel
        }
        set
        {
            _AsFunnel = newValue
        }
    }
    
    private var _AsLozenge: Bool = false
    public var AsLozenge: Bool
    {
        get
        {
            return _AsLozenge
        }
        set
        {
            _AsLozenge = newValue
        }
    }
    
    private func DebugLayer() -> CAShapeLayer
    {
        let Debug = CAShapeLayer()
        Debug.frame = frame
        Debug.bounds = bounds
        if let Context = UIGraphicsGetCurrentContext()
        {
            Context.setStrokeColor(UIColor.black.cgColor)
            Context.setLineWidth(4.0)
            Context.addEllipse(in: GradientRegion())
            Context.drawPath(using: .stroke)
        }
        return Debug
    }
    
    override func draw(in Context: CGContext)
    {
        Context.saveGState()
        shouldRasterize = true
        rasterizationScale = UIScreen.main.scale
        //contentsScale = UIScreen.main.scale
        let ColorSpace = CGColorSpaceCreateDeviceRGB()
        let Locations = Locations1()
        let FinalColors: CFArray = GradientColors as CFArray
        let Grad = CGGradient(colorsSpace: ColorSpace, colors: FinalColors, locations: Locations)
        var NewCenter = CGPoint(x: Center.x, y: frame.height - Center.y)
        var FinalCenter: CGPoint!
        var InitialRadius: CGFloat = 0.0
        //print("AnchorInCenter=\(AnchorInCenter)")
        if AnchorInCenter
        {
            if AsLozenge
            {
                InitialRadius = Radius
                FinalCenter = CenterPoint
            }
            else
            {
                if AsFunnel
                {
                    FinalCenter = CenterPoint
                }
                else
                {
                    //Triangular
                    FinalCenter = NewCenter
                    NewCenter = CenterPoint!
                }
            }
        }
        else
        {
            FinalCenter = NewCenter
        }
        Context.drawRadialGradient(Grad!,
                                   startCenter: FinalCenter, startRadius: InitialRadius,
                                   endCenter: NewCenter, endRadius: Radius,
                                   options: .drawsBeforeStartLocation)
        if ShowWork
        {
            sublayers?.forEach{$0.removeFromSuperlayer()}
            addSublayer(DebugLayer())
        }
    }
    
    // MARK: Animation functions.
    
    // MARK: Animate radius.
    
    private var RadiusAnimation: LinkAnimation!
    
    func HandleNewRadiusValue(_ NewValue: CGFloat)
    {
        self.Radius = NewValue
    }
    
    func RadiusAnimationCompleted()
    {
        print("Radius animation completed.")
    }
    
    @discardableResult public func AnimateRadius(From: CGFloat, To: CGFloat, Duration: TimeInterval) -> Bool
    {
        assert(Duration > 0.0, "Duration must be greater than 0.0.")
        RadiusAnimation = LinkAnimation()
        return RadiusAnimation.AnimateCGFloat(From: From, To: To, Duration: Duration,
                                              NewValueHandler: HandleNewRadiusValue,
                                              CompletionHandler: RadiusAnimationCompleted)
    }
    
    private var RadiusPulsation: LinkAnimation? = nil
    
    func HandleNewRadiusPulsationValue(_ NewValue: CGFloat)
    {
        self.Radius = NewValue
    }
    
    func HandleRadiusPulsationCompleted()
    {
        let NewFrom = PulsationEnd
        var NewEnd: CGFloat = PulsationStart
        if PulsationRadiusRandom
        {
            NewEnd = CGFloat.random(in: 20.0 ... 350.0)
        }
        PulsationEnd = NewEnd
        PulsationStart = NewFrom
        if PulsationDurationRandom
        {
            PulsationCycleDuration = TimeInterval(Double.random(in: 3.0 ... 10.0))
        }
        RadiusPulsation?.AnimateCGFloat(From: NewFrom, To: NewEnd, Duration: PulsationCycleDuration!,
                                        NewValueHandler: HandleNewRadiusPulsationValue,
                                        CompletionHandler: HandleRadiusPulsationCompleted)
    }
    
    /// Pulsate the radius of the gradient between From and To. If Duration is nil, select a random duration
    /// for each pulsation cycle.
    ///
    /// - Parameters:
    ///   - From: Starting radius.
    ///   - To: Ending radius.
    ///   - RandomizeRadius: If true, From and To are ignored in favor of randomly generated radii.
    ///   - Duration: Duration of the pulation. If nil, random cycle durations are used.
    @discardableResult public func PulsateRadius(From: CGFloat, To: CGFloat,
                                                 RandomizeRadius: Bool = false, Duration: TimeInterval? = nil) -> Bool
    {
        if RadiusPulsation != nil
        {
            print("Currently animating radius.")
            return false
        }
        PulsationStart = From
        var PulsationDuration: TimeInterval!
        if let Duration = Duration
        {
            assert(Duration > 0.0, "Duration (if specified) must be greater than 0.0.")
            PulsationDuration = Duration
            PulsationDurationRandom = false
        }
        else
        {
            let CycleDuration = Double.random(in: 3.0 ... 10.0)
            PulsationDuration = TimeInterval(CycleDuration)
            PulsationDurationRandom = true
        }
        PulsationCycleDuration = PulsationDuration
        RadiusPulsation = LinkAnimation()
        var DestRadius: CGFloat = To
        if RandomizeRadius
        {
            let Sign: CGFloat = Bool.random() ? 1.0 : -1.0
            let DeltaValue = CGFloat.random(in: 20.0 ... 100.0)
            DestRadius = From + (Sign * DeltaValue)
            if DestRadius < 5.0
            {
                DestRadius = 5.0
            }
        }
        PulsationRadiusRandom = RandomizeRadius
        PulsationEnd = DestRadius
        return (RadiusPulsation?.AnimateCGFloat(From: From, To: DestRadius, Duration: PulsationDuration,
                                                NewValueHandler: HandleNewRadiusPulsationValue,
                                                CompletionHandler: HandleRadiusPulsationCompleted))!
    }
    
    func HandleRadiusPulsationInRangeCompleted()
    {
        PulsationStart = PulsationEnd
        PulsationEnd = CGFloat.random(in: RadialRange)
        let Duration = TimeInterval(Double.random(in: PulsationDurationRange))
        RadiusPulsation?.AnimateCGFloat(From: PulsationStart, To: PulsationEnd, Duration: Duration,
                                        NewValueHandler: HandleNewRadiusPulsationValue,
                                        CompletionHandler: HandleRadiusPulsationInRangeCompleted)
    }
    
    @discardableResult public func PulsateRadius(WithRadiusRange: ClosedRange<CGFloat>, DurationRange: ClosedRange<Double>) -> Bool
    {
        if RadiusPulsation != nil
        {
            print("Currently animating radius.")
            return false
        }
        RadiusPulsation = LinkAnimation()
        RadialRange = WithRadiusRange
        PulsationDurationRange = DurationRange
        PulsationEnd = CGFloat.random(in: WithRadiusRange)
        PulsationStart = self.Radius
        let InitialDuration = TimeInterval(Double.random(in: DurationRange))
        return ((RadiusPulsation?.AnimateCGFloat(From: PulsationStart, To: PulsationEnd, Duration: InitialDuration,
                                                 NewValueHandler: HandleNewRadiusPulsationValue,
                                                 CompletionHandler: HandleRadiusPulsationInRangeCompleted))!)
    }
    
    private var RadialRange: ClosedRange<CGFloat>!
    private var PulsationDurationRange: ClosedRange<Double>!
    
    @discardableResult public func VaryRadiusPeriodically(From: CGFloat, To: CGFloat, Duration: TimeInterval) -> Bool
    {
        if RadiusPulsation != nil
        {
            print("Currently animating radius.")
            return false
        }
        PulsationStart = From
        PulsationEnd = To
        PulsationDurationRandom = false
        PulsationRadiusRandom = false
        PulsationCycleDuration = Duration
        RadiusPulsation = LinkAnimation()
        return ((RadiusPulsation?.AnimateCGFloat(From: PulsationStart, To: PulsationEnd,
                                                 Duration: PulsationCycleDuration!,
                                                 NewValueHandler: HandleNewRadiusPulsationValue,
                                                 CompletionHandler: HandleRadiusPulsationCompleted))!)
    }
    
    private var PulsationStart: CGFloat = 0.0
    private var PulsationEnd: CGFloat = 0.0
    private var PulsationRadiusRandom: Bool = false
    private var PulsationDurationRandom: Bool = false
    private var PulsationCycleDuration: TimeInterval? = nil
    
    public func StopRadiusPulsation()
    {
        if RadiusPulsation != nil
        {
            RadiusPulsation?.StopCGFloatAnimation()
            RadiusPulsation = nil
        }
    }
    
    // MARK: Animate opacity.
    
    func UpdateOpacity(Interval: CGFloat)
    {
        LastOpacityUpdateTime = CACurrentMediaTime()
        CumulativeOpacity = CumulativeOpacity + Interval
        var NewOpacity = CGFloat(OpacityDelta) * CumulativeOpacity * CGFloat(OpacitySign)
        NewOpacity = CGFloat(StartingOpacity) + NewOpacity
        if CumulativeOpacity >= 1.0
        {
            CumulativeOpacity = 1.0
            OpacityLink.invalidate()
            OpacityLink = nil
            _AnimatingOpacity = false
            NewOpacity = CGFloat(EndingOpacity)
        }
        self.opacity = Float(NewOpacity)
    }
    
    @objc func UpdateOpacityAnimation(Link: CADisplayLink)
    {
        let Now = CACurrentMediaTime()
        let Interval = (Now - LastOpacityUpdateTime) / OpacityAnimationDuration
        UpdateOpacity(Interval: CGFloat(Interval))
    }
    
    var LastOpacityUpdateTime = CACurrentMediaTime()
    var OpacityAnimationDuration: Double = 1.0
    var OpacityLink: CADisplayLink!
    var _AnimatingOpacity: Bool = false
    var CumulativeOpacity: CGFloat = 0.0
    var StartingOpacity: CGFloat = 0.0
    var EndingOpacity: CGFloat = 0.0
    var OpacityDelta: CGFloat = 0.0
    var OpacitySign: CGFloat = 1.0
    
    @discardableResult public func AnimateOpacity(From: CGFloat, To: CGFloat, Duration: TimeInterval) -> Bool
    {
        if _AnimatingOpacity
        {
            return false
        }
        assert(Duration > 0.0, "Duration must be greater than 0.0")
        StartingOpacity = From
        EndingOpacity = To
        OpacityDelta = abs(To - From)
        OpacitySign = To < From ? -1.0 : 1.0
        CumulativeOpacity = 0.0
        OpacityAnimationDuration = Duration
        OpacityLink = CADisplayLink(target: self, selector: #selector(UpdateOpacityAnimation))
        OpacityLink.preferredFramesPerSecond = 60
        OpacityLink.add(to: .current, forMode: .default)
        _AnimatingOpacity = true
        UpdateOpacity(Interval: 0)
        return true
    }
    
    // MARK: Animate colors.
    
    public func AnimateColor(ColorIndex: Int, From: UIColor, To: UIColor, Duration: TimeInterval)
    {
        
    }
}
