//
//  3DTest.swift
//  Visualizer Clock
//
//  Created by Stuart Rankin on 11/16/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit
import SpriteKit

class Test3D: UITableViewController
{
    let DefaultCameraPositionX: Float = 0.9
    let DefaultCameraPositionY: Float = -0.28
    let DefaultCameraPositionZ: Float = 1.4
    let DefaultCameraOrientationX: Float = 0.2
    let DefaultCameraOrientationY: Float = 0.2
    let DefaultCameraOrientationZ: Float = 0.2
    let DefaultCameraOrientationW: Float = 1.0
    let DefaultCameraRotationX: Float = 0.6
    let DefaultCameraRotationY: Float = 0.7
    let DefaultCameraRotationZ: Float = 0.6
    let DefaultCameraRotationW: Float = 0.6
    let DefaultFOV: Float = 40.0
    let DefaultHBlockCount: Int = 5
    let DefaultVBlockCount: Int = 5
    let DefaultWidth: CGFloat = 0.12
    let DefaultHeight: CGFloat = 0.12
    let DefaultDepth: CGFloat = 0.20
    let DefaultRadius: CGFloat = 0.025
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        View3D.layer.borderColor = UIColor.black.cgColor
        View3D.layer.borderWidth = 0.5
        View3D.layer.cornerRadius = 5.0
        View3D.backgroundColor = UIColor.red//UIColor(hue: 0.0, saturation: 0.8, brightness: 0.9, alpha: 1.0)
        
        #if true
        UIView.animate(withDuration: 15, delay: 0, options: [UIView.AnimationOptions.allowUserInteraction, UIView.AnimationOptions.repeat,
                                                             UIView.AnimationOptions.autoreverse],
                       animations:
            {
                self.View3D.backgroundColor = UIColor.blue//UIColor(hue: 1.0, saturation: 0.8, brightness: 0.9, alpha: 1.0)
        },
                       completion: nil
        )
        #else
        let BGAnim = CABasicAnimation(keyPath: "backgroundColor")
        BGAnim.duration = 15
        BGAnim.autoreverses = true
        BGAnim.fromValue = UIColor(hue: 0.0, saturation: 0.8, brightness: 0.9, alpha: 1.0).cgColor
        BGAnim.toValue = UIColor(hue: 1.0, saturation: 0.8, brightness: 0.9, alpha: 1.0).cgColor
        BGAnim.repeatCount = HUGE
        View3D?.layer.add(BGAnim, forKey: nil)
        #endif
        
        LoadDefaults()
        Set3DTest(View3D)
    }
    
    @IBOutlet weak var View3D: UIView!
    
    var CameraNode: SCNNode!
    
    func MakeScene(_ Parent: UIView) -> SCNView
    {
        let SceneView = SCNView(frame: CGRect(x: 0, y: 0, width: Parent.bounds.width, height: Parent.bounds.height))
        let Scene = SCNScene()
        SceneView.scene = Scene
        SceneView.showsStatistics = true
        SceneView.allowsCameraControl = true
        SceneView.preferredFramesPerSecond = 60
        SceneView.antialiasingMode = .multisampling4X
        
        #if true
        SceneView.backgroundColor = UIColor.clear
        #else
        SceneView.backgroundColor = UIColor.gold
        
        let BGAnim = CABasicAnimation(keyPath: "backgroundColor")
        BGAnim.duration = 15
        BGAnim.fromValue = UIColor(hue: 0.0, saturation: 0.8, brightness: 0.9, alpha: 1.0)
        BGAnim.toValue = UIColor(hue: 359.0 / 360.0, saturation: 0.8, brightness: 0.9, alpha: 1.0)
        BGAnim.repeatCount = HUGE
        SceneView.add(BGAnim, forKey: nil)
        #endif
        
        SceneView.autoenablesDefaultLighting = true
        let FOV: CGFloat = GetValue(FieldOfViewBox)
        CameraNode = SCNNode()
        CameraNode.camera = SCNCamera()
        CameraNode.camera?.fieldOfView = FOV
        
        let CameraPosition = GetCameraPosition()
        let CameraOrientation = GetCameraOrientation()
        #if false
        let CameraRotation = GetCameraRotation()
        #endif
        
        CameraNode.position = CameraPosition
        CameraNode.orientation = CameraOrientation
        #if false
        CameraNode.rotation = CameraRotation
        #endif
        
        Scene.rootNode.addChildNode(CameraNode)
        
        return SceneView
    }
    
    func MakeBox(Width: CGFloat, Height: CGFloat) -> SCNNode
    {
        let Box = SCNBox(width: Width, height: Height, length: DefaultDepth,
                         chamferRadius: DefaultRadius)
        Box.firstMaterial?.diffuse.contents = UIColor.red
        Box.firstMaterial?.diffuse.contents = UIColor.red
        let BoxNode = SCNNode(geometry: Box)
        BoxNode.name = "BoxNode"
        return BoxNode
    }
    
    func MakePosition(X: Int, Y: Int, Width: CGFloat, Height: CGFloat) -> SCNVector3
    {
        let FinalX: Float = Float(X) * Float(Width)
        let FinalY: Float = Float(Y) * Float(Height)
        return SCNVector3(x: FinalX, y: FinalY, z: 0)
    }
    
    var SView: SCNView? = nil
    
    func Set3DTest(_ Parent: UIView)
    {
        let HBoxCount: Int = GetValue(HBlockCount)
        let VBoxCount: Int = GetValue(VBlockCount)
        let BlockWidth: CGFloat = GetValue(BlockWidthBox)
        let BlockHeight: CGFloat = GetValue(BlockHeightBox)
        let DoAnimate = AnimateSwitch.isOn
        
        if SView == nil
        {
            SView = MakeScene(Parent)
            objc_sync_enter(SView as Any)
        }
        else
        {
            SView?.scene?.rootNode.childNodes.forEach(
                {
                    if $0.name == "BoxNode"
                    {
                        $0.removeFromParentNode()
                    }
                }
            )
        }
        
        if ShowQRCodeSwitch.isOn
        {
            var BitmapWidth: Int = 0
            var BitmapHeight: Int = 0
            var NotUsed: CIImage? = nil
            let TimeStamp = Utility.MakeTimeString(TheDate: Date(), IncludeSeconds: true)
            let BitmapArray = BarcodeGenerator.CreateBarcodeBitmap(from: TimeStamp, WithType: "CodeQR3D",
                                                                   FinalWidth: &BitmapWidth, FinalHeight: &BitmapHeight,
                                                                   Native: &NotUsed)
            for Y in 0 ..< BitmapHeight
            {
                for X in 0 ..< BitmapWidth
                {
                    if BitmapArray![Y][X] == 0
                    {
                        continue
                    }
                    let BoxNode = MakeBox(Width: BlockWidth, Height: BlockHeight)
                    BoxNode.position = MakePosition(X: X, Y: Y, Width: BlockWidth, Height: BlockHeight)
                    SView!.scene?.rootNode.addChildNode(BoxNode)
                }
            }
        }
        else
        {
            for Y in 0 ..< VBoxCount
            {
                for X in 0 ..< HBoxCount
                {
                    let BoxNode = MakeBox(Width: BlockWidth, Height: BlockHeight)
                    BoxNode.position = MakePosition(X: X, Y: Y, Width: BlockWidth, Height: BlockHeight)
                    SView!.scene?.rootNode.addChildNode(BoxNode)
                    
                    if DoAnimate
                    {
                        let DepthChange = CABasicAnimation(keyPath: "scale.z")
                        DepthChange.toValue = CGFloat.random(in: 0.1 ... 2.0)
                        DepthChange.fromValue = CGFloat.random(in: 0.2 ... 3.0)
                        DepthChange.duration = Double.random(in: 0.3 ... 2.0)
                        DepthChange.repeatCount = HUGE
                        DepthChange.autoreverses = true
                        BoxNode.addAnimation(DepthChange, forKey: "depth")
                    }
                }
            }
        }
        
        Parent.subviews.forEach({$0.removeFromSuperview()})
        Parent.addSubview(SView!)
        objc_sync_exit(SView as Any)
    }
    
    func SetValue(_ TextBox: UITextField, _ InitValue: Float)
    {
        let DVal = String(describing: InitValue)
        TextBox.text = DVal
    }
    
    func SetValue(_ TextBox: UITextField, _ InitValue: CGFloat)
    {
        let DVal = String(describing: InitValue)
        TextBox.text = DVal
    }
    
    func SetValue(_ TextBox: UITextField, _ InitValue: Double)
    {
        let DVal = String(describing: InitValue)
        TextBox.text = DVal
    }
    
    func SetValue(_ TextBox: UITextField, _ InitValue: Int)
    {
        let DVal = String(describing: InitValue)
        TextBox.text = DVal
    }
    
    func LoadDefaults()
    {
        AnimateSwitch.isOn = false
        ShowQRCodeSwitch.isOn = false
        CameraControlSwitch.isOn = false
        SetValue(FieldOfViewBox, DefaultFOV)
        SetValue(HBlockCount, DefaultHBlockCount)
        SetValue(VBlockCount, DefaultVBlockCount)
        SetValue(BlockWidthBox, DefaultWidth)
        SetValue(BlockHeightBox, DefaultHeight)
        SetValue(CameraXBox, DefaultCameraPositionX)
        SetValue(CameraYBox, DefaultCameraPositionY)
        SetValue(CameraZBox, DefaultCameraPositionZ)
        SetValue(CameraOrientationXBox, DefaultCameraOrientationX)
        SetValue(CameraOrientationYBox, DefaultCameraOrientationY)
        SetValue(CameraOrientationZBox, DefaultCameraOrientationZ)
        SetValue(CameraOrientationWBox, DefaultCameraOrientationW)
        SetValue(CameraRotationXBox, DefaultCameraRotationX)
        SetValue(CameraRotationYBox, DefaultCameraRotationY)
        SetValue(CameraRotationZBox, DefaultCameraRotationZ)
        SetValue(CameraRotationWBox, DefaultCameraRotationW)
    }
    
    func GetValue(_ TextBox: UITextField) -> Float
    {
        if let SVal = TextBox.text
        {
            if let DVal = Double(SVal)
            {
                return Float(DVal)
            }
            else
            {
                TextBox.text = "0.0"
                return 0.0
            }
        }
        else
        {
            TextBox.text = "0.0"
            return 0.0
        }
    }
    
    func GetValue(_ TextBox: UITextField) -> CGFloat
    {
        if let SVal = TextBox.text
        {
            if let DVal = Double(SVal)
            {
                return CGFloat(DVal)
            }
            else
            {
                TextBox.text = "0.0"
                return 0.0
            }
        }
        else
        {
            TextBox.text = "0.0"
            return 0.0
        }
    }
    
    func GetValue(_ TextBox: UITextField) -> Int
    {
        if let SVal = TextBox.text
        {
            if let IVal = Int(SVal)
            {
                return IVal
            }
            else
            {
                TextBox.text = "1"
                return 1
            }
        }
        else
        {
            TextBox.text = "1"
            return 1
        }
    }
    
    func GetCameraRotation() -> SCNVector4
    {
        return SCNVector4(x: GetValue(CameraRotationXBox),
                          y: GetValue(CameraRotationYBox),
                          z: GetValue(CameraRotationZBox),
                          w: GetValue(CameraRotationWBox))
    }
    
    func GetCameraOrientation() -> SCNVector4
    {
        return SCNVector4(x: GetValue(CameraOrientationXBox),
                          y: GetValue(CameraOrientationYBox),
                          z: GetValue(CameraOrientationZBox),
                          w: GetValue(CameraOrientationWBox))
    }
    
    func GetCameraPosition() -> SCNVector3
    {
        return SCNVector3(x: GetValue(CameraXBox),
                          y: GetValue(CameraYBox),
                          z: GetValue(CameraZBox))
    }
    
    @IBAction func HandleReloadButtonPress(_ sender: Any)
    {
        view.endEditing(true)
        SView = nil
        Set3DTest(View3D)
    }
    
    @IBAction func HandleCameraXChange(_ sender: Any)
    {
    }
    
    @IBOutlet weak var CameraXBox: UITextField!
    
    @IBAction func HandleCameraYChange(_ sender: Any)
    {
    }
    
    @IBOutlet weak var CameraYBox: UITextField!
    
    @IBAction func HandleCameraZChange(_ sender: Any)
    {
    }
    
    @IBOutlet weak var CameraZBox: UITextField!
    
    @IBAction func HandleCameraOrientationXChange(_ sender: Any)
    {
    }
    
    @IBOutlet weak var CameraOrientationXBox: UITextField!
    
    @IBAction func HandleCameraOrientationYChange(_ sender: Any)
    {
    }
    
    @IBOutlet weak var CameraOrientationYBox: UITextField!
    
    @IBAction func HandleCameraOrientationZChange(_ sender: Any)
    {
    }
    
    @IBOutlet weak var CameraOrientationZBox: UITextField!
    
    @IBAction func HandleCameraOrientationWChange(_ sender: Any)
    {
    }
    
    @IBOutlet weak var CameraOrientationWBox: UITextField!
    
    @IBAction func HandleCameraRotationXChange(_ sender: Any)
    {
    }
    
    @IBOutlet weak var CameraRotationXBox: UITextField!
    
    @IBAction func HandleCameraRotationYChange(_ sender: Any)
    {
    }
    
    @IBOutlet weak var CameraRotationYBox: UITextField!
    
    @IBAction func HandleCameraRotationZChange(_ sender: Any)
    {
    }
    
    @IBOutlet weak var CameraRotationZBox: UITextField!
    
    @IBAction func HandleCameraRotationWChange(_ sender: Any)
    {
    }
    
    @IBOutlet weak var CameraRotationWBox: UITextField!
    
    @IBOutlet weak var HBlockCount: UITextField!
    
    @IBAction func HBlockCountChange(_ sender: Any)
    {
    }
    
    @IBOutlet weak var VBlockCount: UITextField!
    
    @IBAction func VBlockCountChange(_ sender: Any)
    {
    }
    
    @IBOutlet weak var BlockHeightBox: UITextField!
    
    @IBAction func BlockHeightChanged(_ sender: Any)
    {
    }
    
    @IBOutlet weak var BlockWidthBox: UITextField!
    
    @IBAction func BlockWidthChanged(_ sender: Any)
    {
    }
    
    @IBOutlet weak var FieldOfViewBox: UITextField!
    
    @IBAction func FieldOfViewChange(_ sender: Any)
    {
    }
    
    @IBOutlet weak var AnimateSwitch: UISwitch!
    
    @IBAction func HandleAnimateChanged(_ sender: Any)
    {
        view.endEditing(true)
        Set3DTest(View3D)
    }
    
    @IBAction func HandleResetParametes(_ sender: Any)
    {
        SView = nil
        view.endEditing(true)
        LoadDefaults()
        Set3DTest(View3D)
    }
    
    @IBOutlet weak var ShowQRCodeSwitch: UISwitch!
    
    @IBAction func HandleQRCodeChanged(_ sender: Any)
    {
        view.endEditing(true)
        SView = nil
        if ShowQRCodeSwitch.isOn
        {
            QRUpdateTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(UpdateQRCode), userInfo: nil, repeats: true)
        }
        else
        {
            if QRUpdateTimer != nil
            {
                QRUpdateTimer?.invalidate()
                QRUpdateTimer = nil
            }
        }
        Set3DTest(View3D)
    }
    
    var QRUpdateTimer: Timer? = nil
    
    @objc func UpdateQRCode()
    {
        Set3DTest(View3D)
    }
    
    @IBAction func HandleCameraControlChanged(_ sender: Any)
    {
        if CameraControlSwitch.isOn
        {
            if UpdateTimer == nil
            {
                UpdateTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(UpdatePositionData),
                                                   userInfo: nil, repeats: true)
            }
        }
        else
        {
            if UpdateTimer != nil
            {
                UpdateTimer?.invalidate()
                UpdateTimer = nil
            }
        }
        Set3DTest(View3D)
    }
    
    @IBOutlet weak var CameraControlSwitch: UISwitch!
    
    var UpdateTimer: Timer? = nil
    
    @objc func UpdatePositionData()
    {
        #if true
        let CameraRot = (SView?.pointOfView?.rotation)!
        let CameraPos = (SView?.pointOfView?.position)!
        let CameraOri = (SView?.pointOfView?.orientation)!
        #else
        let CameraRot = CameraNode.rotation
        let CameraPos = CameraNode.position
        let CameraOri = CameraNode.orientation
        #endif
        
        if !SCNVector3EqualToVector3(CameraPos, PreviousCameraPosition)
        {
            let (PX, PY, PZ) = Utility.VectorToString(CameraPos)
            CameraXBox.text = PX
            CameraYBox.text = PY
            CameraZBox.text = PZ
            print("Camera Position: \(PX),\(PY),\(PZ)")
            PreviousCameraPosition = CameraPos
        }
        
        if !SCNVector4EqualToVector4(CameraRot, PreviousCameraRotation)
        {
            let (RX, RY, RZ, RW) = Utility.VectorToString(CameraRot)
            CameraRotationXBox.text = RX
            CameraRotationYBox.text = RY
            CameraRotationZBox.text = RZ
            CameraRotationWBox.text = RW
            print("Camera Rotation: \(RX),\(RY),\(RZ),\(RW)")
            PreviousCameraRotation = CameraRot
        }
        
        if !SCNVector4EqualToVector4(CameraOri, PreviousCameraOrientation)
        {
            let (OX, OY, OZ, OW) = Utility.QuaternionToString(CameraOri)
            CameraOrientationXBox.text = OX
            CameraOrientationYBox.text = OY
            CameraOrientationZBox.text = OZ
            CameraOrientationWBox.text = OW
            print("Camera Orientation: \(OX),\(OY),\(OZ),\(OW)")
            PreviousCameraOrientation = CameraOri
        }
    }
    
    var PreviousCameraRotation: SCNVector4 = SCNVector4Zero
    var PreviousCameraPosition: SCNVector3 = SCNVector3Zero
    var PreviousCameraOrientation: SCNQuaternion = SCNVector4Zero
}
