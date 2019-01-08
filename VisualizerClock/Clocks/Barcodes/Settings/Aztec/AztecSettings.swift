//
//  AztecSettings.swift
//  Visualizer Clock
//
//  Created by Stuart Rankin on 12/1/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class AztecSettings: UITableViewController, ColorReceiver, SettingProtocol, ClockSettingsProtocol
{
    let _Settings = UserDefaults.standard
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        Handle = VectorHandle.Make()
        Background = BackgroundServer(AztecSample)
        BGTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self,
                                       selector: #selector(UpdateBG), userInfo: nil, repeats: true)
        
        BarcodeContentsLabel.text = Utility.GetTimeStampToEncode(From: Date())
        ContentTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self,
                                            selector: #selector(UpdateContentSample), userInfo: nil, repeats: true)
        
        AztecSample.layer.borderColor = UIColor.black.cgColor
        AztecSample.layer.borderWidth = 0.5
        AztecSample.layer.cornerRadius = 5.0
        UpdateColorSample(ForegroundSampleView, WithColor: _Settings.uicolor(forKey: Setting.Key.Aztec.NodeColor)!)
        UpdateColorSample(HighlightSampleView, WithColor: _Settings.uicolor(forKey: Setting.Key.Aztec.HighlightColor)!)
        UpdateAztecSample()
        SampleTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self,
                                           selector: #selector(UpdateAztecSample), userInfo: nil, repeats: true)
    
    SFXSegment.selectedSegmentIndex = _Settings.integer(forKey: Setting.Key.Aztec.HighlightStyle)
        NodeShapeSegment.selectedSegmentIndex = _Settings.integer(forKey: Setting.Key.Aztec.NodeStyle)
        ShadowsSegment.selectedSegmentIndex = _Settings.integer(forKey: Setting.Key.Aztec.ShadowLevel)
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
    
    var Handle: VectorHandle!
    var Background: BackgroundServer!
    var BGTimer: Timer!
    var ContentTimer: Timer!
    var SampleTimer: Timer!
    
    @objc func UpdateBG()
    {
        Background.UpdateBackgroundColors()
    }
    
    @objc func UpdateContentSample()
    {
        let Final = Utility.GetTimeStampToEncode(From: Date())
        BarcodeContentsLabel.text = Final
    }
    
    @objc func UpdateAztecSample()
    {
        Handle.Background = UIColor.clear
        Handle.Foreground = _Settings.uicolor(forKey: Setting.Key.Aztec.NodeColor)!
        Handle.HighlightColor = _Settings.uicolor(forKey: Setting.Key.Aztec.HighlightColor)!
        Handle.ShadowLevel = _Settings.integer(forKey: Setting.Key.Aztec.ShadowLevel)
        Handle.NodeShape = _Settings.integer(forKey: Setting.Key.Aztec.NodeStyle)
        Handle.HighlightStyle = _Settings.integer(forKey: Setting.Key.Aztec.HighlightStyle)
        let Final = Utility.GetTimeStampToEncode(From: Date())
        var NotUsed: Int = 0
        let Sample = BarcodeAztecClock.CreateAztecBarcodeA(From: Final, OutputFrame: AztecSample.frame,
                                                           Count: &NotUsed, Handle: Handle,
                                                           Caller: "AztecSettings")
        if Sample == nil
        {
            print("CreateAztecBarcodeA returned error.")
            return
        }
        AztecSample.subviews.forEach{$0.removeFromSuperview()}
        Sample!.frame = CGRect(x: AztecSample.bounds.width / 2.0 - Sample!.bounds.width / 2.0,
                               y: AztecSample.bounds.height / 2.0 - Sample!.bounds.height / 2.0,
                               width: Sample!.frame.width, height: Sample!.frame.height)
        AztecSample.addSubview(Sample!)
    }
    
    func UpdateColorSample(_ View: UIView, WithColor: UIColor)
    {
        View.layer.borderWidth = 0.5
        View.layer.borderColor = UIColor.black.cgColor
        View.layer.cornerRadius = 5.0
        View.backgroundColor = WithColor
    }
    
    @IBAction func HandleDonePressed(_ sender: Any)
    {
        dismiss(animated: true, completion: nil)
    }   
    
    @IBAction func HandleNodeShapeChanged(_ sender: Any)
    {
        _Settings.set(NodeShapeSegment.selectedSegmentIndex, forKey: Setting.Key.Aztec.NodeStyle)
        UpdateAztecSample()
    }
    
    @IBOutlet weak var NodeShapeSegment: UISegmentedControl!
    
    @IBAction func HandleSFXSegmentChanged(_ sender: Any)
    {
        _Settings.set(SFXSegment.selectedSegmentIndex, forKey: Setting.Key.Aztec.HighlightStyle)
        UpdateAztecSample()
    }
    
    @IBOutlet weak var SFXSegment: UISegmentedControl!
    
    @IBOutlet weak var ShadowsSegment: UISegmentedControl!
    
    @IBAction func HandleShadowsChanged(_ sender: Any)
    {
        _Settings.set(ShadowsSegment.selectedSegmentIndex, forKey: Setting.Key.Aztec.ShadowLevel)
        UpdateAztecSample()
    }
    
    func DoSet(Key: String, Value: Any?)
    {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        var NewSegue: UIStoryboardSegue!
        
        switch segue.identifier
        {
        case "ToBarcodeContents":
            let Dest = segue.destination as? EncodedTimeFormatting
            Dest?.delegate = self
            
        case "ToNodeColor":
            NewSegue = ColorEditorManager.Show(Segue: segue, Receiver: self, Title: "Aztec Barcode",
                                               InitialColor: _Settings.uicolor(forKey: Setting.Key.Aztec.NodeColor)!,
                                               ColorSpace: ColorEditorColorSpaces.HSB, Tag: "ForegroundColor")
            super.prepare(for: NewSegue, sender: self)
            return
            
        case "ToHighlightColor":
            NewSegue = ColorEditorManager.Show(Segue: segue, Receiver: self, Title: "Aztec Barcode Highlight",
                                               InitialColor: _Settings.uicolor(forKey: Setting.Key.Aztec.HighlightColor)!,
                                               ColorSpace: ColorEditorColorSpaces.HSB, Tag: "HighlightColor")
            super.prepare(for: NewSegue, sender: self)
            return
            
        default:
            break
        }
        
        super.prepare(for: segue, sender: self)
    }
    
    func ColorChanged(NewColor: UIColor, DidChange: Bool, Tag: String?)
    {
        if !DidChange
        {
            return
        }
        switch Tag
        {
        case "ForegroundColor":
            _Settings.set(NewColor, forKey: Setting.Key.Aztec.NodeColor)
            UpdateAztecSample()
            UpdateColorSample(ForegroundSampleView, WithColor: NewColor)
            
        case "HighlightColor":
            _Settings.set(NewColor, forKey: Setting.Key.Aztec.HighlightColor)
            UpdateAztecSample()
            UpdateColorSample(HighlightSampleView, WithColor: NewColor)
            
        default:
            break
        }
    }
    
    @IBOutlet weak var AztecSample: UIView!
    @IBOutlet weak var BarcodeContentsLabel: UILabel!
    @IBOutlet weak var ForegroundSampleView: UIView!
    @IBOutlet weak var HighlightSampleView: UIView!
}
