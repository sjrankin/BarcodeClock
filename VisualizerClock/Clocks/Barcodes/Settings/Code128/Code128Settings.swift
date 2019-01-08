//
//  Code128Settings.swift
//  Visualizer Clock
//
//  Created by Stuart Rankin on 11/26/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class Code128Settings: UITableViewController, SettingProtocol, ClockSettingsProtocol
{
    let _Settings = UserDefaults.standard
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        Handle = VectorHandle.Make()
        ShadowSegment.selectedSegmentIndex = _Settings.integer(forKey: Setting.Key.Code128.ShadowEffect)
        SFXSegment.selectedSegmentIndex = _Settings.integer(forKey: Setting.Key.Code128.SpecialEffect)
        ShapeSegment.selectedSegmentIndex = _Settings.integer(forKey: Setting.Key.Code128.BarcodeShape)
        let Tap = UITapGestureRecognizer(target: self, action: #selector(HandleSampleTap))
        SampleView.addGestureRecognizer(Tap)
        ShowSample()
        UpdateSample()
        BarcodeContentSample.text = Utility.GetTimeStampToEncode(From: Date())
        ContentTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(UpdateContentSample), userInfo: nil, repeats: true)
        let Outer = Float(_Settings.double(forKey: Setting.Key.Code128.OuterRadius))
        OuterSlider.value = Outer * 1000.0
        var Inner = Float(_Settings.double(forKey: Setting.Key.Code128.InnerRadius))
        if Inner >= Outer
        {
            Inner = Outer - 0.01
        }
        InnerSlider.value = Inner * 1000.0
        let Hgt = Float(_Settings.double(forKey: Setting.Key.Code128.BarcodeHeight))
        HeightSlider.value = Hgt * 1000.0
        UpdateUI()
        Background = BackgroundServer(SampleView)
        BGTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(UpdateBG),
                                       userInfo: nil, repeats: true)
    }
    
    var Handle: VectorHandle!
    var Background: BackgroundServer!
    var BGTimer: Timer!
    
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
    
    func UpdateUI()
    {
        if _Settings.integer(forKey: Setting.Key.Code128.BarcodeShape) == 0 ||
            _Settings.integer(forKey: Setting.Key.Code128.BarcodeShape) == 2
        {
            if _Settings.integer(forKey: Setting.Key.Code128.BarcodeShape) == 0
            {
                HeightLabel.text = "Barcode height"
            }
            else
            {
                HeightLabel.text = "Barcode radius"
            }
            InnerRadiusLabel.isEnabled = false
            InnerBigLabel.isEnabled = false
            InnerSmallLabel.isEnabled = false
            InnerSlider.isEnabled = false
            OuterRadiusLabel.isEnabled = false
            OuterBigLabel.isEnabled = false
            OuterSmallLabel.isEnabled = false
            OuterSlider.isEnabled = false
            HeightLabel.isEnabled = true
            HeightBigLabel.isEnabled = true
            HeightSmallLabel.isEnabled = true
            HeightSlider.isEnabled = true
        }
        else
        {
            InnerRadiusLabel.isEnabled = true
            InnerBigLabel.isEnabled = true
            InnerSmallLabel.isEnabled = true
            InnerSlider.isEnabled = true
            OuterRadiusLabel.isEnabled = true
            OuterBigLabel.isEnabled = true
            OuterSmallLabel.isEnabled = true
            OuterSlider.isEnabled = true
            HeightLabel.isEnabled = false
            HeightBigLabel.isEnabled = false
            HeightSmallLabel.isEnabled = false
            HeightSlider.isEnabled = false
        }
    }
    
    @IBAction func unwindToStep1ViewController(_ segue: UIStoryboardSegue)
    {
        
    }
    
    var ContentTimer: Timer!
    
    var ShowCenterLines: Bool = false
    
    @objc func HandleSampleTap(sender: UITapGestureRecognizer)
    {
        if LineLayer != nil
        {
            LineLayer?.removeFromSuperlayer()
            LineLayer = nil
        }
        ShowCenterLines = !ShowCenterLines
        ShowSample()
    }
    
    @IBAction func HandleShapeChanged(_ sender: Any)
    {
        _Settings.set(ShapeSegment.selectedSegmentIndex, forKey: Setting.Key.Code128.BarcodeShape)
        UpdateSample()
        UpdateUI()
    }
    
    @IBOutlet weak var ShapeSegment: UISegmentedControl!
    
    @IBAction func HandleDonePressed(_ sender: Any)
    {
        if SampleTimer != nil
        {
            SampleTimer!.invalidate()
        }
        dismiss(animated: true, completion: nil)
    }
    
    func ShowSample()
    {
        SampleView.layer.cornerRadius = 5.0
        SampleView.layer.borderColor = UIColor.black.cgColor
        SampleView.layer.borderWidth = 0.5
        
        if ShowCenterLines
        {
            LineLayer = CAShapeLayer()
            LineLayer?.lineWidth = 1
            LineLayer?.strokeColor = UIColor.red.cgColor
            let MidY = SampleView.bounds.height / 2.0
            let MidX = SampleView.bounds.width / 2.0
            let HLine = UIBezierPath(rect: CGRect(x: 0, y: MidY, width: SampleView.bounds.width, height: 1))
            let VLine = UIBezierPath(rect: CGRect(x: MidX, y: 0, width: 1, height: SampleView.bounds.height + 10))
            let FinalLine = HLine
            if _Settings.integer(forKey: Setting.Key.Code128.BarcodeShape) == 0
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
        
        if SampleTimer == nil
        {
            SampleTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(UpdateSample),
                                               userInfo: nil, repeats: true)
        }
    }
    
    var LineLayer: CAShapeLayer? = nil
    
    var SampleTimer: Timer? = nil
    
    @objc func UpdateSample()
    {
        Handle.BarcodeShape = _Settings.integer(forKey: Setting.Key.Code128.BarcodeShape)
        Handle.Foreground = _Settings.uicolor(forKey: Setting.Key.Code128.BarcodeForegroundColor1)!
        Handle.HighlightColor = _Settings.uicolor(forKey: Setting.Key.Code128.BarcodeForegroundColor2)!
        Handle.ShadowLevel = _Settings.integer(forKey: Setting.Key.Code128.ShadowEffect)
        Handle.HighlightStyle = _Settings.integer(forKey: Setting.Key.Code128.SpecialEffect)
        Handle.WaveEffects = _Settings.integer(forKey: Setting.Key.Code128.WavyHeights)
        Handle.UseLongAxis = true
        let Final = Utility.GetTimeStampToEncode(From: Date())
        Handle.FinalCenter = SampleView.bounds.height / 2.0
        if let Sample = Barcode128Clock.CommonMakeBarcode2(From: Final, TargetView: SampleView.frame,
                                                           Handle: Handle, Caller: "Code128Settings",
                                                           SampleOffset: 1.7)
        {
            SampleView.subviews.forEach{$0.removeFromSuperview()}
            //Assign the bounds to the frame because the frame has offsets for the control which mess up
            //where the sample barcode is placed.
            Sample.frame = Sample.bounds
            SampleView.addSubview(Sample)
        }
        else
        {
            print("Nil barcode returned by Barcode128Clock.CommonMakeBarcode")
        }
    }
    
    @IBOutlet weak var StrokeNodesSwitch: UISwitch!
    
    @IBAction func HandleStrokeNodesChanged(_ sender: Any)
    {
        _Settings.set(StrokeNodesSwitch.isOn, forKey: Setting.Key.Code128.BarcodeStroked)
        UpdateSample()
    }
    
    @IBOutlet weak var SampleView: UIView!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        switch segue.identifier
        {
        case "ToBarcodeContentEditor":
            let Dest = segue.destination as? EncodedTimeFormatting
            Dest?.delegate = self
            
        case "ToCode128ColorsEditor":
            let Dest = segue.destination as? Code128ColorSettings
            Dest?.delegate = self
            
        default:
            break
        }
        
        super.prepare(for: segue, sender: self)
    }
    
    @IBOutlet weak var BarcodeContentSample: UILabel!
    
    @objc func UpdateContentSample()
    {
        let Final = Utility.GetTimeStampToEncode(From: Date())
        BarcodeContentSample.text = Final
    }
    
    func DoSet(Key: String, Value: Any?)
    {
        if Key == "SomeColor"
        {
            UpdateSample()
        }
        if Key == "TimeEncodingChanged"
        {
            print("Updated barcode contents.")
        }
    }
    
    @IBOutlet weak var SFXSegment: UISegmentedControl!
    
    @IBAction func HandleSFXChanged(_ sender: Any)
    {
        _Settings.set(SFXSegment.selectedSegmentIndex, forKey: Setting.Key.Code128.SpecialEffect)
        UpdateSample()
    }
    
    @IBOutlet weak var ShadowSegment: UISegmentedControl!
    
    @IBAction func HandleShadowsChanged(_ sender: Any)
    {
        _Settings.set(ShadowSegment.selectedSegmentIndex, forKey: Setting.Key.Code128.ShadowEffect)
        UpdateSample()
    }
    
    /// Returns the values of the two size sliders. The values are returned as is (eg, raw) in Outer, Inner order.
    ///
    /// - Returns: Tuple with the slider values in Outer, Inner order.
    func GetRadialValues() -> (Float, Float)
    {
        let Outer = OuterSlider.value
        let Inner = InnerSlider.value
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
    
    @IBOutlet weak var OuterSlider: UISlider!
    
    @IBAction func HandleOuterRadiusChanged(_ sender: Any)
    {
        if _Settings.integer(forKey: Setting.Key.Code128.BarcodeShape) == 0
        {
            let Outer = OuterSlider.value / 1000.0
            _Settings.set(Outer, forKey: Setting.Key.Code128.OuterRadius)
            UpdateSample()
            return
        }
        let CurrentValues = GetRadialValues()
        let FinalValues = AdjustRadialValues(Outer: CurrentValues.0, Inner: CurrentValues.1, OuterWasMoved: true)
        if let Small = FinalValues.1
        {
            InnerSlider.value = Small
            _Settings.set(Double(Small / 1000.0), forKey: Setting.Key.Code128.InnerRadius)
        }
        _Settings.set(Double(CurrentValues.0 / 1000.0), forKey: Setting.Key.Code128.OuterRadius)
        UpdateSample()
    }
    
    @IBOutlet weak var InnerSlider: UISlider!
    
    @IBAction func HandleInnerRadiusChanged(_ sender: Any)
    {
        let CurrentValues = GetRadialValues()
        let FinalValues = AdjustRadialValues(Outer: CurrentValues.0, Inner: CurrentValues.1, OuterWasMoved: false)
        if let Big = FinalValues.0
        {
            OuterSlider.value = Big
            _Settings.set(Double(Big / 1000.0), forKey: Setting.Key.Code128.OuterRadius)
        }
        _Settings.set(Double(CurrentValues.1 / 1000.0), forKey: Setting.Key.Code128.InnerRadius)
        UpdateSample()
    }
    
    @IBOutlet weak var HeightSlider: UISlider!
    
    @IBAction func HandleHeightSliderChanged(_ sender: Any)
    {
        _Settings.set(Double(HeightSlider.value / 1000.0), forKey: Setting.Key.Code128.BarcodeHeight)
        UpdateSample()
    }
    
    @IBOutlet weak var OuterRadiusLabel: UILabel!
    @IBOutlet weak var OuterSmallLabel: UILabel!
    @IBOutlet weak var OuterBigLabel: UILabel!
    @IBOutlet weak var InnerRadiusLabel: UILabel!
    @IBOutlet weak var InnerSmallLabel: UILabel!
    @IBOutlet weak var InnerBigLabel: UILabel!
    @IBOutlet weak var HeightLabel: UILabel!
    @IBOutlet weak var HeightSmallLabel: UILabel!
    @IBOutlet weak var HeightBigLabel: UILabel!
}
