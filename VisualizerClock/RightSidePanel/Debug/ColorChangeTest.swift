//
//  ColorChangeTest.swift
//  Barcode Clock
//
//  Created by Stuart Rankin on 8/29/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class ColorChangeTest: UIViewController, CAAnimationDelegate
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        SimpleSample.backgroundColor = UIColor.clear
        SimpleSample.layer.borderColor = UIColor.black.cgColor
        SimpleSample.layer.borderWidth = 1.0
        SimpleSample.layer.cornerRadius = 5.0
        Gradient1 = CAGradientLayer()
        MakeGradientDisplay(View: Gradient1Sample, Gradient: &Gradient1)
        Gradient2 = CAGradientLayer()
        MakeGradientDisplay(View: Gradient2Sample, Gradient: &Gradient2)
        
        MajorHue1.text = ""
        PropAnimMajorHue.text = ""
        PropAnimMinorHue.text = ""
        BasicAnimMajorHue.text = ""
        BasicAnimMinorHue.text = ""
    }
    
    func MakeGradientDisplay(View: UIView, Gradient: inout CAGradientLayer)
    {
        View.backgroundColor = UIColor.clear
        View.layer.borderColor = UIColor.black.cgColor
        View.layer.borderWidth = 1.0
        View.layer.cornerRadius = 5.0
        Gradient = CAGradientLayer()
        Gradient.frame = View.bounds
        View.layer.insertSublayer(Gradient, at: 0)
        View.layer.masksToBounds = true
        let G1 = UIColor(hue: 0.0, saturation: 0.9, brightness: 0.9, alpha: 1.0)
        let G2 = UIColor(hue: 0.5, saturation: 0.9, brightness: 0.9, alpha: 1.0)
        Gradient.colors = [G1.cgColor as Any, G2.cgColor as Any]
    }
    
    func RunSingleLayer()
    {
        SimpleTimer = Timer.scheduledTimer(timeInterval: TimeInterval(0.5), target: self,
                                           selector: #selector(SimpleColorChange), userInfo: nil, repeats: true)
    }
    
    func StopSingleLayer()
    {
        SimpleTimer?.invalidate()
        SimpleTimer = nil
    }
    
    @objc func SimpleColorChange()
    {
        let PeriodPercent = Times.Percent(Period: 0, Now: Date())
        var Hue: CGFloat = CGFloat(PeriodPercent * 360.0)
        Hue = fmod(Hue, 360.0)
        let HueAngle = Hue
        Hue = Hue / 360.0
        MajorHue1.text = "\(Utility.Round(HueAngle, ToPlaces: 3))°"
        BasicAnimMajorHue.text = MajorHue1.text
        PropAnimMajorHue.text = MajorHue1.text
                var MinorHue: CGFloat = CGFloat((PeriodPercent + 0.5) * 360.0)
        MinorHue = fmod(MinorHue, 360.0)
        BasicAnimMinorHue.text = "\(Utility.Round(MinorHue, ToPlaces: 3))°"
        PropAnimMinorHue.text = BasicAnimMinorHue.text
        
        SimpleColor = UIColor(hue: Hue, saturation: 0.9, brightness: 0.9, alpha: 1.0)
        if SimpleAnimation.isRunning
        {
            SimpleAnimation.stopAnimation(true)
        }
        else
        {
            SimpleAnimation.isUserInteractionEnabled = true
        }
        SimpleAnimation.addAnimations {
            self.SimpleSample.backgroundColor = self.SimpleColor
        }
        SimpleAnimation.startAnimation()
    }
    
    var SimpleColor: UIColor!
    var SimpleAnimation = UIViewPropertyAnimator(duration: 1, curve: .linear)
    
    var SimpleTimer: Timer? = nil
    var Gradient1Timer: Timer? = nil
    var Gradient2Timer: Timer? = nil
    
    @IBOutlet weak var ColorChangeCountSegment: UISegmentedControl!
    
    @IBAction func HandleColorCountChanged(_ sender: Any)
    {
    }
    
    func RunGradientLayers()
    {
        Gradient1Timer = Timer.scheduledTimer(timeInterval: TimeInterval(1.0), target: self,
                                              selector: #selector(HandleGradient1), userInfo: nil, repeats: true)
        Gradient2Timer = Timer.scheduledTimer(timeInterval: TimeInterval(1.0), target: self,
                                              selector: #selector(HandleGradient2), userInfo: nil, repeats: true)
    }
    
    @objc func HandleGradient1()
    {
        //This one works if called at the same frequency it changes colors.
        let PeriodPercent = Times.Percent(Period: 0, Now: Date())
        var Hue: CGFloat = CGFloat(PeriodPercent * 360.0)
        var Hue2 = Hue
        Hue = fmod(Hue, 360.0)
        Hue = Hue / 360.0
        GradientColor1A = UIColor(hue: Hue, saturation: 0.9, brightness: 0.9, alpha: 1.0)
        Hue2 = Hue2 + 180.0
        Hue2 = fmod(Hue2, 360.0)
        Hue2 = Hue2 / 360.0
        GradientColor1B = UIColor(hue: Hue2, saturation: 0.9, brightness: 0.9, alpha: 1.0)
        let NewColors = [GradientColor1A.cgColor, GradientColor1B.cgColor]
        let ColorChange = CABasicAnimation(keyPath: "colors")
        ColorChange.duration = 1
        ColorChange.fillMode = CAMediaTimingFillMode.forwards
        ColorChange.isRemovedOnCompletion = false
        ColorChange.fromValue = PreviousColors
        ColorChange.toValue = NewColors
        Gradient1.add(ColorChange, forKey: "colorChange")
        PreviousColors = NewColors
    }
    
    #if false
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool)
    {
        if flag
        {
            PreviousColors = FinalGradient
            print("Assigning previous colors")
        }
    }
    #endif
    
    public var PreviousColors = [CGColor]()
    public var FinalGradient = [CGColor]()
    var GradientColor1A: UIColor!
    var GradientColor1B: UIColor!
    
    var Gradient2Animation = UIViewPropertyAnimator(duration: 1, curve: .linear)
    
    @objc func HandleGradient2()
    {
        let PeriodPercent = Times.Percent(Period: 0, Now: Date())
        var Hue: CGFloat = CGFloat(PeriodPercent * 360.0)
        var Hue2 = Hue
        Hue = fmod(Hue, 360.0)
        Hue = Hue / 360.0
        GradientColor2A = UIColor(hue: Hue, saturation: 0.9, brightness: 0.9, alpha: 1.0)
        Hue2 = Hue2 + 180.0
        Hue2 = fmod(Hue2, 360.0)
        Hue2 = Hue2 / 360.0
        GradientColor2B = UIColor(hue: Hue2, saturation: 0.9, brightness: 0.9, alpha: 1.0)
        
        if Gradient2Animation.isRunning
        {
            Gradient2Animation.stopAnimation(true)
        }
        else
        {
            Gradient2Animation.isUserInteractionEnabled = true
        }
        Gradient2Animation.addAnimations {
            self.Gradient2.colors?[0] = self.GradientColor2A.cgColor
            self.Gradient2.colors?[1] = self.GradientColor2B.cgColor
        }
        Gradient2Animation.startAnimation()
    }
    
    var GradientColor2A: UIColor!
    var GradientColor2B: UIColor!
    
    @IBOutlet weak var SimpleSample: UIView!
    
    @IBOutlet weak var Gradient1Sample: UIView!
    
    @IBOutlet weak var Gradient2Sample: UIView!
    
    var Gradient1: CAGradientLayer!
    var Gradient2: CAGradientLayer!
    
    @IBAction func HandleStartButton(_ sender: Any)
    {
        RunSingleLayer()
        RunGradientLayers()
    }
    
    @IBAction func HandleStopButton(_ sender: Any)
    {
    }
    
    @IBOutlet weak var MajorHue1: UILabel!
    @IBOutlet weak var BasicAnimMajorHue: UILabel!
    @IBOutlet weak var PropAnimMajorHue: UILabel!
    @IBOutlet weak var BasicAnimMinorHue: UILabel!
    @IBOutlet weak var PropAnimMinorHue: UILabel!
}
