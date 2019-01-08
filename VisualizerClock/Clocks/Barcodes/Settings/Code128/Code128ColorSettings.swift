//
//  Code128ColorSettings.swift
//  Visualizer Clock
//
//  Created by Stuart Rankin on 11/29/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class Code128ColorSettings: UITableViewController, ColorReceiver, SettingProtocol
{
    let _Settings = UserDefaults.standard
    
    var delegate: SettingProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        OutlineNodeSwitch.isOn = _Settings.bool(forKey: Setting.Key.Code128.BarcodeStroked)
        UpdateUI()
        #if false
        if _Settings.bool(forKey: Setting.Key.Device.IsSmallDevice)
        {
            OutlineColorLabel.text = "Outline"
            ForegroundColorLabel.text = "Foreground"
            AttentionColorLabel.text = "Attention"
        }
        #endif
        ShowSampleColor(_Settings.uicolor(forKey: Setting.Key.Code128.BarcodeStrokeColor)!, View: OutlineColorSample)
        ShowSampleColor(_Settings.uicolor(forKey: Setting.Key.Code128.BarcodeForegroundColor1)!, View: ForegroundColorSample)
        ShowSampleColor(_Settings.uicolor(forKey: Setting.Key.Code128.BarcodeForegroundColor2)!, View: Foreground2ColorSample)
    }
    
    @IBAction func unwindToStep1ViewController(_ segue: UIStoryboardSegue)
    {
        
    }
    
    func UpdateUI()
    {
        OutlineColorLabel.isEnabled = OutlineNodeSwitch.isOn
    }
    
    @IBAction func HandleOutlineNodesChanged(_ sender: Any)
    {
        _Settings.set(OutlineNodeSwitch.isOn, forKey: Setting.Key.Code128.BarcodeStroked)
    }
    
    func ShowSampleColor(_ TheColor: UIColor, View: UIView)
    {
        View.layer.borderColor = UIColor.black.cgColor
        View.layer.borderWidth = 0.5
        View.layer.cornerRadius = 5.0
        View.backgroundColor = TheColor
    }
    
    func DoSet(Key: String, Value: Any?)
    {
        
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool
    {
        switch identifier
        {
        case "EditOutlineColor":
            return OutlineNodeSwitch.isOn
            
        default:
            return true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        var NewSegue: UIStoryboardSegue!
        switch segue.identifier
        {
        case "EditOutlineColor":
            #if true
            NewSegue = ColorEditorManager.Show(Segue: segue, Receiver: self, Title: "Outline Color",
                                               InitialColor: _Settings.uicolor(forKey: Setting.Key.Code128.BarcodeStrokeColor)!,
                                               ColorSpace: ColorEditorColorSpaces.HSB, Tag: "OutlineColor")
            //print("NewSegue.identifier=\((NewSegue.identifier)!)")
            super.prepare(for: NewSegue, sender: self)
            return
            #else
            let Dest = segue.destination as? BasicColorEditor
            Dest?.CallerDelegate = self
            Dest?.InitialTitle = "Outline Color"
            Dest?.InitialColorSpace = ColorEditorColorSpaces.HSB
            Dest?.InitialColor = _Settings.uicolor(forKey: Setting.Key.Code128.BarcodeStrokeColor)!
            Dest?.DelegateTag = "OutlineColor"
            #endif
            
        case "EditFG1Color":
            #if true
            NewSegue = ColorEditorManager.Show(Segue: segue, Receiver: self, Title: "Foreground Color",
                                               InitialColor: _Settings.uicolor(forKey: Setting.Key.Code128.BarcodeForegroundColor1)!,
                                               ColorSpace: ColorEditorColorSpaces.HSB, Tag: "FG1Color")
            //print("NewSegue.identifier=\((NewSegue.identifier)!)")
            super.prepare(for: NewSegue, sender: self)
            return
            #else
            let Dest = segue.destination as? BasicColorEditor
            Dest?.CallerDelegate = self
            Dest?.InitialTitle = "Foreground Color"
            Dest?.InitialColorSpace = ColorEditorColorSpaces.HSB
            Dest?.InitialColor = _Settings.uicolor(forKey: Setting.Key.Code128.BarcodeForegroundColor1)!
            Dest?.DelegateTag = "FG1Color"
            #endif
            
        case "EditFG2Color":
            #if true
            NewSegue = ColorEditorManager.Show(Segue: segue, Receiver: self, Title: "Attention Color",
                                    InitialColor: _Settings.uicolor(forKey: Setting.Key.Code128.BarcodeForegroundColor2)!,
                                    ColorSpace: ColorEditorColorSpaces.HSB, Tag: "FG2Color")
            //print("NewSegue.identifier=\((NewSegue.identifier)!)")
            super.prepare(for: NewSegue, sender: self)
            return
            #else
            let Dest = segue.destination as? BasicColorEditor
            Dest?.CallerDelegate = self
            Dest?.InitialTitle = "Attention Color"
            Dest?.InitialColorSpace = ColorEditorColorSpaces.HSB
            Dest?.InitialColor = _Settings.uicolor(forKey: Setting.Key.Code128.BarcodeForegroundColor2)!
            Dest?.DelegateTag = "FG2Color"
            #endif
            
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
        case "OutlineColor":
            _Settings.set(NewColor, forKey: Setting.Key.Code128.BarcodeStrokeColor)
            ShowSampleColor(NewColor, View: OutlineColorSample)
            
        case "FG1Color":
            _Settings.set(NewColor, forKey: Setting.Key.Code128.BarcodeForegroundColor1)
            ShowSampleColor(NewColor, View: ForegroundColorSample)
            
        case "FG2Color":
            _Settings.set(NewColor, forKey: Setting.Key.Code128.BarcodeForegroundColor2)
            ShowSampleColor(NewColor, View: Foreground2ColorSample)
            
        default:
            break
        }
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        delegate?.DoSet(Key: "SomeColor", Value: nil)
        super.viewWillDisappear(animated)
    }
    
    @IBOutlet weak var AttentionColorLabel: UILabel!
    @IBOutlet weak var ForegroundColorLabel: UILabel!
    @IBOutlet weak var OutlineNodeSwitch: UISwitch!
    @IBOutlet weak var OutlineColorLabel: UILabel!
    @IBOutlet weak var OutlineColorSample: UIView!
    @IBOutlet weak var ForegroundColorSample: UIView!
    @IBOutlet weak var Foreground2ColorSample: UIView!
}
