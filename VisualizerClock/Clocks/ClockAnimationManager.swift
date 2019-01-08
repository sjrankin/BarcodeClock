//
//  ClockAnimationManager.swift
//  Visualizer Clock
//
//  Created by Stuart Rankin on 9/23/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Manages clock animations for vector-based clocks. Non-vector based clocks are essentially ignored.
class ClockAnimationManager
{
    /// Set a clock to animate. Only one clock at a time may be animated. Successfully setting the clock will remove all animations
    /// set previously.
    ///
    /// - Parameter Clock: The clock to animate. If the clock has already been set, false will be returned but animation may
    ///                    be executed. If Clock is not vector based, false is returned and animation may not be executed.
    /// - Returns: True on success, false on error (trying to set the same clock more than one time in a row, or the clock is not vector based).
    @discardableResult public static func ClockToAnimate(_ Clock: ClockProtocol) -> Bool
    {
        if let AnimateClock = AnimateClock
        {
            if AnimateClock.ClockID == Clock.ClockID
            {
                return false
            }
        }
        if !Clock.IsVectorBased
        {
            _AnimationState = .InvalidClock
            AnimateClock = nil
            return false
        }
        AnimateClock = Clock
        AnimationList.removeAll()
        _AnimationState = .NotStarted
        return true
    }
    
    /// Get the ID of the clock being animated. Nil returned if no clock is set.
    public static var CurrentID: UUID?
    {
        get
        {
            if let AnimateClock = AnimateClock
            {
                return AnimateClock.ClockID
            }
            return nil
        }
    }
    
    /// Contains the clock to animate. Nil if no clock was set.
    private static var AnimateClock: ClockProtocol? = nil
    
    /// Set the animations to apply to the clock. No animations occur until StartAnimation is called.
    ///
    /// - Parameter Animations: List of animations to apply to the clock.
    /// - Returns: True on success, false on failure (no clock available to apply the animations to - most likely because the
    ///            clock doesn't support vectors).
    @discardableResult public static func SetAnimations(_ Animations: [ClockAnimations]) -> Bool
    {
        if AnimationState == .InvalidClock
        {
            print("Clock not valid for animation.")
            return false
        }
        AnimationList.removeAll()
        AnimationList = Animations
        _AnimationState = .Ready
        return true
    }
    
    /// Holds a list of animations to apply to the currently set clock.
    private static var AnimationList = [ClockAnimations]()
    
    /// Start execution of animations.
    ///
    /// - Returns: True on success, false if no clock to animate or no animations were set in SetAnimations (eg, the animation list is emtpy).
    @discardableResult public static func StartAnimation() -> Bool
    {
        if AnimateClock == nil
        {
            print("No clock to animate.")
            return false
        }
        if AnimationList.isEmpty
        {
            print("Animation list is empty.")
            return false
        }
        _AnimationState = .Running
        return true
    }
    
    private static var ColorTimer: Timer? = nil
    private static var MotionTimer: Timer? = nil
    
    /// Pause animations. Call this function to temporarily halt animation in the clock. Call this function to change animations. Call StartAnimation
    /// to restart animations.
    ///
    /// - Returns: True on success, false on failure.
    @discardableResult public static func PauseAnimation() -> Bool
    {
        if AnimationState == .InvalidClock
        {
            return false
        }
        _AnimationState = .Paused
        return true
    }
    
    /// Stop all animations. Clear the animation list. Remove the clock to be animated.
    public static func Stop()
    {
        if ColorTimer != nil
        {
            ColorTimer?.invalidate()
            ColorTimer = nil
        }
        if MotionTimer != nil
        {
            MotionTimer?.invalidate()
            MotionTimer = nil
        }
        AnimateClock = nil
        AnimationList.removeAll()
        _AnimationState = .Stopped
    }
    
    private static var _AnimationState: AnimationStates = .NotStarted
    public static var AnimationState: AnimationStates
    {
        get
        {
            return _AnimationState
        }
    }
}

/// Types of supported animations.
///
/// - Color: Color animation. Nodes have their foreground color changed, potentially individually.
/// - Motion: Motion animation. Nodes may have their positions changed, potentially individually.
enum ClockAnimations
{
    case Color
    case Motion
}

/// Animation states.
///
/// - NotStarted: Animation not stated but valid clock assigned.
/// - Ready: Animation ready, animation types assigned.
/// - Running: Animation is running.
/// - Paused: Animation is paused.
/// - Stopped: Animation is stopped and clocks and animation types removed.
/// - InvalidClock: No animation possible - invalid clock (eg, not vectorized) attempted to be set.
enum AnimationStates
{
    case NotStarted
    case Ready
    case Running
    case Paused
    case Stopped
    case InvalidClock
}
