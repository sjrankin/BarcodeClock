//
//  IroBlob.swift
//  GradientTestBed
//
//  Created by Stuart Rankin on 9/30/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Implements the attributes of a single blob (radial gradient).
class IroBlob
{
    /// Delegate to call when there is a change to visual attributes.
    public var delegate: IroColorBlendProtocol? = nil
    
    /// Holds the original point. If nil, no point yet set. When the Center property is set, it will set this value if not already
    /// set. If this value has already been set, it will not be changed.
    private var _OriginalPoint: CGPoint? = nil
    /// Get the original location of the blob. The first time Center is set, the location is saved as the original location. Subsequent
    /// changes to Center will not change the value of OriginalPoint.
    public var OriginalPoint: CGPoint
    {
        get
        {
            if _OriginalPoint == nil
            {
                return CGPoint.zero
            }
            return _OriginalPoint!
        }
    }
    
    /// Holds the center of the blob.
    private var _BlobCenter: CGPoint = CGPoint(x: 0, y: 0)
    /// Get or set the center of the blob.
    public var BlobCenter: CGPoint
    {
        get
        {
            return _BlobCenter
        }
        set
        {
            if newValue == _BlobCenter
            {
                return
            }
            IsDirty = true
            _BlobCenter = newValue
            if _OriginalPoint == nil
            {
                _OriginalPoint = _BlobCenter
            }
            delegate?.BlobUpdated(ID: ID)
        }
    }
    
    /// Holds the flag to remove animation if the blob is off screen.
    private var _RemoveOffScreenBlobAnimation: Bool = true
    /// Get or set the flag to remove animation if the blob is off screen. True will cause all animations to be removed as soon as the
    /// blob is fully off screen (even if motion may have eventually caused it to return to on screen) and false will let animation
    /// continue even when the blob is fully off screen.
    public var RemoveOffScreenBlobAnimation: Bool
    {
        get
        {
            return _RemoveOffScreenBlobAnimation
        }
        set
        {
            _RemoveOffScreenBlobAnimation = newValue
        }
    }
    
    ///Holds the radius of the blob.
    private var _Radius: CGFloat = 1.0
    /// Get or set the radius of the blob.
    public var Radius: CGFloat
    {
        get
        {
            return _Radius
        }
        set
        {
            if newValue == _Radius
            {
                return
            }
            IsDirty = true
            //Reset the WasRendered flag as well to force a rerendering when GetBytes is called.
            WasRendered = false
            _Radius = newValue
            delegate?.BlobUpdated(ID: ID)
        }
    }
    
    /// Holds the flag that determines if shadows are shown.
    private var _ShowShadows: Bool = false
    /// Show or hide shadows. Only used for IroColorBlendLayer rendering.
    public var ShowShadows: Bool
    {
        get
        {
            return _ShowShadows
        }
        set
        {
            if newValue == _ShowShadows
            {
                return
            }
            _ShowShadows = newValue
            IsDirty = true
            delegate?.BlobUpdated(ID: ID)
        }
    }
    
    /// Holds the shadow offset value.
    private var _ShadowOffset: CGSize = CGSize(width: 3.0, height: -3.0)
    /// Shadow offset. Used only if ShowShadows is true and rendering in IroColorBlendLayer.
    public var ShadowOffset: CGSize
    {
        get
        {
            return _ShadowOffset
        }
        set
        {
            if newValue == _ShadowOffset
            {
                return
            }
            _ShadowOffset = newValue
            IsDirty = true
            delegate?.BlobUpdated(ID: ID)
        }
    }
    
    /// Holds the current overall-alpha value of the blob. Used for IroColorBlendLayer rendering.
    private var _BlobAlpha: CGFloat = 1.0
    /// Get or set the overall blob alpha value. Used only for IroColorBlendLayer rendering.
    public var BlobAlpha: CGFloat
    {
        get
        {
            return _BlobAlpha
        }
        set
        {
            if newValue == _BlobAlpha
            {
                return
            }
            _BlobAlpha = newValue
            IsDirty = true
            delegate?.BlobUpdated(ID: ID)
        }
    }
    
    /// Get the region of the blob (defined as the location and diameter returned in a rectangle).
    public var Region: CGRect
    {
        get
        {
            let Rgn = CGRect(x: BlobCenter.x - Radius, y: BlobCenter.y - Radius, width: Radius * 2.0, height: Radius * 2.0)
            return Rgn
        }
    }
    
    /// Edges of the blob. Edges in this case are representative of the radius of the blob, not the region.
    ///
    /// - Top: Top edge.
    /// - Bottom: Bottom edge.
    /// - Left: Left edge.
    /// - Right: Right edge.
    enum Edges
    {
        case Top
        case Bottom
        case Left
        case Right
    }
    
    /// Given an edge, return its endpoints.
    ///
    /// - Parameter Edge: Determines the edge whose endpoints will be returned.
    /// - Returns: Endpoints of the specified edge.
    public func GetEdges(Edge: Edges) -> [CGPoint]
    {
        var EdgeList = [CGPoint]()
        switch Edge
        {
        case .Top:
            EdgeList.append(CGPoint(x: BlobCenter.x - Radius, y: BlobCenter.y - Radius))
            EdgeList.append(CGPoint(x: BlobCenter.x + Radius, y: BlobCenter.y - Radius))
            
        case .Bottom:
            EdgeList.append(CGPoint(x: BlobCenter.x - Radius, y: BlobCenter.y + Radius))
            EdgeList.append(CGPoint(x: BlobCenter.x + Radius, y: BlobCenter.y + Radius))
            
        case .Left:
            EdgeList.append(CGPoint(x: BlobCenter.x - Radius, y: BlobCenter.y - Radius))
            EdgeList.append(CGPoint(x: BlobCenter.x - Radius, y: BlobCenter.y + Radius))
            
        case .Right:
            EdgeList.append(CGPoint(x: BlobCenter.x + Radius, y: BlobCenter.y - Radius))
            EdgeList.append(CGPoint(x: BlobCenter.x + Radius, y: BlobCenter.y + Radius))
        }
        return EdgeList
    }
    
    /// Returns the visible portion of the blob.
    ///
    /// - Parameter Frame: The surface frame rectangle.
    /// - Returns: The visible portion (eg, intersection between the blob and the surface) of the blob. If there is no intersection,
    ///            nil is returned.
    public func VisibleRegion(Frame: CGRect) -> CGRect?
    {
        let Intersection = Frame.intersection(Region)
        return Intersection.isNull ? nil : Intersection
    }
    
    /// Determines if the blob overlaps with the passed blob.
    ///
    /// - Parameter OtherRegion: The other blob's region to compare against this blob's region.
    /// - Returns: True if there is overlapping, false if not.
    public func RegionOverlapsWith(_ OtherRegion: CGRect) -> Bool
    {
        return Region.intersects(OtherRegion)
    }
    
    /// Determines if the blob is off screen or not. The screen is defined as the UIView parent.
    ///
    /// - Returns: True if at least part of the blob's region (including transparent parts) is on screen, false if not.
    public func OnScreen() -> Bool
    {
        let Surface: CGRect = (delegate?.SurfaceSize())!
        return RegionOverlapsWith(Surface)
    }
    
    /// Holds the list of colors to use to render the blob.
    private var _Colors: [UIColor] = [UIColor.red]
    /// Get or set the list of colors to use to render the blob. The first item is always the center-most color, leading in
    /// sequence through the remainder colors to the outer-most color.
    public var Colors: [UIColor]
    {
        get
        {
            return _Colors
        }
        set
        {
            if newValue == _Colors
            {
                return
            }
            IsDirty = true
            _Colors = newValue
            delegate?.BlobUpdated(ID: ID)
        }
    }
    
    /// Contains the center color.
    private var _CenterColor: UIColor = UIColor.white
    /// Get or set the color of the center of the blob.
    public var CenterColor: UIColor
    {
        get
        {
            return _CenterColor
        }
        set
        {
            if newValue == _CenterColor
            {
                return
            }
            IsDirty = true
            _CenterColor = newValue
            delegate?.BlobUpdated(ID: ID)
        }
    }
    
    /// Contains the edge color.
    private var _EdgeColor: UIColor = UIColor.clear
    /// Get or set the color of the edge of the blob.
    public var EdgeColor: UIColor
    {
        get
        {
            return _EdgeColor
        }
        set
        {
            if newValue == _EdgeColor
            {
                return
            }
            IsDirty = true
            _EdgeColor = newValue
            delegate?.BlobUpdated(ID: ID)
        }
    }
    
    /// Holds the show outline flag.
    private var _ShowRegionOutline: Bool = false
    /// Get or set the flag that controls the visibility of the region outline.
    public var ShowRegionOutline: Bool
    {
        get
        {
            return _ShowRegionOutline
        }
        set
        {
            if newValue == _ShowRegionOutline
            {
                return
            }
            _ShowRegionOutline = newValue
            IsDirty = true
            delegate?.BlobUpdated(ID: ID)
        }
    }
    
    /// Holds the color of the outline.
    private var _OutlineColor: UIColor = UIColor.red
    /// Get or set the color to use when drawing the region outline. Setting this property does not turn on the
    /// outline - you need to set ShowRegionOutline to true to show the outline.
    public var OutlineColor: UIColor
    {
        get
        {
            return _OutlineColor
        }
        set
        {
            if newValue == _OutlineColor
            {
                return
            }
            _OutlineColor = newValue
            IsDirty = true
            delegate?.BlobUpdated(ID: ID)
        }
    }
    
    /// Holds the starting alpha value.
    private var _AlphaStart: CGFloat = 1.0
    /// Get or set the starting alpha value. This is the value of alpha for the center of the blob.
    public var AlphaStart: CGFloat
    {
        get
        {
            return _AlphaStart
        }
        set
        {
            if newValue == _AlphaStart
            {
                return
            }
            IsDirty = true
            _AlphaStart = newValue
            delegate?.BlobUpdated(ID: ID)
        }
    }
    
    /// Holds the ending alpha value.
    private var _AlphaEnd: CGFloat = 0.0
    /// Get or set the ending alpha value. This is the value of alpha for the edge of the blob.
    public var AlphaEnd: CGFloat
    {
        get
        {
            return _AlphaEnd
        }
        set
        {
            if newValue == _AlphaEnd
            {
                return
            }
            IsDirty = true
            _AlphaEnd = newValue
            delegate?.BlobUpdated(ID: ID)
        }
    }
    
    /// Holds the registered flag.
    private var _Registered: Bool = false
    /// Get or set the registered flag. This flag is used by IroColorBlendLayer to make sure it understands
    /// about a given blob instantiation.
    public var Registered: Bool
    {
        get
        {
            return _Registered
        }
        set
        {
            _Registered = newValue
        }
    }
    
    /// Holds the ID of the blob.
    private var _ID: UUID = UUID()
    /// Get or set the ID of the blob.
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
    
    /// Render the blob into an abstract array (meaning, it has no concept of where it will end up). The channel order
    /// of the array is RGBA.
    ///
    /// - Returns: Tuple with contents in the order: (Array of data (of size 4 * width * height), width (in bytes), height (in scanlines)).
    public func GetBytes() -> ([UInt8], Int, Int)
    {
        let Width: Int = Int(Radius * 2) + 1
        let Height: Int = Int(Radius * 2) + 1
        if !IsDirty && WasRendered
        {
            return (Rendered, Width, Height)
        }
        
        let ArraySize = Width * Height * 4
        Rendered = [UInt8](repeating: 0, count: ArraySize)
        
        let (ea, er, eg, eb) = UIColor.GetARGB(EdgeColor)
        let (EdgeA, EdgeRed, EdgeGreen, EdgeBlue) = DenormalizeARGB(ea, er, eg, eb)
        let (_, cr, cg, cb) = UIColor.GetARGB(CenterColor)
        let (_, CenterRed, CenterGreen, CenterBlue) = DenormalizeARGB(0.0, cr, cg, cb)
        let (oa, or, og, ob) = UIColor.GetARGB(OutlineColor)
        let (OutA, OutR, OutG, OutB) = DenormalizeARGB(oa, or, og, ob)
        
        let AlphaDelta = abs(AlphaStart - AlphaEnd)
        for Row in 0 ... Height - 1
        {
            let RowOffset = Row * (Width * 4)
            for Column in 0 ... Width - 1
            {
                let Index = RowOffset + (Column * 4)
                
                if ShowRegionOutline
                {
                    if Column == 0 || Column == Width - 1 || Row == 0 || Row == Height - 1
                    {
                        Rendered[Index + 0] = OutR
                        Rendered[Index + 1] = OutG
                        Rendered[Index + 2] = OutB
                        Rendered[Index + 3] = OutA
                        continue
                    }
                }
                
                if EdgeA > 0x0
                {
                    if (Row == 0) || (Row == Height - 1) || (Column == 0) || (Column == Width - 1)
                    {
                        Rendered[Index + 0] = EdgeRed
                        Rendered[Index + 1] = EdgeGreen
                        Rendered[Index + 2] = EdgeBlue
                        Rendered[Index + 3] = EdgeA
                        continue
                    }
                }
                
                let iR: UInt8 = CenterRed
                let iG: UInt8 = CenterGreen
                let iB: UInt8 = CenterBlue
                var iA: UInt8 = 0x0
                
                let Distance = BlobCenter.Distance(Column, Row)
                if CGFloat(Distance) > Radius
                {
                    Rendered[Index + 0] = 0xff
                    Rendered[Index + 1] = 0xff
                    Rendered[Index + 2] = 0xff
                    Rendered[Index + 3] = 0x0
                    continue
                }
                if Distance == 0.0
                {
                    iA = CGFloat.Denormalize(AlphaStart)
                }
                else
                {
                    var Percent = CGFloat(Distance) / Radius
                    Percent = 1.0 - Percent
                    if Percent < 0.0
                    {
                        Percent = 0.0
                    }
                    if AlphaDelta == 0.0
                    {
                        iA = 0xff
                    }
                    else
                    {
                        iA = UInt8(Percent * AlphaDelta)
                    }
                }
                
                Rendered[Index + 0] = iR
                Rendered[Index + 1] = iG
                Rendered[Index + 2] = iB
                Rendered[Index + 3] = iA
            }
        }
        
        IsDirty = false
        WasRendered = true
        return (Rendered, Width, Height)
    }
    
    /// Holds the was rendered flag. Reset only if the dimensions change or when the bytes are rendered.
    private var WasRendered: Bool = false
    /// Holds the cached rendered data.
    private var Rendered: [UInt8]!
    
    private func DenormalizeARGB(_ A: CGFloat, _ R: CGFloat, _ G: CGFloat, _ B: CGFloat) -> (UInt8, UInt8, UInt8, UInt8)
    {
        let FA: UInt8 = UInt8(A * 255.0)
        let FR: UInt8 = UInt8(R * 255.0)
        let FG: UInt8 = UInt8(G * 255.0)
        let FB: UInt8 = UInt8(B * 255.0)
        return (FA, FR, FG, FB)
    }
    
    /// Holds the dirty flag
    private var _IsDirty: Bool = true
    /// Get or set the dirty flag.
    public var IsDirty: Bool
    {
        get
        {
            return _IsDirty
        }
        set
        {
            _IsDirty = false
        }
    }
    
    public func AnimateInterior()
    {
        ITimer = Timer.scheduledTimer(timeInterval: TimeInterval(0.01), target: self, selector: #selector(InteriorTick),
                                      userInfo: nil, repeats: true)
    }
    
    @objc func InteriorTick()
    {
        
    }
    
    var ITimer: Timer!
    
    // MARK: Radial animation.
    
    /// Runs the animation for animating the radius to a specific value then stopping.
    ///
    /// - Parameter DL: Display link. Not used.
    @objc func UpdateRadialToAnimation(DL: CADisplayLink)
    {
        let Now = CACurrentMediaTime()
        let Interval = (Now - LastRadialUpdateTime) / RadialAnimationDuration
        self.UpdateRadiusTo(CGFloat(Interval))
    }
    
    /// Determines if the two passed values are "close enough", which can be set by changing the value of Within.
    ///
    /// - Parameters:
    ///   - To: Target value to see if TestValue is close enough.
    ///   - TestValue: Value to test against the target value in To.
    ///   - Within: Value that determines whether To and TestValue are close enough.
    /// - Returns: True if To and TestValue are within Within units, false if not.
    func CloseEnough(To: CGFloat, _ TestValue: CGFloat, Within: CGFloat = 0.5) -> Bool
    {
        return abs(To - TestValue) < Within
    }
    
    /// Animate the radius to a specific value then stop animation.
    ///
    /// - Parameter Interval: The amount by which to update the radius. This value multiplied by RadialDelta and RadiusDirection
    ///                       define the new radius.
    func UpdateRadiusTo(_ Interval: CGFloat)
    {
        LastRadialUpdateTime = CACurrentMediaTime()
        let RI = RadialDelta * Interval * RadiusDirection
        let NewRadial = Radius + RI
        Radius = NewRadial
        if CloseEnough(To: RadiusToTarget, NewRadial)
        {
            print("Reached (or close enough to) target size of \(RadiusToTarget)")
            StopAnimation(.Radius)
        }
    }
    
    /// Handle callbacks by the display link - it's time to update the radial animation.
    ///
    /// - Parameter DL: The display link. Not used.
    @objc func UpdateRadialAnimation(DL: CADisplayLink)
    {
        let Now = CACurrentMediaTime()
        let Interval = (Now - LastRadialUpdateTime) / RadialAnimationDuration
        self.UpdateRadius(CGFloat(Interval))
    }
    
    /// Update the radius during animation. Depending on user-set values, animation may be terminated here.
    ///
    /// - Parameter Interval: The amount by which to update the radius. This value multiplied by RadialDelta and RadiusDirection
    ///                       define the new radius.
    func UpdateRadius(_ Interval: CGFloat)
    {
        LastRadialUpdateTime = CACurrentMediaTime()
        let RI = RadialDelta * Interval * RadiusDirection
        var NewRadial = Radius + RI
        var EndOfHalfCycle: Bool = false
        if NewRadial < MinRadius
        {
            NewRadial = MinRadius
            RadiusDirection = 1.0
            CurrentRadialCycle = CurrentRadialCycle + 1
            EndOfHalfCycle = true
        }
        if NewRadial > MaxRadius
        {
            NewRadial = MaxRadius
            RadiusDirection = -1.0
            CurrentRadialCycle = CurrentRadialCycle + 1
            EndOfHalfCycle = true
        }
        Radius = NewRadial
        if EndOfHalfCycle && StopAtRadialHalfCycle
        {
            StopAnimation(.Radius)
        }
        if let MaxCycles = RadialMaxCycles
        {
            if CurrentRadialCycle % 2 == 0
            {
                if MaxCycles == (CurrentRadialCycle / 2)
                {
                    StopAnimation(.Radius)
                }
            }
        }
    }
    
    var CumulativeInterval: CGFloat = 0.0
    var MinRadius: CGFloat = 5.0
    var MaxRadius: CGFloat = 50.0
    var RadialDelta: CGFloat = 0.0
    var LastRadialUpdateTime = CACurrentMediaTime()
    var RadialAnimationDuration: Double = 2.0
    var RadiusAnimationDisplayLink: CADisplayLink!
    var RadiusDirection: CGFloat = -1
    var RadialMaxCycles: Int? = nil
    var CurrentRadialCycle: Int = 0
    var StopAtRadialHalfCycle: Bool = false
    
    /// Direction of animation.
    ///
    /// - ToLarger: To the larger clamp value.
    /// - ToSmaller: to the smaller clamp value.
    enum AnimationDirections
    {
        case ToLarger
        case ToSmaller
    }
    
    /// Holds the animating radius flag.
    private var _AnimatingRadius: Bool = false
    /// Get the radius is animating flag.
    public var AnimatingRadius: Bool
    {
        get
        {
            return _AnimatingRadius
        }
    }
    
    /// Animate the radial size of the blob. Animation will stop after the specified number of cycles or after a call to
    /// StopAnimation with .All or .Radius as the type of animation to stop.
    /// https://www.hackingwithswift.com/example-code/system/how-to-synchronize-code-to-drawing-using-cadisplaylink
    ///
    /// - Parameters:
    ///   - Duration: Duration of the animation in seconds. This is the time from the MinimunRadius value to the MaximumRadius value
    ///               (regardless of the direction).
    ///   - MinimumRadius: Smallest radius value target.
    ///   - MaximumRadius: Largest radius value target.
    ///   - InitialDirection: Determines the initial direction of animation.
    ///   - CycleCount: If specified, the number of cycles (one cycle is animation towards the minimum radius and animation towards
    ///                 the maximum radius) to execute. Set to nil for infinite cycles.
    public func AnimateRadius(Duration: Double = 5.0, MinimumRadius: CGFloat, MaximumRadius: CGFloat,
                              InitialDirection: AnimationDirections, CycleCount: Int? = nil)
    {
        CurrentRadialCycle = 0
        RadialMaxCycles = CycleCount
        switch InitialDirection
        {
        case .ToSmaller:
            RadiusDirection = -1.0
            
        case .ToLarger:
            RadiusDirection = 1.0
        }
        MinRadius = MinimumRadius
        MaxRadius = MaximumRadius
        RadialAnimationDuration = Duration
        RadialDelta = MaxRadius - MinRadius
        RadiusAnimationDisplayLink = CADisplayLink(target: self, selector: #selector(UpdateRadialAnimation))
        RadiusAnimationDisplayLink.preferredFramesPerSecond = 60
        RadiusAnimationDisplayLink.add(to: .current, forMode: .default)
        _AnimatingRadius = true
        delegate?.AnimationStarted(ID: ID, AnimationType: .Radius)
        self.UpdateRadius(0)
    }
    
    /// Animate the radial size of the blob. The radial size will vary between the previously set radial value and MinimumRadius.
    ///
    /// - Parameters:
    ///   - Duration: Duration of the animation in seconds. This is the time from the MinimumRadius value to the MaximumRadius value
    ///               (regardless of the direction).
    ///   - MinimumRadius: Smallest radius value target.
    ///   - InitialDirection: Determines the initial direction of animation.
    ///   - CycleCount: If specified, the number of cycles (one cycle is animation towards the minimum radius and animation towards
    ///                 the maximum radius) to execute. Set to nil for infinite cycles.
    public func AnimateRadius(Duration: Double = 5.0, MinimumRadius: CGFloat, InitialDirection: AnimationDirections, CycleCount: Int? = nil)
    {
        AnimateRadius(Duration: Duration, MinimumRadius: MinimumRadius, MaximumRadius: Radius,
                      InitialDirection: InitialDirection, CycleCount: CycleCount)
    }
    
    /// Animate the radial size of the blob. The radial size will vary between the previously set radial value and Maximum.
    ///
    /// - Parameters:
    ///   - Duration: Duration of the animation in seconds. This is the time from the MinimumRadius value to the MaximumRadius value
    ///               (regardless of the direction).
    ///   - MaximumRadius: Largest radius value target.
    ///   - InitialDirection: Determines the initial direction of animation.
    ///   - CycleCount: If specified, the number of cycles (one cycle is animation towards the minimum radius and animation towards
    ///                 the maximum radius) to execute. Set to nil for infinite cycles.
    public func AnimateRadius(Duration: Double = 5.0, MaximumRadius: CGFloat, InitialDirection: AnimationDirections, CycleCount: Int? = nil)
    {
        AnimateRadius(Duration: Duration, MinimumRadius: Radius, MaximumRadius: MaximumRadius,
                      InitialDirection: InitialDirection, CycleCount: CycleCount)
    }
    
    /// Animate the radial size of the blob half of a cycle (eg, to the largest or smallest radius, determiend by the InitialDirection).
    ///
    /// - Parameters:
    ///   - Duration: Duration of the animation in seconds. This is the time from the MinimumRadius value to the MaximumRadius value
    ///               (regardless of the direction).
    ///   - MinimumRadius: Smallest radius value target.
    ///   - MaximumRadius: Largest radius value target.
    ///   - InitialDirection: Determines the initial direction of animation.
    public func AnimateRadiusOnce(Duration: Double = 5.0, MinimumRadius: CGFloat, MaximumRadius: CGFloat,
                                  InitialDirection: AnimationDirections)
    {
        StopAtRadialHalfCycle = true
        AnimateRadius(Duration: Duration, MinimumRadius: MinimumRadius, MaximumRadius: MaximumRadius,
                      InitialDirection: InitialDirection)
    }
    
    /// Animate the radial size of the blob one cycle (from one extreme to the other), leaving the size at the size of the direction.
    ///
    /// - Parameters:
    ///   - Duration: Duration of the animation in seconds. This is the time from the MinimumRadius value to the MaximumRadius value
    ///               (regardless of the direction).
    ///   - MinimumRadius: Smallest radius value target.
    ///   - MaximumRadius: Largest radius value target.
    ///   - InitialDirection: Determines the initial direction of animation.
    public func AnimateRadiusOneCycle(Duration: Double = 5.0, MinimumRadius: CGFloat, MaximumRadius: CGFloat,
                                      InitialDirection: AnimationDirections)
    {
        AnimateRadius(Duration: Duration, MinimumRadius: MinimumRadius, MaximumRadius: MaximumRadius,
                      InitialDirection: InitialDirection, CycleCount: 1)
    }
    
    var RadiusToTarget: CGFloat = 10.0
    
    /// Animate the radius to a specific value then stop.
    ///
    /// - Parameters:
    ///   - NewRadius: New radius of the blob.
    ///   - Duration: Duration of the animation in seconds.
    public func AnimateRadiusTo(NewRadius: CGFloat, Duration: Double = 5.0)
    {
        if NewRadius == Radius
        {
            print("Radius is already at \(NewRadius) - no animation started.")
            return
        }
        RadialAnimationDuration = Duration
        RadialDelta = abs(Radius - NewRadius)
        RadiusDirection = NewRadius > Radius ? 1.0 : -1.0
        RadiusToTarget = NewRadius
        RadiusAnimationDisplayLink = CADisplayLink(target: self, selector: #selector(UpdateRadialToAnimation))
        RadiusAnimationDisplayLink.preferredFramesPerSecond = 60
        RadiusAnimationDisplayLink.add(to: .current, forMode: .default)
        _AnimatingRadius = true
        delegate?.AnimationStarted(ID: ID, AnimationType: .Radius)
        self.UpdateRadius(0)
    }
    
    // MARK: Opacity animation.
    
    /// Handle callbacks by the display link - it's time to update the alpha animation.
    ///
    /// - Parameter DL: The display link. Not used.
    @objc func UpdateAlphaAnimation(DL: CADisplayLink)
    {
        let Now = CACurrentMediaTime()
        let Interval = (Now - LastAlphaUpdateTime) / AlphaAnimationDuration
        self.UpdateAlpha(CGFloat(Interval))
    }
    
    func UpdateAlpha(_ Interval: CGFloat)
    {
        LastAlphaUpdateTime = CACurrentMediaTime()
        let AI = AlphaDelta * Interval * AlphaDirection
        var NewAlpha = BlobAlpha + AI
        if NewAlpha < MinAlphaValue
        {
            AlphaDirection = AlphaDirection * -1.0
            CurrentAlphaSemiCycleCount = CurrentAlphaSemiCycleCount + 1
            NewAlpha = MinAlphaValue
        }
        if NewAlpha > MaxAlphaValue
        {
            AlphaDirection = AlphaDirection * -1.0
            CurrentAlphaSemiCycleCount = CurrentAlphaSemiCycleCount + 1
            NewAlpha = MaxAlphaValue
        }
        BlobAlpha = NewAlpha
        if  AlphaSemiCycleCount != nil
        {
            if CurrentAlphaSemiCycleCount >= AlphaSemiCycleCount!
            {
                StopAnimation(.Alpha)
            }
        }
    }
    
    /// Holds the animating alpha flag.
    private var _AnimatingAlpha: Bool = false
    /// Get the alpha level is animating flag.
    public var AnimatingAlpha: Bool
    {
        get
        {
            return _AnimatingAlpha
        }
    }
    
    var LastAlphaUpdateTime = CACurrentMediaTime()
    var AlphaAnimationDuration: Double = 2.0
    var AlphaAnimationDisplayLink: CADisplayLink!
    var AlphaFrom: CGFloat = 1.0
    var AlphaTo: CGFloat = 0.0
    var AlphaSemiCycleCount: Int? = 0
    var CurrentAlphaSemiCycleCount: Int = 0
    var AlphaDelta: CGFloat = 0.0
    var AlphaDirection: CGFloat = 1.0
    var MinAlphaValue: CGFloat = 0.0
    var MaxAlphaValue: CGFloat = 1.0
    
    /// Animate the alpha level of the blob. This only takes effect when IroColorBlenLayer is rendering
    ///
    /// - Parameters:
    ///   - Duration: Duration of one sub-cycle (From to To) of animation in seconds.
    ///   - From: Initial alpha value. If not specified, current blob alpha value is used.
    ///   - To: Final alpha value. If not specified, the extreme alpha value furtherest away from the intial value is used.
    ///   - Count: If present, number of sub-cycles (either From to To or To to From) to animate.
    public func AnimateOpacity(Duration: Double = 5.0, From: CGFloat? = 1.0, To: CGFloat? = 0.0, Count: Int? = nil)
    {
        CurrentAlphaSemiCycleCount = 0
        if From == nil
        {
            AlphaFrom = BlobAlpha
        }
        else
        {
            AlphaFrom = CGFloat.ClampNormal(From!)
        }
        if To == nil
        {
            let Delta = 1.0 - BlobAlpha
            if Delta > 0.5
            {
                AlphaTo = 1.0
            }
            else
            {
                AlphaTo = 0.0
            }
        }
        else
        {
            AlphaTo = CGFloat.ClampNormal(To!)
        }
        MinAlphaValue = min(AlphaTo, AlphaFrom)
        MaxAlphaValue = max(AlphaTo, AlphaFrom)
        AlphaAnimationDuration = Duration
        AlphaSemiCycleCount = Count
        AlphaDelta = max(From!, To!) - min(From!, To!)
        if AlphaDelta == 0.0
        {
            print("Alpha delta is 0 - no alpha animation will take place.")
            return
        }
        AlphaDirection = From! > To! ? -1.0 : 1.0
        AlphaAnimationDisplayLink = CADisplayLink(target: self, selector: #selector(UpdateAlphaAnimation))
        AlphaAnimationDisplayLink.preferredFramesPerSecond = 60
        AlphaAnimationDisplayLink.add(to: .current, forMode: .default)
        _AnimatingRadius = true
        delegate?.AnimationStarted(ID: ID, AnimationType: .Alpha)
        self.UpdateAlpha(0)
    }
    
    public func AnimateOpacity(Duration: Double = 5.0, From: CGFloat? = 1.0, To: CGFloat? = 0.0, CycleCount: Int? = nil)
    {
        var Count: Int? = 0
        if CycleCount == nil
        {
            Count = nil
        }
        else
        {
            Count = CycleCount! * 2
        }
        AnimateOpacity(Duration: Duration, From: From, To: To, Count: Count)
    }
    
    public func AnimateOpacityInfinitely(Duration: Double = 5.0, From: CGFloat? = 1.0, To: CGFloat? = 0.0)
    {
        AnimateOpacity(Duration: Duration, From: From, To: To, Count: nil)
    }
    
    public func AnimateOpacity(Duration: Double = 5.0, To: CGFloat)
    {
        if BlobAlpha == To
        {
            print("No opacity animation - target alpha is same as current alpha.")
            return
        }
        AnimateOpacity(Duration: Duration, From: BlobAlpha, To: To, CycleCount: 1)
    }
    
    // MARK: Motion/location animation.
    
    /// Handle callbacks by the display link - it's time to update the motion animation.
    ///
    /// - Parameter DL: The display link. Not used.
    @objc func UpdateLocationAnimation(DL: CADisplayLink)
    {
        let Now = CACurrentMediaTime()
        let Interval = (Now - LastMotionUpdateTime) / CurrentMotionAnimationDuration
        self.UpdateMotion(Interval: CGFloat(Interval))
    }
    
    /// Calculate parameters for the animation segment specified by the Step parameter.
    ///
    /// - Parameter Step: Determines which segment to use to calculate parameters.
    func CalculateMotionFor(Step: Int)
    {
        CurrentMotionTarget = MotionLocations[Step].0
        CurrentMotionAnimationDuration = MotionLocations[Step].1
        if CurrentMotionAnimationDuration == 0.0
        {
            CurrentMotionAnimationDuration = 1.0
        }
        MotionXDelta = abs(BlobCenter.x - CurrentMotionTarget.x)
        if MotionXDelta == 0
        {
            MotionXDirection = 0
        }
        else
        {
            MotionXDirection = BlobCenter.x > CurrentMotionTarget.x ? -1.0 : 1.0
        }
        MotionYDelta = abs(BlobCenter.y - CurrentMotionTarget.y)
        if MotionYDelta == 0
        {
            MotionYDirection = 0
        }
        else
        {
            MotionYDirection = BlobCenter.y > CurrentMotionTarget.y ? -1.0 : 1.0
        }
    }
    
    var OffScreenMessageShown: Bool = false
    var MinDistance: Double = 10000.0
    var MinDistanceLocation: CGPoint = CGPoint.zero
    var PreviousMin: Int = 10000
    
    var OvershotCount: Int = 0
    
    var CumulativeMotion: CGFloat = 0.0
    var CMNum: Int = 0
    
    func UpdateMotion(Interval: CGFloat)
    {
        LastMotionUpdateTime = CACurrentMediaTime()
        CumulativeMotion = CumulativeMotion + Interval
        var TestPoint = TestMotion.GetPoint(Percent: Double(CumulativeMotion))
        //let fred: CGPoint = CGPoint(x: TestMotion.EndPoint.x - TestPoint.x, y: TestMotion.EndPoint.y - TestPoint.y)
       // print("\(CMNum) TestPoint=\(TestPoint), Target: \(TestMotion.EndPoint), Delta: \(fred)")
        if CumulativeMotion >= 1.0
        {
                        print("CumulativeMotion=\(CumulativeMotion), Stopping CADisplayLink")
            CumulativeMotion = 1.0
            MotionAnimationDisplayLink.remove(from: .current, forMode: .default)
            TestPoint = TestMotion.GetPoint(Percent: 1.0)
            print("Moving to final point: \(TestPoint)")
        }
        CMNum = CMNum + 1
                BlobCenter = TestPoint
    }
    
    /// Update the location/motion animation.
    ///
    /// - Parameter Interval: How far along the current segment the blob has traveled for this time unit (about 1/60th of a second).
    func xUpdateMotion(Interval: CGFloat)
    {
        LastMotionUpdateTime = CACurrentMediaTime()
       
        if MotionLocationIndex == nil
        {
            MotionLocationIndex = 0
            CalculateMotionFor(Step: MotionLocationIndex!)
        }
        
        let MIX = MotionXDelta * Interval * MotionXDirection
        var NewX = BlobCenter.x + MIX
        let MIY = MotionYDelta * Interval * MotionYDirection
        var NewY = BlobCenter.y + MIY
        
        //        let Distance = CurrentMotionTarget.Distance(NewX, NewY)
        let MinIDistance = CurrentMotionTarget.IntDistance(Int(NewX), Int(NewY))
        /*
         if Distance < MinDistance
         {
         MinDistance = Distance
         MinDistanceLocation = CGPoint(x: NewX, y: NewY)
         }
         */
        
        var EndOfSegment = false
        //See if it's time to stop running this segment.
        //If the distance is close to the target, it's time to end.
        if MinIDistance < 2
        {
            NewX = CurrentMotionTarget.x
            NewY = CurrentMotionTarget.y
            EndOfSegment = true
        }
        //If the distance from the target is increasing, we've overshot and it's time to end.
        if MinIDistance > PreviousMin
        {
            print("Overshot: \(OvershotCount)")
            OvershotCount = OvershotCount + 1
            NewX = CurrentMotionTarget.x
            NewY = CurrentMotionTarget.y
            EndOfSegment = true
        }
        else
        {
            PreviousMin = MinIDistance
        }
        
        if !OnScreen()
        {
            //The blob's region doesn't overlap with the surface - the blob is no longer visible.
            if RemoveOffScreenBlobAnimation
            {
                print("Blob \(ID) moved off screen - all animations removed.")
                StopAnimation(.All)
            }
        }

        BlobCenter = CGPoint(x: NewX, y: NewY)
        
        if EndOfSegment
        {
            PreviousMin = 100000
            delegate?.MotionSegmentEnded(ID: ID, AtSegment: MotionLocationIndex!, AtPoint: BlobCenter)
            MotionLocationIndex! = MotionLocationIndex! + 1
            if MotionLocationIndex! >= MotionLocations.count - 1
            {
                //Used up all of the segments.
                if MotionRepeatCount == nil || MotionCounter < MotionRepeatCount!
                {
                    //Resume from the first step.
                    MotionLocationIndex = 0
                    CalculateMotionFor(Step: MotionLocationIndex!)
                    MotionCounter = MotionCounter + 1
                }
                else
                {
                    //All done.
                    _AnimatingMotion = false
                    StopAnimation(.Motion)
                }
            }
            else
            {
                //Calculate next step's data.
                CalculateMotionFor(Step: MotionLocationIndex!)
            }
        }
    }
    
    var MotionCounter: Int = 0
    var LastMotionUpdateTime = CACurrentMediaTime()
    var CurrentMotionAnimationDuration: Double = 2.0
    var MotionAnimationDisplayLink: CADisplayLink!
    var MotionXDelta: CGFloat = 0.0
    var MotionYDelta: CGFloat = 0.0
    var MotionXDirection: CGFloat = 1.0
    var MotionYDirection: CGFloat = 1.0
    var MotionLocations: [(CGPoint, Double)]!
    var CurrentMotionTarget: CGPoint = CGPoint.zero
    var MotionLocationIndex: Int? = nil
    var MotionRepeatCount: Int? = nil
    
    /// Move the blob through the list of points and durations per point. The duration to move to each point is the double
    /// value in each tuple associated with the location the blob is moving to.
    ///
    /// - Parameters:
    ///   - Locations: List of location, duration pairs in tuples.
    ///   - RepeatCount: If present, the number of times to repeat the animation. If nil
    ///                  the animation is repeated infinitely. If set to 0, the path is animated one time.
    public func AnimateLocation(Locations: [(CGPoint, Double)], RepeatCount: Int? = nil)
    {
        if Locations.isEmpty
        {
            print("No locations to animate.")
            return
        }
        MotionRepeatCount = RepeatCount
        MotionCounter = 0
        MotionLocations = Locations
        MotionAnimationDisplayLink = CADisplayLink(target: self, selector: #selector(UpdateLocationAnimation))
        MotionAnimationDisplayLink.preferredFramesPerSecond = 60
        MotionAnimationDisplayLink.add(to: .current, forMode: .default)
        _AnimatingMotion = true
        delegate?.AnimationStarted(ID: ID, AnimationType: .Motion)
        UpdateMotion(Interval: 0)
    }
    
    /// Move the blob through the points specified for the specified duration.
    ///
    /// - Parameters:
    ///   - Duration: Duration for the entire path's animation. Internally, this value is divided by the number of points and
    ///               assigned equally to each.
    ///   - Points: Locations where to move the blob.
    ///    - RepeatCount: If present, the number of times to repeat the animation. If nil
    ///                   the animation is repeated infinitely. If set to 0, the path is animated one time.
    public func AnimateLocation(Duration: Double = 5.0, Points: [CGPoint], RepeatCount: Int? = nil)
    {
        if Points.isEmpty
        {
            print("No points to move to.")
            return
        }
        if Duration == 0.0
        {
            print("Invalid duration - must be greater than 0.0.")
            return
        }
        let CommonDuration = Duration / Double(Points.count)
        var FinalLocations = [(CGPoint, Double)]()
        for SomePoint in Points
        {
            FinalLocations.append((SomePoint, CommonDuration))
        }
        AnimateLocation(Locations: FinalLocations)
    }
    
    /// Move the blob to the specified point, taking the specified amount of time.
    ///
    /// - Parameters:
    ///   - Duration: The length of time to move to the new point.
    ///   - To: New point of the blob.
    public func AnimateLocation(Duration: Double = 5.0, To: CGPoint)
    {
        AnimateLocation(Locations: [(To, Duration)], RepeatCount: 0)
    }
    
    public func AnimateLocation(Duration: Double = 5, To: CGPoint, _ PMotion: MotionPath)
    {
        TestMotion = PMotion
        AnimateLocation(Locations: [(To, Duration)], RepeatCount: 0)
    }
    
    var TestMotion: MotionPath!
    
    /// Holds the animting motion flag.
    private var _AnimatingMotion: Bool = false
    /// Get the state of motion animation. Set internally indirectly.
    public var AnimatingMotion: Bool
    {
        get
        {
            return _AnimatingMotion
        }
    }
    
    public var HasMotionPaths: Bool
    {
        get
        {
            return test.count > 0
        }
    }
    
    /// Holds the draw path flag.
    private var _DrawPath: Bool = false
    /// Get or set the flag that indicates the blob wants its motion path drawn.
    public var DrawPath: Bool
    {
        get
        {
            return _DrawPath
        }
        set
        {
            _DrawPath = newValue
        }
    }
    
    private var _test: [MotionPath]!
    public var test: [MotionPath]
    {
        get
        {
            return _test
        }
        set
        {
            _test = newValue
        }
    }
    
    // MARK: General animation control.
    
    /// Defines the animations IroBlob can run.
    ///
    /// - All: All animations - used by StopAnimation.
    /// - Radius: Change radius animation.
    /// - Alpha: Change overall alpha animation.
    /// - Motio: Change the location of the blob.
    enum Animations
    {
        case All
        case Radius
        case Alpha
        case Motion
    }
    
    /// Stop animating the specified animation. Internally, all functions that stop animation call this function.
    ///
    /// - Parameter Which: Determines which animation to stop. To stop all animations, specify Animations.All.
    public func StopAnimation(_ Which: Animations)
    {
        if Which == .All || Which == .Radius
        {
            if let RadiusAnimationDisplayLink = RadiusAnimationDisplayLink
            {
                RadiusAnimationDisplayLink.remove(from: .current, forMode: .default)
                _AnimatingRadius = false
                delegate?.AnimationStopped(ID: ID, AnimationType: .Radius)
            }
        }
        if Which == .All || Which == .Alpha
        {
            if let AlphaAnimationDisplayLink = AlphaAnimationDisplayLink
            {
                AlphaAnimationDisplayLink.remove(from: .current, forMode: .default)
                _AnimatingAlpha = false
                delegate?.AnimationStopped(ID: ID, AnimationType: .Alpha)
            }
        }
        if Which == .All || Which == .Motion
        {
            if let MotionAnimationDisplayLink = MotionAnimationDisplayLink
            {
                MotionAnimationDisplayLink.remove(from: .current, forMode: .default)
                _AnimatingMotion = false
                delegate?.AnimationStopped(ID: ID, AnimationType: .Motion)
                delegate?.MotionEnded(ID: ID, AtPoint: BlobCenter)
            }
        }
    }
    
    public func RunningAnimations() -> [Animations]
    {
        var AnimList = [Animations]()
        if AnimatingRadius
        {
            AnimList.append(.Radius)
        }
        if AnimatingAlpha
        {
            AnimList.append(.Alpha)
        }
        if AnimatingMotion
        {
            AnimList.append(.Motion)
        }
        return AnimList
    }
}
