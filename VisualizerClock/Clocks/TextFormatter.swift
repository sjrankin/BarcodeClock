//
//  TextFormatter.swift
//  Visualizer Clock
//
//  Created by Stuart Rankin on 12/2/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class TextFormatter: UITableViewController, SettingProtocol, ColorReceiver
{
    let _Settings = UserDefaults.standard
    var delegate: SettingProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        InitializeColorSample(View: OutlineColorSample)
        InitializeColorSample(View: ShadowColorSample)
        InitializeColorSample(View: GlowColorSample)
        InitializeColorSample(View: FontColorSample)
        DoParseSettings()
    }
    
    //https://medium.com/@KaushElsewhere/how-to-dismiss-keyboard-in-a-view-controller-of-ios-3b1bfe973ad1
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        self.view.endEditing(true)
    }
    
    func DoParseSettings()
    {
        FontSizeTextBox.isEnabled = ShowSizeControls
        FontSizeLabel.isEnabled = ShowSizeControls
        if FontSetting == nil
        {
            FontName.text = ""
            FontLabel.isEnabled = false
        }
        else
        {
            FontLabel.isEnabled = true
            FontName.text = _Settings.string(forKey: FontSetting!)
        }
        if SizeSetting == nil
        {
            FontSizeLabel.isEnabled = false
            FontSizeTextBox.isEnabled = false
            FontSizeTextBox.isUserInteractionEnabled = false
            SetFontSizeButton.isUserInteractionEnabled = false
            SetFontSizeButton.isEnabled = false
        }
        else
        {
            FontSizeLabel.isEnabled = true
            FontSizeTextBox.isEnabled = true
            FontSizeTextBox.isUserInteractionEnabled = true
            SetFontSizeButton.isUserInteractionEnabled = true
            SetFontSizeButton.isEnabled = true
        }
        if FontColor == nil
        {
            FontColorSample.alpha = 0.0
            FontColorLabel.isEnabled = false
        }
        else
        {
            FontColorSample.backgroundColor = _Settings.uicolor(forKey: FontColor!)
        }
        if OutlineSetting == nil
        {
            OutlineLabel.isEnabled = false
            OutlineColorLabel.isEnabled = false
            OutlineSegment.isEnabled = false
            OutlineColorSample.alpha = 0.0
        }
        else
        {
            OutlineSegment.selectedSegmentIndex = _Settings.integer(forKey: OutlineSetting!)
            OutlineColorSample.backgroundColor = _Settings.uicolor(forKey: OutlineColor!)
        }
        if ShadowSetting == nil
        {
            ShadowLabel.isEnabled = false
            ShadowColorLabel.isEnabled = false
            ShadowSegment.isEnabled = false
            ShadowColorSample.alpha = 0.0
        }
        else
        {
            ShadowSegment.selectedSegmentIndex = _Settings.integer(forKey: ShadowSetting!)
            ShadowColorSample.backgroundColor = _Settings.uicolor(forKey: ShadowColor!)
        }
        if GlowSetting == nil
        {
            GlowLabel.isEnabled = false
            GlowColorLabel.isEnabled = false
            GlowSegment.isEnabled = false
            GlowColorSample.alpha = 0.0
        }
        else
        {
            GlowSegment.selectedSegmentIndex = _Settings.integer(forKey: GlowSetting!)
            GlowColorSample.backgroundColor = _Settings.uicolor(forKey: GlowColor!)
        }
        UpdateSample()
    }
    
    func InitializeColorSample(View: UIView)
    {
        View.layer.borderColor = UIColor.black.cgColor
        View.layer.borderWidth = 0.5
        View.layer.cornerRadius = 5.0
    }
    
    func UpdateSample()
    {
        SampleTextView.text = SampleText
        var FontName = "Helvetica Neue"
        var FontSize: CGFloat = 20.0
        if FontSetting != nil
        {
            FontName = _Settings.string(forKey: FontSetting!)!
        }
        if SizeSetting == nil
        {
            FontSize = Utility.RecommendedFontSize(HorizontalConstraint: SampleTextView.bounds.width, TheString: SampleText, FontName: FontName)
        }
        let Font = UIFont(name: FontName, size: FontSize)
        SampleTextView.font = Font
        SampleTextView.backgroundColor = CurrentBackgroundColor
        SampleTextView.textColor = FontColor == nil ? UIColor.black : _Settings.uicolor(forKey: FontColor!)!
    }
    
    var CurrentBackgroundColor = UIColor.white
    var SizeSetting: String? = nil
    var FontSetting: String? = nil
    var OutlineSetting: String? = nil
    var OutlineColor: String? = nil
    var ShadowSetting: String? = nil
    var ShadowColor: String? = nil
    var GlowSetting: String? = nil
    var GlowColor: String? = nil
    var SampleText: String = "Sample Text"
    var ShowSizeControls: Bool = true
    var FontColor: String? = nil
    
    func DoSet(Key: String, Value: Any?)
    {
        switch Key
        {
        case "ViewTitle":
            if let NewTitle = Value as? String
            {
                title = NewTitle
            }
            
        case "SizeType":
            ShowSizeControls = Value as! Bool
            
        case "SizeSetting":
            SizeSetting = Value as? String
            
        case "SampleText":
            SampleText = Value as! String
            SampleTextView.text = SampleText
            
        case "FontColor":
            FontColor = Value as? String
            
        case "FontSetting":
            FontSetting = Value as? String
            
        case "OutlineSetting":
            OutlineSetting = Value as? String
            
        case "OutlineColor":
            OutlineColor = Value as? String
            
        case "ShadowSetting":
            ShadowSetting = Value as? String
            
        case "ShadowColor":
            ShadowColor = Value as? String
            
        case "GlowSetting":
            GlowSetting = Value as? String
            
        case "GlowColor":
            GlowColor = Value as? String
            
        default:
            break
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        switch segue.identifier
        {
        case "ToFontPicker":
            break
            
        case "ToGlowColorEditor":
            if GlowColor == nil
            {
                return
            }
            let Dest = segue.destination as? BasicColorEditor
            Dest?.CallerDelegate = self
            Dest?.DelegateTag = "GlowColor"
            Dest?.InitialTitle = "Glow Color"
            Dest?.InitialColor = _Settings.uicolor(forKey: GlowColor!)!
            Dest?.InitialColorSpace = ColorEditorColorSpaces.HSB
            
        case "ToShadowColorEditor":
            if ShadowColor == nil
            {
                return
            }
            let Dest = segue.destination as? BasicColorEditor
            Dest?.CallerDelegate = self
            Dest?.DelegateTag = "ShadowColor"
            Dest?.DelegateTag = "ShadowColor"
            Dest?.InitialTitle = "Shadow Color"
            Dest?.InitialColor = _Settings.uicolor(forKey: ShadowColor!)!
            Dest?.InitialColorSpace = ColorEditorColorSpaces.HSB
            
        case "ToOutlineColorEditor":
            if OutlineColor == nil
            {
                return
            }
            let Dest = segue.destination as? BasicColorEditor
            Dest?.CallerDelegate = self
            Dest?.DelegateTag = "OutlineColor"
            Dest?.DelegateTag = "OutlineColor"
            Dest?.InitialTitle = "Outline Color"
            Dest?.InitialColor = _Settings.uicolor(forKey: OutlineColor!)!
            Dest?.InitialColorSpace = ColorEditorColorSpaces.HSB
            
        case "ToFontColorEditor":
            if FontColor == nil
            {
                return
            }
            let Dest = segue.destination as? BasicColorEditor
            Dest?.CallerDelegate = self
            Dest?.DelegateTag = "FontColor"
            Dest?.DelegateTag = "FontColor"
            Dest?.InitialTitle = "Font Color"
            Dest?.InitialColor = _Settings.uicolor(forKey: FontColor!)!
            Dest?.InitialColorSpace = ColorEditorColorSpaces.HSB
            
        case "ToBackgroundColorEditor":
            let Dest = segue.destination as? BasicColorEditor
            Dest?.CallerDelegate = self
            Dest?.DelegateTag = "BackgroundColor"
            Dest?.DelegateTag = "BackgroundColor"
            Dest?.InitialTitle = "Sample Background Color"
            Dest?.InitialColor = CurrentBackgroundColor
            Dest?.InitialColorSpace = ColorEditorColorSpaces.HSB
            
        default:
            break
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool
    {
        switch identifier
        {
        case "ToFontPicker":
            return FontSetting != nil
            
        case "ToGlowColorEditor":
            return GlowSetting != nil
            
        case "ToShadowColorEditor":
            return ShadowSetting != nil
            
        case "ToOutlineColorEditor":
            return OutlineSetting != nil
            
        case "ToFontColorEditor":
            return FontColor != nil
            
        case "ToBackgroundColorEditor":
            return true
            
        default:
            return true
        }
    }
    
    func ColorChanged(NewColor: UIColor, DidChange: Bool, Tag: String?)
    {
        if !DidChange
        {
            return
        }
        switch Tag
        {
        case "BackgroundColor":
            CurrentBackgroundColor = NewColor
            UpdateSample()
            
        case "GlowColor":
            if GlowColor != nil
            {
                _Settings.set(NewColor, forKey: GlowColor!)
                UpdateSample()
            }
            
        case "OutlineColor":
            if OutlineColor != nil
            {
                _Settings.set(NewColor, forKey: OutlineColor!)
                UpdateSample()
            }
            
        case "ShadowColor":
            if ShadowColor != nil
            {
                _Settings.set(NewColor, forKey: ShadowColor!)
                UpdateSample()
            }
            
        case "FontColor":
            if FontColor != nil
            {
                _Settings.set(NewColor, forKey: FontColor!)
                UpdateSample()
            }
            
        default:
            break
        }
    }
    
    @IBAction func HandleSetFontSizePressed(_ sender: Any)
    {
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        delegate?.DoSet(Key: "TextFormatter", Value: nil)
        super.viewWillDisappear(animated)
    }
    
    @IBOutlet weak var SetFontSizeButton: UIButton!
    @IBOutlet weak var FontColorLabel: UILabel!
    @IBOutlet weak var FontColorSample: UIView!
    @IBOutlet weak var GlowSegment: UISegmentedControl!
    @IBOutlet weak var ShadowSegment: UISegmentedControl!
    @IBOutlet weak var OutlineSegment: UISegmentedControl!
    @IBOutlet weak var GlowColorSample: UIView!
    @IBOutlet weak var ShadowColorSample: UIView!
    @IBOutlet weak var OutlineColorSample: UIView!
    @IBOutlet weak var GlowColorLabel: UILabel!
    @IBOutlet weak var GlowLabel: UILabel!
    @IBOutlet weak var ShadowColorLabel: UILabel!
    @IBOutlet weak var ShadowLabel: UILabel!
    @IBOutlet weak var OutlineColorLabel: UILabel!
    @IBOutlet weak var OutlineLabel: UILabel!
    @IBOutlet weak var FontName: UILabel!
    @IBOutlet weak var FontLabel: UILabel!
    @IBOutlet weak var SampleTextView: UILabel!
    @IBOutlet weak var FontSizeLabel: UILabel!
    @IBOutlet weak var FontSizeTextBox: UITextField!
}
