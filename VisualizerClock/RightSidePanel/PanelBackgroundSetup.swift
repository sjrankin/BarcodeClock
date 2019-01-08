//
//  PanelBackgroundSetup.swift
//  Visualizer Clock
//
//  Created by Stuart Rankin on 9/26/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class PanelBackgroundSetup: UITableViewController, ColorReceiver
{
    let _Settings = UserDefaults.standard
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        HasThinLinesSwitch.isOn = _Settings.bool(forKey: Setting.Key.PanelBackgroundHasThinLines)
        MakeColorSample(SampleView: Pattern1ColorSample, SampleColor: _Settings.uicolor(forKey: Setting.Key.PanelBackgroundPatternColor1)!)
        MakeColorSample(SampleView: Pattern2ColorSample, SampleColor: _Settings.uicolor(forKey: Setting.Key.PanelBackgroundPatternColor2)!)
        MakeColorSample(SampleView: StaticColorSample, SampleColor: _Settings.uicolor(forKey: Setting.Key.PanelBackgroundStaticColor)!)
        MakeColorSample(SampleView: ChangingColor1Sample, SampleColor: _Settings.uicolor(forKey: Setting.Key.PanelBackgroundChangeColor1)!)
        MakeColorSample(SampleView: ChangingColor2Sample, SampleColor: _Settings.uicolor(forKey: Setting.Key.PanelBackgroundChangeColor2)!)
        PatternSegment.selectedSegmentIndex = _Settings.integer(forKey: Setting.Key.PanelBackgroundPattern)
        PanelBGSegment.selectedSegmentIndex = _Settings.integer(forKey: Setting.Key.PanelBackgroundType)
        MakeColorSample(SampleView: PatternSample, SampleColor: UIColor.clear)
        PatternSample.setNeedsDisplay()
        let DescIndex = _Settings.integer(forKey: Setting.Key.PanelBackgroundPattern)
        SetPatternDescription(PatternIndex: DescIndex)
        
        SetUI()
    }
    
    func MakeColorSample(SampleView: UIView, SampleColor: UIColor)
    {
        SampleView.backgroundColor = SampleColor
        SampleView.layer.borderColor = UIColor.black.cgColor
        SampleView.layer.borderWidth = 0.5
        SampleView.layer.cornerRadius = 5.0
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        switch segue.identifier
        {
        case "ToColor":
            let Dest = segue.destination as? BasicColorEditor
            Dest?.InitialTitle = "Panel Static Color"
            Dest?.InitialColorSpace = ColorEditorColorSpaces.HSB
            //Dest?.InitialColorSpaceIsHSB = true
            Dest?.DelegateTag = "StaticColor"
            if let FGColor = _Settings.uicolor(forKey: Setting.Key.PanelBackgroundStaticColor)
            {
                Dest?.InitialColor = FGColor
            }
            else
            {
                Dest?.InitialColor = UIColor.white
            }
            Dest?.CallerDelegate = self
            
        case "ToPattern1ColorEditor":
            let Dest = segue.destination as? BasicColorEditor
            Dest?.InitialTitle = "Pattern Color 1"
            Dest?.InitialColorSpace = ColorEditorColorSpaces.HSB
            //            Dest?.InitialColorSpaceIsHSB = true
            Dest?.DelegateTag = "PatternColor1"
            if let FGColor = _Settings.uicolor(forKey: Setting.Key.PanelBackgroundPatternColor1)
            {
                Dest?.InitialColor = FGColor
            }
            else
            {
                Dest?.InitialColor = UIColor.white
            }
            Dest?.CallerDelegate = self
            
        case "ToPattern2ColorEditor":
            let Dest = segue.destination as? BasicColorEditor
            Dest?.InitialTitle = "Pattern Color 2"
            Dest?.InitialColorSpace = ColorEditorColorSpaces.HSB
            //Dest?.InitialColorSpaceIsHSB = true
            Dest?.DelegateTag = "PatternColor2"
            if let FGColor = _Settings.uicolor(forKey: Setting.Key.PanelBackgroundPatternColor2)
            {
                Dest?.InitialColor = FGColor
            }
            else
            {
                Dest?.InitialColor = UIColor.white
            }
            Dest?.CallerDelegate = self
            
        case "ToChangingColor1":
            let Dest = segue.destination as? BasicColorEditor
            Dest?.InitialTitle = "Changing Color 1"
            Dest?.InitialColorSpace = ColorEditorColorSpaces.HSB
            //            Dest?.InitialColorSpaceIsHSB = true
            Dest?.DelegateTag = "ChangingColor1"
            if let FGColor = _Settings.uicolor(forKey: Setting.Key.PanelBackgroundChangeColor1)
            {
                Dest?.InitialColor = FGColor
            }
            else
            {
                Dest?.InitialColor = UIColor.white
            }
            Dest?.CallerDelegate = self
            
        case "ToChangingColor2":
            let Dest = segue.destination as? BasicColorEditor
            Dest?.InitialTitle = "Changing Color 2"
            Dest?.InitialColorSpace = ColorEditorColorSpaces.HSB
            //            Dest?.InitialColorSpaceIsHSB = true
            Dest?.DelegateTag = "ChangingColor2"
            if let FGColor = _Settings.uicolor(forKey: Setting.Key.PanelBackgroundChangeColor2)
            {
                Dest?.InitialColor = FGColor
            }
            else
            {
                Dest?.InitialColor = UIColor.white
            }
            Dest?.CallerDelegate = self
            
        default:
            break
        }
        
        super.prepare(for: segue, sender: self)
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool
    {
        if identifier == "ToColor"
        {
            return _Settings.integer(forKey: Setting.Key.PanelBackgroundType) == 0
        }
        if identifier == "ToPattern1ColorEditor"
        {
            return _Settings.integer(forKey: Setting.Key.PanelBackgroundType) == 2
        }
        if identifier == "ToPattern2ColorEditor"
        {
            return _Settings.integer(forKey: Setting.Key.PanelBackgroundType) == 2
        }
        if identifier == "ChangingColor1"
        {
            return _Settings.integer(forKey: Setting.Key.PanelBackgroundType) == 1
        }
        if identifier == "ChangingColor2"
        {
            return _Settings.integer(forKey: Setting.Key.PanelBackgroundType) == 1
        }
        return true
    }
    
    func ColorChanged(NewColor: UIColor, DidChange: Bool, Tag: String?)
    {
        if let Tag = Tag
        {
            switch Tag
            {
            case "StaticColor":
                StaticColorSample.backgroundColor = NewColor
                _Settings.set(NewColor, forKey: Setting.Key.PanelBackgroundStaticColor)
                PatternSample.setNeedsDisplay()
                
            case "PatternColor1":
                Pattern1ColorSample.backgroundColor = NewColor
                _Settings.set(NewColor, forKey: Setting.Key.PanelBackgroundPatternColor1)
                PatternSample.setNeedsDisplay()
                
            case "PatternColor2":
                Pattern2ColorSample.backgroundColor = NewColor
                _Settings.set(NewColor, forKey: Setting.Key.PanelBackgroundPatternColor2)
                PatternSample.setNeedsDisplay()
                
            case "ChangingColor1":
                ChangingColor1Sample.backgroundColor = NewColor
                _Settings.set(NewColor, forKey: Setting.Key.PanelBackgroundChangeColor1)
                PatternSample.setNeedsDisplay()
                
            case "ChangingColor2":
                ChangingColor2Sample.backgroundColor = NewColor
                _Settings.set(NewColor, forKey: Setting.Key.PanelBackgroundChangeColor2)
                PatternSample.setNeedsDisplay()
                
            default:
                break
            }
        }
    }
    
    @IBOutlet weak var PanelBGSegment: UISegmentedControl!
    
    @IBAction func HandlePanelBGTypeChanged(_ sender: Any)
    {
        _Settings.set(PanelBGSegment.selectedSegmentIndex, forKey: Setting.Key.PanelBackgroundType)
        SetUI()
        PatternSample.setNeedsDisplay()
    }
    
    var IsStaticColor: Bool = false
    var IsPatterned: Bool = false
    var IsChangingColor: Bool = false
    
    func SetUI()
    {
        let BGType = _Settings.integer(forKey: Setting.Key.PanelBackgroundType)
        IsStaticColor = BGType == 0
        StaticColorTitle.isEnabled = IsStaticColor
        StaticColorSample.layer.borderColor = IsStaticColor ? UIColor.black.cgColor : UIColor.lightGray.cgColor
        UIView.animate(withDuration: 0.3, animations:
            {
                self.StaticColorSample.layer.cornerRadius = self.IsStaticColor ? 5.0 : 15.0
        })
        
        IsPatterned = BGType == 2
        PatternSegment.isEnabled = IsPatterned
        BackgroundPatternDescription.isEnabled = IsPatterned
        PatternTitle.isEnabled = IsPatterned
        Color1Label.isEnabled = IsPatterned
        Color2Label.isEnabled = IsPatterned
        ThinLineLabel.isEnabled = IsPatterned
        HasThinLinesSwitch.isEnabled = IsPatterned
        Pattern1ColorSample.layer.borderColor = IsPatterned ? UIColor.black.cgColor : UIColor.lightGray.cgColor
        UIView.animate(withDuration: 0.3, animations:
            {
                self.Pattern1ColorSample.layer.cornerRadius = self.IsPatterned ? 5.0 : 15.0
        })
        Pattern2ColorSample.layer.borderColor = IsPatterned ? UIColor.black.cgColor : UIColor.lightGray.cgColor
        UIView.animate(withDuration: 0.3, animations:
            {
                self.Pattern2ColorSample.layer.cornerRadius = self.IsPatterned ? 5.0 : 15.0
        })
        
        IsChangingColor = BGType == 1
        ColorVelocitySegment.isEnabled = IsChangingColor
        ChangingColorLabel1.isEnabled = IsChangingColor
        ChangingColorLabel2.isEnabled = IsChangingColor
        ChangingColor1Sample.layer.borderColor = IsChangingColor ? UIColor.black.cgColor : UIColor.lightGray.cgColor
        UIView.animate(withDuration: 0.3, animations:
            {
                self.ChangingColor1Sample.layer.cornerRadius = self.IsChangingColor ? 5.0 : 15.0
        })
        ChangingColor2Sample.layer.borderColor = IsChangingColor ? UIColor.black.cgColor : UIColor.lightGray.cgColor
        UIView.animate(withDuration: 0.3, animations:
            {
                self.ChangingColor2Sample.layer.cornerRadius = self.IsChangingColor ? 5.0 : 15.0
        })
    }
    
    func SetPatternDescription(PatternIndex: Int)
    {
        switch (PatternIndex)
        {
        case 0:
            BackgroundPatternDescription.text = "Checkerboard pattern of alternating color blocks."
            
        case 1:
            BackgroundPatternDescription.text = "Vertical lines of alternating colors."
            
        case 2:
            BackgroundPatternDescription.text = "Horizontal lines of alternating colors."
            
        case 3:
            BackgroundPatternDescription.text = "Diagonal lines with a negative slope."
            
        case 4:
            BackgroundPatternDescription.text = "Diagonal lines with a positive slope."
            
        case 5:
            BackgroundPatternDescription.text = "Diamond-shaped pattern."
            
        default:
            BackgroundPatternDescription.text = "unknown"
        }
    }
    
    @IBAction func HandleChangesToPattern(_ sender: Any)
    {
        let PatternIndex = PatternSegment.selectedSegmentIndex
        _Settings.set(PatternIndex, forKey: Setting.Key.PanelBackgroundPattern)
        SetPatternDescription(PatternIndex: PatternIndex)
        PatternSample.setNeedsDisplay()
    }
    
    @IBAction func HandleChangesToColorVelocity(_ sender: Any)
    {
    }
    
    @IBAction func HandleThinLinesChanged(_ sender: Any)
    {
        _Settings.set(HasThinLinesSwitch.isOn, forKey: Setting.Key.PanelBackgroundHasThinLines)
        PatternSample.setNeedsDisplay()
    }
    
    @IBOutlet weak var ThinLineLabel: UILabel!
    @IBOutlet weak var HasThinLinesSwitch: UISwitch!
    @IBOutlet weak var PatternSample: ActiveBackgroundView!
    @IBOutlet weak var PatternSegment: UISegmentedControl!
    @IBOutlet weak var StaticColorSample: UIView!
    @IBOutlet weak var StaticColorTitle: UILabel!
    @IBOutlet weak var BackgroundPatternDescription: UILabel!
    @IBOutlet weak var PatternTitle: UILabel!
    @IBOutlet weak var Pattern1ColorSample: UIView!
    @IBOutlet weak var Pattern2ColorSample: UIView!
    @IBOutlet weak var Color1Label: UILabel!
    @IBOutlet weak var Color2Label: UILabel!
    @IBOutlet weak var ChangingColorLabel1: UILabel!
    @IBOutlet weak var ChangingColorLabel2: UILabel!
    @IBOutlet weak var ColorVelocitySegment: UISegmentedControl!
    @IBOutlet weak var ChangingColor1Sample: UIView!
    @IBOutlet weak var ChangingColor2Sample: UIView!
}
