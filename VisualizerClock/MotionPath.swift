//
//  MotionPath.swift
//  Visualizer Clock
//
//  Created by Stuart Rankin on 10/14/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Actions for the path processor to take when this path is completed.
///
/// - RunNextPath: Run the next path if it exists. If this is the last path, stop.
/// - Stop: Stop running paths.
/// - Repeat: Repeat the path.
/// - RunFirstPath: Run the first path in the sequence. If this is the only path in the sequence, it is run again.
/// - RunPreviousPath: Run the previous path in the secquence. If this is the only path in the sequence, it is run again.
/// - DiscardRunNext: Discard this path and run the next path. Discard means the MotionPath is reomved from list of paths
///                   to execute.
enum TerminalActions
{
    case RunNextPath
    case Stop
    case Repeat
    case RunFirstPath
    case RunPreviousPath
    case DiscardRunNext
}

/// Describes the motion something can take. Motion is defined by two points - the starting point and the ending point, as well as the duration
/// to take to get from the start to the end.
class MotionPath
{
    /// Initialize the path.
    ///
    /// - Parameters:
    ///   - Start: Starting point.
    ///   - End: Ending point
    ///   - Duration: Duration of the motion.
    ///   - Action: Action to take at the end of the motion - when the path has been completed.
    init(Start: CGPoint, End: CGPoint, Duration: Double, Action: TerminalActions = .RunNextPath)
    {
        TerminalAction = Action
        PathDuration = Duration
        StartPoint = Start
        EndPoint = End
        let (RunRatio, RiseRatio) = Geometry.CreateMotionRatios(Point1: StartPoint, Point2: EndPoint)
        RunHypotenuseRatio = RunRatio
        RiseHypotenuseRatio = RiseRatio
        _Hypotenuse = Geometry.HypotenuseFor(Point1: StartPoint, Point2: EndPoint)
    }
    
    /// Initialize the path.
    ///
    /// - Parameters:
    ///   - Start: Starting point.
    ///   - End: Ending point
    ///   - Duration: Duration of the motion.
    ///   - PostDelay: Amount of time to delay before reporting path completion.
    ///   - Action: Action to take at the end of the motion - when the path has been completed.
    init(Start: CGPoint, End: CGPoint, Duration: Double, PostDelay: Double, Action: TerminalActions = .RunNextPath)
    {
        TerminalAction = Action
        PathDuration = Duration
        StartPoint = Start
        EndPoint = End
        PostPathDelay = PostDelay
        let (RunRatio, RiseRatio) = Geometry.CreateMotionRatios(Point1: StartPoint, Point2: EndPoint)
        RunHypotenuseRatio = RunRatio
        RiseHypotenuseRatio = RiseRatio
        _Hypotenuse = Geometry.HypotenuseFor(Point1: StartPoint, Point2: EndPoint)
    }
    
    /// Holds the delay for post-path completion.
    private var _PostPathDelay: Double = 0.0
    /// Get or set the delay time to wait after the path has been completed.
    public var PostPathDelay: Double
    {
        get
        {
            return _PostPathDelay
        }
        set
        {
            _PostPathDelay = newValue
        }
    }
    
    /// Holds the hypotenuse formed by the start and end points and inferred right-triangle point.
    private var _Hypotenuse: Double = 0.0
    /// Get the hypotenuse formed by the start and end pionts and inferred right-triangle point.
    public var Hypotenuse: Double
    {
        get
        {
            return _Hypotenuse
        }
    }
    
    /// Holds the done flag.
    private var _IsDone: Bool = false
    /// Get or set the done flag. This can be used to indicate the path has been followed fully. It is set by the path processor.
    public var IsDone: Bool
    {
        get
        {
            return _IsDone
        }
        set
        {
            _IsDone = newValue
        }
    }
    
    /// Holds the terminal action.
    private var _TerminalAction: TerminalActions = .Stop
    /// Get or set the terminal action to take once this path has been completed.
    public var TerminalAction: TerminalActions
    {
        get
        {
            return _TerminalAction
        }
        set
        {
            _TerminalAction = newValue
        }
    }
    
    /// Holds the number of times the path has been fully completed.
    private var _PathCompletedCount: Int = 0
    /// Get or set the path completion count.
    public var PathCompletedCount: Int
    {
        get
        {
            return _PathCompletedCount
        }
        set
        {
            _PathCompletedCount = newValue
        }
    }
    
    /// Holds the direction of motion.
    private var _Direction: CGFloat = 1.0
    /// Get or set the direction of motion 1.0 for forward motion and -1.0 for reverse (along the path) motion. Invalid directions
    /// are ignored. (When DEBUG is true, an assertion fails if setting any value not 1.0 or -1.0.)
    public var Direction: CGFloat
    {
        get
        {
            return _Direction
        }
        set
        {
            assert(newValue != 1.0 && newValue != 1.0, "Bad direction value: must be 1.0 or -1.0.")
            _Direction = newValue
        }
    }
    
    /// Holds the duration of the path.
    private var _PathDuration: Double = 0.0
    /// Get or set the duration of the path.
    public var PathDuration: Double
    {
        get
        {
            return _PathDuration
        }
        set
        {
            _PathDuration = newValue
        }
    }
    
    /// Holds the starting point.
    private var _StartPoint: CGPoint? = nil
    /// Get or set the starting point. If the start point hasn't been defined. CGPoint.zero is returned.
    public var StartPoint: CGPoint
    {
        get
        {
            if _StartPoint == nil
            {
                return CGPoint.zero
            }
            return _StartPoint!
        }
        set
        {
            _StartPoint = newValue
        }
    }
    
    /// Holds the ending point.
    private var _EndPoint: CGPoint? = nil
    /// Get or set the ending point. If the end point hasn't been defined. CGPoint.zero is returned.
    public var EndPoint: CGPoint
    {
        get
        {
            if _EndPoint == nil
            {
                return CGPoint.zero
            }
            return _EndPoint!
        }
        set
        {
            _EndPoint = newValue
        }
    }
    
    /// Holds the run to hypotenuse ratio.
    private var _RunHypotenuseRatio: Double = 0.0
    /// Get or set the run to hypotenuse ratio.
    public var RunHypotenuseRatio: Double
    {
        get
        {
            return _RunHypotenuseRatio
        }
        set
        {
            _RunHypotenuseRatio = newValue
        }
    }
    
    /// Hold the rise to hypotenuse ratio.
    private var _RiseHypotenuseRatio: Double = 0.0
    /// Get or set the rise to hypotenuse ratio.
    public var RiseHypotenuseRatio: Double
    {
        get
        {
            return _RiseHypotenuseRatio
        }
        set
        {
            _RiseHypotenuseRatio = newValue
        }
    }
    
    /// Return the X value on the hypotenuse Percent of the way from the starting point.
    ///
    /// - Parameters:
    ///   - Percent: Distance from the starting point to determine the X value. If Direction is -1, the percent is for
    ///              distance from the ending point.
    ///   - Direction: 1 for distance from the starting point, -1 for the distance from the ending point.
    /// - Returns: Horizontal (X) position of the hypotenuse at Percent distance from the starting or ending point (determined
    ///            by the value of Direction).
    public func GetX(_ Percent: Double, _ Direction: Int = 1) -> CGFloat
    {
        let Dir = Direction == 1 ? Double(1.0) : Double(1.0 - Double(Direction))
        var X = Hypotenuse * (Dir * Percent)
        X = X * RunHypotenuseRatio
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
    public func GetY(_ Percent: Double, _ Direction: Int = 1) -> CGFloat
    {
        let Dir = Direction == 1 ? Double(1.0) : Double(1.0 - Double(Direction))
        var Y = Hypotenuse * (Dir * Percent)
        Y = Y * RiseHypotenuseRatio
        return CGFloat(Y) + StartPoint.y
    }
    
    /// Return the point along the hypotenuse Percent of the way from the starting point. If Direction is -1, the
    /// returned point is Percent of the way from the ending point.
    ///
    /// - Parameters:
    ///   - Percent: How far from the starting point the returned point is along the hypotenuse.
    ///   - Direction: Determines direction - 1 for distance from starting point, -1 for distance from ending point.
    /// - Returns: Point along the hypotenuse Percent distance from the starting (or ending point if Direction is -1) point.
    public func GetPoint(Percent: Double, Direction: Int = 1) -> CGPoint
    {
        return CGPoint(x: GetX(Percent, Direction), y: GetY(Percent, Direction))
    }
}
