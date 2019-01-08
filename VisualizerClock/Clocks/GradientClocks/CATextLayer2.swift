//
//  CATextLayer2.swift
//  GradientTestBed
//
//  Created by Stuart Rankin on 10/13/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// CATextLayer with additionaly functionality, mainly related to animation.
class CATextLayer2: CATextLayer, CAAnimationDelegate
{
    // MARK: Initializers.
    
    /// Required initializer.
    ///
    /// - Parameter layer: See iOS documentation.
    override init(layer: Any)
    {
        super.init(layer: layer)
    }
    
    /// Initializer.
    ///
    /// - Parameter Home: Home location.
    convenience init(Home: CGPoint)
    {
        self.init()
        HomeLocation = Home
    }
    
    /// Initializer.
    ///
    /// - Parameters:
    ///   - Home: Home location.
    ///   - FontSize: Base font size.
    convenience init(Home: CGPoint, FontSize: CGFloat)
    {
        self.init()
        HomeLocation = Home
        BaseFontSize = FontSize
    }
    
    /// Initializer.
    ///
    /// - Parameters:
    ///   - Home: Home location.
    ///   - Contents: Contents of the layer. In this case just a raw (eg, non-attributed) string.
    convenience init(Home: CGPoint, Contents: String)
    {
        self.init()
        HomeLocation = Home
        self.string = Contents
    }
    
    /// Initializer.
    ///
    /// - Parameters:
    ///   - Home: Home location.
    ///   - StringContents: Attributed string. Internally, converted to a mutable attributed string.
    convenience init(Home: CGPoint, StringContents: NSAttributedString)
    {
        self.init()
        HomeLocation = Home
        Contents = NSMutableAttributedString(attributedString: StringContents)
    }
    
    /// Initializer.
    ///
    /// - Parameters:
    ///   - Home: Home location.
    ///   - StringContents: Attributed string.
    convenience init(Home: CGPoint, StringContents: NSMutableAttributedString)
    {
        self.init()
        HomeLocation = Home
        Contents = StringContents
    }
    
    /// Initializer.
    ///
    /// - Parameters:
    ///   - Home: Home location.
    ///   - FontSize: Base font size.
    ///   - StringContents: Attributed string.
    convenience init(Home: CGPoint, FontSize: CGFloat, StringContents: NSMutableAttributedString)
    {
        self.init()
        HomeLocation = Home
        Contents = StringContents
    }
    
    /// Initializer.
    required override init()
    {
        super.init()
    }
    
    /// Initializer.
    ///
    /// - Parameter aDecoder: See iOS documentation.
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    // MARK: Attributes.
    
    /// Holds the last random angle assigned.
    private var _LastRandomAngle: CGFloat = 0.0
    /// Get or set the last random angle used.
    public var LastRandomAngle: CGFloat
    {
        get
        {
            return _LastRandomAngle
        }
        set
        {
            _LastRandomAngle = newValue
        }
    }
    
    /// Holds the point where the text is hiding.
    private var _HidingPoint: CGPoint = CGPoint.zero
    /// Get or set the text's hiding point.
    public var HidingPoint: CGPoint
    {
        get
        {
            return _HidingPoint
        }
        set
        {
            _HidingPoint = newValue
        }
    }
    
    /// Get or set the contents (eg, the text) of the layer.
    public var Contents: NSMutableAttributedString
    {
        get
        {
            let Fred: NSAttributedString = self.string as! NSAttributedString
            return NSMutableAttributedString(attributedString: Fred)
        }
        set
        {
            self.string = newValue
            GetAttributes(From: newValue)
        }
    }
    
    /// Extracts an array of attributes from the attributed string. Extracted attributes are placed in the global CurrentAttributes.
    ///
    /// - SeeAlso: https://stackoverflow.com/questions/19844336/is-it-possible-to-get-a-listing-of-attributes-and-ranges-for-an-nsmutableattribu
    ///
    /// - Parameter From: The attributed string from which all attributes are extracted.
    private func GetAttributes(From: NSAttributedString)
    {
        CurrentAttributes.removeAll()
        CurrentAttributes = From.attributes(at: 0, effectiveRange: nil)
    }
    
    /// Extracts an array of attributes from the mutable attributed string. Extracted attributes are placed in the global CurrentAttributes.
    ///
    /// - SeeAlso: https://stackoverflow.com/questions/19844336/is-it-possible-to-get-a-listing-of-attributes-and-ranges-for-an-nsmutableattribu
    ///
    /// - Parameter From: The attributed string from which all attributes are extracted.
    private func GetAttributes(From: NSMutableAttributedString)
    {
        CurrentAttributes.removeAll()
        CurrentAttributes = From.attributes(at: 0, effectiveRange: nil)
    }
    
    /// Current array of attributes if the text is from an attributed string.
    private var CurrentAttributes = [NSAttributedString.Key: Any]()
    
    /// Holds the base font size.
    private var _BaseFontSize: CGFloat = 12.0
    /// Get or set (but please don't set unless you're the creator of this instance) the base font size of the text. This is used
    /// in various locations for animation purposes.
    public var BaseFontSize: CGFloat
    {
        get
        {
            return _BaseFontSize
        }
        set
        {
            _BaseFontSize = newValue
        }
    }
    
    /// Holds the home location.
    private var _HomeLocation: CGPoint = CGPoint.zero
    /// Get or set the center point of the home position. This property can be set only once. All attempts to set this property
    /// once it is initially set will be ignored and the value of the property will not be changed.
    public var HomeLocation: CGPoint
    {
        get
        {
            return _HomeLocation
        }
        set
        {
            if HomeWasSet
            {
                return
            }
            _HomeLocation = newValue
            HomeWasSet = true
        }
    }
    
    /// Holds the flag that indicates the home location was set.
    private var HomeWasSet: Bool = false
    
    /// Holds the current location.
    private var _CurrentLocation: CGPoint = CGPoint.zero
    /// Get or set the current location.
    public var CurrentLocation: CGPoint
    {
        get
        {
            return _CurrentLocation
        }
        set
        {
            _CurrentLocation = newValue
        }
    }
    
    /// Determines if the text is in its home position. If the home position was not set, false will be returned.
    public var InHomePosition: Bool
    {
        get
        {
            if !HomeWasSet
            {
                return false
            }
            return CurrentLocation == HomeLocation
        }
    }
    
    // MARK: Motion animation.
    
    /// Return the X value on the hypotenuse Percent of the way from the starting point.
    ///
    /// - Parameters:
    ///   - Percent: Distance from the starting point to determine the X value. If Direction is -1, the percent is for
    ///              distance from the ending point.
    ///   - Direction: 1 for distance from the starting point, -1 for the distance from the ending point.
    /// - Returns: Horizontal (X) position of the hypotenuse at Percent distance from the starting or ending point (determined
    ///            by the value of Direction).
    public func GetX(_ StartPoint: CGPoint, _ Percent: Double, _ Direction: Int = 1) -> CGFloat
    {
        if Percent == 0.0
        {
            return StartPoint.x
        }
        let Dir = Direction == 1 ? Double(1.0) : Double(1.0 - Double(Direction))
        var X = Hypotenuse * (Dir * Percent)
        X = X * RunHypotenuseRatio
        if X.isNaN
        {
            print("X is NaN")
            print("X = \(Hypotenuse) * \(Dir) * \(Percent)")
            print("X = X * \(RunHypotenuseRatio)")
        }
        return CGFloat(X) + StartPoint.x
    }
    
    /// Return the Y value on the hypotenuse Percent of the way from the starting point.
    ///
    /// - Parameters:
    ///   - Percent: Distance from the starting point to determine the Y value. If Direction is -1, the percent is for
    ///              distance from the ending point.
    ///   - Direction: 1 for distance from the starting point, -1 for the distance from the ending point.
    /// - Returns: Vertical (Y) position of the hypotenuse at Percent distance from the starting or ending point (determined
    ///            by the value of Direction).
    public func GetY(_ StartPoint: CGPoint, _ Percent: Double, _ Direction: Int = 1) -> CGFloat
    {
        if Percent == 0.0
        {
            return StartPoint.y
        }
        let Dir = Direction == 1 ? Double(1.0) : Double(1.0 - Double(Direction))
        var Y = Hypotenuse * (Dir * Percent)
        Y = Y * RiseHypotenuseRatio
        if Y.isNaN
        {
            print("Y is NaN")
            print("Y = \(Hypotenuse) * \(Dir) * \(Percent)")
            print("Y = Y * \(RiseHypotenuseRatio)")
        }
        return CGFloat(Y) + StartPoint.y
    }
    
    private func GetPointOnPath(StartingPoint: CGPoint, Percent: Double, Direction: Int = 1) -> CGPoint
    {
        let X = GetX(StartingPoint, Percent, Direction)
        let Y = GetY(StartingPoint, Percent, Direction)
        if X.isNaN
        {
            print("X is NaN in GetPointOnPath, starting at \(StartingPoint) at \(Percent)%")
        }
        if Y.isNaN
        {
            print("Y is NaN in GetPointOnPath, starting at \(StartingPoint) at \(Percent)%")
        }
        return CGPoint(x: X, y: Y)
    }
    
    @objc func UpdateLocationHandler(Link: CADisplayLink)
    {
        let Now = CACurrentMediaTime()
        let Interval = (Now - LastMotionUpdateTime) / AnimationDuration
        self.UpdateLocation(Interval: CGFloat(Interval))
    }
    
    func UpdateLocation(Interval: CGFloat)
    {
        LastMotionUpdateTime = CACurrentMediaTime()
        CumulativeMotion = CumulativeMotion + Interval
        var NewPoint = GetPointOnPath(StartingPoint: InitialMotionPoint, Percent: Double(CumulativeMotion))
        if CumulativeMotion >= 1.0
        {
            //print("Animation completed. CumulativeMotion=\(CumulativeMotion)")
            _MoveCompleted = true
            MotionLink?.invalidate()
            MotionLink = nil
            NewPoint = GetPointOnPath(StartingPoint: InitialMotionPoint, Percent: 1.0)
            CurrentLocation = NewPoint
            _AnimationRunning = false
            CumulativeMotion = 1.0
        }
        let NewFrame = CGRect(x: NewPoint.x - XOffset, y: NewPoint.y - YOffset, width: frame.width, height: frame.height)
        self.frame = NewFrame
    }
    
    var CumulativeMotion: CGFloat = 0.0
    var MotionLink: CADisplayLink? = nil
    var AnimationDuration: Double = 0
    var LastMotionUpdateTime = CACurrentMediaTime()
    var RunHypotenuseRatio: Double = 0.0
    var RiseHypotenuseRatio: Double = 0.0
    var Hypotenuse: Double = 0.0
    var XOffset: CGFloat = 0.0
    var YOffset: CGFloat = 0.0
    var InitialMotionPoint = CGPoint.zero
    
    @discardableResult public func Move(From: CGPoint, To: CGPoint, Duration: TimeInterval) -> Bool
    {
        assert(Duration > 0.0, "Duration must be greater than 0.0")
        if _AnimationRunning
        {
            print("Attempted to run animation when previous animation currently running.")
            return false
        }
        if Duration == 0.0
        {
            print("Duration must be greater than 0.0.")
            return false
        }
        //let Tag: Int = value(forKey: "Tag") as! Int
        //print("Moving \(Tag) from \(From) to \(To) in \(Duration) seconds.")
        InitialMotionPoint = From
        let (RunRatio, RiseRatio) = Geometry.CreateMotionRatios(Point1: From, Point2: To)
        RunHypotenuseRatio = RunRatio
        RiseHypotenuseRatio = RiseRatio
        Hypotenuse = Geometry.HypotenuseFor(Point1: From, Point2: To)
        
        CumulativeMotion = 0.0
        _MoveCompleted = false
        AnimationDuration = Duration
        XOffset = ContentsSize.width / 2.0
        YOffset = ContentsSize.height / 2.0
        
        MotionLink = CADisplayLink(target: self, selector: #selector(UpdateLocationHandler))
        MotionLink?.preferredFramesPerSecond = 60
        MotionLink?.add(to: .current, forMode: .default)
        _AnimationRunning = true
        UpdateLocation(Interval: 0)
        return true
    }
    
    private var _AnimationRunning: Bool = false
    
    private var _MoveCompleted: Bool = false
    public var MoveCompleted: Bool
    {
        get
        {
            return _MoveCompleted
        }
    }
    
    private var _ContentsSize: CGSize = CGSize.zero
    public var ContentsSize: CGSize
    {
        get
        {
            return _ContentsSize
        }
        set
        {
            _ContentsSize = newValue
        }
    }
    
    // MARK: Animate layer opacity.
    
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
    var StartingOpacity: Double = 0.0
    var EndingOpacity: Double = 0.0
    var OpacityDelta: Double = 0.0
    var OpacitySign: Double = 1.0
    
    @discardableResult public func AnimateAlpha(From: Double, To: Double, Duration: TimeInterval) -> Bool
    {
        if _AnimatingOpacity
        {
            return false
        }
        assert(Duration > 0.0, "Duration must be greater than 0.0")
        //print("AnimateAlpha(From: \(From), To: \(To), Duration: \(Duration)")
        StartingOpacity = From
        EndingOpacity = To
        OpacityDelta = abs(To - From)
        OpacitySign = To < From ? -1.0 : 1.0
        //print("Opacity delta: \(OpacityDelta), Opacity sign: \(OpacitySign)")
        CumulativeOpacity = 0.0
        OpacityAnimationDuration = Duration
        OpacityLink = CADisplayLink(target: self, selector: #selector(UpdateOpacityAnimation))
        OpacityLink.preferredFramesPerSecond = 60
        OpacityLink.add(to: .current, forMode: .default)
        _AnimatingOpacity = true
        UpdateOpacity(Interval: 0)
        return true
    }
    
    // MARK: Color animation.
    
    func ColorAnimationCompleted()
    {
        #if false
        print("Color animation completed.")
        #endif
    }
    
    func HandleNewColor(_ NewColor: UIColor)
    {
        let StringLiteral: String = Contents.string
        var LocalAttributes = CurrentAttributes
        LocalAttributes.removeValue(forKey: NSAttributedString.Key.foregroundColor)
        LocalAttributes[NSAttributedString.Key.foregroundColor] = NewColor
        Contents = NSMutableAttributedString(string: StringLiteral, attributes: LocalAttributes)
    }
    
    @discardableResult public func AnimateTextColor(From: UIColor, To: UIColor, Duration: TimeInterval) -> Bool
    {
        assert(Duration > 0.0, "Duration must be greater than 0.0.")
        let ColorAnimation = LinkAnimation()
        return ColorAnimation.StartHSBColorAnimation(From: From, To: To, Duration: Duration,
                                                     NewValueHandler: HandleNewColor,
                                                     CompletionHandler: ColorAnimationCompleted)
    }
    
    @discardableResult public func AnimateTextColor(StartDelay: TimeInterval, From: UIColor, To: UIColor, Duration: TimeInterval) -> Bool
    {
        assert(Duration > 0.0, "Duration must be greater than 0.0.")
        let ColorAnimation = LinkAnimation()
        ColorAnimation.StartHSBColorAnimation(StartDelay: StartDelay, From: From, To: To, Duration: Duration,
                                              NewValueHandler: HandleNewColor,
                                              CompletionHandler: ColorAnimationCompleted)
        return true
    }
    
    func ColorListAnimationCompleted()
    {
        if ColorList.isEmpty
        {
            print("Color list is empty")
            return
        }
        ColorListIndex = ColorListIndex + 1
        if ColorListIndex > ColorList.count - 1
        {
            if !ColorListIsContinuous
            {
                return
            }
            ColorListIndex = 0
        }
        let NewFirstColor = DestinationColorListColor
        let NewNextColor = ColorList[ColorListIndex]
        DestinationColorListColor = NewNextColor
        
        let _ = Timer.scheduledTimer(withTimeInterval: TerminalColorListDelay, repeats: false, block:
        {
            timer in
            timer.invalidate()
            let ColorAnimation = LinkAnimation()
            ColorAnimation.StartHSBColorAnimation(From: NewFirstColor, To: NewNextColor, Duration: self.ColorListDuration, NewValueHandler: self.HandleNewColor,
                                                  CompletionHandler: self.ColorListAnimationCompleted)
        })
    }
    
    private var ColorList = [UIColor]()
    private var ColorListIndex: Int = 0
    private var ColorListDuration: TimeInterval!
    private var ColorListIsContinuous: Bool = true
    private var DestinationColorListColor: UIColor = UIColor.clear
    private var TerminalColorListDelay: TimeInterval = 0
    
    @discardableResult public func AnimateTextColor(StartDelay: TimeInterval, EndDelay: TimeInterval = 0.0, From: UIColor, To: [UIColor],
                                                    Continuous: Bool = true, Duration: TimeInterval) -> Bool
    {
        assert(Duration > 0.0, "Duration must be greater than 0.0.")
        assert(!To.isEmpty, "No colors in color list.")
        ColorListIsContinuous = Continuous
        ColorList = To
        ColorListIndex = 0
        ColorListDuration = Duration
        TerminalColorListDelay = EndDelay
        DestinationColorListColor = To.first!
        let ColorAnimation = LinkAnimation()
        ColorAnimation.StartHSBColorAnimation(StartDelay: StartDelay, From: From, To: To.first!, Duration: Duration,
                                              NewValueHandler: HandleNewColor, CompletionHandler: ColorListAnimationCompleted)
        return true
    }
    
    // MARK: Rotation animation.
    
    func RotationCompleted()
    {
        if RepeatRotation
        {
            ZValue = RotationStart < RotationEnd ? -1.0 : 1.0
            let RotationAnimation = LinkAnimation()
            RotationAnimation.AnimateCGFloat(From: RotationStart, To: RotationEnd, Duration: RotationDuration,
                                             NewValueHandler: NewRotationalValue, CompletionHandler: RotationCompleted)
        }
    }
    
    func NewRotationalValue(_ NewValue: CGFloat)
    {
        let Radians = NewValue * CGFloat.pi / 180.0
        #if false
        self.transform = CATransform3DMakeAffineTransform(CGAffineTransform(rotationAngle: Radians))
        //        let Current = transform
        //        transform = CATransform3DRotate(Current, Radians, 0.0, 0.0, ZValue)
        #else
        self.transform = CATransform3DMakeRotation(Radians, 0.0, 0.0, ZValue)
        #endif
    }
    
    private var RepeatRotation: Bool = false
    private var RotationStart: CGFloat = 0.0
    private var RotationEnd: CGFloat = 0.0
    private var RotationDuration: TimeInterval = 1.0
    private var ZValue: CGFloat = 1.0
    
    @discardableResult public func RotationAnimationx(From: CGFloat, To: CGFloat, Repeats: Bool = false, Duration: TimeInterval) -> Bool
    {
        assert(Duration > 0.0, "Duration must be greater than 0.0.")
        RepeatRotation = Repeats
        RotationStart = From
        RotationEnd = To
        RotationDuration = Duration
        ZValue = To < From ? -1.0 : 1.0
        let RotationAnimation = LinkAnimation()
        return RotationAnimation.AnimateCGFloat(From: From, To: To, Duration: Duration, NewValueHandler: NewRotationalValue, CompletionHandler: RotationCompleted)
    }
    
    //https://stackoverflow.com/questions/27882016/wait-for-swift-animation-to-complete-before-executing-code
    public func RotationAnimation(From: CGFloat, To: CGFloat, Repeats: Bool = false, Duration: TimeInterval)
    {
        let anim = CABasicAnimation(keyPath: "transform.rotation")
        anim.fromValue = 0.0
        anim.toValue = To * CGFloat.pi / 180.0
        anim.duration = Duration
        anim.delegate = self
        anim.isRemovedOnCompletion = false
        bRepeatRotationInfinitely = Repeats
        anim.fillMode = CAMediaTimingFillMode.forwards
        bRotationEnd = To
        bRotationStart = From
        bRotationDuration = Duration
        AnimationFromRotation = true
        self.add(anim, forKey: nil)
    }
    
    private var bRepeatRotationInfinitely: Bool = false
    private var bRotationStart: CGFloat = 0.0
    private var bRotationEnd: CGFloat = 0.0
    private var bRotationDuration: TimeInterval = 1.0
    private var AnimationFromRotation: Bool = true
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool)
    {
        if !bRepeatRotationInfinitely
        {
            return
        }
        self.removeAllAnimations()
        let anim = CABasicAnimation(keyPath: "transform.rotation")
        anim.fromValue = bRotationStart
        anim.toValue = bRotationEnd * CGFloat.pi / 180.0
        anim.duration = bRotationDuration
        anim.delegate = self
        anim.isRemovedOnCompletion = false
        anim.fillMode = CAMediaTimingFillMode.forwards
        self.add(anim, forKey: nil)
    }
    
    // MARK: Motion animation.
    
    //https://stackoverflow.com/questions/44230796/what-is-the-full-keypath-list-for-cabasicanimation?rq=1
    public func MotionAnimation(From: CGPoint, To: CGPoint, Duration: TimeInterval, Easing: CAMediaTimingFunctionName = .easeIn)
    {
        let anim = CABasicAnimation(keyPath: "position")
        anim.fromValue = From
        anim.toValue = To
        anim.isRemovedOnCompletion = false
        anim.fillMode = CAMediaTimingFillMode.forwards
        anim.duration = Duration
        anim.timingFunction = CAMediaTimingFunction(name: Easing)
        self.add(anim, forKey: nil)
    }
    
    // MARK: Spiral animation.
    
    /// Execute spiral animation based on the parameters passed to us. The actual path used for spiral animation is pre-generated at start-up time.
    /// Additionally, opacity can be varied as well via animation by setting different values for OpacityStart and OpacityEnd.
    ///
    /// - Parameters:
    ///   - ToCenter: Determines whether to get the spiral path that hides or shows the text. Set to true to hide the text, false to show the text.
    ///   - From: Not currently used.
    ///   - Duration: Duration of the animation.
    ///   - ForHour: Determines which hour text is being animated.
    ///   - OpacityStart: Starting opacity level.
    ///   - OpacityEnd: Ending opacity level. If the OpacityStart level is the same as the OpacityEnd level, no opacity animation
    ///                 will take place.
    ///   - Outward: If true, a pre-generated spiral path that leads away from the circumference of the clock face is used. If false,
    ///              a pre-generated spiral path that leads to the center of the clock face will be used.
    ///   - HourOffset: Allows the usage of more than one spiral path if stored in the Geometry cache.
    private func DoSpiralAniamtion(ToCenter: Bool, From: CGPoint, Duration: TimeInterval, ForHour: Int, OpacityStart: Double, OpacityEnd: Double,
                                   Outward: Bool, HourOffset: Int = 0)
    {
        let KFA = CAKeyframeAnimation(keyPath: "position")
        KFA.isRemovedOnCompletion = false
        KFA.fillMode = CAMediaTimingFillMode.forwards
        KFA.rotationMode = CAAnimationRotationMode.rotateAuto
        let HourDirOffset = Outward ? 100 : 0
        let Points = Geometry.GetSpiral(For: ForHour + HourDirOffset + HourOffset, Reversed: !ToCenter)
        KFA.values = Points
        var KeyTimes = [NSNumber]()
        let PointCount: Int = (Points?.count)!
        if PointCount == 0
        {
            print("No points for hour \(ForHour) spiral. Animation aborted.")
            return
        }
        let Intervals = Duration / Double(PointCount - 1)
        for Index in 0 ..< PointCount
        {
            KeyTimes.append(NSNumber(value: Double(Index) * Intervals))
        }
        KFA.keyTimes = KeyTimes
        KFA.duration = Duration
        
        var oanim: CABasicAnimation? = nil
        if OpacityEnd != OpacityStart
        {
            oanim = CABasicAnimation(keyPath: "opacity")
            oanim!.fromValue = OpacityStart
            oanim!.toValue = OpacityEnd
            oanim!.isRemovedOnCompletion = false
            oanim!.fillMode = CAMediaTimingFillMode.forwards
            oanim!.duration = Duration * 0.85
        }
        
        if let oanim = oanim
        {
            let animg = CAAnimationGroup()
            animg.fillMode = CAMediaTimingFillMode.forwards
            animg.isRemovedOnCompletion = false
            animg.animations = [KFA, oanim]
            animg.duration = Duration
            self.add(animg, forKey: nil)
        }
        else
        {
            //No opacity delta so don't waste time doing nothing. We don't need the animation group either, so just add the
            //key frame opacity for the spiral.
            self.add(KFA, forKey: nil)
        }
    }
    
    /// Spiral the text into the center using a pre-defined (at start-up time) set of points that define the spiral. Opacity is also
    /// animated.
    ///
    /// - Parameters:
    ///   - From: Source point. Not currently used.
    ///   - Duration: Duration of the spiral animation.
    ///   - ForHour: Determines which spiral path to use - valid values are 1 through 12. Invalid values will result in a debug
    ///              message and no action (eg, no animation).
    ///   - OpacityStart: Starting opacity value.
    ///   - OpacityEnd: Ending opacity value.
    ///   - Outward: If true, the spiral is for "exterior" (radius +), not "interior" (radius -).
    public func SpiralAnimationIn(From: CGPoint, Duration: TimeInterval, ForHour: Int, OpacityStart: Double, OpacityEnd: Double, Outward: Bool = false, HourOffset: Int = 0)
    {
        DoSpiralAniamtion(ToCenter: true, From: From, Duration: Duration, ForHour: ForHour, OpacityStart: OpacityStart, OpacityEnd: OpacityEnd,
                          Outward: Outward, HourOffset: HourOffset)
    }
    
    /// Spiral the text away from the center using a pre-defined (at start-up time) set of points that define the spiral. Opacity is also
    /// animated.
    ///
    /// - Parameters:
    ///   - From: Source point. Not currently used.
    ///   - Duration: Duration of the spiral animation.
    ///   - ForHour: Determines which spiral path to use - valid values are 1 through 12. Invalid values will result in a debug
    ///              message and no action (eg, no animation).
    ///   - OpacityStart: Starting opacity value.
    ///   - OpacityEnd: Ending opacity value.
    ///   - Outward: If true, the spiral is for "exterior" (radius +), not "interior" (radius -).
    public func SpiralAnimationOut(From: CGPoint, Duration: TimeInterval, ForHour: Int, OpacityStart: Double, OpacityEnd: Double, Outward: Bool = false, HourOffset: Int = 0)
    {
        DoSpiralAniamtion(ToCenter: false, From: From, Duration: Duration, ForHour: ForHour, OpacityStart: OpacityStart, OpacityEnd: OpacityEnd,
                          Outward: Outward, HourOffset: HourOffset)
    }
    
    // MARK: Font size animation.
    
    /// Animate the font size and opacity.
    ///
    /// - Important: The font size is animated by using a basic animation on the transform.scale.xy key path, which leads to very fuzzy-looking
    ///              text with large variations from the original size.
    ///
    /// - Parameters:
    ///   - FromScale: Starting scale for the font. (Set to 1.0 to animate from the original font size.)
    ///   - ToScale: Ending scale for the font. This is the proportionate delta from the original size - for example, set to 1.5 to enlarge
    ///              the font from 10 to 15.
    ///   - StartingOpacity: Initial opacity of the text.
    ///   - EndingOpacity: Ending opacity of the text.
    ///   - Duration: Duration of the animation.
    public func AnimateFontSize(FromScale: CGFloat, ToScale: CGFloat, StartingOpacity: CGFloat = 1.0, EndingOpacity: CGFloat = 0.0, Duration: TimeInterval)
    {
        //let ToScale = To / From
        //print("Font size ToScale: \(ToScale)")
        let fsanim = CABasicAnimation(keyPath: "transform.scale.xy")
        fsanim.fromValue = FromScale
        fsanim.toValue = ToScale
        fsanim.isRemovedOnCompletion = false
        fsanim.fillMode = CAMediaTimingFillMode.forwards
        fsanim.duration = Duration
        
        let oanim = CABasicAnimation(keyPath: "opacity")
        oanim.fromValue = StartingOpacity
        oanim.toValue = EndingOpacity
        oanim.isRemovedOnCompletion = false
        oanim.fillMode = CAMediaTimingFillMode.forwards
        oanim.duration = Duration * 0.75
        
        let animg = CAAnimationGroup()
        animg.fillMode = CAMediaTimingFillMode.forwards
        animg.isRemovedOnCompletion = false
        animg.animations = [fsanim, oanim]
        animg.duration = Duration
        self.add(animg, forKey: nil)
    }
    
    /// Handles new font sizes from LinkAnimation classes. Font sizes and frames are updated here.
    ///
    /// - Parameter NewFontSize: New font size.
    public func NewFontSizeHandler(NewFontSize: CGFloat)
    {
        let StringLiteral: String = Contents.string
        var LocalAttributes = CurrentAttributes
        let OldFont: UIFont = LocalAttributes[NSAttributedString.Key.font] as! UIFont
        LocalAttributes.removeValue(forKey: NSAttributedString.Key.font)
        let NewFont = UIFont(name: OldFont.fontName, size: NewFontSize)
        LocalAttributes[NSAttributedString.Key.font] = NewFont
        let TextSize = Utility.StringSize(StringLiteral, NewFont!)
        self.frame = CGRect(x: HomeLocation.x - TextSize.width / 2, y: HomeLocation.y - TextSize.height / 2, width: TextSize.width, height: TextSize.height)
        Contents = NSMutableAttributedString(string: StringLiteral, attributes: LocalAttributes)
    }
    
    /// Not used - supplied for completeness' sake.
    public func FontAnimationCompleted()
    {
    }
    
    /// Animate the font size. Assumes the string whose font size will be animated is an NSMutableAttributed String
    ///
    /// - Parameters:
    ///   - From: Original size.
    ///   - To: Target size.
    ///   - StartingOpacity: Initial opacity.
    ///   - EndingOpacity: Ending opacity.
    ///   - Duration: Duration of the animation.
    public func AnimateFontSize2(From: CGFloat, To: CGFloat, StartingOpacity: CGFloat = 1.0, EndingOpacity: CGFloat = 0.0, Duration: TimeInterval)
    {
        let FontAnim = LinkAnimation()
        FontAnim.AnimateCGFloat(From: From, To: To, Duration: Duration, NewValueHandler: NewFontSizeHandler, CompletionHandler: FontAnimationCompleted)
        
        let oanim = CABasicAnimation(keyPath: "opacity")
        oanim.fromValue = StartingOpacity
        oanim.toValue = EndingOpacity
        oanim.isRemovedOnCompletion = false
        oanim.fillMode = CAMediaTimingFillMode.forwards
        oanim.duration = Duration * 0.75
        self.add(oanim, forKey: nil)
    }
    
    // MARK: Color animation.
    
    /// Animate the foreground color using CABasicAnimation.
    ///
    /// - Parameters:
    ///   - From: Source color.
    ///   - To: Destination color.
    ///   - Duration: Duration of the animation.
    public func ColorAnimation(From: UIColor, To: UIColor, Duration: TimeInterval)
    {
        let anim = CABasicAnimation(keyPath: "foregroundColor")
        anim.fromValue = From
        anim.toValue = To
        anim.isRemovedOnCompletion = false
        anim.fillMode = CAMediaTimingFillMode.forwards
        anim.duration = Duration
        self.add(anim, forKey: nil)
    }
    
    /// Timer used to change the foreground color on occassion. Set by external classes.
    @objc var TextColorTimer: Timer!
    
    /// Handle text color timer trigger events. Triggered when it's time to change the foreground color.
    ///
    /// - Parameter TheTimer: The timer that was triggered. It's assumed the timer has user info associated with it. The
    ///                       following keys are required: "ID" - used for debugging; "FirstColor" - initial color,
    ///                       "LastColor" - last color.
    @objc func TextTimerTriggered(TheTimer: Timer)
    {
        let UserInfo = TheTimer.userInfo as! Dictionary<String, Any>
        let First: UIColor = UserInfo["FirstColor"] as! UIColor
        let Last: UIColor = UserInfo["LastColor"] as! UIColor
        if TextColorStart == nil
        {
            TextColorStart = First
        }
        if TextColorEnd == nil
        {
            TextColorEnd = Last
        }
        AnimateTextColor(From: TextColorStart!, To: TextColorEnd!, Duration: 0.5)
        swap(&TextColorStart, &TextColorEnd)
    }
    
    private var TextColorStart: UIColor? = nil
    private var TextColorEnd: UIColor? = nil
    
    // MARK: Bezier path animation.
    
    /// Animate the text along a randomly-generated bezier path between the supplied start and end points.
    ///
    /// - Parameters:
    ///   - From: Starting point.
    ///   - To: Ending point. Usually (but not required to be) set to a point off screen.
    ///   - Frame: The frame where the animation take place.
    ///   - StartOpacity: Starting opacity value.
    ///   - EndOpacity: Ending opacity value.
    ///   - Hour: The hour being animated. Used for debugging purposes.
    ///   - Duration: Duration of the animation.
    public func AnimateBezierPath(From: CGPoint, To: CGPoint, Frame: CGRect, StartOpacity: CGFloat, EndOpacity: CGFloat, Hour: Int, Duration: TimeInterval)
    {
        let Path = UIBezierPath()
        Path.move(to: From)
        let CP1 = Geometry.RandomPoint(Width: Frame.width, Height: Frame.height)
        let CP2 = Geometry.RandomPoint(Width: Frame.width, Height: Frame.height)
        Path.addCurve(to: To, controlPoint1: CP1, controlPoint2: CP2)
        
        let banim = CAKeyframeAnimation(keyPath: "position")
        banim.timingFunctions = [CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)]
        banim.path = Path.cgPath
        banim.duration = Duration
        banim.fillMode = CAMediaTimingFillMode.forwards
        banim.isRemovedOnCompletion = false
        #if true
        self.add(banim, forKey: nil)
        
        #else
        let oanim = CABasicAnimation(keyPath: "opacity")
        oanim.fromValue = StartingOpacity
        oanim.toValue = EndingOpacity
        oanim.duration = Duration * 0.75
        
        let animg = CAAnimationGroup()
        animg.fillMode = CAMediaTimingFillMode.forwards
        animg.isRemovedOnCompletion = false
        animg.animations = [banim, oanim]
        animg.duration = Duration
        self.add(animg, forKey: nil)
        #endif
    }
    
    // MARK: Rotation again
    
    public func SpinInPlace(StartingOpacity: CGFloat, EndingOpacity: CGFloat, Duration: TimeInterval, SpinIncreasesWithTime: Bool)
    {
        //https://stackoverflow.com/questions/45892080/smoothly-speed-up-an-running-rotation-animation
        let ranim = CABasicAnimation(keyPath: "transform.rotation")
        ranim.fromValue = 359.0
        ranim.toValue = 0.0
        ranim.duration = Duration
        ranim.fillMode = CAMediaTimingFillMode.forwards
        ranim.isRemovedOnCompletion = false
        
        let oanim = CABasicAnimation(keyPath: "opacity")
        oanim.fromValue = StartingOpacity
        oanim.toValue = EndingOpacity
        oanim.duration = Duration * 0.8
        oanim.fillMode = CAMediaTimingFillMode.forwards
        oanim.isRemovedOnCompletion = false
        
        let animg = CAAnimationGroup()
        animg.fillMode = CAMediaTimingFillMode.forwards
        animg.isRemovedOnCompletion = false
        animg.animations = [ranim, oanim]
        animg.duration = Duration
        self.add(animg, forKey: nil)
    }
}
