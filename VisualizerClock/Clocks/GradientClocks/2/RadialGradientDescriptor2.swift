//
//  RadialGradientDescriptor2.swift
//  Visualizer Clock
//
//  Created by Stuart Rankin on 1/5/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Intended usages for gradients. This is a convenience and not enforced in the RadialGradientDescriptor2 class.
///
/// - Center: The radial gradient is used as the center dot.
/// - Second: The radial gradient is used as the second hand.
/// - Minute: The radial gradient is used as the minute hand.
/// - Hour: The radial gradient is used as the hour hand.
/// - Other: The radial gradient is used for something else.
enum GradientTypes: Int
{
    case Center = 0
    case Second = 1
    case Minute = 2
    case Hour = 3
    case Other = 1000
}

/// Encapsulates a radial gradient layer.
class RadialGradientDescriptor2: CAGradientLayer, SettingProtocol
{
    /// Definition of clear for our purposes.
    var ClearColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.0)
    
    let _Settings = UserDefaults.standard
    
    /// Minimal initializer.
    required override init()
    {
        super.init()
        needsDisplayOnBoundsChange = true
        Handle = VectorHandle.Make()
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
    
    /// Initializer. The caller will still have to set bounds and frames and the like before this class will
    /// create any gradial gradients. The type of the gradient is read from the contents of the user settings.
    ///
    /// - Parameter SettingsKey: The settings key for the description of the radial. This class will not change
    ///                          the contents of where the key points.
    init?(SettingsKey: String, VHandle: VectorHandle? = nil)
    {
        super.init()
        if SettingsKey.isEmpty
        {
            return nil
        }
        if VHandle == nil
        {
            Handle = VectorHandle.Make()
            Handle?.RadialGradientShape = 0
            Handle?.CenterAnchor = false
        }
        else
        {
            Handle = VHandle
        }
        SettingKeyName = SettingsKey
        if !Reload()
        {
            return nil
        }
    }
    
    /// Initialize the radial gradient from the contents pointed to by the settings key and other parameters.
    ///
    /// - Parameters:
    ///   - SettingsKey: Points to the user settings where the contents of the gradient are stored.
    ///   - VHandle: Optional handle that describes how to draw the gradient. If not present, a default handle
    ///              will be created and used.
    ///   - Frame: The frame to use for the gradient layer.
    ///   - Bounds: The bounds to use for the gradient layer.
    ///   - Location: Location of the gradient with respect to the parent container - this can also be thought of as the
    ///               coordinates of the center of the gradien in parent container space.
    ///   - OuterAlpha: The outer circumferential alpha value - used for blending the radial gradient into the background.
    ///   - AlphaDistance: The location of the outer alpha value in percent of the total radial distance of the gradient.
    ///   - TheCenter: If present, the center of the radial for drawing non-circular radial gradients.
    init?(SettingsKey: String, VHandle: VectorHandle? = nil, Frame: CGRect, Bounds: CGRect, Location: CGPoint,
          OuterAlpha: CGFloat, AlphaDistance: CGFloat = 0.1, TheCenter: CGPoint? = nil)
    {
        super.init()
        if SettingsKey.isEmpty
        {
            return nil
        }
        if VHandle == nil
        {
            Handle = VectorHandle.Make()
        }
        else
        {
            Handle = VHandle
            Handle?.RadialGradientShape = 0
            Handle?.CenterAnchor = false
        }
        SettingKeyName = SettingsKey
        if !Reload()
        {
            return nil
        }
        frame = Frame
        bounds = Bounds
        CenterPoint = Location
        OuterAlphaValue = OuterAlpha
        OuterAlphaDistance = AlphaDistance
        EnableOuterAlpha = true
        CenterPoint = TheCenter
    }
    
    private var _Handle: VectorHandle? = nil
    /// Get or set the handle used for some drawing parameters. If not explicitly supplied (either here or in an initializer),
    /// one is created by an initializer with default values.
    public var Handle: VectorHandle?
    {
        get
        {
            return _Handle
        }
        set
        {
            _Handle = newValue
        }
    }
    
    private var _SettingKeyName: String = ""
    /// Get or set the settings key name where the radial gradient stop information is kept.
    public var SettingKeyName: String
    {
        get
        {
            return _SettingKeyName
        }
        set
        {
            _SettingKeyName = newValue
        }
    }
    
    /// Reload the radial gradient stop information from user settings. This function assumes WithSettingKey has already
    /// been set with a valid setting key into user settings.
    ///
    /// - Returns: True on success, false on failure.
    public func Reload() -> Bool
    {
        return Reload(WithSettingKey: SettingKeyName)
    }
    
    /// Reload the radial gradient stop information from use settings with the supplied settings key.
    ///
    /// - Parameter WithSettingKey: The key name to use to retrieve gradient stop information.
    /// - Returns: True on success, false on failure.
    public func Reload(WithSettingKey: String) -> Bool
    {
        if WithSettingKey.isEmpty
        {
            return false
        }
        if let Raw = _Settings.string(forKey: WithSettingKey)
        {
            let Parsed = RadialGradientDescriptor2.ParseRawColorNode(Raw)
            RadialDistance = CGFloat(Parsed!.1)
            RadialType = GradientTypes(rawValue: Parsed!.2)!
            ColorList = Parsed!.3
            return true
        }
        else
        {
            return false
        }
    }
    
    var SettingDelegate: SettingProtocol? = nil
    
    func DoSet(Key: String, Value: Any?)
    {
        
    }
    
    /// Contains cached gradient stop locations. If gradient stops change, this is cleared and set to nil which forces
    /// GradientLocations to recalculate the values.
    var CachedLocations: [CGFloat]? = nil
    
    /// Get a list of gradient stop locations. If no changes were made to the gradient stop list, a cached list will be
    /// returned.
    ///
    /// - Returns: List of gradient stop locations, from inner to outer.
    func GradientLocations() -> [CGFloat]
    {
        if CachedLocations != nil
        {
            return CachedLocations!
        }
        var Results = [CGFloat]()
        if EnableOuterAlpha
        {
            if RawColors.last != ClearColor
            {
                RawColors.append(ClearColor)
            }
            let AlphaZone = RadialDistance * OuterAlphaDistance
            let Step = CGFloat((RadialDistance - AlphaZone) / CGFloat(RawColors.count))
            for i in 0 ..< RawColors.count - 1
            {
                let ColorStep = Step * CGFloat(i) / RadialDistance
                Results.append(ColorStep)
            }
            Results.append(1.0)
        }
        else
        {
            Results = RawLocations
        }
        CachedLocations = Results
        return Results
    }
    
    private var _ID: UUID = UUID()
    /// Get or set the ID of the radial gradient descriptor. An ID is generated automatically so setting this isn't necessary
    /// for those applications that don't need a specific ID.
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
    
    private var _AlphaDistance: CGFloat = 0.1
    /// Get or set the distance (in percent of the overall radial distance) of where the alpha blending starts to take place.
    public var AlphaDistance: CGFloat
    {
        get
        {
            return _AlphaDistance
        }
        set
        {
            _AlphaDistance = newValue
        }
    }
    
    private var _EnableOuterAlpha: Bool = true
    /// Determines if the outer alpha blending is enabled or disabled.
    public var EnableOuterAlpha: Bool
    {
        get
        {
            return _EnableOuterAlpha
        }
        set
        {
            _EnableOuterAlpha = newValue
        }
    }
    
    private var _OuterAlphaDistance: CGFloat = 0.0
    /// Get or set the distance (in percent of the overall radial distance) of where the alpha blending starts to take place.
    public var OuterAlphaDistance: CGFloat
    {
        get
        {
            return _OuterAlphaDistance
        }
        set
        {
            _OuterAlphaDistance = newValue
        }
    }
    
    private var _OuterAlphaValue: CGFloat = 0.5
    /// Get or set the outer circumferential alpha value for blending with the background.
    public var OuterAlphaValue: CGFloat
    {
        get
        {
            return _OuterAlphaValue
        }
        set
        {
            _OuterAlphaValue = newValue
        }
    }
    
    private var _Center: CGPoint? = nil
    /// Get or set the center point of the radial gradient.
    public var Center: CGPoint?
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
    
    private var _RadialDistance: CGFloat = 0.0
    /// Get or set the distance between the center and the edge of the radial gradient.
    public var RadialDistance: CGFloat
    {
        get
        {
            return _RadialDistance
        }
        set
        {
            _RadialDistance = newValue
        }
    }
    
    private var _RadialType: GradientTypes = .Other
    /// Get or set the type of the radial. Not used internally but supplied as a convenience to callers.
    public var RadialType: GradientTypes
    {
        get
        {
            return _RadialType
        }
        set
        {
            _RadialType = newValue
        }
    }
    
    /// Holds the gradient stop list.
    private var _ColorList: [(Double, UIColor, Bool, UUID)]? = nil
    /// Get or set the list of gradient stops. Converted internally to color lists for the actual gradient. Additionally,
    /// gradient stop locations are extracted and saved.
    public var ColorList: [(Double, UIColor, Bool, UUID)]?
    {
        get
        {
            return _ColorList
        }
        set
        {
            _ColorList = newValue
            RawColors.removeAll()
            RawLocations.removeAll()
            CachedLocations?.removeAll()
            CachedLocations = nil
            for (Location, Color, _, _) in _ColorList!
            {
                RawLocations.append(CGFloat(Location))
                RawColors.append(Color)
            }
        }
    }
    
    /// Locations of the gradient stops. Derived from the caller-supplied list of colors. There may be more locations here
    /// than in the caller-supplied list due to automatically-created colors and locations for edge blending.
    private var RawLocations = [CGFloat]()
    
    /// Raw colors derived from the caller-specified color list. There may be more entries in this list than in the caller-
    /// supplied list because of blending at the outer radius.
    private var _RawColors = [UIColor]()
    public var RawColors: [UIColor]
    {
        get
        {
            return _RawColors
        }
        set
        {
            _RawColors = newValue
            _GColors.removeAll()
            for Color in _RawColors
            {
                _GColors.append(Color.cgColor as Any)
            }
        }
    }
    
    private var _GColors = [UIColor.black.cgColor as Any, UIColor.white.cgColor as Any]
    /// Get or set a list of raw colors (CGColors cast to Any) used directly by the radial gradient.
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
    
    /// Hide or show an outline around the edge of the layer.
    ///
    /// - Parameters:
    ///   - Show: If true, the outline is shown. If false, the outline is hidden.
    ///   - OutlineColor: If provided the color of the outline. If not provided, red will be used.
    public func ShowOutline(_ Show: Bool, OutlineColor: UIColor? = nil)
    {
        if Show
        {
            if let OutlineColor = OutlineColor
            {
                borderColor = OutlineColor.cgColor
            }
            else
            {
                borderColor = UIColor.red.cgColor
            }
            borderWidth = 1.0
        }
        else
        {
            borderColor = nil
            borderWidth = 0.0
        }
    }
    
    /// Parse a color node (most likely from user settings) in to data other functions can use.
    ///
    /// - Parameter Node: The string description of the color node in string format.
    /// - Returns: On success, tuple with the contents: (Number of colors, radius of gradient, gradient type,
    ///            list of (normalized color position, color, convenience bool, gradient stop ID)). Nil returned on error.
    public static func ParseRawColorNode(_ Node: String) -> (Int, Double, Int, [(Double, UIColor, Bool, UUID)])?
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
        var FinalGradientType: Int = 1000
        if let GrType = XMLF.AttributeInt(Node, Name: "Type")
        {
            FinalGradientType = GrType
        }
        else
        {
            print("No type found.")
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
        
        return (FinalColorCount, FinalRadius, FinalGradientType, ColorList)
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
    
    /// Serialize a radial gradient into an XML fragment.
    ///
    /// - Parameters:
    ///   - Radius: The radius of the gradient.
    ///   - GradientType: The type of gradient beng serialized.
    ///   - Colors: The list of colors in the gradient along with their positions.
    /// - Returns: XML fragment string describing the gradient.
    public static func SerializeRadial(Radius: Double, GradientType: GradientTypes, Colors: [(Double, UIColor, Bool, UUID)]) -> String
    {
        let GType = GradientType.rawValue
        var stemp = "<Gradient Radius=\"\(Radius)\" Type=\"\(GType)\" Colors=\"\(Colors.count)\">"
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
    
    /// Serialize the instance of the radial gradient.
    ///
    /// - Returns: Serialized radial gradient as an XML fragment. This fragment can be fed into the parsing routine or various
    ///            initializers to this class and used again.
    public func SerializeRadial() -> String
    {
        return RadialGradientDescriptor2.SerializeRadial(Radius: Double(RadialDistance), GradientType: RadialType, Colors: ColorList!)
    }
    
    /// Return the ARGB channels of the passed color.
    ///
    /// - Parameter Source: The color whose channels will be returned.
    /// - Returns: Normalized channels in the order alpha, red, green, and blue.
    func GetARGB(_ Source: UIColor) -> (CGFloat, CGFloat, CGFloat, CGFloat)
    {
        var Red: CGFloat = 0.0
        var Green: CGFloat = 0.0
        var Blue: CGFloat = 0.0
        var Alpha: CGFloat = 0.0
        Source.getRed(&Red, green: &Green, blue: &Blue, alpha: &Alpha)
        return (Alpha, Red, Green, Blue)
    }

    // MARK: Radial rendering.
    
    var CenterPoint: CGPoint? = nil
    
    /// Draw the radial gradient.
    ///
    /// - Parameter Context: Where the gradient will be drawn.
    override func draw(in Context: CGContext)
    {
        Context.saveGState()
        shouldRasterize = true
        rasterizationScale = UIScreen.main.scale
        let ColorSpace = CGColorSpaceCreateDeviceRGB()
        let Locations = GradientLocations()
        let FinalColors: CFArray = GradientColors as CFArray
        let Grad = CGGradient(colorsSpace: ColorSpace, colors: FinalColors, locations: Locations)
        var NewCenter = CGPoint(x: Center!.x, y: frame.height - Center!.y)
        var FinalCenter: CGPoint!
        var InitialRadius: CGFloat = 0.0
        switch Handle?.RadialGradientShape
        {
        case 0:
            //Circular
            FinalCenter = NewCenter
            
        case 1:
            //Triangular
            FinalCenter = NewCenter
            NewCenter = CenterPoint!
            
        case 2:
            //Funnel
            FinalCenter = CenterPoint
            
        case 3:
            //Square
            FinalCenter = NewCenter
            
        case 4:
            //Lozenge
            FinalCenter = CenterPoint
            InitialRadius = RadialDistance
            
        default:
            //Circular
            FinalCenter = NewCenter
        }
        Context.drawRadialGradient(Grad!, startCenter: FinalCenter, startRadius: InitialRadius, endCenter: NewCenter,
                                   endRadius: RadialDistance, options: .drawsBeforeStartLocation)
    }
    
    // MARK: Animation-related functions
    
    private var RadiusAnimation: LinkAnimation!
    
    func HandleNewRadiusValue(_ NewValue: CGFloat)
    {
        self.RadialDistance = NewValue
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
    
    func HandleNewRadiusAnimationValue(_ NewValue: CGFloat)
    {
        self.RadialDistance = NewValue
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
                                        NewValueHandler: HandleNewRadiusAnimationValue,
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
                                                NewValueHandler: HandleNewRadiusAnimationValue,
                                                CompletionHandler: HandleRadiusPulsationCompleted))!
    }
    
    func HandleRadiusAnimationInRangeCompleted()
    {
        PulsationStart = PulsationEnd
        PulsationEnd = CGFloat.random(in: RadialRange)
        let Duration = TimeInterval(Double.random(in: PulsationDurationRange))
        RadiusPulsation?.AnimateCGFloat(From: PulsationStart, To: PulsationEnd, Duration: Duration,
                                        NewValueHandler: HandleNewRadiusAnimationValue,
                                        CompletionHandler: HandleRadiusAnimationInRangeCompleted)
    }
    
    @discardableResult public func AnimateRadius(WithRadialRange: ClosedRange<CGFloat>, DurationRange: ClosedRange<Double>) -> Bool
    {
        if RadiusPulsation != nil
        {
            print("Already animating radius.")
            return false
        }
        RadiusPulsation = LinkAnimation()
        RadialRange = WithRadialRange
        PulsationDurationRange = DurationRange
        PulsationEnd = CGFloat.random(in: WithRadialRange)
        PulsationStart = self.RadialDistance
        let InitialDuration = TimeInterval(Double.random(in: DurationRange))
        return ((RadiusPulsation?.AnimateCGFloat(From: PulsationStart, To: PulsationEnd, Duration: InitialDuration,
                                                 NewValueHandler: HandleNewRadiusAnimationValue,
                                                 CompletionHandler: HandleRadiusAnimationInRangeCompleted))!)
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
                                                 NewValueHandler: HandleNewRadiusAnimationValue,
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
}
