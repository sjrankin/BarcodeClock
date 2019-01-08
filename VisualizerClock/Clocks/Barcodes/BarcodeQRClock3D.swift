//
//  BarcodeQRClock3D.swift
//  Visualizer Clock
//
//  Created by Stuart Rankin on 11/19/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit
import SpriteKit

/// Class that generates barcodes with time as the content. This class handles iOS built-in barcodes
/// from the CIFilter class.
class BarcodeQRClock3D: ClockProtocol
{
    let _Settings = UserDefaults.standard
    
    let DefaultWidth: CGFloat = 0.12
    let DefaultHeight: CGFloat = 0.12
    let DefaultDepth: CGFloat = 0.20
    let DefaultRadius: CGFloat = 0.025
    
    /// Clock initializer.
    ///
    /// - Parameter SurfaceSize: Size of the surface where the clock view will be placed.
    init(SurfaceSize: CGSize)
    {
        CommonInitialization(SurfaceSize)
    }
    
    /// Main UI delegate.
    weak var delegate: MainUIProtocol? = nil
    
    /// Initialization common to all constructions (even if there is only one).
    ///
    /// - Parameter SurfaceSize: Size of the surface where the clock view will be placed.
    private func CommonInitialization(_ SurfaceSize: CGSize)
    {
        ViewPortSize = SurfaceSize
        ViewPortCenter = CGPoint(x: ViewPortSize.width / 2, y: ViewPortSize.height / 2)
        ViewPortSize = SurfaceSize
        ViewPortCenter = CGPoint(x: ViewPortSize.width / 2.0, y: ViewPortSize.height / 2.0)
        delegate?.ClockStarted(ID: ClockID)
        
        StartStatTimer()
    }
    
    /// Returns the type of clock.
    func GetClockType() -> PanelActions
    {
        return PanelActions.SwitchToQRCode3D
    }
    
    var StatTimer: Timer!
    
    /// Initialize the stat display timer.
    func StartStatTimer()
    {
        if StatTimer != nil
        {
            return
        }
        StatTimer = Timer.scheduledTimer(timeInterval: 15.0, target: self, selector: #selector(DisplayPeriodicStats), userInfo: nil, repeats: true)
    }
    
    @objc func DisplayPeriodicStats()
    {
        if FrameCount == 0
        {
            return
        }
        var MeanFrameRenderTime = TotalRenderTime / Double(FrameCount)
        MeanFrameRenderTime = Utility.Round(MeanFrameRenderTime, ToPlaces: 4)
        print("Mean frame render time: \(MeanFrameRenderTime) seconds, Frame count: \(FrameCount)")
    }
    
    /// Holds the name of the clock.
    private var _ClockName: String = "QR Code 3D"
    /// Get the name of the clock.
    public var ClockName: String
    {
        get
        {
            return _ClockName
        }
    }
    
    /// Size of the viewport. This is the UIView in the Main UI where the clock view will be placed.
    private var ViewPortSize: CGSize!
    
    private var ViewPortFrame: CGRect!
    
    /// Center of the viewport.
    private var ViewPortCenter: CGPoint!
    
    /// Clock timer.
    private var ClockTimer: Timer? = nil
    
    /// Initialize the clock timer. Barcodes are updated every half second.
    private func InitializeClockTimer()
    {
        let Interval = TimeInterval(1.0)
        ClockTimer = Timer.scheduledTimer(timeInterval: Interval, target: self, selector: #selector(UpdateClock), userInfo: nil, repeats: true)
    }
    
    /// Called by the clock timer.
    @objc func UpdateClock()
    {
        let TheTime = Date()
        if NewSecond(TheTime)
        {
            delegate?.OneSecondTick(ID: ClockID, Time: TheTime)
        }
        delegate?.CheckForDarkMode(TheTime)
        DrawClock(WithTime: TheTime)
    }
    
    /// Determines if a new second has occurred.
    ///
    /// - Parameter Time: The time used to check for new second state.
    /// - Returns: True if a new second occurred, false if not.
    func NewSecond(_ Time: Date) -> Bool
    {
        let Cal = Calendar.current
        let Second = Cal.component(.second, from: Time)
        if Second != PreviousSecond
        {
            PreviousSecond = Second
            return true
        }
        return false
    }
    
    var PreviousSecond: Int = -1
    
    /// Object used to synchronize the function that draws the clock.
    var ClockLock = NSObject()
    
    /// Draw the clock. Notifies the Main UI of major tasks.
    ///
    /// - Parameter WithTime: Time to use to draw the clock.
    func DrawClock(WithTime: Date)
    {
        objc_sync_enter(ClockLock)
        defer {objc_sync_exit(ClockLock)}
        
        delegate?.PreparingClockUpdate(ID: ClockID)
        DoDrawClock(WithTime)
        delegate?.UpdateMainView(ID: ClockID, WithView: SurfaceView)
        delegate?.FinishedClockUpdate(ID: ClockID)
    }
    
    /// Return the antialiasing mode to use based on the user's settings.
    ///
    /// - Returns: Antialiasing mode to use.
    func GetAntiAliasingSetting() -> SCNAntialiasingMode
    {
        switch _Settings.integer(forKey: Setting.Key.QRCode3D.AntialiasingType)
        {
        case 0:
            return .none
            
        case 1:
            return .multisampling2X
            
        case 2:
            return .multisampling4X
            
        default:
            return .none
        }
    }
    
    func MakeCameraForScene(BarcodeSize: Int) -> SCNNode
    {
        CameraNode = SCNNode()
        CameraNode.name = "QRCamera"
        CameraNode.camera = SCNCamera()
        if BarcodeSize < 25
        {
            CameraNode.camera?.fieldOfView = 85.0
            CameraNode.position = SCNVector3(x: 0.7, y: 2.3, z: 1.9)
            CameraNode.orientation = SCNVector4(x: 0.2, y: 0.2, z: 0.2, w: -0.5)
        }
        else
        {
            CameraNode.camera?.fieldOfView = 95.0
            CameraNode.position = SCNVector3(x: 0.7, y: 2.5, z: 2.0)
            CameraNode.orientation = SCNVector4(x: 0.2, y: 0.22, z: 0.3, w: -0.4)
        }
        print("Camera for \(BarcodeSize):")
        print("  Field of view: \((CameraNode.camera?.fieldOfView)!)")
        print("  Position: \(CameraNode.position)")
        print("  Orientation: \(CameraNode.orientation)")
        return CameraNode
    }
    
    /// Create a scene kit view with the proper camera settings.
    ///
    /// - Parameter Frame: The frame to use for the scene kit view.
    /// - Returns: Scene kit view for the 3D QR Code barcode.
    func CreateScene(Frame: CGRect) -> SCNView
    {
        let SceneView = SCNView(frame: Frame)
        #if false
        SceneView.layer.borderColor = UIColor.yellow.cgColor
        SceneView.layer.borderWidth = 2.0
        #endif
        let Scene = SCNScene()
        SceneView.scene = Scene
        SceneView.showsStatistics = false
        SceneView.allowsCameraControl = false
        SceneView.preferredFramesPerSecond = _Settings.integer(forKey: Setting.Key.QRCode3D.DesiredFrameRate)
        SceneView.antialiasingMode = GetAntiAliasingSetting()
        SceneView.backgroundColor = UIColor.clear
        SceneView.autoenablesDefaultLighting = true
        #if false
        CameraNode = SCNNode()
        CameraNode.camera = SCNCamera()
        CameraNode.camera?.fieldOfView = 95.0//85.0
        CameraNode.position = SCNVector3(x: 0.7, y: 2.5, z: 2.0)//(x: 0.7, y: 2.3, z: 1.9)
        CameraNode.orientation = SCNVector4(x: 0.2, y: 0.22, z: 0.3, w: -0.4)//(x: 0.2, y: 0.2, z: 0.2, w: -0.5)
        Scene.rootNode.addChildNode(CameraNode)
        #endif
        return SceneView
    }
    
    var CameraNode: SCNNode!
    let QRCodeNodeName = "QRCodeNode"
    
    /// Actual clock drawing takes place here. This function does not communicate with the Main UI.
    ///
    /// - Parameter WithTime: Time to use to draw the clock.
    func DoDrawClock(_ WithTime: Date)
    {
        let Start = CACurrentMediaTime()
        if SView == nil
        {
            let Side = min(ViewPortSize.width, ViewPortSize.height) - 20.0
            let XLoc = ViewPortSize.width / 2.0 - Side / 2.0
            let YLoc = ViewPortSize.height / 2.0 - Side / 2.0
            SView = CreateScene(Frame: CGRect(x: XLoc, y: YLoc, width: Side, height: Side))
        }
        else
        {
            SView?.scene?.rootNode.childNodes.forEach(
                    {
                        if $0.name == QRCodeNodeName
                        {
                            $0.removeFromParentNode()
                        }
                    }
            )
        }
        
        SurfaceView = UIView()
        SurfaceView.frame = CGRect(x: 0, y: 0, width: ViewPortSize.width, height: ViewPortSize.height)
        SurfaceView.backgroundColor = UIColor.clear
        let format = DateFormatter()
        format.timeStyle = .medium
        //let Final = format.string(from: WithTime)
        let Final = Utility.GetTimeStampToEncode(From: WithTime)
        Add3DQRCodeToView(From: Final, Parent: SurfaceView)
        let End = CACurrentMediaTime()
        let FrameDuration = End - Start
        TotalRenderTime = TotalRenderTime + FrameDuration
        FrameCount = FrameCount + 1
    }
    
    var TotalRenderTime: CFTimeInterval = 0
    var FrameCount: Int = 0
    
    /// Given the time (in the form of a string), return a 3D QR Code barcode as a subview to the passed view.
    ///
    /// - Parameters:
    ///   - From: The contents of the QR Code barcode (presumed (but not required) to be a time-stamp).
    ///   - Parent: The parent UIView where the 3D scene view will be placed.
    func Add3DQRCodeToView(From: String, Parent: UIView)
    {
        var BitmapWidth: Int = 0
        var BitmapHeight: Int = 0
        var NotUsed: CIImage? = nil
        let BitmapArray = BarcodeGenerator.CreateBarcodeBitmap(from: From, WithType: "CodeQR3D",
                                                               FinalWidth: &BitmapWidth, FinalHeight: &BitmapHeight,
                                                               Native: &NotUsed)
        //print("BitmapWidth: \(BitmapWidth), BitmapHeight:\(BitmapHeight)")
        for Y in 0 ..< BitmapHeight
        {
            for X in 0 ..< BitmapWidth
            {
                //if BitmapArray![(BitmapHeight - 1) - Y][X] == 0
                if BitmapArray![Y][X] == 0
                {
                    continue
                }
                let BoxNode = MakeQRNodeShape(Width: DefaultWidth, Height: DefaultHeight)
                BoxNode.position = MakePosition(X: X, Y: Y, Width: DefaultWidth, Height: DefaultHeight)
                SView!.scene?.rootNode.addChildNode(BoxNode)
            }
        }
        
        Parent.subviews.forEach({$0.removeFromSuperview()})
        AddNewCamera(BarcodeSize: BitmapWidth)
        Parent.addSubview(SView!)
    }
    
    func AddNewCamera(BarcodeSize: Int)
    {
        //Remove any existing cameras.
        SView?.scene?.rootNode.childNodes.forEach
            {
            if $0.name == "QRCamera"
            {
                $0.removeFromParentNode()
            }
        }
        let CameraNode = MakeCameraForScene(BarcodeSize: BarcodeSize)
        SView?.scene?.rootNode.addChildNode(CameraNode)
    }
    
    enum QRCode3DNodeShapes: Int
    {
        case Box = 0
        case Capsule = 1
        case Cone = 2
        case Cylinder = 3
        case Pyramid = 4
        case Sphere = 5
        case Torus = 6
        case Tube = 7
    }
    
    func MakeQRNodeShape(Width: CGFloat, Height: CGFloat) -> SCNNode
    {
        var NodeShape: SCNGeometry!
        switch _Settings.integer(forKey: Setting.Key.QRCode3D.NodeShape)
        {
        case 0:
            let Box = SCNBox(width: Width, height: Height, length: DefaultDepth, chamferRadius: DefaultRadius)
            NodeShape = Box
            
        case 1:
            let Capsule = SCNCapsule(capRadius: DefaultRadius, height: Height)
            NodeShape = Capsule
            
        case 2:
            let Cone = SCNCone(topRadius: 0.0, bottomRadius: Width, height: Height)
            NodeShape = Cone
            
        case 3:
            let Cylinder = SCNCylinder(radius: Width / 2.0, height: Height)
            NodeShape = Cylinder
            
        case 4:
            let Pyramid = SCNPyramid(width: Width, height: Height, length: Width)
            NodeShape = Pyramid
            
        case 5:
            let Sphere = SCNSphere(radius: Width / 2.0)
            NodeShape = Sphere
            
        case 6:
            let Torus = SCNTorus(ringRadius: Width, pipeRadius: Width / 3.0)
            NodeShape = Torus
            
        case 7:
            let Tube = SCNTube(innerRadius: Width / 3.0, outerRadius: Width, height: Height)
            NodeShape = Tube
            
        default:
            let Box = SCNBox(width: Width, height: Height, length: DefaultDepth, chamferRadius: DefaultRadius)
            NodeShape = Box
        }
        //let Box = SCNBox(width: Width, height: Height, length: DefaultDepth,
        //                 chamferRadius: DefaultRadius)
        #if true
        NodeShape.firstMaterial?.diffuse.contents = _Settings.uicolor(forKey: Setting.Key.QRCode3D.NodeDiffuseColor)
                NodeShape.firstMaterial?.specular.contents = _Settings.uicolor(forKey: Setting.Key.QRCode3D.NodeSpecularColor)
        #else
        Box.firstMaterial?.diffuse.contents = UIColor.red
        Box.firstMaterial?.specular.contents = UIColor.white
        #endif
        let ShapeNode = SCNNode(geometry: NodeShape)
        ShapeNode.name = QRCodeNodeName
        return ShapeNode
    }
    
    func MakePosition(X: Int, Y: Int, Width: CGFloat, Height: CGFloat) -> SCNVector3
    {
        let FinalX: Float = Float(X) * Float(Width)
        let FinalY: Float = Float(Y) * Float(Height)
        return SCNVector3(x: FinalX, y: FinalY, z: 0)
    }
    
    var SView: SCNView? = nil
    
    private var Handle3D: BarcodeVectorHandle? = nil
    
    /// Holds the number of vector nodes generated.
    private var _VectorNodeCount: Int = 0
    /// Get the number of vector nodes generated.
    public var VectorNodeCount: Int
    {
        get
        {
            return _VectorNodeCount
        }
    }
    
    /// Convenience function to allow the Main UI to display a different time than the clock timer.
    ///
    /// - Parameter NewTime: The time to display.
    func UpdateTime(NewTime: Date)
    {
        DrawClock(WithTime: NewTime)
    }
    
    /// Set the clock state to run or halt. The state of the clock does not affect the validity (IsValid) flag.
    ///
    /// - Parameter ToRunning: Pass true to set the clock state to running, false to stop the clock.
    /// - Parameter Animation: Animation types for begining or ending events. Set to 0 for no animation.
    func SetClockState(ToRunning: Bool, Animation: Int = 0)
    {
        _IsRunning = ToRunning
        if ToRunning
        {
            InitializeClockTimer()
            StartStatTimer()
            StartTime = Date()
            UpdateClock()
        }
        else
        {
            if Handle3D != nil
            {
                BarcodeVector.Close3DHandle(Handle: &Handle3D!)
                Handle3D = nil
            }
            ClockTimer?.invalidate()
            ClockTimer = nil
            if StatTimer != nil
            {
                StatTimer.invalidate()
                StatTimer = nil
            }
            delegate?.ClockStopped(ID: ClockID)
        }
    }
    
    /// Holds the running state of the clock.
    private var _IsRunning: Bool = false
    /// Get the running state of the clock.
    public var IsRunning: Bool
    {
        get
        {
            return _IsRunning
        }
    }
    
    /// Update the viewport where the clock is drawn. Called when the user changes the orientation of the device.
    ///
    /// - Parameters:
    ///   - NewWidth: New viewport width.
    ///   - NewHeight: New viewport height.
    func UpdateViewPort(NewWidth: Int, NewHeight: Int)
    {
        ViewPortSize = CGSize(width: NewWidth, height: NewHeight)
        ViewPortCenter = CGPoint(x: NewWidth / 2, y: NewHeight / 2)
        UpdateClock()
    }
    
    /// Holds the UIView passed to the Main UI.
    private var SurfaceView: UIView!
    
    /// Holds the UIImageView of the actual barcode to display.
    private var BarcodeView: UIImageView!
    
    /// Will contain the ID of the clock.
    private var _ClockID: UUID = UUID(uuidString: Clocks.ClockIDMap[PanelActions.SwitchToQRCode3D]!)!//"1034c46a-767f-4dc1-a2e0-5154bd3cb128")!
    /// Get the ID of the clock.
    public var ClockID: UUID
    {
        get
        {
            return _ClockID
        }
    }
    
    /// Returns the number of seconds this clock was active.
    func SecondsDisplayed() -> Int
    {
        let Now = Date()
        let Elapsed: Int = Int(Now.timeIntervalSince(StartTime))
        return Elapsed
    }
    
    /// Start time of the clock.
    private var StartTime = Date()
    
    /// Should be called by the Main UI when another clock is selected. Shut down this clock and clean
    /// things up.
    func FinishedWithClock()
    {
        let MeanFrameRenderTime = TotalRenderTime / Double(FrameCount)
        print("Mean frame render time: \(MeanFrameRenderTime) seconds, Frame count: \(FrameCount)")
        if ClockTimer != nil
        {
            ClockTimer?.invalidate()
            ClockTimer = nil
        }
        if StatTimer != nil
        {
            StatTimer.invalidate()
            StatTimer = nil
        }
        delegate?.ClockClosed(ID: ClockID)
        _IsValid = false
    }
    
    /// Contains the is valid flag.
    private var _IsValid: Bool = true
    /// Get the is valid flag. If false is returned, do not use the clock - reinstantiate it first.
    public var IsValid: Bool
    {
        return _IsValid
    }
    
    /// Holds the value that determines if callers can update colors asynchronously.
    private var _CanUpdateColorsAsynchronously: Bool = true
    /// Get the flag that indicates the clock can update colors asynchronously.
    public var CanUpdateColorsAsynchronously: Bool
    {
        get
        {
            return _CanUpdateColorsAsynchronously
        }
    }
    
    /// Sets the foreground color of the clock (where it makes sense) to the passed color, asynchronously.
    ///
    /// - Parameter Color: New foreground color.
    func SetForegroundColorAsynchronously(_ Color: UIColor)
    {
        if !UpdateColorsAsynchronously
        {
            return
        }
        AsynchronousForeground = CIColor(color: Color)
        DrawClock(WithTime: Date())
    }
    
    var AsynchronousForeground: CIColor = CIColor.black
    
    /// Holds the flag that lets callers update colors asynchronously.
    private var _UpdateColorsAsynchronously: Bool = false
    /// Enables or disables usage of asynchronous colors.
    public var UpdateColorsAsynchronously: Bool
    {
        get
        {
            return _UpdateColorsAsynchronously
        }
        set
        {
            _UpdateColorsAsynchronously = newValue
        }
    }
    
    /// Update the specified nodes with associated colors.
    ///
    /// - Parameter Data: List of tuples. First item is the node index (0-based) and the second item is the color to
    ///                   apply to the node. If there are insufficient nodes in the bitmap, excess node data will be ignored.
    public func UpdateNodeColors(_ Data: [(Int, UIColor)])
    {
    }
    
    /// This clock is vector based...
    public var IsVectorBased: Bool
    {
        return true
    }
    
    /// Holds the is full screen flag.
    private var _IsFullScreen: Bool = false
    /// Get the full screen flag.
    public var IsFullScreen: Bool
    {
        get
        {
            return _IsFullScreen
        }
    }
    
    /// Holds the handles taps flag.
    private var _HandlesTaps: Bool = false
    /// Get or set the handles tap flag.
    public var HandlesTaps: Bool
    {
        get
        {
            return _HandlesTaps
        }
        set
        {
            _HandlesTaps = newValue
        }
    }
    
    /// Handle taps on the screen by the user. Sent to us by the main UI.
    ///
    /// -Paramter At: Where the tap occured in the clock view.
    public func WasTapped(At: CGPoint)
    {
    }
    
    /// Run clock-specific settings.
    public func RunClockSettings()
    {
        
    }
    
    /// Get the segue ID of the settings view controller.
    ///
    /// - Returns: ID of the settings view controller. Nil if none available.
    func SettingsSegueID() -> String?
    {
        return "ToQRCode3DSettings"
    }
    
    /// Get changed settings.
    ///
    /// - Parameter Changed: List of changed settings. If nil, possibly no settings changed
    ///                      or too many to list.
    func ChangedSettings(_ Changed: [String])
    {
    }
}
