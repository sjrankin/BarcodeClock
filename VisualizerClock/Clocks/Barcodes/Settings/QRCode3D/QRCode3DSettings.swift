//
//  QRCode3DSettings.swift
//  Visualizer Clock
//
//  Created by Stuart Rankin on 11/19/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit
import SpriteKit

class QRCode3DSettings: UITableViewController, ColorReceiver, UIPickerViewDelegate, UIPickerViewDataSource, SettingProtocol, ClockSettingsProtocol
{
    let _Settings = UserDefaults.standard
    let SampleUnit: CGFloat = 2.0
    let IPosX: Float = 0.7
    let IPosY: Float = 1.0
    let IPosZ: Float = 3.5
    let IGFOV: CGFloat = 120.0
    let IOriX: Float = 0.2
    let IOriY: Float = 0.2
    let IOriZ: Float = 0.2
    let IOriW: Float = -0.5
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        BarcodeContentsSample.text = Utility.GetTimeStampToEncode(From: Date())
                ContentTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(UpdateContentSample), userInfo: nil, repeats: true)
        ResetSampleView(false)
        ShapePicker.delegate = self
        ShapePicker.dataSource = self
        SetSample(MaterialColorSample, _Settings.uicolor(forKey: Setting.Key.QRCode3D.NodeDiffuseColor)!)
        SetSample(ShininessColorSample, _Settings.uicolor(forKey: Setting.Key.QRCode3D.NodeSpecularColor)!)
        SetSample(LightingColorSample, _Settings.uicolor(forKey: Setting.Key.QRCode3D.NodeLightingColor)!)
        DebugTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(DumpCameraPOV), userInfo: nil, repeats: true)
        UpdateSampleShape()
        ShapePicker.selectRow(_Settings.integer(forKey: Setting.Key.QRCode3D.NodeShape), inComponent: 0, animated: true)
    }
    
    func FromClock(_ ClockType: PanelActions)
    {
        
    }
    
    var _MainDelegate: MainUIProtocol? = nil
    var MainDelegate: MainUIProtocol?
    {
        get
        {
            return _MainDelegate
        }
        set
        {
            _MainDelegate = newValue
        }
    }
    
    var ContentTimer: Timer!
    
    func ResetSampleView(_ ShowAfterReload: Bool)
    {
        OriX = IOriX
        OriY = IOriY
        OriZ = IOriZ
        OriW = IOriW
        PosX = IPosX
        PosY = IPosY
        PosZ = IPosZ
        GFOV = IGFOV
        if ShowAfterReload
        {
            UpdateSampleShape()
        }
    }
    
    @IBAction func HandleResetSample(_ sender: Any)
    {
        ResetSampleView(true)
    }
    
    var DebugTimer: Timer!
    
    @objc func DumpCameraPOV()
    {
        if let Pos = SampleShape?.pointOfView?.position
        {
            if !SCNVector3EqualToVector3(Pos, PreviousPosition)
            {
                PreviousPosition = Pos
                PosX = Pos.x
                PosY = Pos.y
                PosZ = Pos.z
                print("Camera position \(Pos)")
            }
        }
        if let Ori = SampleShape?.pointOfView?.orientation
        {
            if !SCNVector4EqualToVector4(Ori, PreviousOrientation)
            {
                PreviousOrientation = Ori
                print("Camera orientation \(Ori)")
            }
        }
        
        if let CameraNode = CameraNode
        {
            if let FOV = CameraNode.camera?.fieldOfView
            {
                if FOV != GFOV
                {
                    GFOV = FOV
                    print("Field of view: \(FOV)")
                }
            }
        }
    }
    
    var PreviousPosition: SCNVector3 = SCNVector3Zero
    var PreviousOrientation: SCNVector4 = SCNVector4Zero
    
    var OriX: Float!
    var OriY: Float!
    var OriZ: Float!
    var OriW: Float!
    var PosX: Float!
    var PosY: Float!
    var PosZ: Float!
    var GFOV: CGFloat!
    
    var CameraNode: SCNNode!
    
    func UpdateSampleShape()
    {
        SampleShape.layer.borderWidth = 0.5
        SampleShape.layer.borderColor = UIColor.black.cgColor
        SampleShape.layer.cornerRadius = 5.0
        
        SampleShape.scene = SCNScene()
        SampleShape.preferredFramesPerSecond = 60
        SampleShape.allowsCameraControl = true
        SampleShape.antialiasingMode = .multisampling2X
        SampleShape.backgroundColor = UIColor.black
        SampleShape.autoenablesDefaultLighting = true
        
        CameraNode = SCNNode()
        CameraNode.camera = SCNCamera()
        CameraNode.camera?.fieldOfView = GFOV
        CameraNode.position = SCNVector3(x: PosX, y: PosY, z: PosZ)
        CameraNode.orientation = SCNVector4(x: 0.2, y: 0.2, z: 0.2, w: -0.5)
        SampleShape.scene?.rootNode.addChildNode(CameraNode)
        AddSampleShape(_Settings.integer(forKey: Setting.Key.QRCode3D.NodeShape),
                       _Settings.uicolor(forKey: Setting.Key.QRCode3D.NodeDiffuseColor)!,
                       _Settings.uicolor(forKey: Setting.Key.QRCode3D.NodeSpecularColor)!)
    }
    
    
    
    func AddSampleShape(_ ShapeIndex: Int, _ DiffuseColor: UIColor, _ SpecularColor: UIColor)
    {
        print("Showing shape \(ShapeIndex)")
        SampleShape.scene?.rootNode.childNodes.forEach(
            {
                if $0.name == "SampleShape"
                {
                    $0.removeFromParentNode()
                }
            }
        )
        var NodeShape: SCNGeometry!
        switch ShapeIndex
        {
        case 0:
            let Box = SCNBox(width: SampleUnit, height: SampleUnit, length: SampleUnit, chamferRadius: 0.05)
            NodeShape = Box
            
        case 1:
            let Capsule = SCNCapsule(capRadius: SampleUnit / 2.0, height: SampleUnit)
            NodeShape = Capsule
            
        case 2:
            let Cone = SCNCone(topRadius: 0.0, bottomRadius: SampleUnit, height: SampleUnit)
            NodeShape = Cone
            
        case 3:
            let Cylinder = SCNCylinder(radius: SampleUnit / 2.0, height: SampleUnit)
            NodeShape = Cylinder
            
        case 4:
            let Pyramid = SCNPyramid(width: SampleUnit, height: SampleUnit, length: SampleUnit)
            NodeShape = Pyramid
            
        case 5:
            let Sphere = SCNSphere(radius: SampleUnit / 2.0)
            NodeShape = Sphere
            
        case 6:
            let Torus = SCNTorus(ringRadius: SampleUnit, pipeRadius: SampleUnit / 3.0)
            NodeShape = Torus
            
        case 7:
            let Tube = SCNTube(innerRadius: SampleUnit / 3.0, outerRadius: SampleUnit, height: 1.0)
            NodeShape = Tube
            
        default:
            let Box = SCNBox(width: SampleUnit, height: SampleUnit, length: SampleUnit, chamferRadius: 0.05)
            NodeShape = Box
        }
        
        NodeShape.firstMaterial?.diffuse.contents = DiffuseColor
        NodeShape.firstMaterial?.specular.contents = SpecularColor
        let ShapeNode = SCNNode(geometry: NodeShape)
        ShapeNode.name = "SampleShape"
        ShapeNode.position = SCNVector3(x: 0.0, y: 0.0, z: 0.0)
        SampleShape.scene?.rootNode.addChildNode(ShapeNode)
    }
    
    func SetSample(_ Sample: UIView, _ SampleColor: UIColor)
    {
        Sample.layer.borderColor = UIColor.black.cgColor
        Sample.layer.borderWidth = 0.5
        Sample.layer.cornerRadius = 5.0
        Sample.backgroundColor = SampleColor
    }
    
    func ColorChanged(NewColor: UIColor, DidChange: Bool, Tag: String?)
    {
        if DidChange
        {
            switch Tag
            {
            case "LightingColor":
                _Settings.set(NewColor, forKey: Setting.Key.QRCode3D.NodeLightingColor)
                SetSample(LightingColorSample, NewColor)
                
            case "SpecularColor":
                _Settings.set(NewColor, forKey: Setting.Key.QRCode3D.NodeSpecularColor)
                SetSample(ShininessColorSample, NewColor)
                
            case "DiffuseColor":
                _Settings.set(NewColor, forKey: Setting.Key.QRCode3D.NodeDiffuseColor)
                SetSample(MaterialColorSample, NewColor)
                
            default:
                return
            }
            
            UpdateSampleShape()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        switch segue.identifier
        {
        case "ToLightColorEditor":
            let Dest = segue.destination as? BasicColorEditor
            Dest?.CallerDelegate = self
            Dest?.InitialTitle = "Lighting Color"
            Dest?.InitialColorSpace = ColorEditorColorSpaces.HSB
            Dest?.InitialColor = _Settings.uicolor(forKey: Setting.Key.QRCode3D.NodeLightingColor)!
            Dest?.DelegateTag = "LightingColor"
            
        case "ToSpecularColorEditor":
            let Dest = segue.destination as? BasicColorEditor
            Dest?.CallerDelegate = self
            Dest?.InitialTitle = "Shininess Color"
            Dest?.InitialColorSpace = ColorEditorColorSpaces.HSB
            Dest?.InitialColor = _Settings.uicolor(forKey: Setting.Key.QRCode3D.NodeSpecularColor)!
            Dest?.DelegateTag = "SpecularColor"
            
        case "ToMaterialColorEditor":
            let Dest = segue.destination as? BasicColorEditor
            Dest?.CallerDelegate = self
            Dest?.InitialTitle = "Material Color"
            Dest?.InitialColorSpace = ColorEditorColorSpaces.HSB
            Dest?.InitialColor = _Settings.uicolor(forKey: Setting.Key.QRCode3D.NodeDiffuseColor)!
            Dest?.DelegateTag = "DiffuseColor"
            
        case "QRCodeContents":
            let Dest = segue.destination as? EncodedTimeFormatting
            Dest?.delegate = self
            
        default:
            break
        }
        
        super.prepare(for: segue, sender: self)
    }
    
    let ShapeList = ["Box", "Capsule", "Cone", "Cylinder", "Pyramid", "Sphere", "Torus", "Tube"]
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return ShapeList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return ShapeList[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        _Settings.set(row, forKey: Setting.Key.QRCode3D.NodeShape)
        UpdateSampleShape()
    }
    
    @IBAction func HandleDoneButtonPressed(_ sender: Any)
    {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func UpdateContentSample()
    {
        let Final = Utility.GetTimeStampToEncode(From: Date())
        BarcodeContentsSample.text = Final
    }
    
    func DoSet(Key: String, Value: Any?)
    {
        if Key == "TimeEncodingChanged"
        {
            print("Updated barcode contents.")
        }
    }
    
    @IBOutlet weak var ShapePicker: UIPickerView!
    @IBOutlet weak var SampleShape: SCNView!
    @IBOutlet weak var MaterialColorSample: UIView!
    @IBOutlet weak var ShininessColorSample: UIView!
    @IBOutlet weak var LightingColorSample: UIView!
    @IBOutlet weak var BarcodeContentsSample: UILabel!
}
