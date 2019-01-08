//
//  ColorEditor.swift
//  Barcode Clock
//
//  Created by Stuart Rankin on 8/27/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class ColorEditor: UITableViewController
{
    private var _EditorTitle: String = "Color Editor"
    public var EditorTitle: String
    {
        get
        {
            return _EditorTitle
        }
        set
        {
            _EditorTitle = newValue
        }
    }
    
    private var _ColorIndex: Int = 0
    public var ColorIndex: Int
    {
        get
        {
            return _ColorIndex
        }
        set
        {
            _ColorIndex = newValue
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        ColorSample.layer.borderWidth = 1.0
        ColorSample.layer.borderColor = UIColor.black.cgColor
        ColorSample.layer.cornerRadius = 5.0
        title = EditorTitle
        print("Getting color for index: \(ColorIndex)")
        Colors = Setting.GetBackgroundColor(For: ColorIndex)
        Colors?.ClearDirtyFlag()
        PopulateUI()
    }
    
    var OldIsDynamic: Bool? = nil
    
    var Colors: BackgroundColors? = nil
    
    public var delegate: BackgroundSetting2? = nil
    
    public var crdelegate: ColorReceiver? = nil
    
    override func viewWillDisappear(_ animated: Bool)
    {
        Setting.SetBackgroundColor(With: Colors!)
        delegate?.ColorChanged(ColorIndex, Changed: (Colors?.IsDirty)!)
        if crdelegate != nil
        {
            crdelegate?.ColorChanged(NewColor: ColorSample.backgroundColor!, DidChange: true, Tag: nil)
        }
        super.viewWillDisappear(animated)
    }
    
    func PopulateUI()
    {
        let Hue: Double = Double((Colors?.Hue)!)
        HueInput.text = String(Utility.Round(Hue, ToPlaces: 3))
        HueSlider.value = Float(Hue * 1000.0)
        let Saturation: Double = Double((Colors?.Saturation)!)
        SaturationInput.text = String(Utility.Round(Saturation, ToPlaces: 3))
        SaturationSlider.value = Float(Saturation * 1000.0)
        let Brightness: Double = Double((Colors?.Brightness)!)
        BrightnessInput.text = String(Utility.Round(Brightness, ToPlaces: 3))
        BrightnessSlider.value = Float(Brightness * 1000.0)
        ColorSample.backgroundColor = Colors?.Color()
        DirectionSegment.selectedSegmentIndex = (Colors?.Direction)!
        TimePeriodSegment.selectedSegmentIndex = (Colors?.TimePeriod)!
        ColorChangesSwitch.isOn = (Colors?.IsDynamic)!
        OldIsDynamic = ColorChangesSwitch.isOn
        UpdateForDynamicColor(IsDynamic: ColorChangesSwitch.isOn)
        GrayscaleSwitch.isOn = (Colors?.IsGrayscale)!
        SetGrayscaleControls(AreOn: GrayscaleSwitch.isOn)
        UpdateSample()
    }
    
    func SetMinimalEditor()
    {
        
    }
    
    func UpdateForDynamicColor(IsDynamic: Bool)
    {
        ColorDirectionLabel.isEnabled = IsDynamic
        TimePeriodLabel.isEnabled = IsDynamic
        TimePeriodSegment.isEnabled = IsDynamic
        DirectionSegment.isEnabled = IsDynamic
    }
    
    @IBOutlet weak var ColorSample: UIView!
    
    @IBOutlet weak var TimePeriodSegment: UISegmentedControl!
    
    @IBAction func HandleTimePeriodChanged(_ sender: Any)
    {
        Colors?.TimePeriod = TimePeriodSegment.selectedSegmentIndex
        UpdateSample()
    }
    
    @IBOutlet weak var DirectionSegment: UISegmentedControl!
    
    @IBAction func HandleDirectionChanged(_ sender: Any)
    {
        Colors?.Direction = DirectionSegment.selectedSegmentIndex
        UpdateSample()
    }
    
    @IBOutlet weak var ColorChangesSwitch: UISwitch!
    
    @IBAction func HandleColorChangesChanged(_ sender: Any)
    {
        Colors?.IsDynamic = ColorChangesSwitch.isOn
        UpdateForDynamicColor(IsDynamic: ColorChangesSwitch.isOn)
        UpdateSample()
    }
    
    func ValidateText(Field: UITextField) -> CGFloat
    {
        var NewRaw: String = ""
        if let Raw = Field.text
        {
            NewRaw = Raw
        }
        else
        {
            Field.text = "0.0"
            return 0.0
        }
        if NewRaw.isEmpty
        {
            Field.text = "0.0"
            NewRaw = "0.0"
        }
        var NewVal: Float = 0.0
        if let ValF = Float(NewRaw)
        {
            NewVal = ValF
        }
        else
        {
            Field.text = "0.0"
        }
        if NewVal < 0.0
        {
            NewVal = abs(NewVal)
            Field.text = "\(NewVal)"
        }
        if NewVal > 1.0
        {
            NewVal = 1.0
            Field.text = "1.0"
        }
        return CGFloat(NewVal)
    }
    
    @IBOutlet weak var HueInput: UITextField!
    
    @IBAction func HandleHueChange(_ sender: Any)
    {
        view.endEditing(true)
        let NewHue = ValidateText(Field: HueInput)
        Colors?.Hue = NewHue
        HueSlider.value = Float(NewHue * 1000.0)
        UpdateSample()
    }
    
    @IBOutlet weak var SaturationInput: UITextField!
    
    @IBAction func HandleSaturationChange(_ sender: Any)
    {
        view.endEditing(true)
        let NewSaturation = ValidateText(Field: SaturationInput)
        Colors?.Saturation = NewSaturation
        SaturationSlider.value = Float(NewSaturation * 1000.0)
        UpdateSample()
    }
    
    @IBOutlet weak var BrightnessInput: UITextField!
    
    @IBAction func HandleBrightnessChange(_ sender: Any)
    {
        view.endEditing(true)
        let NewBrightness = ValidateText(Field: BrightnessInput)
        Colors?.Brightness = NewBrightness
        BrightnessSlider.value = Float(NewBrightness * 1000.0)
        UpdateSample()
    }
    
    @IBOutlet weak var HueSlider: UISlider!
    
    @IBAction func HandleHueSliderChanged(_ sender: Any)
    {
        let Value = HueSlider.value / 1000.0
        Colors?.Hue = CGFloat(Value)
        HueInput.text = String(Utility.Round(Double(Value), ToPlaces: 3))
        UpdateSample()
    }
    
    @IBOutlet weak var SaturationSlider: UISlider!
    
    @IBAction func HandleSaturationSliderChanged(_ sender: Any)
    {
        let Value = SaturationSlider.value / 1000.0
        Colors?.Saturation = CGFloat(Value)
        SaturationInput.text = String(Utility.Round(Double(Value), ToPlaces: 3))
        UpdateSample()
    }
    
    @IBOutlet weak var BrightnessSlider: UISlider!
    
    @IBAction func HandleBrightnessSliderChanged(_ sender: Any)
    {
        let Value = BrightnessSlider.value / 1000.0
        Colors?.Brightness = CGFloat(Value)
        BrightnessInput.text = String(Utility.Round(Double(Value), ToPlaces: 3))
        UpdateSample()
    }
    
    @IBOutlet weak var ColorDirectionLabel: UILabel!
    @IBOutlet weak var TimePeriodLabel: UILabel!
    
    func UpdateSample()
    {
        var SampleColor: UIColor!
        if (Colors?.IsGrayscale)!
        {
            SampleColor = UIColor(white: (Colors?.Brightness)!, alpha: 1.0)
        }
        else
        {
            SampleColor = UIColor(hue: (Colors?.Hue)!, saturation: (Colors?.Saturation)!, brightness: (Colors?.Brightness)!, alpha: 1.0)
        }
        ColorSample.backgroundColor = SampleColor
    }
    
    func SetGrayscaleControls(AreOn: Bool)
    {
        HueTitle.isEnabled = !AreOn
        HueSlider.isEnabled = !AreOn
        HueInput.isEnabled = !AreOn
        SaturationTitle.isEnabled = !AreOn
        SaturationSlider.isEnabled = !AreOn
        SaturationInput.isEnabled = !AreOn
    }
    
    @IBOutlet weak var GrayscaleSwitch: UISwitch!
    
    @IBAction func HandleGrayscaleChanged(_ sender: Any)
    {
        Colors?.IsGrayscale = GrayscaleSwitch.isOn
        SetGrayscaleControls(AreOn: GrayscaleSwitch.isOn)
        UpdateSample()
    }
    
    @IBOutlet weak var HueTitle: UILabel!
    @IBOutlet weak var SaturationTitle: UILabel!
}
