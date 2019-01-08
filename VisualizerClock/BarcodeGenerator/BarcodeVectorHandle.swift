//
//  BarcodeVectorHandle.swift
//  Visualizer Clock
//
//  Created by Stuart Rankin on 11/14/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit
import SpriteKit

/// Implements a handle for drawing barcodes in 3D space.
class BarcodeVectorHandle
{
    /// Name of the node in 3D space.
    public static let BoxNodeName = "BoxNode"
    
    /// Initializer.
    ///
    /// - Parameters:
    ///   - Width: Width of the frame.
    ///   - Height: Height of the frame
    init(Width: Int, Height: Int)
    {
        _Width = Width
        _Height = Height
    }
    
    /// Initializer.
    ///
    /// - Parameters:
    ///   - Width: Width of the frame.
    ///   - Height: Height of the frame.
    ///   - Top: Top margin.
    ///   - Left: Left margin.
    ///   - Bottom: Bottom margin.
    ///   - Right: Right margin.
    init(Width: Int, Height: Int, Top: Int = 0, Left: Int = 0, Bottom: Int = 0, Right: Int = 0)
    {
        _Width = Width
        _Height = Height
        _TopMargin = Top
        _LeftMargin = Left
        _BottomMargin = Bottom
        _RightMargin = Right
    }
    
    /// Contains the width of the frame/bounds of the view.
    private var _Width: Int = 0
    /// Contains the height of the frame/bounds of the view.
    private var _Height: Int = 0
    
    /// Get the size of the view.
    public var ViewSize: CGSize
    {
        get
        {
            assert(!IsClosed, "ViewSize: Handle is closed.")
            return CGSize(width: _Width, height: _Height)
        }
    }
    
    /// Determines if the handle is ready to be used. Returns true if the handle can be used, false if not.
    public var IsReady: Bool
    {
        get
        {
            assert(!IsClosed, "IsReady: Handle is closed.")
            return _View3D != nil
        }
    }
    
    /// Holds the 3D scene where the barcode is drawn.
    private var _View3D: SCNView? = nil
    /// Get or set the 3D scene where the barcode is drawn.
    public var View3D: SCNView?
    {
        get
        {
            assert(!IsClosed, "View3D: Handle is closed.")
            return _View3D
        }
        set
        {
            assert(!IsClosed, "View3D: Handle is closed.")
            _View3D = newValue
        }
    }
    
    /// Add a node to the 3D view/scene.
    ///
    /// - Parameter NewNode: Node to add.
    public func AddNode(_ NewNode: SCNNode)
    {
        assert(!IsClosed, "AddNode: Handle is closed.")
        View3D?.scene?.rootNode.addChildNode(NewNode)
    }
    
    /// Holds the top margin value.
    private var _TopMargin: Int = 0
    /// Get or set the top margin value.
    public var TopMargin: Int
    {
        get
        {
            assert(!IsClosed, "TopMargin: Handle is closed.")
            return _TopMargin
        }
        set
        {
            assert(!IsClosed, "TopMargin: Handle is closed.")
            _TopMargin = newValue
        }
    }
    
    /// Holds the left margin value.
    private var _LeftMargin: Int = 0
    /// Get or set the left margin value.
    public var LeftMargin: Int
    {
        get
        {
            assert(!IsClosed, "LeftMargin: Handle is closed.")
            return _LeftMargin
        }
        set
        {
            assert(!IsClosed, "LeftMargin: Handle is closed.")
            _LeftMargin = newValue
        }
    }
    
    /// Holds the bottom margin value.
    private var _BottomMargin: Int = 0
    /// Get or set the bottom margin value.
    public var BottomMargin: Int
    {
        get
        {
            assert(!IsClosed, "BottomMargin: Handle is closed.")
            return _BottomMargin
        }
        set
        {
            assert(!IsClosed, "BottomMargin: Handle is closed.")
            _BottomMargin = newValue
        }
    }
    
    /// Holds the right margin value.
    private var _RightMargin: Int = 0
    /// Get or set the right margin value.
    public var RightMargin: Int
    {
        get
        {
            assert(!IsClosed, "RightMargin: Handle is closed.")
            return _RightMargin
        }
        set
        {
            assert(!IsClosed, "RightMargin: Handle is closed.")
            _RightMargin = newValue
        }
    }
    
    /// Get the total number of barcode nodes drawn in 3D space. This quantity excludes nodes such as cameras and lights.
    public var NodeCount: Int
    {
        get
        {
            assert(!IsClosed, "NodeCount: Handle is closed.")
            var Count = 0
            View3D?.scene?.rootNode.childNodes.forEach(
                {
                    if $0.name == BarcodeVectorHandle.BoxNodeName
                    {
                        Count = Count + 1
                    }
                }
            )
            return Count
        }
    }
    
    /// Get the total number of nodes in 3D space, including cameras and lights.
    public var TotalNodeCount: Int
    {
        get
        {
            assert(!IsClosed, "TotalNodeCount: Handle is closed.")
            return (View3D?.scene?.rootNode.childNodes.count)!
        }
    }
    
    /// Remove all 3D barcode nodes from the view.
    public func RemoveChildNodes()
    {
        assert(!IsClosed, "RemoveChildNodes: Handle is closed.")
        RemoveChildNodes(WithName: BarcodeVectorHandle.BoxNodeName)
    }
    
    /// Remove all nodes from the view with the specified name.
    ///
    /// - Parameter WithName: Name of the node(s) to remove. All nodes with this name will be removed.
    public func RemoveChildNodes(WithName: String)
    {
        assert(!IsClosed, "RemoveChildNodes(WithName): Handle is closed.")
        View3D?.scene?.rootNode.childNodes.forEach(
            {
                if $0.name == BarcodeVectorHandle.BoxNodeName
                {
                    $0.removeFromParentNode()
                }
            }
        )
    }
    
    /// Close this handle such that it can no longer be used.
    public func Close()
    {
        assert(!IsClosed, "Close: Handle is closed.")
        View3D = nil
        _IsClosed = true
    }
    
    /// Holds the is closed flag.
    private var _IsClosed: Bool = false
    /// Get the is closed flag. If the return value is true, this handle may no longer be used and attempting to do so will
    /// will result in an assertion failure. Once closed, the only valid calls to this handle are: IsClosed.
    public var IsClosed: Bool
    {
        get
        {
            return _IsClosed
        }
    }
}
