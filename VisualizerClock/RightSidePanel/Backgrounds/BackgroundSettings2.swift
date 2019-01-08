//
//  BackgroundSettings2.swift
//  Barcode Clock
//
//  Created by Stuart Rankin on 8/27/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class BackgroundSetting2: UITableViewController
{
    let _Settings = UserDefaults.standard
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        InitializeSampleViews()
        SetupGradientLayer()
        InitializeGradient()
        BackgroundTypeSegment.selectedSegmentIndex = _Settings.integer(forKey: Setting.Key.BackgroundColors.BackgroundColorCount)
        FirstColorCount = BackgroundTypeSegment.selectedSegmentIndex
        SetUI()
        #if false
        AnimateSwitch.isOn = _Settings.bool(forKey: Setting.Key.AnimateBGSample)
        SetAnimationState(IsOn: AnimateSwitch.isOn)
        #else
        StartSampleUpdate()
        #endif
    }
    
    func InitializeSampleViews()
    {
        InitializeColorSample(Sample: ColorSample)
        InitializeColorSample(Sample: Color1Sample)
        InitializeColorSample(Sample: Color2Sample)
        InitializeColorSample(Sample: Color3Sample)
    }
    
    func InitializeColorSample(Sample: UIView)
    {
        Sample.layer.borderColor = UIColor.black.cgColor
        Sample.layer.borderWidth = 1
        Sample.layer.cornerRadius = 5.0
        Sample.backgroundColor = UIColor.clear
    }
    
    var Gradient: CAGradientLayer!
    
    func SetupGradientLayer()
    {
        Gradient = CAGradientLayer()
        Gradient.frame = ColorSample.bounds
        Gradient.bounds = ColorSample.bounds
        ColorSample.layer.insertSublayer(Gradient, at: 0)
        ColorSample.layer.masksToBounds = true
    }
    
    func SetColorSamples()
    {
        Color1Sample.backgroundColor = ColorSample1?.Color()
        Color2Sample.backgroundColor = ColorSample2?.Color()
        Color3Sample.backgroundColor = ColorSample3?.Color()
    }
    
    func InitializeGradient()
    {
        ColorSample1 = Setting.GetBackgroundColor(For: 1)
        ColorSample2 = Setting.GetBackgroundColor(For: 2)
        ColorSample3 = Setting.GetBackgroundColor(For: 3)
        SetColorSamples()
        let ColorCount = _Settings.integer(forKey: Setting.Key.BackgroundColors.BackgroundColorCount)
        switch ColorCount
        {
        case 0:
            Gradient.colors = [ColorSample1?.Color().cgColor as Any, ColorSample1?.Color().cgColor as Any]
            Gradient.locations = nil
            //print("\((ColorSample1?.IsGrayscale)!)")
            //print("\((ColorSample1?.ToString())!)")
            
        case 1:
            Gradient.colors = [ColorSample1?.Color().cgColor as Any, ColorSample2?.Color().cgColor as Any]
            Gradient.locations = nil
            //print("\((ColorSample1?.ToString())!)")
            //print("\((ColorSample2?.ToString())!)")
            
        case 2:
            Gradient.colors = [ColorSample1?.Color().cgColor as Any, ColorSample2?.Color().cgColor as Any, ColorSample3?.Color().cgColor as Any]
            let Locations: [NSNumber] = [0.0, NSNumber(value: _Settings.double(forKey: Setting.Key.BackgroundColors.BGColor2Location)), 1.0]
            Gradient.locations = Locations
            //print("\((ColorSample1?.ToString())!)")
            //print("\((ColorSample2?.ToString())!)")
            //print("\((ColorSample3?.ToString())!)")
            
        default:
            print("Unexpected number (\(ColorCount)) of gradients found.")
            return
        }
    }
    
    func SetUI()
    {
        switch BackgroundTypeSegment.selectedSegmentIndex
        {
        case 0:
            SecondColorLabel.isEnabled = false
            ThirdColorLabel.isEnabled = false
            Color2Sample.layer.borderColor = UIColor.lightGray.cgColor
            Color3Sample.layer.borderColor = UIColor.lightGray.cgColor
            UIView.animate(withDuration: 0.3, animations:
                {
                    self.Color2Sample.layer.cornerRadius = 15.0
                    self.Color3Sample.layer.cornerRadius = 15.0
            })
            
        case 1:
            SecondColorLabel.isEnabled = true
            ThirdColorLabel.isEnabled = false
            Color2Sample.layer.borderColor = UIColor.black.cgColor
            Color3Sample.layer.borderColor = UIColor.lightGray.cgColor
            UIView.animate(withDuration: 0.3, animations:
                {
                    self.Color2Sample.layer.cornerRadius = 5.0
                    self.Color3Sample.layer.cornerRadius = 15.0
            })
            
        case 2:
            SecondColorLabel.isEnabled = true
            ThirdColorLabel.isEnabled = true
            Color2Sample.layer.borderColor = UIColor.black.cgColor
            Color3Sample.layer.borderColor = UIColor.black.cgColor
            UIView.animate(withDuration: 0.3, animations:
                {
                    self.Color2Sample.layer.cornerRadius = 5.0
                    self.Color3Sample.layer.cornerRadius = 5.0
            })
            
        default:
            break
        }
        ShowMiddleColorLocationControls(Show: _Settings.integer(forKey: Setting.Key.BackgroundColors.BackgroundColorCount) == 2)
        SetLocationText(To: _Settings.double(forKey: Setting.Key.BackgroundColors.BGColor2Location))
        BGColor2LocationSlider.value = Float(_Settings.double(forKey: Setting.Key.BackgroundColors.BGColor2Location) * 1000.0)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        switch segue.identifier
        {
        case "Color1":
            let Dest = segue.destination as? ColorEditor
            Dest?.ColorIndex = 1
            Dest?.EditorTitle = "Edit Color 1"
            Dest?.delegate = self
            
        case "Color2":
            let Dest = segue.destination as? ColorEditor
            Dest?.ColorIndex = 2
            Dest?.EditorTitle = "Edit Color 2"
            Dest?.delegate = self
            
        case "Color3":
            let Dest = segue.destination as? ColorEditor
            Dest?.ColorIndex = 3
            Dest?.EditorTitle = "Edit Color 3"
            Dest?.delegate = self
            
        default:
            break
        }
        super.prepare(for: segue, sender: self)
    }
    
    /// Determines whether a segue should be performed. Whether a segue is performed or not depends on the number of colors
    /// enabled by the user.
    ///
    /// - Parameters:
    ///   - identifier: Segue identifier (eg, name).
    ///   - sender: Not used.
    /// - Returns: True if iOS should perform the segue, false if not.
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool
    {
        switch identifier
        {
        case "Color1":
            //The user can always change the first color.
            return true
            
        case "Color2":
            //Can change the second color only if at least two colors are enabled.
            return SecondColorLabel.isEnabled
            
        case "Color3":
            //Can change the third color if at least three colors are enabled.
            return ThirdColorLabel.isEnabled
            
        default:
            return false
        }
    }
    
    /// Respond to color changes from the color editor.
    ///
    /// - Parameters:
    ///   - Index: Indicates which color changed.
    ///   - Changed: True if the color was really changed, false if not.
    public func ColorChanged(_ Index: Int, Changed: Bool)
    {
        NotifyMainUIOfBackgroundChange(From: "BackgroundSettings2.ColorChanged")
        print("Color \(Index) is dirty: \(Changed)")
        if Changed
        {
            InitializeGradient()
            SetColorSamples()
            ResetSample()
            StartSampleUpdate()
        }
    }
    
    /// Reset the sample.
    func ResetSample()
    {
        print("ResetSample - timer invalidated.")
        SampleTimer?.invalidate()
        SampleTimer = nil
    }
    
    var ColorSample1: BackgroundColors? = nil
    var ColorSample2: BackgroundColors? = nil
    var ColorSample3: BackgroundColors? = nil
    
    /// Start updating the sample.
    func StartSampleUpdate()
    {
        print("Sample timer started.")
        SampleTimer = Timer.scheduledTimer(timeInterval: TimeInterval(1), target: self,
                                           selector: #selector(SampleUpdate), userInfo: nil, repeats: true)
    }
    
    var SampleTimer: Timer? = nil
    
    var PreviousColors = [CGColor]()
    
    /// Update the color sample.
    @objc func SampleUpdate()
    {
        let Now = Date()
        let Color1 = ColorSample1?.Move(ToTime: Now)
        let Color2 = ColorSample2?.Move(ToTime: Now)
        let Color3 = ColorSample3?.Move(ToTime: Now)
        var NewColors = [CGColor]()
        switch _Settings.integer(forKey: Setting.Key.BackgroundColors.BackgroundColorCount)
        {
        case 0:
            NewColors = [Color1!.cgColor, Color1!.cgColor]
            if PreviousColors.isEmpty || PreviousColors.count != 2
            {
                PreviousColors = [UIColor.white.cgColor, UIColor.white.cgColor]
            }
            
        case 1:
            NewColors = [Color1!.cgColor, Color2!.cgColor]
            if PreviousColors.isEmpty || PreviousColors.count != 2
            {
                PreviousColors = [UIColor.white.cgColor, UIColor.black.cgColor]
            }
            
        case 2:
            NewColors = [Color1!.cgColor, Color2!.cgColor, Color3!.cgColor]
            if PreviousColors.isEmpty || PreviousColors.count != 3
            {
                PreviousColors = [UIColor.white.cgColor, UIColor.gray.cgColor, UIColor.black.cgColor]
            }
            
        default:
            print("Unexpected color count.")
            return
        }
        let SampleAnimation = CABasicAnimation(keyPath: "colors")
        SampleAnimation.duration = 1
        SampleAnimation.fillMode = CAMediaTimingFillMode.forwards
        SampleAnimation.isRemovedOnCompletion = false
        SampleAnimation.fromValue = PreviousColors
        SampleAnimation.toValue = NewColors
        Gradient.add(SampleAnimation, forKey: "colorChange")
        PreviousColors = NewColors
    }
    
    @IBOutlet weak var BackgroundTypeSegment: UISegmentedControl!
    
    @IBAction func HandleBackgroundColorCountChanged(_ sender: Any)
    {
        _Settings.set(BackgroundTypeSegment.selectedSegmentIndex, forKey: Setting.Key.BackgroundColors.BackgroundColorCount)
        SetUI()
        InitializeGradient()
        ShowMiddleColorLocationControls(Show: BackgroundTypeSegment.selectedSegmentIndex == 2)
        NotifyMainUIOfBackgroundChange(From: "BackgroundSettings2.HandleBackgroundColorCountChanged")
    }
    
    /// Enables or disables the controls for setting the location of the middle color.
    ///
    /// - Parameter Show: Determines if the controls are enabled (true) or disabled (false).
    func ShowMiddleColorLocationControls(Show: Bool)
    {
        #if true
        MiddleColorTitle.isEnabled = Show
        BGColor2LocationSlider.isEnabled = Show
        BGColor2LocationOut.isEnabled = Show
        TopLabel.isEnabled = Show
        BottomLabel.isEnabled = Show
        #else
        if Show
        {
            let NewFrame = CGRect(x: LocationCell.frame.minX, y: LocationCell.frame.minY, width: LocationCell.frame.width, height: 74)
            LocationCell.bounds = NewFrame
        }
        else
        {
            let NewFrame = CGRect(x: LocationCell.frame.minX, y: LocationCell.frame.minY, width: LocationCell.frame.width, height: 0)
            LocationCell.bounds = NewFrame
        }
        #endif
    }
    
    /// Update the text that indicates the location of the middle color.
    ///
    /// - Parameter To: Value indicating the new location of the middle color (in percent). Invalid values
    ///                 are clamped.
    func SetLocationText(To: Double)
    {
        var Value = To
        if Value < 0.0
        {
            Value = 0.0
        }
        if Value > 1.0
        {
            Value = 1.0
        }
        Value = Value * 100.0
        let Final = Int(Value)
        BGColor2LocationOut.text = "\(Final)%"
    }
    
    @IBAction func HandleColor2LocationSliderChanged(_ sender: Any)
    {
        var Where = Double(BGColor2LocationSlider.value)
        Where = Where / 1000.0
        if LastWhere == Where
        {
            return
        }
        LastWhere = Where
        SetLocationText(To: Where)
        _Settings.set(Where, forKey: Setting.Key.BackgroundColors.BGColor2Location)
        InitializeGradient()
        let x = Utility.Round(Where, ToPlaces: 2)
        NotifyMainUIOfBackgroundChange(From: "BackgroundSettings2.HandleColor2LocationSliderChanged(\(x))")
    }
    
    var LastWhere: Double = -1
    
    /// Tell the main UI that the background changed.
    ///
    /// - Parameter From: Where the call is from.
    func NotifyMainUIOfBackgroundChange(From: String)
    {
        let AD = UIApplication.shared.delegate as! AppDelegate
        AD.Container?.CenterViewController.BackgroundChange(From: From)
    }
    
    func SetAnimationState(IsOn: Bool)
    {
        if IsOn
        {
            ResetSample()
            InitializeGradient()
            StartSampleUpdate()
        }
        else
        {
            ResetSample()
            InitializeGradient()
        }
    }
    
    @IBAction func HandleAnimateChanged(_ sender: Any)
    {
        SetAnimationState(IsOn: AnimateSwitch.isOn)
        _Settings.set(AnimateSwitch.isOn, forKey: Setting.Key.BackgroundColors.AnimateBGSample)
    }
    
    var FirstColorCount: Int = -1
    
    /// Handle the view will disappear notification.
    ///
    /// - Parameter animated: Not used - passed to super class.
    override func viewWillDisappear(_ animated: Bool)
    {
        if FirstColorCount > -1
        {
            if FirstColorCount != BackgroundTypeSegment.selectedSegmentIndex
            {
                let Value = "\(BackgroundTypeSegment.selectedSegmentIndex)"
                Setting.SendNotice(Key: "BGColorCountChanged", Value: Value)
            }
        }
        super.viewWillDisappear(animated)
    }
    
    @IBOutlet weak var MiddleColorTitle: UILabel!
    @IBOutlet weak var LocationCell: UITableViewCell!
    @IBOutlet weak var BGColor2LocationOut: UILabel!
    @IBOutlet weak var BGColor2LocationSlider: UISlider!
    @IBOutlet weak var ColorSample: UIView!
    @IBOutlet weak var SecondColorLabel: UILabel!
    @IBOutlet weak var ThirdColorLabel: UILabel!
    @IBOutlet weak var Color1Sample: UIView!
    @IBOutlet weak var Color2Sample: UIView!
    @IBOutlet weak var Color3Sample: UIView!
    @IBOutlet weak var BottomLabel: UILabel!
    @IBOutlet weak var TopLabel: UILabel!
    @IBOutlet weak var AnimateSwitch: UISwitch!
}
