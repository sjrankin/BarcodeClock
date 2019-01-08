//
//  TextVisualAttributes.swift
//  Visualizer Clock
//
//  Created by Stuart Rankin on 11/29/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class TextVisualAttributes: UITableViewController, ColorReceiver, SettingProtocol
{
    let _Settings = UserDefaults.standard
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        TextView.backgroundColor = _Settings.uicolor(forKey: Setting.Key.Text.SampleBackground)
        TextView.layer.borderWidth = 0.5
        TextView.layer.borderColor = UIColor.black.cgColor
        TextView.layer.cornerRadius = 5.0
        SetSampleMenu()
        let _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(UpdateTimeSample), userInfo: nil, repeats: true)
        UpdateTimeSample()
        UpdateColorSample(With: _Settings.uicolor(forKey: Setting.Key.Text.Color)!, InView: TextColorSample)
        UpdateColorSample(With: _Settings.uicolor(forKey: Setting.Key.Text.OutlineColor)!, InView: OutlineColorSample)
        BlinkColonsSwitch.isOn = _Settings.bool(forKey: Setting.Key.Text.BlinkColons)
        OutlineTextSwitch.isOn = _Settings.bool(forKey: Setting.Key.Text.OutlineText)
    }
    
    func SetSampleMenu()
    {
        let LongPress = UILongPressGestureRecognizer(target: self, action: #selector(HandleSampleLongPress))
        TextView.addGestureRecognizer(LongPress)
    }
    
    @objc func HandleSampleLongPress(_ sender: UILongPressGestureRecognizer)
    {
        if sender.state != UIGestureRecognizer.State.began
        {
            return
        }
        let SampleOptions = UIAlertController(title: "Sample Options",
                                              message: "Options for the sample view.",
                                              preferredStyle: UIAlertController.Style.actionSheet)
        SampleOptions.addAction(UIAlertAction(title: "Change background color", style: UIAlertAction.Style.default, handler: HandleSampleOption))
        SampleOptions.addAction(UIAlertAction(title: "Reset background color", style: UIAlertAction.Style.default, handler: HandleSampleOption))
        SampleOptions.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(SampleOptions, animated: true)
    }
    
    @objc func HandleSampleOption(Action: UIAlertAction!)
    {
        switch Action.title
        {
        case "Change background color":
            performSegue(withIdentifier: "EditSampleBackgroundColor", sender: self)
            
        case "Reset background color":
            _Settings.set(UIColor.gold, forKey: Setting.Key.Text.SampleBackground)
            SampleLabel.backgroundColor = _Settings.uicolor(forKey: Setting.Key.Text.SampleBackground)
            
        default:
            break
        }
    }
    
    @objc func UpdateTimeSample()
    {
        TimeFormatter.GetDisplayTime(Date(), Output: SampleLabel)
    }
    
    func UpdateColorSample(With: UIColor, InView: UIView)
    {
        InView.layer.cornerRadius = 5.0
        InView.layer.borderColor = UIColor.black.cgColor
        InView.layer.borderWidth = 0.5
        InView.backgroundColor = With
    }
    
    @IBOutlet weak var TextView: UIView!
    
    @IBAction func HandleBlinkColonsChanged(_ sender: Any)
    {
        _Settings.set(BlinkColonsSwitch.isOn, forKey: Setting.Key.Text.BlinkColons)
        UpdateTimeSample()
    }
    
    @IBOutlet weak var BlinkColonsSwitch: UISwitch!
    
    @IBOutlet weak var OutlineTextSwitch: UISwitch!
    
    @IBAction func HandleOutlineTextChanged(_ sender: Any)
    {
        _Settings.set(OutlineTextSwitch.isOn, forKey: Setting.Key.Text.OutlineText)
        UpdateTimeSample()
    }
    
    func ColorChanged(NewColor: UIColor, DidChange: Bool, Tag: String?)
    {
        if !DidChange
        {
            return
        }
        switch Tag
        {
        case "TextColor":
            _Settings.set(NewColor, forKey: Setting.Key.Text.Color)
            UpdateColorSample(With: _Settings.uicolor(forKey: Setting.Key.Text.Color)!, InView: TextColorSample)
            UpdateTimeSample()
            
        case "OutlineColor":
            _Settings.set(NewColor, forKey: Setting.Key.Text.OutlineColor)
            UpdateColorSample(With: _Settings.uicolor(forKey: Setting.Key.Text.OutlineColor)!, InView: OutlineColorSample)
            UpdateTimeSample()

        case "SampleBackground":
            _Settings.set(NewColor, forKey: Setting.Key.Text.SampleBackground)
            SampleLabel.backgroundColor = NewColor
            
        default:
            break
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        switch segue.identifier
        {
        case "ToFontViewer":
            let Dest = segue.destination as? FontSelection2
            Dest?.DoSet(Key: "FontName", Value: _Settings.string(forKey: Setting.Key.Text.FontName))
            
        case "EditSampleBackgroundColor":
            let Dest = segue.destination as? BasicColorEditor
            Dest?.CallerDelegate = self
            Dest?.InitialTitle = "Sample Background Color"
            Dest?.InitialColorSpace = ColorEditorColorSpaces.HSB
            Dest?.InitialColor = _Settings.uicolor(forKey: Setting.Key.Text.SampleBackground)!
            Dest?.DelegateTag = "SampleBackground"
            
        case "EditTextColor":
            let Dest = segue.destination as? BasicColorEditor
            Dest?.CallerDelegate = self
            Dest?.InitialTitle = "Text Color"
            Dest?.InitialColorSpace = ColorEditorColorSpaces.HSB
            Dest?.InitialColor = _Settings.uicolor(forKey: Setting.Key.Text.Color)!
            Dest?.DelegateTag = "TextColor"
            
        case "EditOutlineColor":
            let Dest = segue.destination as? BasicColorEditor
            Dest?.CallerDelegate = self
            Dest?.InitialTitle = "Text Outline Color"
            Dest?.InitialColorSpace = ColorEditorColorSpaces.HSB
            Dest?.InitialColor = _Settings.uicolor(forKey: Setting.Key.Text.OutlineColor)!
            Dest?.DelegateTag = "OutlineColor"

        default:
            break
        }
        super.prepare(for: segue, sender: self)
    }
    
    func DoSet(Key: String, Value: Any?)
    {
        if Key == "ChildUpdated"
        {
            let NewFontName = Value as! String
            _Settings.set(NewFontName, forKey: Setting.Key.Text.FontName)
            UpdateTimeSample()
        }
    }
    
    @IBOutlet weak var TextColorSample: UIView!
    
    @IBOutlet weak var OutlineColorSample: UIView!
    
    @IBOutlet weak var SampleLabel: UILabel!
}
