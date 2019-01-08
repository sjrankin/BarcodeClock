//
//  Geometry.swift
//  Visualizer Clock
//
//  Created by Stuart Rankin on 10/14/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class Geometry
{
    public static func PrettyPrint(_ Point: CGPoint) -> String
    {
        let x: String = "\(Point.x.rounded(.down))"
        let y: String = "\(Point.y.rounded(.down))"
        return "(\(x),\(y))"
    }
    
    /// Return a random point.
    ///
    /// - Parameters:
    ///   - Width: Maximum permissible width.
    ///   - Height: Maximum permissible height.
    /// - Returns: Random point within the passed parametes.
    public static func RandomPoint(Width: CGFloat, Height: CGFloat) -> CGPoint
    {
        return CGPoint(x: CGFloat.random(in: 0 ..< Width), y: CGFloat.random(in: 0 ..< Height))
    }
    
    /// Return a random point off screen.
    ///
    /// - Parameters:
    ///   - VisibleFrame: The visible dimensions of the screen.
    ///   - Offset: offset to apply to the off screen point calculation.
    /// - Returns: Point off the visible screen.
    public static func RandomOffscreenPoint(VisibleFrame: CGRect, Offset: CGFloat = 100.0) -> CGPoint
    {
        let Angle = CGFloat.random(in: 0.0 ... 359.0)
        let Radius = max(VisibleFrame.width, VisibleFrame.height) + Offset
        let OffScreen = PolarToCartesian(r: Double(Radius), theta: Double(Angle))
        return OffScreen
    }
    
    public static func RandomPointInSector(Sector: ClosedRange<CGFloat>, MinimumRadius: CGFloat? = nil, MaximumRadius: CGFloat?) -> CGPoint?
    {
        if Sector.lowerBound > Sector.upperBound
        {
            return nil
        }
        let NewAngle = CGFloat.random(in: Sector)
        var Lower: CGFloat = 0.0
        if let MinimumRadius = MinimumRadius
        {
            Lower = MinimumRadius
        }
        var Upper: CGFloat = 0.0
        if let MaximumRadius = MaximumRadius
        {
            Upper = MaximumRadius
        }
        let Radial = CGFloat.random(in: Lower ... Upper)
        return PolarToCartesian(r: Double(Radial), theta: Double(NewAngle))
    }
    
    /// Given an angle, return its clock sector (where sectors are defined as the sector between hour markings).
    ///
    /// - Parameter Angle: The angle that determines the returned sector.
    /// - Returns: Sector defined as two angles.
    public func SectorRange(Angle: Double) -> ClosedRange<CGFloat>
    {
        var r = Angle / 30.0
        r = r.rounded(.down)
        let ri = Int(r)
        let rng: ClosedRange<CGFloat> = CGFloat(ri) * 30.0 ... CGFloat(ri + 1) * 30.0
        return rng
    }
    
    /// Return the angle between Point1 and Point2. If not specified, Point2 is set to (0,0)
    // https://stackoverflow.com/questions/1311049/how-to-map-atan2-to-degrees-0-360
    ///
    /// - Parameters:
    ///   - Point1: First point - usually the point of interest.
    ///   - Point2: Second point. If not specified, set to (0,0). Usually interpreted as the origin point.
    ///   - Offset: Optional offset to add to the result before being returned. If not specified, set to 90.0.
    /// - Returns: Angle (in degrees) between Point1 and Point2. If Offset specified, includes that value as well.
    public static func AngleFromPoint(Point1: CGPoint, Point2: CGPoint = CGPoint(x: 0, y: 0), Offset: Double = 90.0) -> Double
    {
        var Angle: Double = 0.0
        let DeltaX = Double(Point2.x - Point1.x)
        let DeltaY = Double(Point2.y - Point1.y)
        //Get the angle in radians.
        Angle = Angle + atan2(DeltaY, DeltaX)
        //Convert to degrees.
        Angle = Angle * 180.0 / Double.pi
        //Add the offset.
        Angle = Angle + Offset
        //Adjust to restrict to the range of 0 to 360.
        Angle = fmod((Angle + 360.0), 360.0)
        return Angle
    }
    
    /// Given a radius and center, return a point on a circle at the given angle. (In other words, convert from polar coordinates
    /// to cartesian coordinates.)
    ///
    /// - Parameters:
    ///   - Radius: Radius from the center of the circle where the point will be placed.
    ///   - Angle: Angle (in degrees) that determines the location of the point.
    ///   - Center: Center of the circle in local coordinates.
    /// - Returns: Point defined by the polar coordinates radius and angle.
    public static func RadialCoordinate(Radius: Double, Angle: Double, Center: CGPoint) -> CGPoint
    {
        let Radians = Angle * Double.pi / 180.0
        let X: CGFloat = CGFloat(Center.x + CGFloat((Radius * cos(Radians))))
        let Y: CGFloat = CGFloat(Center.y + CGFloat((Radius * sin(Radians))))
        return CGPoint(x: X, y: Y)
    }
    
    /// Create a radial path (eg, circular) around the passed center point and radius.
    ///
    /// - Parameters:
    ///   - Radius: Radial distance from the center point.
    ///   - Center: Center of the circle.
    /// - Returns: Array of 360 points describing a circle at radius away from the center.
    public static func RadialPath(Radius: Double, Center: CGPoint) -> [CGPoint]
    {
        var Results = [CGPoint]()
        
        for IAngle in 0 ... 359
        {
            let Angle: Double = Double(IAngle)
            Results.append(RadialCoordinate(Radius: Radius, Angle: Angle, Center: Center))
        }
        
        return Results
    }
    
    /// Create a radial path (eg, circular) around the passed center point and radius.
    ///
    /// - Parameters:
    ///   - Radius: Radial distance from the center point.
    ///   - Center: Center of the circle.
    ///   - TotalDuration: The total time (in any unit). This value will be divided by the number of points returned by
    ///                    RadialPath(Double,CGPoint) and used as part of each returned tuple.
    /// - Returns: Array of tuples. Each tuple has a point and a duration.
    public static func RadialPath(Radius: Double, Center: CGPoint, TotalDuration: Double) -> [(CGPoint, Double)]
    {
        let Points = RadialPath(Radius: Radius, Center: Center)
        var Results = [(CGPoint, Double)]()
        if Points.count == 0
        {
            return Results
        }
        let CommonDuration = TotalDuration / Double(Points.count)
        for Point in Points
        {
            Results.append((Point, CommonDuration))
        }
        return Results
    }
    
    /// Return a list of MotionPaths based on a circular path around the passed center and radial.
    ///
    /// - Parameters:
    ///   - StartPoint: The starting point. This determines the first point in the returned list of MotionPaths. This is to ensure
    ///                 motion doesn't cause objects to zoom across the screen to the first location.
    ///   - Radius: The radius of the circle/circular path.
    ///   - Center: Center of the circle about which the circular path will be constructed.
    ///   - TotalDuration: Total duration of motion around the circle. Each segment in the path will have an equal sub-duration.
    /// - Returns: List of MotionPath instances to send to the IroBlob for motion.
    public static func RadialPath(StartPoint: CGPoint, Radius: Double, Center: CGPoint, TotalDuration: Double) -> [MotionPath]
    {
        let StartingAngle = Int(AngleFromPoint(Point1: StartPoint, Point2: Center))
        var Paths = [MotionPath]()
        let Points = RadialPath(Radius: Radius, Center: Center)
        let CommonDuration = TotalDuration / Double(Points.count)
        
        var IndexAngle = StartingAngle
        for _ in 0 ..< Points.count
        {
            var PreviousAngle = IndexAngle - 1
            if PreviousAngle < 0
            {
                PreviousAngle = Points.count - 1
            }
            let NewPath = MotionPath(Start: Points[PreviousAngle], End: Points[IndexAngle], Duration: CommonDuration, Action: .RunNextPath)
            Paths.append(NewPath)
            IndexAngle = IndexAngle + 1
            if IndexAngle > Points.count - 1
            {
                IndexAngle = 0
            }
        }
        
        return Paths
    }
    
    /// Return the hypotenuse of the triangle formed by the two points (with the third inferred).
    ///
    /// - Parameters:
    ///   - Point1: First point.
    ///   - Point2: Second point.
    /// - Returns: Hypotenuse formed by the two passed points and one inferred point.
    public static func HypotenuseFor(Point1: CGPoint, Point2: CGPoint) -> Double
    {
        let A = Point2.y - Point1.y
        let B = Point2.x - Point1.x
        let C = sqrt((A * A) + (B * B))
        return Double(C)
    }
    
    /// Return the Run:Hypotenuse and Rise:Hypotenuse ratios for the triangle defined by the two passed points (the
    /// third point is inferred from the two passed points). The ratios can be used during animation to calculate
    /// distances along the hypotenuse.
    ///
    /// - Parameters:
    ///   - Point1: First point.
    ///   - Point2: Second point.
    /// - Returns: Tuple with contents in the order: (Run:Hypotenuse ratio, Rise:Hypotenuse ratio).
    public static func CreateMotionRatios(Point1: CGPoint, Point2: CGPoint) -> (Double, Double)
    {
        let A = Point2.y - Point1.y
        let B = Point2.x - Point1.x
        let C = sqrt((A * A) + (B * B))
        let RunRatio = Double(B / C)
        let RiseRatio = Double(A / C)
        return (RunRatio, RiseRatio)
    }
    
    /// Rotate a point by the specified number of degrees around the supplied center point.
    ///
    /// - Parameters:
    ///   - Point: The point to rotate.
    ///   - Degrees: Number of degrees to rotate by.
    ///   - Around: Center point. If not specified, (0,0) will be used.
    /// - Returns: Rotated point.
    public static func RotatePoint(_ Point: CGPoint, Degrees: Double, Around: CGPoint = CGPoint.zero) -> CGPoint
    {
        let Radians: CGFloat = CGFloat(Degrees) * CGFloat.pi / 180.0
        let SinValue = sin(Radians)
        let CosValue = cos(Radians)
        let X = Point.x - Around.x
        let Y = Point.y - Around.y
        let NewX = (X * CosValue) - (Y * SinValue)
        let NewY = (X * SinValue) + (Y * CosValue)
        let Rotated = CGPoint(x: NewX + Around.x, y: NewY + Around.y)
        return Rotated
    }
    
    /// Return a cartesian point from the polar coordinate passed to us.
    ///
    /// - Parameters:
    ///   - r: Radius of the point from its origin.
    ///   - theta: Angle of the point.
    ///   - Offset: Optional offset to add to the angle before it is converted to radians.
    ///   - Center: If present, the point (assumed to be the center of the plotting region) to be added to the generated
    ///             cartesian coordinate.
    /// - Returns: Cartesian equivalent of the passed polar coordinate.
    public static func PolarToCartesian(r: Double, theta: Double, Offset: Double = 90.0, Center: CGPoint? = nil) -> CGPoint
    {
        let Radians = (theta + Offset) * Double.pi / 180.0
        let X = -r * cos(Radians)
        let Y = -r * sin(Radians)
        var XOffset: CGFloat = 0.0
        var YOffset: CGFloat = 0.0
        if let Center = Center
        {
            XOffset = Center.x
            YOffset = Center.y
        }
        return CGPoint(x: X + Double(XOffset), y: Y + Double(YOffset))
    }
    
    /// Rotate all points in the passed array of point by the supplied number of degrees around the specified center point.
    ///
    /// - Parameters:
    ///   - Source: Contains a list of points to rotate.
    ///   - Degrees: Number of degrees to rotate each point by.
    ///   - Around: Center point.
    /// - Returns: New array of rotated points in the same order as the passed array.
    public static func RotatePointList(_ Source: [CGPoint], Degrees: Double, Around: CGPoint) -> [CGPoint]
    {
        var Rotated = [CGPoint]()
        for Point in Source
        {
            let NewPoint = RotatePoint(Point, Degrees: Degrees, Around: Around)
            Rotated.append(NewPoint)
        }
        return Rotated
    }
    
    /// Returns a list of points that defines a spiral. The starting point is implicitly defined by the StartingAngle and InitialRadius
    /// and is also implicitly a polar coordinate.
    ///
    /// - Bug:
    ///     This function is buggy - it only works if the starting angle is 0.0.
    ///
    /// - Parameters:
    ///   - StartingAngle: Starting angle - for now, must be 0.0 in order for a proper spiral to be created.
    ///   - InitialRadius: The starting radius of the first point.
    ///   - Rotations: How many rotations (from StartingAngle to StartingAngle) to create.
    ///   - Steps: Number of steps. This is also the number of points returned. This value is independent of the number of rotations
    ///            the loop will create.
    ///   - RadialDelta: Direction of the cyclical radial change - eg, from the point to the center or away from the center.
    ///   - Center: The center of the plotting area.
    ///   - RadiusOffset: The offset value to add to the calculation for the CyclicalRadiusAdjustment value.
    /// - Returns: List of points that defines the spiral as determined by the passed parameters.
    public static func MakeSpiral(StartingAngle: CGFloat, InitialRadius: CGFloat, Rotations: CGFloat, Steps: Int, RadialDelta: CGFloat,
                                  Center: CGPoint, RadiusOffset: CGFloat = 0.0) -> [CGPoint]
    {
        var Results = [CGPoint]()
        let FinalAngle = StartingAngle + (Rotations * 360.0)
        let AngleDelta = FinalAngle - StartingAngle
        let AngleStep = AngleDelta / CGFloat(Steps)
        let CyclicalRadiusAdjustment = (InitialRadius + RadiusOffset) / CGFloat(Steps) * RadialDelta
        
        let LoopStart: Int = Int(StartingAngle)
        let LoopEnd: Int = Steps + Int(StartingAngle)
        var Count = 0
        
        for Increment in LoopStart ..< LoopEnd
        {
            let NewRadius = InitialRadius + (CGFloat(Increment) * CyclicalRadiusAdjustment) + (RadiusOffset * RadialDelta)
            let IncrementAngle = (Double(Count) * Double(AngleStep)) + Double(StartingAngle)
            let Point = PolarToCartesian(r: Double(NewRadius), theta: IncrementAngle, Center: Center)
            Results.append(Point)
            Count = Count + 1
        }
        
        return Results
    }
    
    /// Return the distance between the two points.
    ///
    /// - Parameters:
    ///   - From: First point.
    ///   - To: Second point.
    /// - Returns: Distance (in cartesian units) between the two points.
    public static func Distance(From: CGPoint, To: CGPoint) -> CGFloat
    {
        let Term1: CGFloat = (From.x - To.x) * (From.x - To.x)
        let Term2: CGFloat = (From.y - To.y) * (From.y - To.y)
        return sqrt(Term1 + Term2)
    }
    
    /// Contains a dictionary of generated spiral data. The key acts as the hour and value as the set of points that define a
    /// spiral for that hour.
    private static var SavedSpirals = [Int: [CGPoint]]()
    
    /// Get the number of saved spirals (not points).
    public static var SpiralCount: Int
    {
        get
        {
            return SavedSpirals.count
        }
    }
    
    /// Determine if pre-defined spiral data exists for the passed hour/key.
    ///
    /// - Parameter For: Key/hour used to determine existence of spiral data.
    /// - Returns: True if the spiral data exists, false if not.
    public static func SpiralExists(For: Int) -> Bool
    {
        return SavedSpirals[For] != nil
    }
    
    /// Save spiral data for use later on. This lets spiral data be created once rather than every time it's needed.
    ///
    /// - Parameters:
    ///   - Hour: The hour/key for the passed spiral data.
    ///   - SpiralPath: Set of points that define a spiral.
    public static func SaveSpiral(Hour: Int, SpiralPath: [CGPoint])
    {
        SavedSpirals[Hour] = SpiralPath
    }
    
    /// Return spiral data for the passed key/hour.
    ///
    /// - Parameters:
    ///   - For: The key/hour whose spiral data will be returned.
    ///   - Reversed: If true, the spiral data will be reversed before being returned (but the original data will not be modified).
    /// - Returns: Set of points that defines a spiral for the passed key. Order reversed if Reversed is true. Nil if no data found.
    public static func GetSpiral(For: Int, Reversed: Bool = false) -> [CGPoint]?
    {
        if let Points = SavedSpirals[For]
        {
            if Reversed
            {
                var ReversedOrder = [CGPoint]()
                for Point in Points
                {
                    ReversedOrder.insert(Point, at: 0)
                }
                return ReversedOrder
            }
            else
            {
                return Points
            }
        }
        else
        {
            return nil
        }
    }
}
