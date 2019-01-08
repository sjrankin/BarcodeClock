//
//  TextHighlighting.swift
//  Visualizer Clock
//
//  Created by Stuart Rankin on 11/30/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class TextHighlighting: UITableViewController, SettingProtocol, ColorReceiver
{
    let _Settings = UserDefaults.standard
    var delegate: SettingProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        TextView.backgroundColor = _Settings.uicolor(forKey: Setting.Key.Text.SampleBackground)
        TextView.layer.borderWidth = 0.5
        TextView.layer.borderColor = UIColor.black.cgColor
        TextView.layer.cornerRadius = 5.0
        SetSampleMenu()
        let _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(UpdateTimeSample), userInfo: nil, repeats: true)
        GlowSegment.selectedSegmentIndex = _Settings.integer(forKey: Setting.Key.Text.GlowType)
        ShadowSegment.selectedSegmentIndex = _Settings.integer(forKey: Setting.Key.Text.ShadowType)
        UpdateColorSample(With: _Settings.uicolor(forKey: Setting.Key.Text.ShadowColor)!, InView: ShadowColorSample)
        UpdateColorSample(With: _Settings.uicolor(forKey: Setting.Key.Text.GlowColor)!, InView: GlowColorSample)
        UpdateUI()
        UpdateTimeSample()
    }
    
    func UpdateUI()
    {
        HighlightSegment.selectedSegmentIndex = _Settings.integer(forKey: Setting.Key.Text.HighlightType)
        switch _Settings.integer(forKey: Setting.Key.Text.HighlightType)
        {
        case 0:
            ShadowLabel.isEnabled = false
            ShadowSegment.isEnabled = false
            GlowLabel.isEnabled = false
            GlowSegment.isEnabled = false
            
        case 1:
            ShadowLabel.isEnabled = true
            ShadowSegment.isEnabled = true
            GlowLabel.isEnabled = false
            GlowSegment.isEnabled = false
            
        case 2:
            ShadowLabel.isEnabled = false
            ShadowSegment.isEnabled = false
            GlowLabel.isEnabled = true
            GlowSegment.isEnabled = true
            
        default:
            break
        }
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
    
    func DoSet(Key: String, Value: Any?)
    {
    }
    
    @IBAction func HandleHighlightChanged(_ sender: Any)
    {
        _Settings.set(HighlightSegment.selectedSegmentIndex, forKey: Setting.Key.Text.HighlightType)
        UpdateUI()
    }
    
    @IBOutlet weak var HighlightSegment: UISegmentedControl!
    
    @IBOutlet weak var ShadowLabel: UILabel!
    
    @IBAction func HandleShadowChanged(_ sender: Any)
    {
        _Settings.set(ShadowSegment.selectedSegmentIndex, forKey: Setting.Key.Text.ShadowType)
        UpdateTimeSample()
    }
    
    @IBOutlet weak var ShadowSegment: UISegmentedControl!
    
    @IBOutlet weak var GlowLabel: UILabel!
    
    @IBAction func HandleGlowChanged(_ sender: Any)
    {
        _Settings.set(GlowSegment.selectedSegmentIndex, forKey: Setting.Key.Text.GlowType)
        UpdateTimeSample()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        switch segue.identifier
        {
        case "EditSampleBackgroundColor":
            let Dest = segue.destination as? BasicColorEditor
            Dest?.CallerDelegate = self
            Dest?.InitialTitle = "Sample Background Color"
            Dest?.InitialColorSpace = ColorEditorColorSpaces.HSB
            Dest?.InitialColor = _Settings.uicolor(forKey: Setting.Key.Text.SampleBackground)!
            Dest?.DelegateTag = "SampleBackground"
            
        case "EditShadowColor":
            let Dest = segue.destination as? BasicColorEditor
            Dest?.CallerDelegate = self
            Dest?.InitialTitle = "Text Shadow Color"
            Dest?.InitialColorSpace = ColorEditorColorSpaces.HSB
            Dest?.InitialColor = _Settings.uicolor(forKey: Setting.Key.Text.ShadowColor)!
            Dest?.DelegateTag = "ShadowColor"
            
        case "EditGlowColor":
            let Dest = segue.destination as? BasicColorEditor
            Dest?.CallerDelegate = self
            Dest?.InitialTitle = "Text Glow Color"
            Dest?.InitialColorSpace = ColorEditorColorSpaces.HSB
            Dest?.InitialColor = _Settings.uicolor(forKey: Setting.Key.Text.GlowColor)!
            Dest?.DelegateTag = "GlowColor"
            
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
        case "ShadowColor":
            _Settings.set(NewColor, forKey: Setting.Key.Text.ShadowColor)
            UpdateColorSample(With: _Settings.uicolor(forKey: Setting.Key.Text.ShadowColor)!, InView: ShadowColorSample)
            UpdateTimeSample()
            
        case "GlowColor":
            _Settings.set(NewColor, forKey: Setting.Key.Text.GlowColor)
            UpdateColorSample(With: _Settings.uicolor(forKey: Setting.Key.Text.GlowColor)!, InView: GlowColorSample)
            UpdateTimeSample()
            
        case "SampleBackground":
            _Settings.set(NewColor, forKey: Setting.Key.Text.SampleBackground)
            SampleLabel.backgroundColor = NewColor
            
        default:
            break
        }
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        delegate?.DoSet(Key: "ChildUpdated", Value: nil)
        super.viewWillDisappear(animated)
    }
    
    @IBOutlet weak var ShadowColorSample: UIView!
    @IBOutlet weak var GlowColorSample: UIView!
    @IBOutlet weak var GlowSegment: UISegmentedControl!
    @IBOutlet weak var SampleLabel: UILabel!
    @IBOutlet weak var TextView: UIView!
}
