//
//  IroColorBlendProtocol.swift
//  GradientTestBed
//
//  Created by Stuart Rankin on 10/1/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Protocol to allow straightforward communications between IroBlob and IroColorBlendLayer.
protocol IroColorBlendProtocol
{
    /// Called by a blob when an attribute that can be translated to the screen (eg, a visual attribute) is updated.
    ///
    /// - Parameter ID: ID of the blob that was updated.
    func BlobUpdated(ID: UUID)
    
    /// Called when an animation is stopped.
    ///
    /// - Parameter ID: ID of the blob.
    /// - Parameter AnimationType: The type of animation that stopped.
    func AnimationStopped(ID: UUID, AnimationType: IroBlob.Animations)

    /// Called when an animation is started.
    ///
    /// - Parameter ID: ID of the blob.
    /// - Parameter AnimationType: The type of animation that started.
    func AnimationStarted(ID: UUID, AnimationType: IroBlob.Animations)
    
    /// Called when animated motion has completed.
    ///
    /// - Parameters:
    ///   - ID: ID of the blob.
    ///   - AtPoint: Where the motion animation ended.
    func MotionEnded(ID: UUID, AtPoint: CGPoint)
    
    /// Called when a motion segment has completed.
    ///
    /// - Parameters:
    ///   - ID: ID of the blob.
    ///   - AtSegment: Index of the segment that completed.
    ///   - AtPoint: Where the segment ended.
    func MotionSegmentEnded(ID: UUID, AtSegment: Int, AtPoint: CGPoint)
    
    /// Returns the surface size where the blobs are drawn.
    ///
    /// - Returns: Rectangle describing the size of the surface.
    func SurfaceSize() -> CGRect
}
