//
//  LinkAnimation.swift
//  GradientTestBed
//
//  Created by Stuart Rankin on 10/14/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Implements animation of non-animatable properties by handling timing via CADisplayLink objects. For each type animated,
/// the caller assigns a handler for when a new value is available and is responsible for handling changes in values.
class LinkAnimation
{
    // MARK: Double animation.
    
    private var _CurrentlyAnimatingDouble: Bool = false
    public var CurrentlyAnimatingDouble: Bool
    {
        get
        {
            return _CurrentlyAnimatingDouble
        }
    }
    
    private var _CumulativeDoublePercent: Double = 0.0
    public var CumulativeDoublePercent: Double
    {
        get
        {
            return _CumulativeDoublePercent
        }
    }
    
    @objc private func HandleLinkDoubleEvent(Link: CADisplayLink)
    {
        let Now = CACurrentMediaTime()
        let Interval = (Now - LastDoubleUpdateTime) / DoubleAnimationDuration
        UpdateDoubleValue(Interval: Interval)
    }
    
    private func UpdateDoubleValue(Interval: Double)
    {
        assert(CGFloatValueHandler != nil, "No new value handler declared.")
        assert(CGFloatCompleted != nil, "No completion handler declared.")
        LastDoubleUpdateTime = CACurrentMediaTime()
        _CumulativeDoublePercent = _CumulativeDoublePercent + Interval
        var NewValue = DoubleDelta * _CumulativeDoublePercent * DoubleSign
        NewValue = NewValue + StartingDouble
        var DoneWithAnimation: Bool = false
        if _CumulativeDoublePercent >= 1.0
        {
            _CumulativeDoublePercent = 1.0
            DoubleLink.invalidate()
            DoubleLink = nil
            _CurrentlyAnimatingDouble = false
            NewValue = EndingDouble
            DoneWithAnimation = true
        }
        DoubleValueHandler?(NewValue)
        if DoneWithAnimation
        {
            DoubleCompleted?()
        }
    }
    
    private var LastDoubleUpdateTime = CACurrentMediaTime()
    private var DoubleAnimationDuration = 0.0
    private var DoubleLink: CADisplayLink!
    private var DoubleValueHandler: ((Double) -> ())? = nil
    private var DoubleCompleted: (() -> ())? = nil
    private var StartingDouble: Double = 0.0
    private var EndingDouble: Double = 0.0
    private var DoubleDelta: Double = 0.0
    private var DoubleSign: Double = 0.0
    
    @discardableResult public func AnimateDouble(From: Double, To: Double, Duration: TimeInterval, NewValueHandler: @escaping (Double) -> (),
                                                 CompletionHandler: @escaping () -> ()) -> Bool
    {
        assert(Duration > 0.0, "Duration must be greater than 0.0.")
        if CurrentlyAnimatingDouble
        {
            return false
        }
        DoubleValueHandler = NewValueHandler
        DoubleCompleted = CompletionHandler
        StartingDouble = From
        EndingDouble = To
        DoubleDelta = abs(To - From)
        DoubleSign = To < From ? -1.0 : 1.0
        _CumulativeDoublePercent = 0.0
        DoubleAnimationDuration = Duration
        DoubleLink = CADisplayLink(target: self, selector: #selector(HandleLinkDoubleEvent))
        DoubleLink.preferredFramesPerSecond = 60
        DoubleLink.add(to: .current, forMode: .default)
        _CurrentlyAnimatingDouble = true
        UpdateDoubleValue(Interval: 0.0)
        return true
    }
    
    public func AnimateDouble(StartDelay: TimeInterval, From: Double, To: Double, Duration: TimeInterval,
                              NewValueHandler: @escaping (Double) -> (), CompletionHandler: @escaping () -> ())
    {
        let _ = Timer.scheduledTimer(withTimeInterval: StartDelay, repeats: false, block:
        {
            timer in
            self.AnimateDouble(From: From, To: To, Duration: Duration, NewValueHandler: NewValueHandler, CompletionHandler: CompletionHandler)
        })
    }
    
    @discardableResult public func StopDoubleAnimation() -> Double?
    {
        if DoubleLink == nil
        {
            print("No double link available.")
            return nil
        }
        DoubleLink.invalidate()
        DoubleLink.remove(from: .current, forMode: .default)
        DoubleLink = nil
        return CumulativeDoublePercent
    }
    
    // MARK: CGFloat animation.
    
    private var _CurrentlyAnimatingCGFloat: Bool = false
    public var CurrentlyAnimatingCGFloat: Bool
    {
        get
        {
            return _CurrentlyAnimatingCGFloat
        }
    }
    
    private var _CGFloatPercent: CGFloat = 0.0
    public var CGFloatPercent: CGFloat
    {
        get
        {
            return _CGFloatPercent
        }
    }
    
    private var CGFloatAnimationDuration: Double = 1.0
    private var CGFloatLink: CADisplayLink!
    private var LastCGFloatUpdateTime = CACurrentMediaTime()
    private var CGFloatValueHandler: ((CGFloat) -> ())? = nil
    private var CGFloatCompleted: (() -> ())? = nil
    private var StartingCGFloat: CGFloat = 0.0
    private var EndingCGFloat: CGFloat = 0.0
    private var CGFloatDelta: CGFloat = 0.0
    private var CGFloatSign: CGFloat = 0.0
    
    @objc private func HandleCGFloatLinkEvent(Link: CADisplayLink)
    {
        let Now = CACurrentMediaTime()
        let Interval = (Now - LastCGFloatUpdateTime) / CGFloatAnimationDuration
        UpdateCGFloatValue(Interval: CGFloat(Interval))
    }
    
    private func UpdateCGFloatValue(Interval: CGFloat)
    {
        assert(CGFloatValueHandler != nil, "No new value handler declared.")
        assert(CGFloatCompleted != nil, "No completion handler declared.")
        LastCGFloatUpdateTime = CACurrentMediaTime()
        _CGFloatPercent = _CGFloatPercent + Interval
        var NewValue = CGFloatDelta * _CGFloatPercent * CGFloatSign
        NewValue = NewValue + StartingCGFloat
        var DoneWithAnimation: Bool = false
        if _CGFloatPercent >= 1.0
        {
            _CGFloatPercent = 1.0
            CGFloatLink.invalidate()
            CGFloatLink = nil
            _CurrentlyAnimatingCGFloat = false
            NewValue = EndingCGFloat
            DoneWithAnimation = true
        }
        CGFloatValueHandler?(NewValue)
        if DoneWithAnimation
        {
            CGFloatCompleted?()
        }
    }
    
    @discardableResult public func AnimateCGFloat(From: CGFloat, To: CGFloat, Duration: TimeInterval, NewValueHandler: @escaping (CGFloat) -> (),
                                                  CompletionHandler: @escaping () -> ()) -> Bool
    {
        assert(Duration > 0.0, "Duration must be greater than 0.0.")
        if CurrentlyAnimatingCGFloat
        {
            return false
        }
        CGFloatValueHandler = NewValueHandler
        CGFloatCompleted = CompletionHandler
        StartingCGFloat = From
        EndingCGFloat = To
        CGFloatDelta = abs(To - From)
        CGFloatSign = To < From ? -1.0 : 1.0
        _CGFloatPercent = 0.0
        CGFloatAnimationDuration = Duration
        CGFloatLink = CADisplayLink(target: self, selector: #selector(HandleCGFloatLinkEvent))
        CGFloatLink.preferredFramesPerSecond = 60
        CGFloatLink.add(to: .current, forMode: .default)
        _CurrentlyAnimatingCGFloat = true
        UpdateCGFloatValue(Interval: 0.0)
        return true
    }
    
    @discardableResult public func StopCGFloatAnimation() -> CGFloat?
    {
        if CGFloatLink == nil
        {
            print("No animation link available.")
            return nil
        }
        CGFloatLink.invalidate()
        CGFloatLink.remove(from: .current, forMode: .default)
        CGFloatLink = nil
        return CGFloatPercent
    }
    
    // MARK: UIColor (HSB) animation.
    
    private var _AnimatingHSBColor: Bool = false
    public var AnimatingHSBColor: Bool
    {
        get
        {
            return _AnimatingHSBColor
        }
    }
    
    /// - Parameter SourceColor: The color whose hue, saturation, and brightness will be returned.
    /// - Returns: Tuple in the order: hue, saturation, brightness.
    public func GetHSB(_ SourceColor: UIColor) -> (CGFloat, CGFloat, CGFloat)
    {
        let Hue = UnsafeMutablePointer<CGFloat>.allocate(capacity: 1)
        Hue.initialize(to: 0.0)
        let Saturation = UnsafeMutablePointer<CGFloat>.allocate(capacity: 1)
        Saturation.initialize(to: 0.0)
        let Brightness = UnsafeMutablePointer<CGFloat>.allocate(capacity: 1)
        Brightness.initialize(to: 0.0)
        let UnusedAlpha = UnsafeMutablePointer<CGFloat>.allocate(capacity: 1)
        UnusedAlpha.initialize(to: 0.0)
        
        SourceColor.getHue(Hue, saturation: Saturation, brightness: Brightness, alpha: UnusedAlpha)
        
        let FinalHue = Hue.move()
        let FinalSaturation = Saturation.move()
        let FinalBrightness = Brightness.move()
        let _ = UnusedAlpha.move()
        
        //Clean up.
        Hue.deallocate()
        Saturation.deallocate()
        Brightness.deallocate()
        UnusedAlpha.deallocate()
        
        return (FinalHue, FinalSaturation, FinalBrightness)
    }
    
    private var _ColorAnimationPercent: CGFloat = 0.0
    public var ColorAnimationPercent: CGFloat
    {
        get
        {
            return _ColorAnimationPercent
        }
    }
    
    private var ColorAnimationDuration: Double = 1.0
    private var ColorLink: CADisplayLink!
    private var LastColorUpdateTime = CACurrentMediaTime()
    private var ColorValueHandler: ((UIColor) -> ())? = nil
    private var ColorCompleted: (() -> ())? = nil
    private var HueStartingValue: CGFloat = 0.0
    private var HueEndingValue: CGFloat = 0.0
    private var HueDelta: CGFloat = 0.0
    private var HueSign: CGFloat = 1.0
    private var SatStartingValue: CGFloat = 0.0
    private var SatEndingValue: CGFloat = 0.0
    private var SatDelta: CGFloat = 0.0
    private var SatSign: CGFloat = 0.0
    private var BriStartingValue: CGFloat = 0.0
    private var BriEndingValue: CGFloat = 0.0
    private var BriDelta: CGFloat = 0.0
    private var BriSign: CGFloat = 0.0
    
    @objc private func HandleColorLinkEvent(Link: CADisplayLink)
    {
        let Now = CACurrentMediaTime()
        let Interval = (Now - LastColorUpdateTime) / ColorAnimationDuration
        UpdateColorValue(Interval: CGFloat(Interval))
    }
    
    private func NormalizeChannel(_ Raw: CGFloat) -> CGFloat
    {
        if Raw < 0.0
        {
            return 0.0
        }
        if Raw > 1.0
        {
            return 1.0
        }
        return Raw
    }
    
    private func UpdateColorValue(Interval: CGFloat)
    {
        assert(ColorValueHandler != nil, "No new value handler declared.")
        assert(ColorCompleted != nil, "No completion handler declared.")
        LastColorUpdateTime = CACurrentMediaTime()
        _ColorAnimationPercent = _ColorAnimationPercent + Interval
        
        var NewH = HueDelta * _ColorAnimationPercent * HueSign
        NewH = NormalizeChannel(NewH + HueStartingValue)
        var NewS = SatDelta * _ColorAnimationPercent * SatSign
        NewS = NormalizeChannel(NewS + SatStartingValue)
        var NewB = BriDelta * _ColorAnimationPercent * BriSign
        NewB = NormalizeChannel(NewB + BriStartingValue)
        
        var NewColor = UIColor(hue: NewH, saturation: NewS, brightness: NewB, alpha: 1.0)
        var DoneWithAnimation: Bool = false
        if _ColorAnimationPercent >= 1.0
        {
            _ColorAnimationPercent = 1.0
            ColorLink.invalidate()
            ColorLink = nil
            _AnimatingHSBColor = false
            NewColor = UIColor(hue: HueEndingValue, saturation: SatEndingValue, brightness: BriEndingValue, alpha: 1.0)
            DoneWithAnimation = true
        }
        ColorValueHandler?(NewColor)
        if DoneWithAnimation
        {
            ColorCompleted?()
        }
    }
    
    @discardableResult public func StartHSBColorAnimation(From: UIColor, To: UIColor, Duration: TimeInterval,
                                                          NewValueHandler: @escaping (UIColor) -> (),
                                                          CompletionHandler: @escaping () -> (),
                                                          AnimateHue: Bool = true, AnimateSaturation: Bool = true, AnimateBrightness: Bool = true) -> Bool
    {
        assert(Duration > 0.0, "Duration must be greater than 0.0.")
        if AnimatingHSBColor
        {
            return false
        }
        _ColorAnimationPercent = 0.0
        ColorValueHandler = NewValueHandler
        ColorCompleted = CompletionHandler
        ColorAnimationDuration = Duration
        let (H0, S0, B0) = GetHSB(From)
        let (H1, S1, B1) = GetHSB(To)
        HueStartingValue = H0
        HueEndingValue = H1
        HueDelta = abs(H1 - H0)
        HueSign = H1 < H0 ? -1.0 : 1.0
        SatStartingValue = S0
        SatEndingValue = S1
        SatDelta = abs(S1 - S0)
        SatSign = S1 < S0 ? -1.0 : 1.0
        BriStartingValue = B0
        BriEndingValue = B1
        BriDelta = abs(B1 - B0)
        BriSign = B1 < B0 ? -1.0 : 1.0
        ColorLink = CADisplayLink(target: self, selector: #selector(HandleColorLinkEvent))
        ColorLink.preferredFramesPerSecond = 60
        ColorLink.add(to: .current, forMode: .default)
        _CurrentlyAnimatingCGFloat = true
        UpdateColorValue(Interval: CGFloat(0.0))
        return true
    }
    
    public func StartHSBColorAnimation(StartDelay: TimeInterval, From: UIColor, To: UIColor, Duration: TimeInterval,
                                       NewValueHandler: @escaping (UIColor) -> (),
                                       CompletionHandler: @escaping () -> (),
                                       AnimateHue: Bool = true, AnimateSaturation: Bool = true, AnimateBrightness: Bool = true)
    {
        DelayTimer = Timer.scheduledTimer(withTimeInterval: StartDelay, repeats: false, block: {
            timer in
            timer.invalidate()
            self.StartHSBColorAnimation(From: From, To: To, Duration: Duration, NewValueHandler: NewValueHandler,
                                        CompletionHandler: CompletionHandler, AnimateHue: AnimateHue,
                                        AnimateSaturation: AnimateSaturation, AnimateBrightness: AnimateBrightness)
        })
    }
    
    private var DelayTimer: Timer!
    
    @objc func DelayTimerExpired()
    {
        DelayTimer.invalidate()
        DelayTimer = nil
    }
    
    @discardableResult public func StopHSBColorAnimation() -> CGFloat?
    {
        if ColorLink == nil
        {
            print("No HSB color animation link available.")
            return nil
        }
        ColorLink.invalidate()
        ColorLink.remove(from: .current, forMode: .default)
        ColorLink = nil
        return ColorAnimationPercent
    }
    
    // MARK: UIColor (RGB) animation.
    
    private var _AnimatingRGBColor: Bool = false
    public var AnimatingRGBColor: Bool
    {
        get
        {
            return _AnimatingRGBColor
        }
    }
    
    private var _ColorRGBAnimationPercent: CGFloat = 0.0
    public var ColorRGBAnimationPercent: CGFloat
    {
        get
        {
            return _ColorRGBAnimationPercent
        }
    }
    
    @objc private func HandleColorRGBLinkEvent(Link: CADisplayLink)
    {
        let Now = CACurrentMediaTime()
        let Interval = (Now - LastColorRGBUpdateTime) / ColorRGBAnimationDuration
        UpdateColorRGBValue(Interval: CGFloat(Interval))
    }
    
    private func UpdateColorRGBValue(Interval: CGFloat)
    {
        assert(ColorRGBValueHandler != nil, "No new value handler declared.")
        assert(ColorRGBCompleted != nil, "No completion handler declared.")
        LastColorRGBUpdateTime = CACurrentMediaTime()
        _ColorRGBAnimationPercent = _ColorRGBAnimationPercent + Interval
        
        var NewR = RedDelta * _ColorRGBAnimationPercent * RedSign
        NewR = NormalizeChannel(NewR + RedStartingValue)
        var NewG = GrnDelta * _ColorRGBAnimationPercent * GrnSign
        NewG = NormalizeChannel(NewG + GrnStartingValue)
        var NewB = BluDelta * _ColorRGBAnimationPercent * BluSign
        NewB = NormalizeChannel(NewB + BluStartingValue)
        
        var NewColor = UIColor(red: NewR, green: NewG, blue: NewB, alpha: 1.0)
        var DoneWithAnimation: Bool = false
        if _ColorRGBAnimationPercent >= 1.0
        {
            _ColorRGBAnimationPercent = 1.0
            ColorRGBLink.invalidate()
            ColorRGBLink = nil
            _AnimatingHSBColor = false
            NewColor = UIColor(red: RedEndingValue, green: GrnEndingValue, blue: BluEndingValue, alpha: 1.0)
            DoneWithAnimation = true
        }
        ColorRGBValueHandler?(NewColor)
        if DoneWithAnimation
        {
            ColorRGBCompleted?()
        }
    }
    
    private var ColorRGBAnimationDuration: Double = 1.0
    private var ColorRGBLink: CADisplayLink!
    private var LastColorRGBUpdateTime = CACurrentMediaTime()
    private var ColorRGBValueHandler: ((UIColor) -> ())? = nil
    private var ColorRGBCompleted: (() -> ())? = nil
    private var RedStartingValue: CGFloat = 0.0
    private var RedEndingValue: CGFloat = 0.0
    private var RedDelta: CGFloat = 0.0
    private var RedSign: CGFloat = 1.0
    private var GrnStartingValue: CGFloat = 0.0
    private var GrnEndingValue: CGFloat = 0.0
    private var GrnDelta: CGFloat = 0.0
    private var GrnSign: CGFloat = 0.0
    private var BluStartingValue: CGFloat = 0.0
    private var BluEndingValue: CGFloat = 0.0
    private var BluDelta: CGFloat = 0.0
    private var BluSign: CGFloat = 0.0
    
    /// Given a UIColor, return the alpha red, green, and blue component parts.
    /// - Parameter SourceColor: The color whose component parts will be returned.
    /// - Returns: Tuple in the order: Alpha, Red, Green, Blue.
    public func GetARGB(_ SourceColor: UIColor) -> (CGFloat, CGFloat, CGFloat, CGFloat)
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
    
    @discardableResult public func StartRGBColorAnimation(From: UIColor, To: UIColor, Duration: TimeInterval,
                                                          NewValueHandler: @escaping (UIColor) -> (),
                                                          CompletionHandler: @escaping () -> (),
                                                          AnimateRed: Bool = true, AnimateGreen: Bool = true, AnimateBlue: Bool = true) -> Bool
    {
        assert(Duration > 0.0, "Duration must be greater than 0.0.")
        if AnimatingRGBColor
        {
            return false
        }
        _ColorRGBAnimationPercent = 0.0
        ColorRGBValueHandler = NewValueHandler
        ColorRGBCompleted = CompletionHandler
        ColorRGBAnimationDuration = Duration
        let (_, R0, G0, B0) = GetARGB(From)
        let (_, R1, G1, B1) = GetARGB(To)
        RedStartingValue = R0
        RedEndingValue = R1
        RedDelta = abs(R1 - R0)
        RedSign = R1 < R0 ? -1.0 : 1.0
        GrnStartingValue = G0
        GrnEndingValue = G1
        GrnDelta = abs(G1 - G0)
        GrnSign = G1 < G0 ? -1.0 : 1.0
        BluStartingValue = B0
        BluEndingValue = B1
        BluDelta = abs(B1 - B0)
        BluSign = B1 < B0 ? -1.0 : 1.0
        ColorRGBLink = CADisplayLink(target: self, selector: #selector(HandleColorRGBLinkEvent))
        ColorRGBLink.preferredFramesPerSecond = 60
        ColorRGBLink.add(to: .current, forMode: .default)
        _AnimatingRGBColor = true
        UpdateColorRGBValue(Interval: CGFloat(0.0))
        return true
    }
    
    public func StartRGBColorAnimation(StartDelay: TimeInterval, From: UIColor, To: UIColor, Duration: TimeInterval,
                                       NewValueHandler: @escaping (UIColor) -> (),
                                       CompletionHandler: @escaping () -> (),
                                       AnimateRed: Bool = true, AnimateGreen: Bool = true, AnimateBlue: Bool = true)
    {
        let _ = Timer.scheduledTimer(withTimeInterval: StartDelay, repeats: false, block: {
            timer in
            timer.invalidate()
            self.StartRGBColorAnimation(From: From, To: To, Duration: Duration, NewValueHandler: NewValueHandler,
                                        CompletionHandler: CompletionHandler, AnimateRed: AnimateRed,
                                        AnimateGreen: AnimateGreen, AnimateBlue: AnimateBlue)
        })
    }
    
    @discardableResult public func StopRGBColorAnimation() -> CGFloat?
    {
        if ColorRGBLink == nil
        {
            print("No rgb color animation link available.")
            return nil
        }
        ColorRGBLink.invalidate()
        ColorRGBLink.remove(from: .current, forMode: .default)
        ColorRGBLink = nil
        return ColorRGBAnimationPercent
    }
    
    // MARK: Point animation (eg, motion).
    
    private var _AnimatingPoint: Bool = false
    public var AnimatingPoint: Bool
    {
        get
        {
            return _AnimatingPoint
        }
    }
    
    private var _PointAnimationPercent: CGFloat = 0.0
    public var PointAnimationPercent: CGFloat
    {
        get
        {
            return _PointAnimationPercent
        }
    }
    
    @objc func HandlePointUpdateEvent(Link: CADisplayLink)
    {
        let Now = CACurrentMediaTime()
        let Interval = (Now - LastPointUpdateTime) / CurrentPointAnimationDuration
        UpdatePoint(Interval: CGFloat(Interval))
    }
    
    func UpdatePoint(Interval: CGFloat)
    {
        LastPointUpdateTime = CACurrentMediaTime()
        _PointAnimationPercent = _PointAnimationPercent + Interval
        let CurrentPath = WorkingPoints[CurrentPointIndex]
        var WorkingPoint = CurrentPath.GetPoint(Percent: Double(_PointAnimationPercent))
        let PointDelay = CurrentPath.PostPathDelay
        if _PointAnimationPercent >= 1.0
        {
            _PointAnimationPercent = 1.0
            WorkingPoint = CurrentPath.EndPoint
        }
        NewPointHandler?(WorkingPoint)
        let _ = Timer.scheduledTimer(withTimeInterval: PointDelay, repeats: false, block:
        {
            timer in
            self.CurrentPointIndex = self.CurrentPointIndex + 1
            if self.CurrentPointIndex > self.WorkingPoints.count - 1
            {
                self.PointAnimationCompleted?()
            }
        })
    }
    
    var LastPointUpdateTime = CACurrentMediaTime()
    var CurrentPointAnimationDuration: Double = 1.0
    var PointDisplayLink: CADisplayLink!
    var CurrentPointIndex: Int = 0
    var WorkingPoints = [MotionPath]()
    var NewPointHandler: ((CGPoint) -> ())? = nil
    var PointAnimationCompleted: (() ->())? = nil
    
    @discardableResult public func AnimatePath(MotionPaths: [MotionPath],
                                               NewValueHandler: @escaping (CGPoint) -> (),
                                               CompletionHandler: @escaping () -> ()) -> Bool
    {
        if AnimatingPoint
        {
            return false
        }
        if MotionPaths.isEmpty
        {
            print("MotionPaths is empty - nothing to animate.")
            return false
        }
        WorkingPoints = MotionPaths
        CurrentPointIndex = 0
        NewPointHandler = NewValueHandler
        PointAnimationCompleted = CompletionHandler
        PointDisplayLink = CADisplayLink(target: self, selector: #selector(HandlePointUpdateEvent))
        PointDisplayLink.preferredFramesPerSecond = 60
        return true
    }
    
    public func AnimatePath(StartDelay: TimeInterval, MotionPaths: [MotionPath],
                            NewValueHandler: @escaping (CGPoint) -> (),
                            CompletionHandler: @escaping () -> ())
    {
        let _ = Timer.scheduledTimer(withTimeInterval: StartDelay, repeats: false, block:
        {
            timer in
            self.AnimatePath(MotionPaths: MotionPaths, NewValueHandler: NewValueHandler, CompletionHandler: CompletionHandler)
        })
    }
    
    @discardableResult public func AnimatePoints(Locations: [CGPoint], Duration: TimeInterval, DurationIsTotal: Bool = false,
                                                 NewValueHandler: @escaping (CGPoint) -> (),
                                                 CompletionHandler: @escaping () -> ()) -> Bool
    {
        assert(Duration > 0.0, "Duration must be greater than 0.0.")
        if AnimatingPoint
        {
            return false
        }
        if Locations.count < 2
        {
            print("Need at least two points to animate.")
            return false
        }
        var ThePath = [MotionPath]()
        let PointDuration = DurationIsTotal ? (Duration / (Double(Locations.count - 1))) : Duration
        var Index = 0
        for SomePoint in Locations
        {
            if Index >= Locations.count - 1
            {
                break
            }
            let NewPath = MotionPath(Start: SomePoint, End: Locations[Index], Duration: PointDuration)
            ThePath.append(NewPath)
            Index = Index + 1
        }
        return AnimatePath(MotionPaths: ThePath, NewValueHandler: NewValueHandler, CompletionHandler: CompletionHandler)
    }
    
    public func AnimatePoints(StartDelay: TimeInterval, Locations: [CGPoint], Duration: TimeInterval, DurationIsTotal: Bool = false,
                              NewValueHandler: @escaping (CGPoint) -> (),
                              CompletionHandler: @escaping () -> ())
    {
        let _ = Timer.scheduledTimer(withTimeInterval: StartDelay, repeats: false, block:
        {
            timer in
            self.AnimatePoints(Locations: Locations, Duration: Duration, DurationIsTotal: DurationIsTotal,
                               NewValueHandler: NewValueHandler, CompletionHandler: CompletionHandler)
        })
    }
    
    @discardableResult public func AnimatePoint(From: CGPoint, To: CGPoint, Duration: TimeInterval,
                                                NewValueHandler: @escaping (CGPoint) -> (),
                                                CompletionHandler: @escaping () -> ()) -> Bool
    {
        assert(Duration > 0.0, "Duration must be greater than 0.0.")
        if AnimatingPoint
        {
            return false
        }
        let Points = [From, To]
        return AnimatePoints(Locations: Points, Duration: Duration, DurationIsTotal: true, NewValueHandler: NewValueHandler, CompletionHandler: CompletionHandler)
    }
    
    public func AnimatePoint(StartDelay: TimeInterval, From: CGPoint, To: CGPoint, Duration: TimeInterval,
                             NewValueHandler: @escaping (CGPoint) -> (),
                             CompletionHandler: @escaping () -> ())
    {
        let _ = Timer.scheduledTimer(withTimeInterval: StartDelay, repeats: false, block:
        {
            timer in
            self.AnimatePoint(From: From, To: To, Duration: Duration, NewValueHandler: NewValueHandler, CompletionHandler: CompletionHandler)
        })
    }
    
    @discardableResult public func StopPointAnimation() -> CGFloat?
    {
        if PointDisplayLink == nil
        {
            print("No point animation link available.")
            return nil
        }
        PointDisplayLink.invalidate()
        PointDisplayLink.remove(from: .current, forMode: .default)
        PointDisplayLink = nil
        return PointAnimationPercent
    }
}
