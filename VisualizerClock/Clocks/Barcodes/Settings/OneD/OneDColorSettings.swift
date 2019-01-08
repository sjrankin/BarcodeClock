//
//  OneDColorSettings.swift
//  Visualizer Clock
//
//  Created by Stuart Rankin on 12/24/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class OneDColorSettings: UITableViewController, ColorReceiver, SettingProtocol
{
    let _Settings = UserDefaults.standard
    
    var delegate: SettingProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if let ParentClock = ParentClock
        {
            ISetting = SettingHandle(FromClock: ParentClock)
        }
        OutlineNodeSwitch.isOn = ISetting!.Get(Key: SettingKey.BarcodeStroked)
        ColorsCanVaryByLength = (ISetting?.HasSetting(Key: SettingKey.ColorsVaryOnLength))!
        UpdateUI()
        ShowSampleColor(ISetting!.Get(Key: SettingKey.BarcodeStrokeColor), View: OutlineColorSample)
        ShowSampleColor(ISetting!.Get(Key: SettingKey.BarcodeForegroundColor), View: ForegroundColorSample)
        ShowSampleColor(ISetting!.Get(Key: SettingKey.BarcodeAttentionColor), View: Foreground2ColorSample)
        if ColorsCanVaryByLength
        {
            ShowSampleColor(ISetting!.Get(Key: SettingKey.LongBarColor), View: TallColorSample)
            ShowSampleColor(ISetting!.Get(Key: SettingKey.ShortBarColor), View: ShortColorSample)
            VaryByLengthSwitch.isOn = ISetting!.Get(Key: SettingKey.ColorsVaryOnLength)
        }
        else
        {
            ShowSampleColor(UIColor.black, View: TallColorSample)
            ShowSampleColor(UIColor.black, View: ShortColorSample)
            VaryByLengthSwitch.isEnabled = false
            VaryLabel.isEnabled = false
            BigLabel.isEnabled = false
            SmallLabel.isEnabled = false
        }
    }
    
    var ColorsCanVaryByLength: Bool = false
    
    var ISetting: SettingHandle? = nil
    
    @IBAction func unwindToStep1ViewController(_ segue: UIStoryboardSegue)
    {
        
    }
    
    func UpdateUI()
    {
        OutlineColorLabel.isEnabled = OutlineNodeSwitch.isOn
    }
    
    @IBAction func HandleOutlineNodesChanged(_ sender: Any)
    {
        ISetting!.Set(OutlineNodeSwitch.isOn, Key: SettingKey.BarcodeStroked)
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
        switch Key
        {
        case "ParentClock":
            ParentClock = Value as? PanelActions
            switch ParentClock!
            {
            case .SwitchToPOSTNET:
                title = "POSTNET Colors"
                
            case .SwitchToPharmaCode:
                title = "Pharmacode Colors"
                
            default:
                title = "UNKNOWN"
            }
            
        default:
            break
        }
    }
    
    var ParentClock: PanelActions? = nil
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool
    {
        switch identifier
        {
        case "EditOutlineColor":
            return OutlineNodeSwitch.isOn
            
        case "EditTallColor":
            return ColorsCanVaryByLength
            
        case "EditSortColor":
            return ColorsCanVaryByLength
            
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
            NewSegue = ColorEditorManager.Show(Segue: segue, Receiver: self, Title: "Outline Color",
                                               InitialColor: ISetting!.Get(Key: SettingKey.BarcodeStrokeColor),
                                               ColorSpace: ColorEditorColorSpaces.HSB, Tag: "OutlineColor")
            super.prepare(for: NewSegue, sender: self)
            return
            
        case "EditFG1Color":
            NewSegue = ColorEditorManager.Show(Segue: segue, Receiver: self, Title: "Foreground Color",
                                               InitialColor: ISetting!.Get(Key: SettingKey.BarcodeForegroundColor),
                                               ColorSpace: ColorEditorColorSpaces.HSB, Tag: "FG1Color")
            super.prepare(for: NewSegue, sender: self)
            return
            
        case "EditFG2Color":
            NewSegue = ColorEditorManager.Show(Segue: segue, Receiver: self, Title: "Attention Color",
                                               InitialColor: ISetting!.Get(Key: SettingKey.BarcodeAttentionColor),
                                               ColorSpace: ColorEditorColorSpaces.HSB, Tag: "FG2Color")
            super.prepare(for: NewSegue, sender: self)
            return
            
        case "EditTallColor":
            NewSegue = ColorEditorManager.Show(Segue: segue, Receiver: self, Title: "Tall Color",
                                               InitialColor: ISetting!.Get(Key: SettingKey.LongBarColor),
                                               ColorSpace: ColorEditorColorSpaces.HSB, Tag: "TallColor")
            super.prepare(for: NewSegue, sender: self)
            return
            
        case "EditShortColor":
            NewSegue = ColorEditorManager.Show(Segue: segue, Receiver: self, Title: "Short Color",
                                               InitialColor: ISetting!.Get(Key: SettingKey.ShortBarColor),
                                               ColorSpace: ColorEditorColorSpaces.HSB, Tag: "ShortColor")
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
        case "OutlineColor":
            ISetting!.Set(NewColor, Key: SettingKey.BarcodeStrokeColor)
            ShowSampleColor(NewColor, View: OutlineColorSample)
            
        case "FG1Color":
            ISetting!.Set(NewColor, Key: SettingKey.BarcodeForegroundColor)
            ShowSampleColor(NewColor, View: ForegroundColorSample)
            
        case "FG2Color":
            ISetting!.Set(NewColor, Key: SettingKey.BarcodeAttentionColor)
            ShowSampleColor(NewColor, View: Foreground2ColorSample)
            
        case "TallColor":
            ISetting!.Set(NewColor, Key: SettingKey.LongBarColor)
            ShowSampleColor(NewColor, View: TallColorSample)
            
        case "ShortColor":
            ISetting!.Set(NewColor, Key: SettingKey.ShortBarColor)
            ShowSampleColor(NewColor, View: ShortColorSample)
            
        default:
            break
        }
    }
    
    @IBAction func HandleVaryByLengthChanged(_ sender: Any)
    {
        ISetting?.Set(VaryByLengthSwitch.isOn, Key: SettingKey.ColorsVaryOnLength)
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        delegate?.DoSet(Key: "SomeColor", Value: nil)
        super.viewWillDisappear(animated)
    }
    
    @IBOutlet weak var ShortColorSample: UIView!
    @IBOutlet weak var TallColorSample: UIView!
    @IBOutlet weak var AttentionColorLabel: UILabel!
    @IBOutlet weak var ForegroundColorLabel: UILabel!
    @IBOutlet weak var OutlineNodeSwitch: UISwitch!
    @IBOutlet weak var OutlineColorLabel: UILabel!
    @IBOutlet weak var OutlineColorSample: UIView!
    @IBOutlet weak var ForegroundColorSample: UIView!
    @IBOutlet weak var Foreground2ColorSample: UIView!
    @IBOutlet weak var VaryByLengthSwitch: UISwitch!
    @IBOutlet weak var VaryLabel: UILabel!
    @IBOutlet weak var BigLabel: UILabel!
    @IBOutlet weak var SmallLabel: UILabel!
}
