//
//  PharmaCodeSettings.swift
//  Visualizer Clock
//
//  Created by Stuart Rankin on 12/22/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Handles settings for all home-grown (eg, drawn by code in the Visualizer Clock and not in any external (including
/// Apple) libraries. It's assumed that the structure of the settings is essentially the same (with perhaps some small
/// deltas between such barcodes).
class OneDBarcodeSettings: UITableViewController, SettingProtocol
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        Parent = parent as? OneDBarcodeNav
        if Parent == nil
        {
            fatalError("Unable to retrieve parent from OneDBarcodeNav.")
        }
        ParentClock = Parent.ParentClock
        if let ParentClock = ParentClock
        {
            ISetting = SettingHandle(FromClock: ParentClock)
            switch ParentClock
            {
            case .SwitchToPharmaCode:
                title = "Pharmacode Settings"
                BarcodeType = .Pharmacode
                OptionLabel.text = "Show digits"
                OptionSwitch.isOn = ISetting!.Get(Key: SettingKey.IncludeDigits)
                
            case .SwitchToPOSTNET:
                title = "POSTNET Settings"
                BarcodeType = .POSTNET
                OptionLabel.text = "Include check digit"
                OptionSwitch.isOn = ISetting!.Get(Key: SettingKey.IncludeCheckDigits)
                
            default:
                fatalError("Unknown parent clock type specified.")
                OptionLabel.alpha = 0.0
                OptionSwitch.isUserInteractionEnabled = false
                OptionSwitch.alpha = 0.0
            }
        }
        else
        {
            fatalError("No parent clock type specified.")
        }
        
        Handle = VectorHandle.Make()
        InitializeSample()
        
        SampleView.layer.borderColor = UIColor.black.cgColor
        SampleView.layer.borderWidth = 0.5
        SampleView.layer.cornerRadius = 5.0
        
        BarcodeShapeSegment.selectedSegmentIndex = ISetting!.Get(Key: SettingKey.BarcodeShape)
        SFXSegment.selectedSegmentIndex = ISetting!.Get(Key: SettingKey.SpecialEffects)
        ShadowSegment.selectedSegmentIndex = ISetting!.Get(Key: SettingKey.Shadows)
        
        Background = BackgroundServer(SampleView)
        BGTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(UpdateBG), userInfo: nil, repeats: true)
        UpdateSample()
        UpdateUI()
        InitializeContent()
        
        let Tap = UITapGestureRecognizer(target: self, action: #selector(HandleSampleTap))
        SampleView.addGestureRecognizer(Tap)
    }
    
    var ShowCenterLines: Bool = false
    
    @objc func HandleSampleTap(sender: UITapGestureRecognizer)
    {
        SampleView.layer.sublayers!.forEach{if $0.name == "DebugLines" {$0.removeFromSuperlayer()}}
        ShowCenterLines = !ShowCenterLines
        UpdateSample()
    }
    
    var ColorTitle: String = ""
    var ISetting: SettingHandle? = nil
    var Parent: OneDBarcodeNav!
    var BGTimer: Timer!
    var Background: BackgroundServer!
    var ParentClock: PanelActions? = nil
    var BarcodeType: Barcode1DClock.DrawnBarcodes = .Pharmacode
    
    func InitializeContent()
    {
        ContentTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(UpdateContent), userInfo: nil, repeats: true)
        UpdateContent()
    }
    
    var ContentTimer: Timer!
    
    func GetContent() -> Int
    {
        let Now = Date()
        var SampleTime: Int
        switch ParentClock!
        {
        case PanelActions.SwitchToPharmaCode:
            SampleTime = Utility.GetTimeStampToEncodeI(From: Now, false)
            
        case PanelActions.SwitchToPOSTNET:
            SampleTime = Utility.GetTimeStampToEncodeI(From: Now, true)
            
        default:
            SampleTime = 0
        }
        return SampleTime
    }
    
    @objc func UpdateContent()
    {
        BarcodeContentSample.text = String(GetContent())
    }
    
    @objc func UpdateBG()
    {
        Background.UpdateBackgroundColors()
    }
    
    func UpdateUI()
    {
        let Index = BarcodeShapeSegment.selectedSegmentIndex
        if Index == 0
        {
            Slider1.value = Float(ISetting!.Get(Key: SettingKey.BarcodeHeight) as Double) * 1000.0
            Slider1Title.text = "Barcode height"
            Slider1Small.text = "Short"
            Slider1Big.text = "Tall"
            Slider2.isUserInteractionEnabled = false
            UIView.animate(withDuration: 0.4, animations: {
                self.Slider2Title.alpha = 0.0
                self.Slider2Small.alpha = 0.0
                self.Slider2Big.alpha = 0.0
                self.Slider2.alpha = 0.0
            }
            )
        }
        else
        {
            Slider1.value = Float(ISetting!.Get(Key: SettingKey.BarcodeOuterRadius) as Double) * 1000.0
            Slider2.value = Float(ISetting!.Get(Key: SettingKey.BarcodeInnerRadius) as Double) * 1000.0
            Slider1Title.text = "Outer radius"
            Slider1Small.text = "Small"
            Slider1Big.text = "Big"
            Slider2.isUserInteractionEnabled = true
            UIView.animate(withDuration: 0.4, animations: {
                self.Slider2Title.alpha = 1.0
                self.Slider2Small.alpha = 1.0
                self.Slider2Big.alpha = 1.0
                self.Slider2.alpha = 1.0
            }
            )
        }
    }
    
    func InitializeSample()
    {
        if SampleTimer == nil
        {
            SampleTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(UpdateSample), userInfo: nil, repeats: true)
        }
    }
    
    var SampleTimer: Timer? = nil
    
    var Handle: VectorHandle? = nil
    
    @objc func UpdateSample()
    {
        let TimeContent = GetContent()
        var BarcodeHeight: CGFloat!
        var BarcodeWidth: CGFloat!
        let HeightMultiplier = ISetting!.Get(Key: SettingKey.BarcodeHeight) as Double
        Handle?.TargetCenter = CGPoint(x: SampleView.frame.width / 2.0, y: SampleView.frame.height / 2.0)

        switch ParentClock!
        {
        case .SwitchToPOSTNET:
            BarcodeHeight = SampleView.frame.height * 0.35 * CGFloat(HeightMultiplier)
            BarcodeWidth = SampleView.frame.width * 0.85
            if ISetting!.Get(Key: SettingKey.BarcodeShape) == 0
            {
                Handle?.ViewHeight = Int(BarcodeHeight)
                Handle?.ViewWidth = Int(BarcodeWidth)
            }
            else
            {
                var Same = min(SampleView.frame.height, SampleView.frame.width)
                Same = Same * 0.95
                let Radius: CGFloat = Same / 2.0
                Handle?.ViewHeight = Int(Same)
                Handle?.ViewWidth = Int(Same)
                Handle?.InnerRadius = Double(CGFloat(ISetting!.Get(Key: SettingKey.BarcodeInnerRadius) as Double) * Radius)
                Handle?.OuterRadius = Double(CGFloat(ISetting!.Get(Key: SettingKey.BarcodeOuterRadius) as Double) * Radius)
            }
            Handle?.IncludeCheckDigit = ISetting!.Get(Key: SettingKey.IncludeCheckDigits)
            Handle?.Foreground = ISetting!.Get(Key: SettingKey.BarcodeForegroundColor)
            Handle?.HighlightColor = ISetting!.Get(Key: SettingKey.BarcodeAttentionColor)
            Handle?.WaveEffects = ISetting!.Get(Key: SettingKey.WavyHeights)
            Handle?.ShadowLevel = ISetting!.Get(Key: SettingKey.Shadows)
            Handle?.BarcodeShape = ISetting!.Get(Key: SettingKey.BarcodeShape)
            Handle?.HighlightStyle = ISetting!.Get(Key: SettingKey.SpecialEffects)
            Handle?.VaryColorByLength = ISetting!.Get(Key: SettingKey.ColorsVaryOnLength)
            Handle?.ShortColor = ISetting!.Get(Key: SettingKey.ShortBarColor)
            Handle?.LongColor = ISetting!.Get(Key: SettingKey.LongBarColor)
            Handle?.HeightMultiplier = ISetting!.Get(Key: SettingKey.BarcodeHeight)
            
        case .SwitchToPharmaCode:
            BarcodeHeight = SampleView.frame.height * 0.75 * CGFloat(HeightMultiplier)
            BarcodeWidth = SampleView.frame.width * 0.85
            if ISetting!.Get(Key: SettingKey.BarcodeShape) == 0
            {
                Handle?.ViewHeight = Int(BarcodeHeight)
                Handle?.ViewWidth = Int(BarcodeWidth)
            }
            else
            {
                var Same = min(SampleView.frame.height, SampleView.frame.width)
                Same = Same * 0.95
                let Radius: CGFloat = Same / 2.0
                Handle?.ViewHeight = Int(Same)
                Handle?.ViewWidth = Int(Same)
                Handle?.InnerRadius = Double(CGFloat(ISetting!.Get(Key: SettingKey.BarcodeInnerRadius) as Double) * Radius)
                Handle?.OuterRadius = Double(CGFloat(ISetting!.Get(Key: SettingKey.BarcodeOuterRadius) as Double) * Radius)
            }
            Handle?.ShowDigits = ISetting!.Get(Key: SettingKey.IncludeDigits)
            Handle?.Foreground = ISetting!.Get(Key: SettingKey.BarcodeForegroundColor)
            Handle?.HighlightColor = ISetting!.Get(Key: SettingKey.BarcodeAttentionColor)
            Handle?.WaveEffects = ISetting!.Get(Key: SettingKey.WavyHeights)
            Handle?.ShadowLevel = ISetting!.Get(Key: SettingKey.Shadows)
            Handle?.BarcodeShape = ISetting!.Get(Key: SettingKey.BarcodeShape)
            Handle?.HighlightStyle = ISetting!.Get(Key: SettingKey.SpecialEffects)
            Handle?.VaryColorByLength = ISetting!.Get(Key: SettingKey.ColorsVaryOnLength)
            Handle?.ShortColor = ISetting!.Get(Key: SettingKey.ShortBarColor)
            Handle?.LongColor = ISetting!.Get(Key: SettingKey.LongBarColor)
            Handle?.HeightMultiplier = ISetting!.Get(Key: SettingKey.BarcodeHeight)
            
        default:
            fatalError("Unknown clock encountered in OneDBarcodeSettings.UpdateSample")
        }
        
        Handle?.EnablePrint = false
        Handle?.PrintPrefix = "Setting"
        Handle?.ShowBorder = false
        Handle?.BorderColor = UIColor.white
        let Size = CGSize(width: BarcodeWidth, height: BarcodeHeight)
        if let Sample = Barcode1DClock.MakeBarcode(Handle: Handle!, BarcodeType: BarcodeType, From: TimeContent, ImageSize: Size,
                                                   ParentSize: SampleView.bounds.size)
        {
            SampleView.subviews.forEach{$0.removeFromSuperview()}
            SampleView.addSubview(Sample)
        }
        else
        {
            print("Nil returned from GetBarcodeImage")
        }
        
        if ShowCenterLines
        {
            LineLayer = CAShapeLayer()
            LineLayer?.name = "DebugLines"
            LineLayer?.lineWidth = 1
            LineLayer?.strokeColor = UIColor.red.cgColor
            let MidY = SampleView.bounds.height / 2.0
            let MidX = SampleView.bounds.width / 2.0
            let HLine = UIBezierPath(rect: CGRect(x: 0, y: MidY, width: SampleView.bounds.width, height: 1))
            let VLine = UIBezierPath(rect: CGRect(x: MidX, y: 0, width: 1, height: SampleView.bounds.height + 10))
            let FinalLine = HLine
            if ISetting!.Get(Key: SettingKey.BarcodeShape) == 0
            {
                let Gap = SampleView.bounds.width / 10.0
                for Index in 0 ... 10
                {
                    let X = Gap * CGFloat(Index)
                    let TickMark = UIBezierPath(rect: CGRect(x: X, y: MidY - 10.0, width: 1, height: 20))
                    FinalLine.append(TickMark)
                }
            }
            else
            {
                let Gap = SampleView.bounds.height / 10.0
                for Index in 0 ... 10
                {
                    let Y = Gap * CGFloat(Index)
                    let TickMark = UIBezierPath(rect: CGRect(x: MidX - 10.0, y: Y, width: 20.0, height: 1))
                    FinalLine.append(TickMark)
                }
            }
            
            FinalLine.append(VLine)
            LineLayer?.path = FinalLine.cgPath
            LineLayer?.zPosition = 1000
            
            SampleView.layer.addSublayer(LineLayer!)
        }
    }
    
    var LineLayer: CAShapeLayer? = nil
    
    func DoSet(Key: String, Value: Any?)
    {
    }
    
    @IBOutlet weak var SampleView: UIView!
    
    @IBAction func HandleDonePressed(_ sender: Any)
    {
        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var BarcodeShapeSegment: UISegmentedControl!
    
    @IBAction func HandleBarcodeShapeChanged(_ sender: Any)
    {
        ISetting?.Set(BarcodeShapeSegment.selectedSegmentIndex, Key: SettingKey.BarcodeShape)
        UpdateUI()
        UpdateSample()
    }
    
    /// Returns the values of the two size sliders. The values are returned as is (eg, raw) in Outer, Inner order.
    ///
    /// - Returns: Tuple with the slider values in Outer, Inner order.
    func GetRadialValues() -> (Float, Float)
    {
        let Outer = Slider1.value
        let Inner = Slider2.value
        return (Outer, Inner)
    }
    
    /// Adjust radial sizes to ensure the inner radius is never larger than the outer radius.
    ///
    /// - Parameters:
    ///   - Outer: The raw (eg, non-percent) outer radius value.
    ///   - Inner: The raw (eg, non-percent) inner radius value.
    ///   - OuterWasMoved: If true, the user moved the outer radius slider. If false, the user moved
    ///                    the inner radius slider. This is used to determine which value has precedence.
    /// - Returns: Tuple with potentially changed values for both sliders in Outer, Inner order. Nil
    ///            values indicate no change.
    func AdjustRadialValues(Outer: Float, Inner: Float, OuterWasMoved: Bool) -> (Float?, Float?)
    {
        if OuterWasMoved
        {
            if Outer < Inner
            {
                if Outer - 10 <= 0.0
                {
                    return (nil, nil)
                }
                return (nil, Outer - 10.0)
            }
        }
        else
        {
            if Inner > Outer
            {
                if Inner + 10 >= 1000.0
                {
                    return (nil, nil)
                }
                return (Inner + 10, nil)
            }
        }
        return (nil, nil)
    }
    
    /// Handle slider 1 changes. If the shape is linear, slider 1 controls the height of the barcode. Otherwise,
    /// slider 1 controls the outer radius of the barcode.
    ///
    /// - Parameter sender: Not used.
    @IBAction func HandleSlider1Changed(_ sender: Any)
    {
        if ISetting?.Get(Key: SettingKey.BarcodeShape) == 0
        {
            //Handle linear barcode heights only.
            ISetting?.Set(Double(Slider1.value / 1000.0), Key: SettingKey.BarcodeHeight)
            UpdateSample()
            return
        }
        let CurrentValues = GetRadialValues()
        let FinalValues = AdjustRadialValues(Outer: CurrentValues.0, Inner: CurrentValues.1, OuterWasMoved: true)
        if let Small = FinalValues.1
        {
            Slider2.value = Small
            ISetting?.Set(Double(Small / 1000.0), Key: SettingKey.BarcodeInnerRadius)
        }
        ISetting?.Set(Double(CurrentValues.0 / 1000.0), Key: SettingKey.BarcodeOuterRadius)
        UpdateSample()
    }
    
    /// Handle slider 2 changes. If the shape is linear, calls to this function are ignored. Otherwise, slider 2
    /// controls the inner radius of the barcode. Raw values that result in an effective radius of 0 are modified
    /// to 5 (which translates to a percentages of 0.05.
    ///
    /// - Parameter sender: Not used.
    @IBAction func HandleSlider2Changed(_ sender: Any)
    {
        if ISetting?.Get(Key: SettingKey.BarcodeShape) == 0
        {
            //Linear barcodes have no inner radius (which is what slider 2 controls).
            return
        }
        //If we're here, we're handing inner radius changes.
        let CurrentValues = GetRadialValues()
        let FinalValues = AdjustRadialValues(Outer: CurrentValues.0, Inner: CurrentValues.1, OuterWasMoved: false)
        if let Big = FinalValues.0
        {
            Slider1.value = Big
            ISetting?.Set(Double(Big / 1000.0), Key: SettingKey.BarcodeOuterRadius)
        }
        var Final: Float = 0.05
        if CurrentValues.1 > 5
        {
            Final = CurrentValues.1 / 1000.0
        }
        ISetting?.Set(Double(Final), Key: SettingKey.BarcodeInnerRadius)
        UpdateSample()
    }
    
    @IBOutlet weak var Slider1Title: UILabel!
    @IBOutlet weak var Slider1Small: UILabel!
    @IBOutlet weak var Slider1Big: UILabel!
    @IBOutlet weak var Slider2Title: UILabel!
    @IBOutlet weak var Slider2Small: UILabel!
    @IBOutlet weak var Slider2Big: UILabel!
    @IBOutlet weak var Slider1: UISlider!
    @IBOutlet weak var Slider2: UISlider!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        switch segue.identifier
        {
        case "To1DColorsEditor":
            let Dest = segue.destination as? OneDColorSettings
            Dest?.DoSet(Key: "ParentClock", Value: ParentClock)
            
        case "ToBarcodeContents":
            UpdateSample()
            UpdateContent()
            
        default:
            break
        }
        
        super.prepare(for: segue, sender: self)
    }
    
    @IBOutlet weak var OptionLabel: UILabel!
    
    @IBOutlet weak var OptionSwitch: UISwitch!
    
    @IBAction func HandleOptionSwitchChanged(_ sender: Any)
    {
        switch ParentClock!
        {
        case PanelActions.SwitchToPharmaCode:
            ISetting?.Set(OptionSwitch.isOn, Key: SettingKey.IncludeDigits)
            
        case PanelActions.SwitchToPOSTNET:
            ISetting?.Set(OptionSwitch.isOn, Key: SettingKey.IncludeCheckDigits)
            
        default:
            break
        }
    }
    
    @IBOutlet weak var SFXSegment: UISegmentedControl!
    
    @IBAction func HandleSFXChanged(_ sender: Any)
    {
        ISetting?.Set(SFXSegment.selectedSegmentIndex, Key: SettingKey.SpecialEffects)
    }
    
    @IBOutlet weak var ShadowSegment: UISegmentedControl!
    
    @IBAction func HandleShadowChanged(_ sender: Any)
    {
        ISetting?.Set(ShadowSegment.selectedSegmentIndex, Key: SettingKey.Shadows)
        UpdateSample()
    }
    
    @IBOutlet weak var BarcodeContentSample: UILabel!
    
    @IBOutlet weak var WavySegment: UISegmentedControl!
    
    @IBAction func HandleWavyChanged(_ sender: Any)
    {
        ISetting?.Set(WavySegment.selectedSegmentIndex, Key: SettingKey.WavyHeights)
        UpdateSample()
    }
}


