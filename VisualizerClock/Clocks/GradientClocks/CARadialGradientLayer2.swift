//
//  CARadialGradientLayer2.swift
//  GradientTestBed
//
//  Created by Stuart Rankin on 10/10/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import CoreImage

/// Radial gradient layer to implement what iOS doesn't.
/// https://stackoverflow.com/questions/26907352/how-to-draw-radial-gradients-in-a-calayer
class CARadialGradientLayer2: CALayer
{
    let _Settings = UserDefaults.standard
    
    /// Init.
    ///
    /// - Parameter Gradients: List of gradients to display.
    init(ColorGradients: [RadialGradientDescriptor])
    {
        super.init()
        MakeEpoch()
        needsDisplayOnBoundsChange = true
        Gradients = ColorGradients
    }
    
    /// Init. Minimal initialization done.
    required override init ()
    {
        super.init()
        MakeEpoch()
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
    
    public func SetGeneralBackgroundColor(_ BGColor: UIColor)
    {
        for Gradient in Gradients
        {
            Gradient.SetGeneralBackgroundColor(BGColor)
        }
        GeneralBackgroundColor = BGColor
    }
    
    private var GeneralBackgroundColor: UIColor = UIColor.yellow
    
    private var _Gradients: [RadialGradientDescriptor] = [RadialGradientDescriptor]()
    public var Gradients: [RadialGradientDescriptor]
    {
        get
        {
            return _Gradients
        }
        set
        {
            _Gradients.removeAll()
            _Gradients = newValue
            for Gradient in _Gradients
            {
                Gradient.SetGeneralBackgroundColor(GeneralBackgroundColor)
            }
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
            for SomeGradient in Gradients
            {
                SomeGradient.ShowWork = _ShowWork
            }
            setNeedsDisplay()
        }
    }
    
    private var HourRotationalValues =
        [
            12: 180.0,
            1: 150.0,
            2: 120.0,
            3: 90.0,
            4: 60.0,
            5: 30.0,
            6: 0.0,
            7: -30.0,
            8: -60.0,
            9: -90.0,
            10: -120.0,
            11: -150.0
    ]
    
    /// Ways to animate the numbers disappearing.
    ///
    /// - Disappear: Disappear with no transition - alpha is set to 0.0 immediately.
    /// - FadeOut: Change alpha to 0.0 over a period of time.
    /// - LinearFromCenter: Move the text linearly (eg, straight line) from the center of the view to the home location.
    /// - SpiralToCenter: Spiral the text in to the center from the home position.
    /// - OutToLeft: Move the text off-screen to the left from the home position.
    /// - OutToRight: Move the text off-screen to the right from the home position.
    /// - OutToTop: Move the text off-screen to the top from the home position.
    /// - OutToBottom: Move the text off-screen to the bottom from the home position.
    /// - LinearToInfinity: Move the text off-screen radially away from the center.
    /// - ExpandToInfinity: Increase the font size from the base size to "infinity" (1000).
    /// - ToRandomOffScreen: Select a polar coordinate with a random angle and move the number there.
    /// - RandomBezierToOffScreen: Create a random bezier curve and follow it off the screen.
    /// - SpinHidden: Spin slow to fast from opacity 1 to opacity 0.
    public enum HideTextAnimations
    {
        case Disappear
        case FadeOut
        case LinearToCenter
        case SpiralToCenter
        case SpiralToInfinity
        case OutToLeft
        case OutToRight
        case OutToTop
        case OutToBottom
        case LinearToInfinity
        case ExpandToInfinity
        case ToRandomOffScreen
        case RandomBezierToOffScreen
        case SpinHidden
    }
    
    /// Ways to animate the numbers appearing.
    ///
    /// - Appear: Appear with no transition - alpha is set to 1.0 immediately.
    /// - FadeIn: Change alpha to 1.0 over a period of time.
    /// - LinearFromCenter: Move the text linearly (eg, straight line) from the center of the view to the home location.
    /// - SpiralFromCenter: Spiral the text to the home position from the center.
    /// - InFromLeft: Move the text in from the left-side of the view from off screen to the home position.
    /// - InFromRight: Move the text in from the right-side of the view from off screen to the home position.
    /// - InFromTop: Move the text in from the top-side of the view from off screen to the home position.
    /// - InFromBottom: Move the text in from the bottom-side of the view from off screen to the home position
    /// - LinearFromInifinity: Move the text to its home position radially from off-screen.
    /// - ContractFromInfinity: Reduce the font size from "infinity" (1000) to the text's base font size.
    /// - FromRandomOffScreen: Return from the randomly generate point off the screen to the text's home position.
    /// - RandomBezierFromOffScreen: Return from off screen to the home position following a random bezier path.
    /// - SpinVisible: Spin fast to slow from opacity 0 to opacity 1.
    public enum ShowTextAnimations
    {
        case Appear
        case FadeIn
        case LinearFromCenter
        case SpiralFromCenter
        case SpiralFromInfinity
        case InFromLeft
        case InFromRight
        case InFromTop
        case InFromBottom
        case LinearFromInfinity
        case ContractFromInfinity
        case FromRandomOffScreen
        case RandomBezierFromOffScreen
        case SpinVisible
    }
    
    public static let AnimationPairs: [(ShowTextAnimations, HideTextAnimations)] =
        [
            (.Appear, .Disappear),
            (.FadeIn, .FadeOut),
            (.LinearFromCenter, .LinearToCenter),
            (.SpiralFromCenter, .SpiralToCenter),
            (.SpiralFromInfinity, .SpiralToInfinity),
            (.InFromLeft, .OutToLeft),
            (.InFromRight, .OutToRight),
            (.InFromTop, .OutToTop),
            (.InFromBottom, .OutToBottom),
            (.LinearFromInfinity, .LinearToInfinity),
            (.ContractFromInfinity, .ExpandToInfinity),
            (.FromRandomOffScreen, .ToRandomOffScreen),
            (.RandomBezierFromOffScreen, .RandomBezierToOffScreen),
            (.SpinVisible, .SpinHidden)
    ]
    
    /// Descriptions of types of numeral animations available.
    public static let AnimationDescriptions: [(Int, String, String, ShowTextAnimations, HideTextAnimations, Bool)] =
        [
            (0, "No animation", "Numerals appear and disappear without transition.", .Appear, .Disappear, false),
            (1, "Fading", "Numerals fade in or out of view.", .FadeIn, .FadeOut, false),
            (2, "Move to center", "Numerals move to or from the center in a straight line.", .LinearFromCenter, .LinearToCenter, false),
            (4, "Spiral to center", "Numerals move to or from the center in a spiral.", .SpiralFromCenter, .SpiralToCenter, false),
            (5, "Spiral to infinity", "Numerals move to or from infinity in a spiral.", .SpiralFromInfinity, .SpiralToInfinity, false),
            (3, "Move to infinity", "Numerals move to or from infinity in a  stright line.", .LinearFromInfinity, .LinearToInfinity, false),
            (13, "Expand/Contract", "Numerals expand or contract to/from infinity.", .ContractFromInfinity, .ExpandToInfinity, false),
            (6, "Randomly to infinity", "Numerals move to or from infinity in random lines.", .FromRandomOffScreen, .ToRandomOffScreen, false),
            (7, "Curving to infinity", "Numerals move to or from infinity in random curved lines.", .RandomBezierFromOffScreen, .RandomBezierToOffScreen, false),
            (8, "Spinning", "Numerals spin and fade in or out.", .SpinVisible, .SpinHidden, false),
            (9, "Left", "Numerals move in from our out to the left.", .InFromLeft, .OutToLeft, false),
            (10, "Right", "Numerals move in from our out to the right.", .InFromRight, .OutToRight, false),
            (11, "Top", "Numerals move in from our out to the top.", .InFromTop, .OutToTop, false),
            (12, "Bottom", "Numerals move in from our out to the bottom.", .InFromBottom, .OutToBottom, false),
            ]
    
    /// Map between animation start delay indices and actual delay values.
    public static let AnimationDelays: [Int: Double] =
        [
            0: 0.0,
            1: 0.8,
            2: 0.55,
            3: 0.15,
            4: 0.05
    ]
    
    /// Hide clock numerals via some type of animation.
    ///
    /// - Parameters:
    ///   - NumeralLayer: The layer with the numeral to animate.
    ///   - Hour: The house of the layer.
    ///   - Duration: Duration of the animation.
    ///   - AnimationType: Describes the animation used to hide the numeral.
    ///   - Delay: How long to delay before starting the initial animation.
    ///   - Frame: The frame rectangle of the surface.
    ///   - Center: The center point.
    ///   - Width: The width of the surface.
    ///   - Height: The height of the surface.
    ///   - HourOffset: Index offset to get spiral information.
    public static func DoHideClockNumerals(NumeralLayer: CATextLayer2, Hour: Int, Duration: TimeInterval,
                                           AnimationType: HideTextAnimations, Delay: TimeInterval,
                                           Frame: CGRect, Center: CGPoint, Width: CGFloat, Height: CGFloat,
                                           HourOffset: Int = 0)
    {
        let HalfX = Frame.width / 2.0
        let HalfY = Frame.height / 2.0
        let _ = Timer.scheduledTimer(withTimeInterval: Delay, repeats: false, block: {
            timer in
            switch AnimationType
            {
            case .Disappear:
                NumeralLayer.opacity = 0.0
                
            case .FadeOut:
                NumeralLayer.AnimateAlpha(From: 1.0, To: 0.0, Duration: Duration)
                
            case .LinearToCenter:
                NumeralLayer.MotionAnimation(From: NumeralLayer.HomeLocation, To: /*CGPoint(x: HalfX, y: HalfY)*/Center, Duration: Duration)
                NumeralLayer.AnimateAlpha(From: 1.0, To: 0.0, Duration: Duration * 0.85)
                
            case .SpiralToCenter:
                NumeralLayer.SpiralAnimationIn(From: NumeralLayer.HomeLocation, Duration: Duration, ForHour: Hour, OpacityStart: 1.0, OpacityEnd: 0.0, HourOffset: HourOffset)
                
            case .OutToLeft:
                let LeftLocation = CGPoint(x: NumeralLayer.HomeLocation.x - Width, y: NumeralLayer.HomeLocation.y)
                NumeralLayer.MotionAnimation(From: LeftLocation, To: NumeralLayer.HomeLocation, Duration: Duration)
                
            case .OutToRight:
                let RightLocation = CGPoint(x: NumeralLayer.HomeLocation.x + Width, y: NumeralLayer.HomeLocation.y)
                NumeralLayer.MotionAnimation(From: RightLocation, To: NumeralLayer.HomeLocation, Duration: Duration)
                
            case .OutToTop:
                let TopLocation = CGPoint(x: NumeralLayer.HomeLocation.x, y: NumeralLayer.HomeLocation.y - Height)
                NumeralLayer.MotionAnimation(From: TopLocation, To: NumeralLayer.HomeLocation, Duration: Duration)
                
            case .OutToBottom:
                let BottomLocation = CGPoint(x: NumeralLayer.HomeLocation.x, y: NumeralLayer.HomeLocation.y + Height)
                NumeralLayer.MotionAnimation(From: BottomLocation, To: NumeralLayer.HomeLocation, Duration: Duration)
                
            case .LinearToInfinity:
                let Angle = (CGFloat(Hour) / 12.0) * 360.0
                var BaseDistance = Geometry.Distance(From: NumeralLayer.HomeLocation, To: Center)
                BaseDistance = BaseDistance + max(HalfX, HalfY)
                let FinalPoint = Geometry.PolarToCartesian(r: Double(BaseDistance), theta: Double(Angle), Center: Center)
                NumeralLayer.MotionAnimation(From: NumeralLayer.HomeLocation, To: FinalPoint, Duration: Duration)
                
            case .ExpandToInfinity:
                NumeralLayer.AnimateFontSize2(From: NumeralLayer.BaseFontSize, To: 150.0, StartingOpacity: 1.0, EndingOpacity: 0.0, Duration: Duration)
                
            case .ToRandomOffScreen:
                NumeralLayer.LastRandomAngle = CGFloat.random(in: 0.0 ... 359.0)
                let Distance: CGFloat = max(HalfY * 2.0, HalfX * 2.0)
                let RandomPoint = Geometry.PolarToCartesian(r: Double(Distance), theta: Double(NumeralLayer.LastRandomAngle), Center: Center)
                NumeralLayer.HidingPoint = RandomPoint
                NumeralLayer.Move(From: NumeralLayer.HomeLocation, To: NumeralLayer.HidingPoint, Duration: Duration)
                
            case .SpiralToInfinity:
                NumeralLayer.SpiralAnimationIn(From: NumeralLayer.HomeLocation, Duration: Duration, ForHour: Hour, OpacityStart: 1.0, OpacityEnd: 0.0, Outward: true, HourOffset: HourOffset)
                
            case .RandomBezierToOffScreen:
                let OffScreen = Geometry.RandomOffscreenPoint(VisibleFrame: Frame)
                NumeralLayer.AnimateBezierPath(From: NumeralLayer.HomeLocation, To: OffScreen, Frame: Frame, StartOpacity: 1.0, EndOpacity: 0.0, Hour: Hour, Duration: Duration)
                
            case .SpinHidden:
                NumeralLayer.SpinInPlace(StartingOpacity: 1.0, EndingOpacity: 0.0, Duration: Duration, SpinIncreasesWithTime: true)
                
            default:
                print("Found unexpected animation: \(AnimationType)")
                NumeralLayer.opacity = 1.0
            }
        })
    }
    
    /// Hide the numerals of the clock.
    ///
    /// - Parameters:
    ///   - Duration: Duration of the animation for each numeral. In general, unless a delay is specified, all animations
    ///               take place simultaneously.
    ///   - AnimationType: The type of animation used to hide the numbers.
    ///   - Delay: Delay before the start of each numeral animation. Regardless of the value of the delay, animation starts immediately.
    public static func HideClockNumerals(ClockFaceLayer: CATextLayer, Duration: TimeInterval = 0.75, AnimationType: HideTextAnimations = .SpiralToCenter, Delay: TimeInterval = 0.05,
                                         Frame: CGRect, Center: CGPoint, Width: CGFloat, Height: CGFloat, HourOffset: Int = 0)
    {
        for Layer in (ClockFaceLayer.sublayers)!
        {
            let GLayer = Layer as! CATextLayer2
            let Tag = GLayer.value(forKey: "Tag") as! Int
            let Base = Tag != 12 ? Tag : 0
            let NumeralDelay: Double = Double(Base) * Delay
            DoHideClockNumerals(NumeralLayer: GLayer, Hour: Tag, Duration: Duration, AnimationType: AnimationType, Delay: NumeralDelay,
                                Frame: Frame, Center: Center, Width: Width, Height: Height, HourOffset: HourOffset)
        }
    }
    
    /// Hide clock numerals via some type of animation.
    ///
    /// - Parameters:
    ///   - NumeralLayer: The layer with the numeral to animate.
    ///   - Hour: The house of the layer.
    ///   - Duration: Duration of the animation.
    ///   - AnimationType: Describes the animation used to hide the numeral.
    ///   - Delay: How long to delay before starting the initial animation.
    private func DoHideClockNumerals(NumeralLayer: CATextLayer2, Hour: Int, Duration: TimeInterval,
                                     AnimationType: HideTextAnimations, Delay: TimeInterval)
    {
        let _ = Timer.scheduledTimer(withTimeInterval: Delay, repeats: false, block: {
            timer in
            switch AnimationType
            {
            case .Disappear:
                NumeralLayer.opacity = 0.0
                
            case .FadeOut:
                NumeralLayer.AnimateAlpha(From: 1.0, To: 0.0, Duration: Duration)
                
            case .LinearToCenter:
                /*
                 var Hypotenuse = sqrt((self.frame.width * self.frame.width) + (self.frame.height * self.frame.height))
                 Hypotenuse = Hypotenuse + 20.0
                 Hypotenuse = Hypotenuse / UIScreen.main.scale
                 let Angle = (CGFloat(Hour) / 12.0) * 360.0
                 let Radian = (Angle - 90.0) * CGFloat.pi / 180.0
                 let X = self.HalfX
                 let Y = self.HalfY
                 */
                NumeralLayer.MotionAnimation(From: NumeralLayer.HomeLocation, To: CGPoint(x: self.HalfX, y: self.HalfY), Duration: Duration)
                NumeralLayer.AnimateAlpha(From: 1.0, To: 0.0, Duration: Duration * 0.85)
                
            case .SpiralToCenter:
                NumeralLayer.SpiralAnimationIn(From: NumeralLayer.HomeLocation, Duration: Duration, ForHour: Hour, OpacityStart: 1.0, OpacityEnd: 0.0)
                
            case .OutToLeft:
                let LeftLocation = CGPoint(x: NumeralLayer.HomeLocation.x - self.frame.width, y: NumeralLayer.HomeLocation.y)
                NumeralLayer.MotionAnimation(From: LeftLocation, To: NumeralLayer.HomeLocation, Duration: Duration)
                
            case .OutToRight:
                let RightLocation = CGPoint(x: NumeralLayer.HomeLocation.x + self.frame.width, y: NumeralLayer.HomeLocation.y)
                NumeralLayer.MotionAnimation(From: RightLocation, To: NumeralLayer.HomeLocation, Duration: Duration)
                
            case .OutToTop:
                let TopLocation = CGPoint(x: NumeralLayer.HomeLocation.x, y: NumeralLayer.HomeLocation.y - self.frame.height)
                NumeralLayer.MotionAnimation(From: TopLocation, To: NumeralLayer.HomeLocation, Duration: Duration)
                
            case .OutToBottom:
                let BottomLocation = CGPoint(x: NumeralLayer.HomeLocation.x, y: NumeralLayer.HomeLocation.y + self.frame.height)
                NumeralLayer.MotionAnimation(From: BottomLocation, To: NumeralLayer.HomeLocation, Duration: Duration)
                
            case .LinearToInfinity:
                let Angle = (CGFloat(Hour) / 12.0) * 360.0
                var BaseDistance = Geometry.Distance(From: NumeralLayer.HomeLocation, To: self.Center)
                BaseDistance = BaseDistance + max(self.HalfX, self.HalfY)
                let FinalPoint = Geometry.PolarToCartesian(r: Double(BaseDistance), theta: Double(Angle), Center: self.Center)
                NumeralLayer.MotionAnimation(From: NumeralLayer.HomeLocation, To: FinalPoint, Duration: Duration)
                
            case .ExpandToInfinity:
                NumeralLayer.AnimateFontSize2(From: NumeralLayer.BaseFontSize, To: 150.0, StartingOpacity: 1.0, EndingOpacity: 0.0, Duration: Duration)
                
            case .ToRandomOffScreen:
                NumeralLayer.LastRandomAngle = CGFloat.random(in: 0.0 ... 359.0)
                let Distance: CGFloat = max(self.HalfY * 2.0, self.HalfX * 2.0)
                let RandomPoint = Geometry.PolarToCartesian(r: Double(Distance), theta: Double(NumeralLayer.LastRandomAngle), Center: self.Center)
                NumeralLayer.HidingPoint = RandomPoint
                NumeralLayer.Move(From: NumeralLayer.HomeLocation, To: NumeralLayer.HidingPoint, Duration: Duration)
                
            case .SpiralToInfinity:
                NumeralLayer.SpiralAnimationIn(From: NumeralLayer.HomeLocation, Duration: Duration, ForHour: Hour, OpacityStart: 1.0, OpacityEnd: 0.0, Outward: true)
                
            case .RandomBezierToOffScreen:
                let OffScreen = Geometry.RandomOffscreenPoint(VisibleFrame: self.frame)
                NumeralLayer.AnimateBezierPath(From: NumeralLayer.HomeLocation, To: OffScreen, Frame: self.frame, StartOpacity: 1.0, EndOpacity: 0.0, Hour: Hour, Duration: Duration)
                
            case .SpinHidden:
                NumeralLayer.SpinInPlace(StartingOpacity: 1.0, EndingOpacity: 0.0, Duration: Duration, SpinIncreasesWithTime: true)
                
            default:
                print("Found unexpected animation: \(AnimationType)")
                NumeralLayer.opacity = 1.0
            }
        })
    }
    
    /// Hide the numerals of the clock.
    ///
    /// - Parameters:
    ///   - Duration: Duration of the animation for each numeral. In general, unless a delay is specified, all animations
    ///               take place simultaneously.
    ///   - AnimationType: The type of animation used to hide the numbers.
    ///   - Delay: Delay before the start of each numeral animation. Regardless of the value of the delay, animation starts immediately.
    public func HideClockNumerals(Duration: TimeInterval = 0.75, AnimationType: HideTextAnimations = .SpiralToCenter, Delay: TimeInterval = 0.05)
    {
        //print("HideClockNumerals:(\(AnimationType))")
        for Layer in (ClockFaceLayer?.sublayers)!
        {
            let GLayer = Layer as! CATextLayer2
            let Tag = GLayer.value(forKey: "Tag") as! Int
            let Base = Tag != 12 ? Tag : 0
            let NumeralDelay: Double = Double(Base) * Delay
            DoHideClockNumerals(NumeralLayer: GLayer, Hour: Tag, Duration: Duration, AnimationType: AnimationType, Delay: NumeralDelay)
        }
    }
    
    /// Animate the hiding the clock face numerals.
    ///
    /// - Parameters:
    ///   - Delay: Delay between hiding animations. First animation takes place immediately.
    ///   - Animations: List of animations for each individual hour value along with the duration of the animation for the given hour.
    public func HideClockNumerals(Delay: TimeInterval = 0.05, Animations: [Int: (HideTextAnimations, TimeInterval)])
    {
        for Layer in (ClockFaceLayer?.sublayers)!
        {
            let GLayer = Layer as! CATextLayer2
            let Hour = GLayer.value(forKey: "Tag") as! Int
            if Animations[Hour] == nil
            {
                continue
            }
            let AdjustedHour = Hour == 12 ? 0 : Hour
            let NumeralDelay: Double = Double(AdjustedHour) * Delay
            DoHideClockNumerals(NumeralLayer: GLayer, Hour: Hour, Duration: Animations[Hour]!.1, AnimationType: Animations[Hour]!.0, Delay: NumeralDelay)
        }
    }
    
    /// Animate the hiding the clock face numerals.
    ///
    /// - Parameters:
    ///   - Duration: Duration of each hiding animation.
    ///   - Delay: Delay between hiding animations. First animation takes place immediately.
    ///   - Animations: List of animations for each individual hour value.
    public func HideClockNumerals(Duration: TimeInterval = 0.75, Delay: TimeInterval = 0.05, Animations: [Int: HideTextAnimations])
    {
        //print("Hiding clock numerals")
        for Layer in (ClockFaceLayer?.sublayers)!
        {
            let GLayer = Layer as! CATextLayer2
            let Hour = GLayer.value(forKey: "Tag") as! Int
            if Animations[Hour] == nil
            {
                continue
            }
            let AdjustedHour = Hour == 12 ? 0 : Hour
            let NumeralDelay: Double = Double(AdjustedHour) * Delay
            DoHideClockNumerals(NumeralLayer: GLayer, Hour: Hour, Duration: Duration, AnimationType: Animations[Hour]!, Delay: NumeralDelay)
        }
    }
    
    /// Show clock numerals via some type of animation.
    ///
    /// - Parameters:
    ///   - NumeralLayer: The layer with the numeral to animate.
    ///   - Hour: The house of the layer.
    ///   - Duration: Duration of the animation.
    ///   - AnimationType: Describes the animation used to hide the numeral.
    ///   - Delay: How long to delay before starting the initial animation.
    ///   - Frame: The frame rectangle of the surface.
    ///   - Center: The center point.
    ///   - Width: The width of the surface.
    ///   - Height: The height of the surface.
    ///   - HourOffset: Index offset to get spiral information.
    public static func DoShowClockNumerals(NumeralLayer: CATextLayer2, Hour: Int, Duration: TimeInterval,
                                           AnimationType: ShowTextAnimations, Delay: TimeInterval,
                                           Frame: CGRect, Center: CGPoint, Width: CGFloat, Height: CGFloat,
                                           HourOffset: Int = 0)
    {
        let HalfX = Frame.width / 2.0
        let HalfY = Frame.height / 2.0
        let _ = Timer.scheduledTimer(withTimeInterval: Delay, repeats: false, block: {
            timer in
            switch AnimationType
            {
            case .Appear:
                NumeralLayer.opacity = 1.0
                
            case .FadeIn:
                NumeralLayer.AnimateAlpha(From: 0.0, To: 1.0, Duration: Duration)
                
            case .LinearFromCenter:
                NumeralLayer.MotionAnimation(From: /*CGPoint(x: HalfX, y: HalfY)*/Center, To: NumeralLayer.HomeLocation, Duration: Duration, Easing: .easeOut)
                NumeralLayer.AnimateAlpha(From: 0.0, To: 1.0, Duration: Duration * 0.85)
                
            case .SpiralFromCenter:
                NumeralLayer.SpiralAnimationOut(From: NumeralLayer.HomeLocation, Duration: Duration, ForHour: Hour, OpacityStart: 0.0, OpacityEnd: 1.0, HourOffset: HourOffset)
                
            case .InFromLeft:
                let LeftLocation = CGPoint(x: NumeralLayer.HomeLocation.x - Width, y: NumeralLayer.HomeLocation.y)
                NumeralLayer.MotionAnimation(From: NumeralLayer.HomeLocation, To: LeftLocation, Duration: Duration)
                
            case .InFromRight:
                let RightLocation = CGPoint(x: NumeralLayer.HomeLocation.x + Width, y: NumeralLayer.HomeLocation.y)
                NumeralLayer.MotionAnimation(From: NumeralLayer.HomeLocation, To: RightLocation, Duration: Duration)
                
            case .InFromTop:
                let TopLocation = CGPoint(x: NumeralLayer.HomeLocation.x, y: NumeralLayer.HomeLocation.y - Height)
                NumeralLayer.MotionAnimation(From: NumeralLayer.HomeLocation, To: TopLocation, Duration: Duration)
                
            case .InFromBottom:
                let BottomLocation = CGPoint(x: NumeralLayer.HomeLocation.x, y: NumeralLayer.HomeLocation.y + Height)
                NumeralLayer.MotionAnimation(From: NumeralLayer.HomeLocation, To: BottomLocation, Duration: Duration)
                
            case .LinearFromInfinity:
                let Angle = (CGFloat(Hour) / 12.0) * 360.0
                var BaseDistance = Geometry.Distance(From: NumeralLayer.HomeLocation, To: Center)
                BaseDistance = BaseDistance + max(HalfX, HalfY)
                let FinalPoint = Geometry.PolarToCartesian(r: Double(BaseDistance), theta: Double(Angle), Center: Center)
                NumeralLayer.MotionAnimation(From: FinalPoint, To: NumeralLayer.HomeLocation, Duration: Duration)
                
            case .ContractFromInfinity:
                NumeralLayer.AnimateFontSize2(From: 150.0, To: NumeralLayer.BaseFontSize, StartingOpacity: 0.0, EndingOpacity: 1.0, Duration: Duration)
                
            case .FromRandomOffScreen:
                NumeralLayer.Move(From: NumeralLayer.HidingPoint, To: NumeralLayer.HomeLocation, Duration: Duration)
                
            case .SpiralFromInfinity:
                NumeralLayer.SpiralAnimationOut(From: NumeralLayer.HomeLocation, Duration: Duration, ForHour: Hour, OpacityStart: 0.0, OpacityEnd: 1.0, Outward: true, HourOffset: HourOffset)
                
            case .RandomBezierFromOffScreen:
                let OffScreen = Geometry.RandomOffscreenPoint(VisibleFrame: Frame)
                NumeralLayer.AnimateBezierPath(From: OffScreen, To: NumeralLayer.HomeLocation, Frame: Frame, StartOpacity: 0.0, EndOpacity: 1.0, Hour: Hour, Duration: Duration)
                
            case .SpinVisible:
                NumeralLayer.SpinInPlace(StartingOpacity: 0.0, EndingOpacity: 1.0, Duration: Duration, SpinIncreasesWithTime: false)
                
            default:
                print("Found unexpected animation: \(AnimationType)")
                NumeralLayer.opacity = 0.0
            }
        })
    }
    
    /// Show the numerals of the clock.
    ///
    /// - Parameters:
    ///   - Duration: Duration of the animation for each numeral. In general, unless a delay is specified, all animations
    ///               take place simultaneously.
    ///   - AnimationType: The type of animation used to hide the numbers.
    ///   - Delay: Delay before the start of each numeral animation. Regardless of the value of the delay, animation starts immediately.
    public static func ShowClockNumerals(ClockFaceLayer: CATextLayer, Duration: TimeInterval = 0.75, AnimationType: ShowTextAnimations = .SpiralFromCenter, Delay: TimeInterval = 0.05,
                                         Frame: CGRect, Center: CGPoint, Width: CGFloat, Height: CGFloat, HourOffset: Int = 0)
    {
        for Layer in (ClockFaceLayer.sublayers)!
        {
            let GLayer = Layer as! CATextLayer2
            let Tag = GLayer.value(forKey: "Tag") as! Int
            let Base = Tag != 12 ? Tag : 0
            let NumeralDelay: Double = Double(Base) * Delay
            DoShowClockNumerals(NumeralLayer: GLayer, Hour: Tag, Duration: Duration, AnimationType: AnimationType, Delay: NumeralDelay,
                                Frame: Frame, Center: Center, Width: Width, Height: Height, HourOffset: HourOffset)
        }
    }
    
    /// Show clock numerals via some type of animation.
    ///
    /// - Parameters:
    ///   - NumeralLayer: The layer with the numeral to animate.
    ///   - Hour: The house of the layer.
    ///   - Duration: Duration of the animation.
    ///   - AnimationType: Describes the animation used to show the numeral.
    ///   - Delay: How long to delay before starting the initial animation.
    private func DoShowClockNumerals(NumeralLayer: CATextLayer2, Hour: Int, Duration: TimeInterval,
                                     AnimationType: ShowTextAnimations, Delay: TimeInterval)
    {
        let _ = Timer.scheduledTimer(withTimeInterval: Delay, repeats: false, block: {
            timer in
            switch AnimationType
            {
            case .Appear:
                NumeralLayer.opacity = 1.0
                
            case .FadeIn:
                NumeralLayer.AnimateAlpha(From: 0.0, To: 1.0, Duration: Duration)
                
            case .LinearFromCenter:
                NumeralLayer.MotionAnimation(From: CGPoint(x: self.HalfX, y: self.HalfY), To: NumeralLayer.HomeLocation, Duration: Duration, Easing: .easeOut)
                NumeralLayer.AnimateAlpha(From: 0.0, To: 1.0, Duration: Duration * 0.85)
                
            case .SpiralFromCenter:
                NumeralLayer.SpiralAnimationOut(From: NumeralLayer.HomeLocation, Duration: Duration, ForHour: Hour, OpacityStart: 0.0, OpacityEnd: 1.0)
                
            case .InFromLeft:
                let LeftLocation = CGPoint(x: NumeralLayer.HomeLocation.x - self.frame.width, y: NumeralLayer.HomeLocation.y)
                NumeralLayer.MotionAnimation(From: NumeralLayer.HomeLocation, To: LeftLocation, Duration: Duration)
                
            case .InFromRight:
                let RightLocation = CGPoint(x: NumeralLayer.HomeLocation.x + self.frame.width, y: NumeralLayer.HomeLocation.y)
                NumeralLayer.MotionAnimation(From: NumeralLayer.HomeLocation, To: RightLocation, Duration: Duration)
                
            case .InFromTop:
                let TopLocation = CGPoint(x: NumeralLayer.HomeLocation.x, y: NumeralLayer.HomeLocation.y - self.frame.height)
                NumeralLayer.MotionAnimation(From: NumeralLayer.HomeLocation, To: TopLocation, Duration: Duration)
                
            case .InFromBottom:
                let BottomLocation = CGPoint(x: NumeralLayer.HomeLocation.x, y: NumeralLayer.HomeLocation.y + self.frame.height)
                NumeralLayer.MotionAnimation(From: NumeralLayer.HomeLocation, To: BottomLocation, Duration: Duration)
                
            case .LinearFromInfinity:
                let Angle = (CGFloat(Hour) / 12.0) * 360.0
                var BaseDistance = Geometry.Distance(From: NumeralLayer.HomeLocation, To: self.Center)
                BaseDistance = BaseDistance + max(self.HalfX, self.HalfY)
                let FinalPoint = Geometry.PolarToCartesian(r: Double(BaseDistance), theta: Double(Angle), Center: self.Center)
                NumeralLayer.MotionAnimation(From: FinalPoint, To: NumeralLayer.HomeLocation, Duration: Duration)
                
            case .ContractFromInfinity:
                NumeralLayer.AnimateFontSize2(From: 150.0, To: NumeralLayer.BaseFontSize, StartingOpacity: 0.0, EndingOpacity: 1.0, Duration: Duration)
                
            case .FromRandomOffScreen:
                NumeralLayer.Move(From: NumeralLayer.HidingPoint, To: NumeralLayer.HomeLocation, Duration: Duration)
                
            case .SpiralFromInfinity:
                NumeralLayer.SpiralAnimationOut(From: NumeralLayer.HomeLocation, Duration: Duration, ForHour: Hour, OpacityStart: 0.0, OpacityEnd: 1.0, Outward: true)
                
            case .RandomBezierFromOffScreen:
                let OffScreen = Geometry.RandomOffscreenPoint(VisibleFrame: self.frame)
                NumeralLayer.AnimateBezierPath(From: OffScreen, To: NumeralLayer.HomeLocation, Frame: self.frame, StartOpacity: 0.0, EndOpacity: 1.0, Hour: Hour, Duration: Duration)
                
            case .SpinVisible:
                NumeralLayer.SpinInPlace(StartingOpacity: 0.0, EndingOpacity: 1.0, Duration: Duration, SpinIncreasesWithTime: false)
                
            default:
                print("Found unexpected animation: \(AnimationType)")
                NumeralLayer.opacity = 0.0
            }
        })
    }
    
    /// Show the numerals of the clock.
    ///
    /// - Parameters:
    ///   - Duration: Duration of the animation for each numeral. In general, unless a delay is specified, all animations
    ///               take place simultaneously.
    ///   - AnimationType: The type of animation used to show the numbers.
    ///   - Delay: Delay before the start of each numeral animation.
    public func ShowClockNumerals(Duration: TimeInterval = 0.75, AnimationType: ShowTextAnimations = .SpiralFromCenter, Delay: TimeInterval = 0.05)
    {
        //        print("ShowClockNumerals:(\(AnimationType))")
        for Layer in (ClockFaceLayer?.sublayers)!
        {
            let GLayer = Layer as! CATextLayer2
            let Tag = GLayer.value(forKey: "Tag") as! Int
            let Base = Tag != 12 ? Tag : 0
            let NumeralDelay: Double = Double(Base) * Delay
            DoShowClockNumerals(NumeralLayer: GLayer, Hour: Tag, Duration: Duration, AnimationType: AnimationType, Delay: NumeralDelay)
        }
    }
    
    /// Animate the showing the clock face numerals.
    ///
    /// - Parameters:
    ///   - Delay: Delay between showing animations. First animation takes place immediately.
    ///   - Animations: List of animations for each individual hour value along with the duration of the animation for the given hour.
    public func ShowClockNumerals(Delay: TimeInterval = 0.05, Animations: [Int: (ShowTextAnimations, TimeInterval)])
    {
        for Layer in (ClockFaceLayer?.sublayers)!
        {
            let GLayer = Layer as! CATextLayer2
            let Hour = GLayer.value(forKey: "Tag") as! Int
            if Animations[Hour] == nil
            {
                continue
            }
            let AdjustedHour = Hour == 12 ? 0 : Hour
            let NumeralDelay: Double = Double(AdjustedHour) * Delay
            DoShowClockNumerals(NumeralLayer: GLayer, Hour: Hour, Duration: Animations[Hour]!.1, AnimationType: Animations[Hour]!.0, Delay: NumeralDelay)
        }
    }
    
    /// Animate the showing the clock face numerals.
    ///
    /// - Parameters:
    ///   - Duration: Duration of each showing animation.
    ///   - Delay: Delay between showing animations. First animation takes place immediately.
    ///   - Animations: List of animations for each individual hour value.
    public func ShowClockNumerals(Duration: TimeInterval = 0.75, Delay: TimeInterval = 0.05, Animations: [Int: ShowTextAnimations])
    {
        //print("Showing clock numerals")
        for Layer in (ClockFaceLayer?.sublayers)!
        {
            let GLayer = Layer as! CATextLayer2
            let Hour = GLayer.value(forKey: "Tag") as! Int
            if Animations[Hour] == nil
            {
                continue
            }
            let AdjustedHour = Hour == 12 ? 0 : Hour
            let NumeralDelay: Double = Double(AdjustedHour) * Delay
            DoShowClockNumerals(NumeralLayer: GLayer, Hour: Hour, Duration: Duration, AnimationType: Animations[Hour]!, Delay: NumeralDelay)
        }
    }
    
    var AnimatingNumerals: Bool = false
    
    var HiddenCount: Int = 0
    
    public func ToggleClockNumerals()
    {
        if IsShowingClockFace
        {
            IsShowingClockFace = false
            HideClockNumerals()
        }
        else
        {
            IsShowingClockFace = true
            ShowClockNumerals()
        }
    }
    
    public func ToggleClockNumerals(HideAnimation: HideTextAnimations, ShowAnimation: ShowTextAnimations, Duration: TimeInterval,
                                    Delay: TimeInterval)
    {
        if IsShowingClockFace
        {
            IsShowingClockFace = false
            HideClockNumerals(Duration: Duration, AnimationType: HideAnimation, Delay: Delay)
        }
        else
        {
            IsShowingClockFace = true
            ShowClockNumerals(Duration: Duration, AnimationType: ShowAnimation, Delay: Delay)
        }
    }
    
    private var _IsShowingClockFace: Bool = true
    public var IsShowingClockFace: Bool
    {
        get
        {
            return _IsShowingClockFace
        }
        set
        {
            _IsShowingClockFace = newValue
        }
    }
    
    var OldGradients = [RadialGradientDescriptor]()
    private func SaveOldGradients()
    {
        OldGradients.removeAll()
        sublayers?.forEach{$0.removeFromSuperlayer()}
        for SomeGradient in Gradients
        {
            OldGradients.append(SomeGradient)
        }
    }
    
    private func MakeClockGradients()
    {
        let IsOnIPad = UIDevice.current.userInterfaceIdiom == .pad
        HalfX = frame.width / 2.0
        HalfY = frame.height / 2.0
        Center = CGPoint(x: HalfX, y: HalfY)
        
        MakeClockFace(OrdinalHoursOnly: false)
        var IsFunnelShapped = false
        var IsLozengeShaped = false
        var CenterGradientInCenter = false
        switch _Settings.integer(forKey: Setting.Key.RadialGradient.HandShape)
        {
        case 0:
            fallthrough
        case 3:
            break
            
        case 1:
            CenterGradientInCenter = true
            IsLozengeShaped = true
            
        case 2:
            CenterGradientInCenter = true
            IsFunnelShapped = true
            
        default:
            break
        }
        
        let MaxVisible = min(HalfX,HalfY)
        
        if _Settings.bool(forKey: Setting.Key.RadialGradient.ShowSeconds)
        {
            SecondRadial = IsOnIPad ? MaxVisible - 30.0 : MaxVisible - 30.0
            let SecondRadius: CGFloat = IsOnIPad ? 80.0 : 45.0
            SecondBlob = RadialGradientDescriptor(Frame: frame, Bounds: bounds, Location: CGPoint(x: HalfX, y: HalfY - SecondRadial),
                                                  GradientRadius: SecondRadius,
                                                  RadialColors: [UIColor.yellow, UIColor.orange, UIColor.red],
                                                  OuterAlphaValue: 0.0, AlphaDistance: 0.1, CenterAnchor: CenterGradientInCenter,
                                                  TheCenter: CGPoint(x: HalfX, y: HalfY))
            SecondBlob.AsFunnel = IsFunnelShapped
            SecondBlob.AsLozenge = IsLozengeShaped
            SecondBlob.SetGeneralBackgroundColor(GeneralBackgroundColor)
            Gradients.append(SecondBlob)
        }
        
        MinuteRadial = IsOnIPad ? MaxVisible - 95.0 : MaxVisible - 75.0
        let MinuteRadius: CGFloat = IsOnIPad ? 90.0 : 64.0
        MinuteBlob = RadialGradientDescriptor(Frame: frame, Bounds: bounds, Location: CGPoint(x: HalfX, y: HalfY - MinuteRadial),
                                              GradientRadius: MinuteRadius,
                                              RadialColors: [UIColor.orange, UIColor.white, UIColor.blue],
                                              OuterAlphaValue: 0.0, AlphaDistance: 0.1, CenterAnchor: CenterGradientInCenter,
                                              TheCenter: CGPoint(x: HalfX, y: HalfY))
        MinuteBlob.AsFunnel = IsFunnelShapped
        MinuteBlob.AsLozenge = IsLozengeShaped
        MinuteBlob.SetGeneralBackgroundColor(GeneralBackgroundColor)
        HourRadial = IsOnIPad ? MaxVisible - 200.0 : MaxVisible - 140.0
        Gradients.append(MinuteBlob)
        
        let HourRadius: CGFloat = IsOnIPad ? 110.0 : 70.0
        HourBlob = RadialGradientDescriptor(Frame: frame, Bounds: bounds, Location: CGPoint(x: HalfX, y: HalfY - HourRadial),
                                            GradientRadius: HourRadius,
                                            RadialColors: [UIColor.red, UIColor.black, UIColor.yellow, UIColor.black],
                                            OuterAlphaValue: 0.0, AlphaDistance: 0.1, CenterAnchor: CenterGradientInCenter,
                                            TheCenter: CGPoint(x: HalfX, y: HalfY))
        HourBlob.AsFunnel = IsFunnelShapped
        HourBlob.AsLozenge = IsLozengeShaped
        HourBlob.SetGeneralBackgroundColor(GeneralBackgroundColor)
        Gradients.append(HourBlob)
        
        if _Settings.bool(forKey: Setting.Key.RadialGradient.ShowCenterDot)
        {
            let CenterBlobRadial = 30.0 //MaxVisible
            CenterBlob = RadialGradientDescriptor(Frame: frame, Bounds: bounds, Location: CGPoint(x: HalfX, y: HalfY),
                                                  GradientRadius: CGFloat(CenterBlobRadial),
                                                  RadialColors: [UIColor.white, UIColor.yellow, UIColor.orange, UIColor.red],
                                                  OuterAlphaValue: 0.0, AlphaDistance: 0.05)
            CenterBlob.SetGeneralBackgroundColor(GeneralBackgroundColor)
            CenterBlob.ShowWork = false
            Gradients.append(CenterBlob)
            
            if _Settings.bool(forKey: Setting.Key.RadialGradient.CenterDotPulsates)
            {
                CenterBlob.VaryRadiusPeriodically(From: 30.0, To: CGFloat(MaxVisible * 2), Duration: 5.0)
            }
        }
    }
    
    public func ResetClock()
    {
        Gradients.removeAll()
        sublayers?.forEach{$0.removeFromSuperlayer()}
        MakeClockGradients()
    }
    
    private var CenterBlob: RadialGradientDescriptor!
    private var HalfX: CGFloat = 0.0
    private var HalfY: CGFloat = 0.0
    private var SecondBlob: RadialGradientDescriptor!
    private var SecondRadial: CGFloat = 0.0
    private var MinuteBlob: RadialGradientDescriptor!
    private var MinuteRadial: CGFloat = 0.0
    private var HourBlob: RadialGradientDescriptor!
    private var HourRadial: CGFloat = 0.0
    
    private func RestoreGradients()
    {
        Gradients.removeAll()
        sublayers?.forEach{$0.removeFromSuperlayer()}
        for SomeGradient in OldGradients
        {
            Gradients.append(SomeGradient)
        }
        setNeedsDisplay()
    }
    
    public func RunAsClock(_ DoRun: Bool, ShowClockNumbers: Bool = true, ShowNumerals: Bool = true, ShowRadials: Bool = true)
    {
        if !ShowRadials
        {
            if RadialLayer != nil
            {
                RadialLayer?.removeFromSuperlayer()
                RadialLayer = nil
            }
        }
        if !ShowNumerals
        {
            if NumeralLayer != nil
            {
                NumeralLayer?.removeFromSuperlayer()
                NumeralLayer = nil
            }
        }
        if !ShowClockNumbers
        {
            if ClockFaceLayer != nil
            {
                ClockFaceLayer?.removeFromSuperlayer()
                ClockFaceLayer = nil
            }
        }
        DoShowRadialLayer = ShowRadials
        DoShowNumeralLayer = ShowNumerals
        DoShowClockLayer = ShowClockNumbers
        if DoRun
        {
            SaveOldGradients()
            Gradients.removeAll()
            MakeClockGradients()
            StartTime = CFAbsoluteTimeGetCurrent()
            ClockTimer = Timer.scheduledTimer(timeInterval: TimeInterval(0.05), target: self,
                                              selector: #selector(UpdateTime), userInfo: nil, repeats: true)
        }
        else
        {
            ClockTimer.invalidate()
            ClockTimer = nil
            RestoreGradients()
            SecondBlob = nil
            MinuteBlob = nil
            HourBlob = nil
        }
    }
    
    private var DoShowClockLayer: Bool = false
    private var DoShowNumeralLayer: Bool = false
    private var DoShowRadialLayer: Bool = false
    
    var ClockFaceLayer: CATextLayer? = nil
    
    func MakeClockNumber(Value: String, Location: CGPoint, FontSize: CGFloat) -> CATextLayer2
    {
        var TextFont: UIFont!
        #if true
        TextFont = UIFont(name: "Avenir-Black", size: FontSize)
        #else
        if GeneralBackgroundColor == UIColor.black
        {
            TextFont = UIFont(name: "Avenir-Black", size: FontSize)
        }
        else
        {
            TextFont = UIFont(name: "Baskerville", size: FontSize)
        }
        #endif
        let TextSize = Utility.StringSize(Value, TextFont)
        let NumberLayer = CATextLayer2()
        //NumberLayer.borderColor = UIColor.white.cgColor
        //NumberLayer.borderWidth = 1.0
        NumberLayer.bounds = bounds
        NumberLayer.frame = CGRect(x: Location.x - TextSize.width / 2, y: Location.y - TextSize.height / 2, width: TextSize.width, height: TextSize.height)
        let Attributes: [NSAttributedString.Key: Any] =
            [
                .font: TextFont as Any,
                .foregroundColor: UIColor.white,
                .strokeColor: UIColor.black,
                .strokeWidth: -2.0
        ]
        NumberLayer.BaseFontSize = FontSize
        NumberLayer.fontSize = FontSize
        NumberLayer.alignmentMode = .center
        NumberLayer.contentsScale = UIScreen.main.scale
        NumberLayer.Contents = NSMutableAttributedString(string: Value, attributes: Attributes)
        NumberLayer.HomeLocation = Location
        NumberLayer.ContentsSize = TextSize
        //NumberLayer.AnimateTextColor(From: UIColor.white, To: UIColor.red, Duration: 5.0)
        var StartingDelay: Int = Int(Value)!
        //print("Value: \(Value)")
        if StartingDelay == 12
        {
            StartingDelay = 0
            //NumberLayer.RotationAnimation(From: 0.0, To: 360.0, Repeats: true, Duration: 0.5)
        }
        StartColorVarier(Layer: NumberLayer, StartingDelay: StartingDelay, For: Value)
        return NumberLayer
    }
    
    public static func MakeClockNumber(Value: String, Location: CGPoint, FontSize: CGFloat, Bounds: CGRect) -> CATextLayer2
    {
        var TextFont: UIFont!
        TextFont = UIFont(name: "Avenir-Black", size: FontSize)
        let TextSize = Utility.StringSize(Value, TextFont)
        let NumberLayer = CATextLayer2()
        NumberLayer.bounds = Bounds
        NumberLayer.frame = CGRect(x: Location.x - TextSize.width / 2, y: Location.y - TextSize.height / 2,
                                   width: TextSize.width, height: TextSize.height)
        let Attributes: [NSAttributedString.Key: Any] =
            [
                .font: TextFont as Any,
                .foregroundColor: UIColor.white,
                .strokeColor: UIColor.black,
                .strokeWidth: -2.0
        ]
        NumberLayer.BaseFontSize = FontSize
        NumberLayer.fontSize = FontSize
        NumberLayer.alignmentMode = .center
        NumberLayer.contentsScale = UIScreen.main.scale
        NumberLayer.Contents = NSMutableAttributedString(string: Value, attributes: Attributes)
        NumberLayer.HomeLocation = Location
        NumberLayer.ContentsSize = TextSize
        var StartingDelay: Int = Int(Value)!
        if StartingDelay == 12
        {
            StartingDelay = 0
        }
        return NumberLayer
    }
    
    /// Starts the foreground color varier.
    ///
    /// - Parameters:
    ///   - Layer: The text layer whose foreground color will be varied.
    ///   - StartingDelay: Starting delay before varying the foreground color. Units are in seconds.
    ///   - For: Debug value passed to handler.
    private func StartColorVarier(Layer: CATextLayer2, StartingDelay: Int, For: String)
    {
        let _ = Timer.scheduledTimer(withTimeInterval: Double(StartingDelay), repeats: false, block:
        {
            timer in
            Layer.TextColorTimer = Timer.scheduledTimer(timeInterval: 2.0, target: Layer, selector: #selector(Layer.TextTimerTriggered(TheTimer: )),
                                                        userInfo: ["ID": For, "FirstColor": UIColor.white, "LastColor": UIColor.red], repeats: true)
        })
    }
    
    /// Return a location on the circumference of a circle given the angle and radius.
    ///
    /// - Parameters:
    ///   - ClockTime: Angle (eg, hour) of the point.
    ///   - Offset: Radius of the point.
    /// - Returns: Circumferential point.
    func GetRadialLocation(ClockTime: Int, Offset: CGFloat) -> CGPoint?
    {
        if ClockTime < 1
        {
            return nil
        }
        if ClockTime > 12
        {
            return nil
        }
        let Angle = (CGFloat(ClockTime) / 12.0) * 360.0
        let Radian = (Angle - 90.0) * CGFloat.pi / 180.0
        let X = (Offset * cos(Radian)) + Center.x
        let Y = (Offset * sin(Radian)) + Center.y
        return CGPoint(x: X, y: Y)
    }
    
    /// Return a location on the circumference of a circle given the angle and radius.
    ///
    /// - Parameters:
    ///   - ClockTime: Angle (eg, hour) of the point.
    ///   - Offset: Radius of the point.
    ///   - Center: Origin (eg, center) of the surface.
    /// - Returns: Circumferential point.
    public static func GetRadialLocation(ClockTime: Int, Offset: CGFloat, Center: CGPoint) -> CGPoint?
    {
        if ClockTime < 1
        {
            return nil
        }
        if ClockTime > 12
        {
            return nil
        }
        let Angle = (CGFloat(ClockTime) / 12.0) * 360.0
        let Radian = (Angle - 90.0) * CGFloat.pi / 180.0
        let X = (Offset * cos(Radian)) + Center.x
        let Y = (Offset * sin(Radian)) + Center.y
        return CGPoint(x: X, y: Y)
    }
    
    func MakeClockFace(OrdinalHoursOnly: Bool = false)
    {
        if ClockFaceLayer != nil
        {
            return
        }
        if Center == nil
        {
            return
        }
        let IsOnIPad = UIDevice.current.userInterfaceIdiom == .pad
        ClockFaceLayer = CATextLayer()
        ClockFaceLayer?.frame = frame
        ClockFaceLayer?.bounds = bounds
        ClockFaceLayer?.backgroundColor = UIColor.clear.cgColor
        ClockFaceLayer?.zPosition = 999
        
        let BigFontSize: CGFloat = IsOnIPad ? 56.0 : 36.0
        let SmallFontSize: CGFloat = IsOnIPad ? 48.0 : 24.0
        var Numbers = [(String, Int, CGPoint, CGFloat)]()
        let Offset: CGFloat = min(HalfX, HalfY) - CGFloat(IsOnIPad ? 25.0 : 15.0)
        Numbers.append(("12", 12, CGPoint(x: Center.x, y: Center.y - Offset), BigFontSize))
        Numbers.append(("3", 3, CGPoint(x: Center.x + Offset, y: Center.y), BigFontSize))
        Numbers.append(("6", 6, CGPoint(x: Center.x, y: Center.y + Offset), BigFontSize))
        Numbers.append(("9", 9, CGPoint(x: Center.x - Offset, y: Center.y), BigFontSize))
        
        if !OrdinalHoursOnly
        {
            Numbers.append(("1", 1, GetRadialLocation(ClockTime: 1, Offset: Offset)!, SmallFontSize))
            Numbers.append(("2", 2, GetRadialLocation(ClockTime: 2, Offset: Offset)!, SmallFontSize))
            Numbers.append(("4", 4, GetRadialLocation(ClockTime: 4, Offset: Offset)!, SmallFontSize))
            Numbers.append(("5", 5, GetRadialLocation(ClockTime: 5, Offset: Offset)!, SmallFontSize))
            Numbers.append(("7", 7, GetRadialLocation(ClockTime: 7, Offset: Offset)!, SmallFontSize))
            Numbers.append(("8", 8, GetRadialLocation(ClockTime: 8, Offset: Offset)!, SmallFontSize))
            Numbers.append(("10", 10, GetRadialLocation(ClockTime: 10, Offset: Offset)!, SmallFontSize))
            Numbers.append(("11", 11, GetRadialLocation(ClockTime: 11, Offset: Offset)!, SmallFontSize))
        }
        
        for (NumberString, Tag, Location, FontSize) in Numbers
        {
            let NewLayer = MakeClockNumber(Value: NumberString, Location: Location, FontSize: FontSize)
            NewLayer.setValue(Tag, forKey: "Tag")
            ClockFaceLayer?.addSublayer(NewLayer)
        }
    }
    
    /// Make a clock face of twelve hour numerals arranged appropriately.
    ///
    /// - Parameters:
    ///   - FontSize: Font size for the numerals.
    ///   - Center: Center of the surface.
    ///   - Frame: Frame to use for the layer.
    ///   - Bounds: Bounds to use for the layer.
    /// - Returns: Text layer with the numerals.
    public static func MakeClockFace(FontSize: CGFloat, ACenter: CGPoint, Frame: CGRect, Bounds: CGRect) -> CATextLayer
    {
        let FaceLayer = CATextLayer()
        FaceLayer.frame = Frame
        FaceLayer.bounds = Bounds
        FaceLayer.zPosition = 999
        
        var Numbers = [(String, Int, CGPoint, CGFloat)]()
        let Offset: CGFloat = (min(Frame.width, Frame.height) / 2.0) - 20.0
        let Center = CGPoint(x: (Frame.width - Frame.minX) / 2.0 - (Frame.minX / 2.0), y: (Frame.height - Frame.minY) / 2.0 - (Frame.minY / 2.0))
        Numbers.append(("12", 12, CGPoint(x: Center.x, y: Center.y - Offset), FontSize))
        Numbers.append(("3", 3, CGPoint(x: Center.x + Offset, y: Center.y), FontSize))
        Numbers.append(("6", 6, CGPoint(x: Center.x, y: Center.y + Offset), FontSize))
        Numbers.append(("9", 9, CGPoint(x: Center.x - Offset, y: Center.y), FontSize))
        Numbers.append(("1", 1, GetRadialLocation(ClockTime: 1, Offset: Offset, Center: Center)!, FontSize))
        Numbers.append(("2", 2, GetRadialLocation(ClockTime: 2, Offset: Offset, Center: Center)!, FontSize))
        Numbers.append(("4", 4, GetRadialLocation(ClockTime: 4, Offset: Offset, Center: Center)!, FontSize))
        Numbers.append(("5", 5, GetRadialLocation(ClockTime: 5, Offset: Offset, Center: Center)!, FontSize))
        Numbers.append(("7", 7, GetRadialLocation(ClockTime: 7, Offset: Offset, Center: Center)!, FontSize))
        Numbers.append(("8", 8, GetRadialLocation(ClockTime: 8, Offset: Offset, Center: Center)!, FontSize))
        Numbers.append(("10", 10, GetRadialLocation(ClockTime: 10, Offset: Offset, Center: Center)!, FontSize))
        Numbers.append(("11", 11, GetRadialLocation(ClockTime: 11, Offset: Offset, Center: Center)!, FontSize))
        
        for (NumberString, Tag, Location, FontSize) in Numbers
        {
            let NewLayer = MakeClockNumber(Value: NumberString, Location: Location, FontSize: FontSize, Bounds: Bounds)
            NewLayer.setValue(Tag, forKey: "Tag")
            FaceLayer.addSublayer(NewLayer)
        }
        
        return FaceLayer
    }
    
    func MakeRadialLayer(_ HourPoint: CGPoint, _ MinutePoint: CGPoint, _ SecondPoint: CGPoint)
    {
        if RadialLayer != nil
        {
            RadialLayer!.removeFromSuperlayer()
            RadialLayer = nil
        }
        RadialLayer = CAShapeLayer()
        RadialLayer?.frame = frame
        RadialLayer?.bounds = bounds
        RadialLayer?.backgroundColor = UIColor.clear.cgColor
        
        let Lines = UIBezierPath()
        
        Lines.move(to: Center)
        Lines.addLine(to: HourPoint)
        Lines.move(to: Center)
        Lines.addLine(to: MinutePoint)
        Lines.move(to: Center)
        Lines.addLine(to: SecondPoint)
        RadialLayer?.path = Lines.cgPath
        RadialLayer?.lineWidth = 1.0
        RadialLayer?.strokeColor = UIColor.yellow.cgColor
        RadialLayer?.zPosition = 1000
    }
    
    private var RadialLayer: CAShapeLayer? = nil
    
    func MakeSubNumeralLayer(WithString: String, Location: CGPoint) -> CATextLayer
    {
        let SubLayer = CATextLayer()
        SubLayer.bounds = bounds
        SubLayer.frame = CGRect(x: Location.x - 25.0, y: Location.y - 25.0, width: 50, height: 50)
        let TextFont = UIFont(name: "Avenir-Black", size: 36.0)
        let Shadow = NSShadow()
        Shadow.shadowColor = UIColor.darkGray
        Shadow.shadowBlurRadius = 5
        Shadow.shadowOffset = CGSize(width: 15, height: 15)
        let Attributes: [NSAttributedString.Key: Any] =
            [
                .font: TextFont as Any,
                .foregroundColor: UIColor.white,
                .strokeColor: UIColor.black,
                .strokeWidth: -2.0,
                .shadow: Shadow
        ]
        SubLayer.fontSize = 36.0
        SubLayer.alignmentMode = .center
        SubLayer.contentsScale = UIScreen.main.scale
        SubLayer.string = NSAttributedString(string: WithString, attributes: Attributes)
        return SubLayer
    }
    
    func MakeNumeralLayer(WithStrings: [(String, CGPoint)])
    {
        if NumeralLayer != nil
        {
            NumeralLayer!.removeFromSuperlayer()
            NumeralLayer = nil
        }
        NumeralLayer = CATextLayer()
        NumeralLayer?.frame = frame
        NumeralLayer?.bounds = bounds
        NumeralLayer?.backgroundColor = UIColor.clear.cgColor
        NumeralLayer?.zPosition = 999
        
        for (StringValue, Location) in WithStrings
        {
            let SubLayer = MakeSubNumeralLayer(WithString: StringValue, Location: Location)
            NumeralLayer?.addSublayer(SubLayer)
        }
    }
    
    func MakeDebugLayer()
    {
        if DebugLayer != nil
        {
            return
        }
        DebugLayer = CATextLayer()
        let Offset: CGFloat = 1300
        DebugLayer?.frame = CGRect(x: 0.0, y: Offset, width: frame.width, height: frame.height - Offset)
        DebugLayer?.bounds = bounds
        DebugLayer?.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5).cgColor
        DebugLayer?.fontSize = 20.0
        DebugLayer?.font = UIFont(name: "Avenir", size: 20.0)
        DebugLayer?.alignmentMode = .left
        DebugLayer?.foregroundColor = UIColor.white.cgColor
        DebugLayer?.contentsScale = UIScreen.main.scale
        DebugLayer?.string = "Current animation\nTotal count"
    }
    
    func UpdateDebug(NewCount: Int, AnimationName: String)
    {
        if !ShowDebugLayer
        {
            return
        }
        let NewString = "Current animation \(AnimationName)\nTotal count \(NewCount)"
        DebugLayer?.string = NewString
    }
    
    private var _ShowDebugLayer: Bool = false
    public var ShowDebugLayer: Bool
    {
        get
        {
            return _ShowDebugLayer
        }
        set
        {
            _ShowDebugLayer = newValue
            if _ShowDebugLayer
            {
                if DebugLayer == nil
                {
                    MakeDebugLayer()
                }
            }
            else
            {
                if DebugLayer != nil
                {
                    DebugLayer?.removeFromSuperlayer()
                    DebugLayer = nil
                }
            }
        }
    }
    
    private var DebugLayer: CATextLayer? = nil
    private var NumeralLayer: CATextLayer? = nil
    
    var StartTime: CFTimeInterval!
    
    var ClockTimer: Timer!
    
    var Epoch: Date? = nil
    
    func MakeEpoch()
    {
        var Comp = DateComponents()
        Comp.timeZone = TimeZone(abbreviation: "GMT")
        Comp.year = 2001
        Comp.month = 1
        Comp.day = 1
        Comp.hour = 0
        Comp.minute = 0
        Comp.second = 0
        let Cal = Calendar.current
        Epoch = Cal.date(from: Comp)
    }
    
    func MakeMidnight() -> Date
    {
        let Now = Date()
        let Cal = Calendar.current
        var Comp = DateComponents()
        Comp.year = Cal.component(.year, from: Now)
        Comp.month = Cal.component(.month, from: Now)
        Comp.day = Cal.component(.day, from: Now)
        Comp.hour = 0
        Comp.minute = 0
        Comp.second = 0
        let Midnight = Cal.date(from: Comp)
        return Midnight!
    }
    
    let MSInDay2: Int64 = 24 * 60 * 60 * 1000
    let MSInHour = 60 * 60 * 1000
    let MSInMinute = 60 * 1000
    let MSinSecond = 1000
    var OldDay = -1
    var PriorMidnight: Date? = nil
    
    func GetElapsedTimeFromSeconds(_ TotalSeconds: Double) -> (Double, Double, Double)
    {
        let Hours = TotalSeconds / 3600.0
        let Minutes0 = TotalSeconds / 60.0
        let Minutes = fmod(Minutes0, 60.0)
        let Seconds = fmod(TotalSeconds, 60.0)
        return (Hours, Minutes, Seconds)
    }
    
    var Center: CGPoint!
    
    @objc func UpdateTime()
    {
        let Cal = Calendar.current
        let Now = Date()
        if OldDay != Cal.component(.day, from: Now) || PriorMidnight == nil
        {
            print("Creating new midnight epoch.")
            PriorMidnight = MakeMidnight()
            OldDay = Cal.component(.day, from: Now)
        }
        
        let AbsTime = CFAbsoluteTimeGetCurrent()
        let TimeFromMidnight = AbsTime - PriorMidnight!.timeIntervalSince(Epoch!)
        let (H, M, S) = GetElapsedTimeFromSeconds(TimeFromMidnight)
        //print("HMS=\(H),\(M),\(S)")
        
        Center = CGPoint(x: HalfX, y: HalfY)
        let H0 = fmod(H, 12.0)
        let H2 = H0 * 1000.0 / 12000.0
        let HourAngle = CGFloat(H2 * 360.0)
        let HourPoint = MakePointOnCircle(Angle: HourAngle, Radius: HourRadial, Center: Center)
        let M2 = M * 1000.0 / 60000.0
        let MinuteAngle = CGFloat(M2 * 360.0)
        let MinutePoint = MakePointOnCircle(Angle: MinuteAngle, Radius: MinuteRadial, Center: Center)
        let S2 = S * 1000.0 / 60000.0
        let SecondAngle = CGFloat(S2 * 360.0)
        let SecondPoint = MakePointOnCircle(Angle: SecondAngle, Radius: SecondRadial, Center: Center)
        
        HourBlob.Center = HourPoint
        HourBlob.setNeedsDisplay()
        MinuteBlob.Center = MinutePoint
        MinuteBlob.setNeedsDisplay()
        if _Settings.bool(forKey: Setting.Key.RadialGradient.ShowSeconds)
        {
            SecondBlob.Center = SecondPoint
            SecondBlob.setNeedsDisplay()
        }
        
        if DoShowRadialLayer
        {
            MakeRadialLayer(HourPoint, MinutePoint, SecondPoint)
        }
        if DoShowNumeralLayer
        {
            let HS = Int(H0)
            var MS = 0
            if M.isNaN || M.isInfinite
            {
                MS = 0
            }
            else
            {
                MS = Int(M)
            }
            let SS = Int(S)
            MakeNumeralLayer(WithStrings: [(String(describing: HS), HourPoint),(String(describing: MS), MinutePoint),(String(describing: SS), SecondPoint)])
        }
        if ShowDebugLayer
        {
            MakeDebugLayer()
        }
        
        setNeedsDisplay()
    }
    
    private func MakePointOnCircle(Angle: CGFloat, Radius: CGFloat, Center: CGPoint) -> CGPoint
    {
        let Radian = (Angle - 90.0) * CGFloat.pi / 180.0
        let X = (Radius * cos(Radian)) + Center.x
        let Y = (Radius * sin(Radian)) + Center.y
        return CGPoint(x: X, y: Y)
    }
    
    private func CombineImages(ImageList: [UIImage], ImageSize: CGSize) -> UIImage
    {
        UIGraphicsBeginImageContext(ImageSize)
        let ImageFrame = CGRect(x: 0, y: 0, width: ImageSize.width, height: ImageSize.height)
        ImageList[0].draw(in: ImageFrame)
        for Index in 1 ..< ImageList.count
        {
            //screen, plusLighter, multiply
            //plusLighter, colorDodge creates interesting effects...
            //multiply is almost perfect but alpha is too dark
            //softLight, luminosity isn't bad
            ImageList[Index].draw(in: ImageFrame, blendMode: .plusLighter, alpha: 1.0)
        }
        let Composited = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return Composited!
    }
    
    func ConvertToGrayscale(_ Image: UIImage) -> UIImage?
    {
        #if true
        let CGI = CIImage(cgImage: (Image.cgImage)!)
        if let Filter = CIFilter(name: "CICircularScreen")
        {
            Filter.setDefaults()
            let Center = CIVector(x: UIScreen.main.bounds.width / 2.0, y: UIScreen.main.bounds.height / 2.0)
            Filter.setValue(Center, forKey: kCIInputCenterKey)
            Filter.setValue(CGI, forKey: kCIInputImageKey)
            //Filter.setValue(150.0, forKey: kCIInputRadiusKey)
            //Filter.setValue(10.0, forKey: kCIInputAngleKey)
            let Context = CIContext(options: nil)
            let ImageRef = Context.createCGImage(Filter.outputImage!, from: CGI.extent)
            return UIImage(cgImage: ImageRef!)
        }
        else
        {
            print("Error getting CICircularScreen")
            return nil
        }
        #else
        let CGI = CIImage(cgImage: (Image.cgImage)!)
        if let Filter = CIFilter(name: "CIPhotoEffectMono")
        {
            Filter.setDefaults()
            Filter.setValue(CGI, forKey: kCIInputImageKey)
            let Context = CIContext(options: nil)
            let ImageRef = Context.createCGImage(Filter.outputImage!, from: CGI.extent)
            return UIImage(cgImage: ImageRef!)
        }
        else
        {
            print("Error getting CIPhotoEffectMono.")
            return nil
        }
        #endif
    }
    
    func ApplyGradientFilter(_ Image: UIImage, Center: CGPoint, FilterIndex: Int) -> UIImage?
    {
        let CGI = CIImage(cgImage: (Image.cgImage)!)
        switch FilterIndex
        {
        case 1:
            if let Filter = CIFilter(name: "CIPhotoEffectMono")
            {
                Filter.setDefaults()
                Filter.setValue(CGI, forKey: kCIInputImageKey)
                let Context = CIContext(options: nil)
                let ImageRef = Context.createCGImage(Filter.outputImage!, from: CGI.extent)
                return UIImage(cgImage: ImageRef!)
            }
            else
            {
                print("Error getting CIPhotoEffectMono.")
                return nil
            }
            
        case 2:
            if let Filter = CIFilter(name: "CICircularScreen")
            {
                Filter.setDefaults()
                let Center = CIVector(x: Center.x, y: Center.y)
                Filter.setValue(Center, forKey: kCIInputCenterKey)
                Filter.setValue(CGI, forKey: kCIInputImageKey)
                let Context = CIContext(options: nil)
                let ImageRef = Context.createCGImage(Filter.outputImage!, from: CGI.extent)
                return UIImage(cgImage: ImageRef!)
            }
            else
            {
                print("Error getting CICircularScreen")
                return nil
            }
            
        case 3:
            if let Filter = CIFilter(name: "CICMYKHalftone")
            {
                Filter.setDefaults()
                Filter.setValue(CGI, forKey: kCIInputImageKey)
                let Context = CIContext(options: nil)
                let ImageRef = Context.createCGImage(Filter.outputImage!, from: CGI.extent)
                return UIImage(cgImage: ImageRef!)
            }
            else
            {
                print("Error getting CICMYKHalftone")
                return nil
            }
            
        case 4:
            if let Filter = CIFilter(name: "CITwirlDistortion")
            {
                Filter.setDefaults()
                let Center = CIVector(x: Center.x, y: Center.y)
                Filter.setValue(Center, forKey: kCIInputCenterKey)
                Filter.setValue(CGI, forKey: kCIInputImageKey)
                Filter.setValue(Center.x, forKey: kCIInputRadiusKey)
//                Filter.setValue(150.0, forKey: kCIInputRadiusKey)
//                let AngleValue = SecondsInRadians() * 10.0
//                Filter.setValue(AngleValue, forKey: kCIInputAngleKey)
                Filter.setValue(CGFloat.pi, forKey: kCIInputAngleKey)
                let Context = CIContext(options: nil)
                let ImageRef = Context.createCGImage(Filter.outputImage!, from: CGI.extent)
                return UIImage(cgImage: ImageRef!)
            }
            else
            {
                print("Error getting CITwirlDistortion")
                return nil
            }
            
        default:
            fatalError("Invalid filter index \(FilterIndex) encountered in ApplyGradientFilter")
        }
    }
    
    func SecondsInRadians() -> CGFloat
    {
        let Cal = Calendar.current
        let Seconds = Cal.component(.second, from: Date())
        let Percent: CGFloat = CGFloat(Seconds) / 60.0
        return Percent// * (CGFloat.pi / 180.0)
    }
    
    /// Draw the radial gradient. For force a draw, call .setNeedsDisplay on the layer instance. Also redrawn when the bounds change.
    ///
    /// - Parameter Context: Context of the drawing.
    override func draw(in Context: CGContext)
    {
        Context.clip(to: CGRect.AdjustOriginAndSize(UIScreen.main.bounds, OriginBy: 1.0, SizeBy: -2.0))
        sublayers?.forEach{$0.removeFromSuperlayer()}
        var LayerImage = [UIImage]()
        for Layer in Gradients
        {
            Layer.setNeedsDisplay()
            UIGraphicsBeginImageContext(CGSize(width: frame.width, height: frame.height))
            defer {UIGraphicsEndImageContext()}
            guard let Context = UIGraphicsGetCurrentContext()
                else
            {
                print("Error getting context in CARadialGradient2.draw")
                return
            }
            Layer.render(in: Context)
            let Rendered = UIGraphicsGetImageFromCurrentImageContext()
            LayerImage.append(Rendered!)
        }
        //contentsScale = UIScreen.main.scale
        shouldRasterize = true
        rasterizationScale = UIScreen.main.scale
        var Final = CombineImages(ImageList: LayerImage, ImageSize: CGSize(width: frame.width, height: frame.height))
        if _Settings.integer(forKey: Setting.Key.RadialGradient.GradientFilter) > 0
        {
            let Center = CGPoint(x: frame.width / 2.0, y: frame.height / 2.0)
            Final = ApplyGradientFilter(Final, Center: Center, FilterIndex: _Settings.integer(forKey: Setting.Key.RadialGradient.GradientFilter))!
        }
        #if false
        if _Settings.bool(forKey: Setting.Key.RadialGradient.InGrayscale)
        {
            Final = ConvertToGrayscale(Final)!
        }
        #endif
        Context.draw(Final.cgImage!, in: frame)
        if let RadialLayer = RadialLayer
        {
            addSublayer(RadialLayer)
        }
        if let NumeralLayer = NumeralLayer
        {
            addSublayer(NumeralLayer)
        }
        if let ClockFaceLayer = ClockFaceLayer
        {
            addSublayer(ClockFaceLayer)
        }
        if ShowDebugLayer
        {
            if let DebugLayer = DebugLayer
            {
                addSublayer(DebugLayer)
            }
        }
    }
}
