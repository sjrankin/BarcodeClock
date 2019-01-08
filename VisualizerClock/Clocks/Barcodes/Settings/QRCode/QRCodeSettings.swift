//
//  QRCodeSettings.swift
//  Visualizer Clock
//
//  Created by Stuart Rankin on 12/1/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class QRCodeSettings: UITableViewController, ColorReceiver, SettingProtocol, ClockSettingsProtocol
{
    let _Settings = UserDefaults.standard
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        Handle = VectorHandle.Make()
        DrawColorSample(NodeColorSample, _Settings.uicolor(forKey: Setting.Key.QRCode.NodeColor)!)
        DrawColorSample(HighlightSample, _Settings.uicolor(forKey: Setting.Key.QRCode.HighlightColor)!)
        NodeShapeSegment.selectedSegmentIndex = _Settings.integer(forKey: Setting.Key.QRCode.NodeStyle)
        ShadowTypeSegment.selectedSegmentIndex = _Settings.integer(forKey: Setting.Key.QRCode.ShadowLevel)
        SFXSegment.selectedSegmentIndex = _Settings.integer(forKey: Setting.Key.QRCode.SpecialEffects)
        ContentTimeStamp.text = Utility.GetTimeStampToEncode(From: Date())
        ContentTimer = Timer.scheduledTimer(timeInterval: 1, target: self,
                                            selector: #selector(UpdateContentSample), userInfo: nil, repeats: true)
        Background = BackgroundServer(BarcodeSample)
        BGTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self,
                                       selector: #selector(UpdateBG), userInfo: nil, repeats: true)
        UpdateContentSample()
        ShowSample(UpdateToo: true)
    }
    
    var Handle: VectorHandle!
    
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
    
    @objc func UpdateBG()
    {
        Background.UpdateBackgroundColors()
    }
    
    var Background: BackgroundServer!
    var BGTimer: Timer!
    var ContentTimer: Timer!
    
    func GetNodeSizeIndex(NodeSize: Double) -> Int
    {
        if NodeSize < 0.75
        {
            return 0
        }
        if NodeSize < 0.85
        {
            return 1
        }
        if NodeSize <= 1.0
        {
            return 2
        }
        return 0
    }
    
    func GetNodeSizeValue(NodeIndex: Int) -> Double
    {
        switch NodeIndex
        {
        case 0:
            return 0.75
            
        case 1:
            return 0.85
            
        case 2:
            return 1.0
            
        default:
            return 0
        }
    }
    
    @objc func UpdateContentSample()
    {
        let Final = Utility.GetTimeStampToEncode(From: Date())
        ContentTimeStamp.text = Final
    }
    
    func DrawColorSample(_ Sample: UIView, _ NodeColor: UIColor)
    {
        Sample.layer.cornerRadius = 5.0
        Sample.layer.borderColor = UIColor.black.cgColor
        Sample.layer.borderWidth = 0.5
        Sample.backgroundColor = NodeColor
    }
    
    func DoSet(Key: String, Value: Any?)
    {
    }
    
    func ColorChanged(NewColor: UIColor, DidChange: Bool, Tag: String?)
    {
        if !DidChange
        {
            return
        }
        switch Tag
        {
        case "NodeColor":
            _Settings.set(NewColor, forKey: Setting.Key.QRCode.NodeColor)
            DrawColorSample(NodeColorSample, NewColor)
            UpdateSample()
            
        case "HighlightColor":
            _Settings.set(NewColor, forKey: Setting.Key.QRCode.HighlightColor)
            DrawColorSample(HighlightSample, NewColor)
            UpdateSample()
            
        default:
            break
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        var NewSegue: UIStoryboardSegue!
        
        switch segue.identifier
        {
        case "ToQRNodeColorEditor":
            NewSegue = ColorEditorManager.Show(Segue: segue, Receiver: self, Title: "QR Code",
                                               InitialColor: _Settings.uicolor(forKey: Setting.Key.QRCode.NodeColor)!,
                                               ColorSpace: ColorEditorColorSpaces.HSB, Tag: "NodeColor")
            super.prepare(for: NewSegue, sender: self)
            return
            
        case "ToQRNodeHighlightColorEditor":
            NewSegue = ColorEditorManager.Show(Segue: segue, Receiver: self, Title: "QR Node Highlight",
                                               InitialColor: _Settings.uicolor(forKey: Setting.Key.QRCode.HighlightColor)!,
                                               ColorSpace: ColorEditorColorSpaces.HSB, Tag: "HighlightColor")
            super.prepare(for: NewSegue, sender: self)
            return
            
        case "ToQRContents":
            let Dest = segue.destination as? EncodedTimeFormatting
            Dest?.delegate = self
            
        default:
            break
        }
        super.prepare(for: segue, sender: self)
    }
    
    @IBOutlet weak var NodeShapeSegment: UISegmentedControl!
    
    @IBAction func HandleNodeShapeChanged(_ sender: Any)
    {
        _Settings.set(NodeShapeSegment.selectedSegmentIndex, forKey: Setting.Key.QRCode.NodeStyle)
        UpdateSample()
    }
    
    @IBOutlet weak var ShadowTypeSegment: UISegmentedControl!
    
    @IBAction func HandleShadowTypeChanged(_ sender: Any)
    {
        _Settings.set(ShadowTypeSegment.selectedSegmentIndex, forKey: Setting.Key.QRCode.ShadowLevel)
        UpdateSample()
    }
    
    func ShowSample(UpdateToo: Bool = false)
    {
        BarcodeSample.layer.cornerRadius = 5.0
        BarcodeSample.layer.borderColor = UIColor.black.cgColor
        BarcodeSample.layer.borderWidth = 0.5
        BarcodeSample.backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 1.0)
        SampleTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(UpdateSample),
                                           userInfo: nil, repeats: true)
        if UpdateToo
        {
            UpdateSample()
        }
    }
    
    var SampleTimer: Timer!
    
    @objc func UpdateSample()
    {
        Handle.Background = UIColor.clear
        Handle.Foreground = _Settings.uicolor(forKey: Setting.Key.QRCode.NodeColor)!
        Handle.HighlightColor = _Settings.uicolor(forKey: Setting.Key.QRCode.HighlightColor)!
        Handle.ShadowLevel = _Settings.integer(forKey: Setting.Key.QRCode.ShadowLevel)
        Handle.NodeShape = _Settings.integer(forKey: Setting.Key.QRCode.NodeStyle)
        Handle.HighlightStyle = _Settings.integer(forKey: Setting.Key.QRCode.SpecialEffects)
        let Final = Utility.GetTimeStampToEncode(From: Date())
        var NotUsed: Int = 0
        let Sample = BarcodeQRClock.CreateQRBarcodeA(From: Final, OutputFrame: BarcodeSample.frame,
                                                     Count: &NotUsed, Handle: Handle,
                                                     Caller: "QRCodeSetttings")
        if Sample == nil
        {
            print("CreateQRBarcodeA returned error.")
            return
        }
        BarcodeSample.subviews.forEach{$0.removeFromSuperview()}
        Sample!.frame = CGRect(x: BarcodeSample.bounds.width / 2.0 - Sample!.bounds.width / 2.0,
                               y: BarcodeSample.bounds.height / 2.0 - Sample!.bounds.height / 2.0,
                               width: Sample!.frame.width, height: Sample!.frame.height)
        BarcodeSample.addSubview(Sample!)
    }
    
    var Previous: [[Int]]? = nil
    
    @IBOutlet weak var SFXSegment: UISegmentedControl!
    
    @IBAction func HandleSFXChanged(_ sender: Any)
    {
        _Settings.set(SFXSegment.selectedSegmentIndex, forKey: Setting.Key.QRCode.SpecialEffects)
        UpdateSample()
    }
    
    @IBAction func HandleDonePressed(_ sender: Any)
    {
        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var ContentTimeStamp: UILabel!
    @IBOutlet weak var NodeColorSample: UIView!
    @IBOutlet weak var BarcodeSample: UIView!
    @IBOutlet weak var HighlightSample: UIView!
}
