//
//  ClockHandRadials.swift
//  Visualizer Clock
//
//  Created by Stuart Rankin on 11/5/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class ClockHandRadials: UITableViewController, SettingProtocol
{
    let _Settings = UserDefaults.standard
    var Parent: RadialGradientSettingsNav!
    var ThisClockID: UUID? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        Parent = parent as? RadialGradientSettingsNav
        if Parent == nil
        {
            fatalError("Unable to retrieve parent from RadialGradientSettingsNav.")
        }
        MainDelegate = Parent.MainDelegate
        ThisClockID = Clocks.GetActualID(PanelActions.SwitchToRadialColors)
        if ThisClockID == nil
        {
            fatalError("Unable to get ID of the radial colors clock: \(Clocks.ClockIDMap[PanelActions.SwitchToRadialColors]!)")
        }
        SampleView.backgroundColor = UIColor.black
        SampleView.layer.borderColor = UIColor.black.cgColor
        SampleView.layer.borderWidth = 0.5
        SampleView.layer.cornerRadius = 5
        ShowSample(100)
        
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
    
    private weak var _MainDelegate: MainUIProtocol? = nil
    weak var MainDelegate: MainUIProtocol?
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
    
    @IBOutlet weak var SampleView: UIView!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        print("Segue for \(segue.identifier!)")
        switch segue.identifier
        {
        case "ToSmallRadialGradientEditor":
            let Dest = segue.destination as? SmallRadialGradientEditor
            Dest?.CallerDelegate = self
            Dest?.DoSet(Key: "RawDescription", Value: GradientToEdit)
            
        case "ToRadialGradientEditor":
            let Dest = segue.destination as? RadialGradientEditor
            Dest?.CallerDelegate = self
            Dest?.DoSet(Key: "RawDescription", Value: GradientToEdit)
            Dest?.DoSet(Key: "Title", Value: GradientTitle)
            Dest?.DoSet(Key: "SettingKey", Value: RadialSettingKey)
            
        default:
            break
        }
    }
    
    var RadialSettingKey: String = ""
    var GradientToEdit: String? = nil
    var GradientTitle: String? = nil
    var CurrentTag: Int = 0
    
    func GetSegueIdentifier() -> String
    {
        let Width = UIScreen.main.bounds.size.width
        let SegueID = Width <= 320 ? "ToSmallRadialGradientEditor" : "ToRadialGradientEditor"
        print("Segue for width of \(Width) is \(SegueID)")
        return SegueID
    }
    
    @IBAction func HandleEditHourHand(_ sender: Any)
    {
        RadialSettingKey = Setting.Key.RadialGradient.HourBlobDefiniton
        let SegueID = GetSegueIdentifier()
        performSegue(withIdentifier: SegueID, sender: self)
    }
    
    @IBAction func HandleEditMinuteHand(_ sender: Any)
    {
        RadialSettingKey = Setting.Key.RadialGradient.MinuteBlobDefiniton
        let SegueID = GetSegueIdentifier()
        performSegue(withIdentifier: SegueID, sender: self)
    }
    
    @IBAction func HandleEditSecondHand(_ sender: Any)
    {
        RadialSettingKey = Setting.Key.RadialGradient.SecondBlobDefiniton
        let SegueID = GetSegueIdentifier()
        performSegue(withIdentifier: SegueID, sender: self)
    }
    
    @IBAction func HandleEditCenterDot(_ sender: Any)
    {
        RadialSettingKey = Setting.Key.RadialGradient.CenterBlobDefiniton
        let SegueID = GetSegueIdentifier()
        performSegue(withIdentifier: SegueID, sender: self)
    }
    
    @IBOutlet weak var SampleTitle: UILabel!
    
    func ShowSample(_ Tag: Int)
    {
        SampleView.layer.sublayers?.forEach{
            if $0.name == "GradientView"
            {
                $0.removeFromSuperlayer()
            }
        }
        //SampleView.layer.sublayers?.forEach{$0.removeFromSuperlayer()}
        var Raw: String = ""
        switch Tag
        {
        case 100:
            Raw = _Settings.string(forKey: Setting.Key.RadialGradient.HourBlobDefiniton)!
            GradientTitle = "Edit Hour Hand Gradient"
            SampleTitle.text = "Hour Hand Gradient"
            
        case 200:
            Raw = _Settings.string(forKey: Setting.Key.RadialGradient.MinuteBlobDefiniton)!
            GradientTitle = "Edit Minute Hand Gradient"
            SampleTitle.text = "Minute Hand Gradient"
            
        case 300:
            Raw = _Settings.string(forKey: Setting.Key.RadialGradient.SecondBlobDefiniton)!
            GradientTitle = "Edit Second Hand Gradient"
            SampleTitle.text = "Second Hand Gradient"
            
        case 400:
            Raw = _Settings.string(forKey: Setting.Key.RadialGradient.CenterBlobDefiniton)!
            GradientTitle = "Edit Center Blob Gradient"
            SampleTitle.text = "Center dot Gradient"
            
        default:
            print("Unknown tag value \(Tag)")
            return
        }
        
        print("Sample raw: \(Raw)")
        GradientToEdit = Raw
        
        var GradientSample: RadialGradientDescriptor!
        do
        {
            //Need to do some contortions to calculate the center of an arbitrarily-placed UIView.
            let X = ((SampleView.frame.width - SampleView.frame.minX) / 2.0) - (SampleView.frame.minX / 2.0)
            let Y = (SampleView.frame.height / 2.0) + (SampleView.frame.minY / 1.0)
            let Center = CGPoint(x: X, y: Y)
            GradientSample = try RadialGradientDescriptor(Frame: SampleView.frame, Bounds: SampleView.bounds,
                                                          Location: Center, Description: Raw,
                                                          OuterAlphaValue: 0.0, AlphaDistance: 0.05)
            GradientSample.name = "GradientView"
            GradientSample.borderColor = UIColor.red.cgColor
            GradientSample.borderWidth = 1.0
        }
        catch
        {
            print("Error returned by RadialGradientDescriptor initializer.")
            return
        }
        SampleView.layer.addSublayer(GradientSample)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let Cell = tableView.cellForRow(at: indexPath)
        CurrentTag = (Cell?.tag)!
        ShowSample((Cell?.tag)!)
    }
    
    func DoSet(Key: String, Value: Any?)
    {
        switch Key
        {
        case "RawDescription":
            let Raw = Value as! String
            switch CurrentTag
            {
            case 100:
                _Settings.set(Raw, forKey: Setting.Key.RadialGradient.HourBlobDefiniton)
                
            case 200:
                _Settings.set(Raw, forKey: Setting.Key.RadialGradient.MinuteBlobDefiniton)
                
            case 300:
                _Settings.set(Raw, forKey: Setting.Key.RadialGradient.SecondBlobDefiniton)
                
            case 400:
                _Settings.set(Raw, forKey: Setting.Key.RadialGradient.CenterBlobDefiniton)
                
            default:
                return
            }
            ShowSample(CurrentTag)
            
        default:
            break
        }
    }
}
