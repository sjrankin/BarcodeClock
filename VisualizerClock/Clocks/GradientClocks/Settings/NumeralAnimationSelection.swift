//
//  NumeralAnimationSelection.swift
//  Visualizer Clock
//
//  Created by Stuart Rankin on 11/4/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Lets the user select the type of animation to hide or show hour numerals in clocks that allow hiding or showing
/// of hour numerals.
class NumeralAnimationSelection: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    let _Settings = UserDefaults.standard
    
    #if true
    weak var delegate: RadialGradientClockNumeralSettings?
    #else
    var delegate: RadialGradientSettings?
    #endif
    
    weak var MainDelegate: MainUIProtocol? = nil
    var ThisClockID: UUID? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        MainDelegate = delegate?.MainDelegate
        ThisClockID = Clocks.GetActualID(PanelActions.SwitchToRadialColors)
        if ThisClockID == nil
        {
            fatalError("Error getting clock ID in NumeralAnimationSelection")
        }
        SequentialDelaySegment.selectedSegmentIndex = _Settings.integer(forKey: Setting.Key.RadialGradient.NumeralAnimationDelay)
        SampleView.layer.borderColor = UIColor.black.cgColor
        SampleView.layer.borderWidth = 0.5
        SampleView.layer.cornerRadius = 5.0
        SampleView.layer.backgroundColor = UIColor.navyblue.cgColor
        GroupBox.layer.borderColor = UIColor.black.cgColor
        GroupBox.layer.borderWidth = 0.5
        GroupBox.layer.cornerRadius = 5.0
        GroupBox.backgroundColor = UIColor.clear
        LoadData()
        InitializeSample()
        AnimationView.layer.borderColor = UIColor.darkGray.cgColor
        AnimationView.layer.borderWidth = 0.5
        AnimationView.layer.cornerRadius = 5.0
        AnimationView.delegate = self
        AnimationView.dataSource = self
        AnimationView.reloadData()
            {
                //RenderedCellHeight is populated by tableView(cellForRowAt) during a reloadData operation.
                let CellHeight = self.RenderedCellHeight
                let YPoint = CellHeight * CGFloat(self._Settings.integer(forKey: Setting.Key.RadialGradient.NumeralAnimationStyle))
                let ScrollPoint = CGPoint(x: 0, y: YPoint)
                self.AnimationView.setContentOffset(ScrollPoint, animated: true)
        }
        
        Background = BackgroundServer(SampleView)
        Background.UpdateBackgroundColors()
        BGTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(UpdateBG), userInfo: nil, repeats: true)
    }
    
    var Background: BackgroundServer!
    var BGTimer: Timer!
    
    @objc func UpdateBG()
    {
        Background.UpdateBackgroundColors()
    }
    
    /// Make sure the data for the table is in the proper order. Also, select the current animation style.
    func LoadData()
    {
        AnimationStyles = CARadialGradientLayer2.AnimationDescriptions
        AnimationStyles = AnimationStyles.sorted(by: {$0.0 < $1.0})
        AnimationStyles![_Settings.integer(forKey: Setting.Key.RadialGradient.NumeralAnimationStyle)].5 = true
    }
    
    var AnimationStyles: [(Int, String, String, CARadialGradientLayer2.ShowTextAnimations, CARadialGradientLayer2.HideTextAnimations, Bool)]!
    
    func InitializeSample()
    {
        let SampleFrame = SampleView.frame
        let SampleBounds = SampleView.bounds
        let Center = CGPoint(x: SampleFrame.width / 2.0, y: SampleFrame.height / 2.0)
        SampleLayer = CARadialGradientLayer2.MakeClockFace(FontSize: 20.0, ACenter: Center, Frame: SampleFrame, Bounds: SampleBounds)
        CreateSpirals()
        SampleView.layer.addSublayer(SampleLayer)
        StartAnimation()
    }
    
    func CreateSpirals()
    {
        let Radius: CGFloat = (min(SampleView.frame.width, SampleView.frame.height) / 2.0) - 20.0
        let Center = CGPoint(x: (SampleView.frame.width - SampleView.frame.minX) / 2.0 - (SampleView.frame.minX / 2.0), y: (SampleView.frame.height - SampleView.frame.minY) / 2.0 - (SampleView.frame.minY / 2.0))
        let BasePoints = Geometry.MakeSpiral(StartingAngle: 0.0, InitialRadius: Radius, Rotations: 0.75, Steps: 100, RadialDelta: -1.0, Center: Center)
        
        for Hour in 1 ... 12
        {
            var PointList = [CGPoint]()
            let Angle = CGFloat(Hour) * 30.0
            if Hour == 12
            {
                PointList = BasePoints
            }
            else
            {
                PointList = Geometry.RotatePointList(BasePoints, Degrees: Double(Angle), Around: Center)
            }
            Geometry.SaveSpiral(Hour: Hour + 1000, SpiralPath: PointList)
        }
        
        let OBasePoints = Geometry.MakeSpiral(StartingAngle: 0.0, InitialRadius: Radius, Rotations: 0.75, Steps: 100,
                                              RadialDelta: 1.0, Center: Center, RadiusOffset: 0.0)
        
        for Hour in 1 ... 12
        {
            var PointList = [CGPoint]()
            let Angle = CGFloat(Hour) * 30.0
            if Hour == 12
            {
                PointList = OBasePoints
            }
            else
            {
                PointList = Geometry.RotatePointList(OBasePoints, Degrees: Double(Angle), Around: Center)
            }
            Geometry.SaveSpiral(Hour: Hour + 100 + 1000, SpiralPath: PointList)
        }
    }
    
    var SampleLayer: CATextLayer!
    
    //var ClockLock = NSObject()
    
    /// Start an animation demo cycle for the user.
    func StartAnimation()
    {
        //objc_sync_enter(ClockLock)
        //defer {objc_sync_exit(ClockLock)}
        
        if SampleTimer != nil
        {
            SampleTimer?.invalidate()
            SampleTimer = nil
        }
        SampleLayer.removeAllAnimations()
        SampleLayer.removeFromSuperlayer()
        SampleLayer = nil
        
        let SampleFrame = SampleView.frame
        let SampleBounds = SampleView.bounds
        let Center = CGPoint(x: SampleFrame.width / 2.0, y: SampleFrame.height / 2.0)
        
        SampleLayer = CARadialGradientLayer2.MakeClockFace(FontSize: 20.0, ACenter: Center, Frame: SampleFrame, Bounds: SampleBounds)
        SampleView.layer.addSublayer(SampleLayer)
        
        let AnimationType = _Settings.integer(forKey: Setting.Key.RadialGradient.NumeralAnimationStyle)
        let DelayIndex = _Settings.integer(forKey: Setting.Key.RadialGradient.NumeralAnimationDelay)
        let Delay = CARadialGradientLayer2.AnimationDelays[DelayIndex]
        let ShowAnimation = AnimationStyles![AnimationType].3
        let HideAnimation = AnimationStyles![AnimationType].4
        
        let Center2 = CGPoint(x: (SampleFrame.width - SampleFrame.minX) / 2.0 - (SampleFrame.minX / 2.0),
                              y: (SampleFrame.height - SampleFrame.minY) / 2.0 - (SampleFrame.minY / 2.0))
        
        SampleTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true, block:
            {
                timer in
                CARadialGradientLayer2.HideClockNumerals(ClockFaceLayer: self.SampleLayer, Duration: 0.75,
                                                         AnimationType: HideAnimation, Delay: Delay!,
                                                         Frame: SampleFrame, Center: Center2,
                                                         Width: SampleFrame.width, Height: SampleFrame.height,
                                                         HourOffset: 1000)
                
                let _ = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block:
                {
                    timer in
                    CARadialGradientLayer2.ShowClockNumerals(ClockFaceLayer: self.SampleLayer, Duration: 0.75,
                                                             AnimationType: ShowAnimation, Delay: Delay!,
                                                             Frame: SampleFrame, Center: Center2,
                                                             Width: SampleFrame.width, Height: SampleFrame.height,
                                                             HourOffset: 1000)
                })
        })
    }
    
    var SampleTimer: Timer? = nil
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return AnimationStyles.count
    }
    
    var RenderedCellHeight: CGFloat = 0.0
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let Cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "AnimationStyleCell")
        Cell.selectionStyle = UITableViewCell.SelectionStyle.blue
        Cell.tag = AnimationStyles[indexPath.row].0
        Cell.textLabel?.text = AnimationStyles[indexPath.row].1
        Cell.detailTextLabel?.text = AnimationStyles[indexPath.row].2
        Cell.isSelected = AnimationStyles[indexPath.row].5
        if AnimationStyles[indexPath.row].5
        {
            Cell.backgroundColor = UIColor.atomictangerine
        }
        else
        {
            Cell.backgroundColor = UIColor.white
        }
        RenderedCellHeight = Cell.frame.height
        return Cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        for Index in 0 ..< AnimationStyles.count
        {
            AnimationStyles[Index].5 = false
        }
        AnimationStyles[indexPath.row].5 = true
        let Cell = AnimationView.cellForRow(at: indexPath)
        let Tag = Cell?.tag
        if let PreviouslySelectedAnimation = PreviouslySelectedAnimation
        {
            if PreviouslySelectedAnimation == Tag
            {
                return
            }
        }
        PreviouslySelectedAnimation = Tag
        _Settings.set(Tag, forKey: Setting.Key.RadialGradient.NumeralAnimationStyle)
        MainDelegate?.BroadcastChanges(ToClock: ThisClockID!, [Setting.Key.RadialGradient.NumeralAnimationStyle])
        delegate?.DoSet(Key: "AnimationDescription", Value: nil)
        AnimationView.reloadData()
        StartAnimation()
    }
    
    private var PreviouslySelectedAnimation: Int? = nil
    
    @IBAction func HandleSequentialDelayChanged(_ sender: Any)
    {
        _Settings.set(SequentialDelaySegment.selectedSegmentIndex, forKey: Setting.Key.RadialGradient.NumeralAnimationDelay)
        MainDelegate?.BroadcastChanges(ToClock: ThisClockID!, [Setting.Key.RadialGradient.NumeralAnimationDelay])
        StartAnimation()
    }
    
    @IBOutlet weak var GroupBox: UIView!
    @IBOutlet weak var SequentialDelaySegment: UISegmentedControl!
    @IBOutlet weak var AnimationView: UITableView!
    @IBOutlet weak var SampleView: UIView!
}

/// Required to get scrolling to work.
/// https://code.i-harness.com/en/q/f53b4f
extension UITableView
{
    /// Reloads data in a UITableView and allows a completion block. This, in turn, lets callers know exactly when
    /// relading is completed, which in turn, guarentees certain globals are properly populated (eg, cell height).
    ///
    /// - Parameter completion: Completion block to execute once reloadData is completed.
    func reloadData(completion: @escaping () -> ())
    {
        UIView.animate(withDuration: 0, animations:
            {self.reloadData()},
                       completion:
            {
                finished in
                completion()
        }
        )
    }
}
