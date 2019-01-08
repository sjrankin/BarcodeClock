//
//  SmallGradientStopEditor.swift
//  Visualizer Clock
//
//  Created by Stuart Rankin on 11/12/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class SmallGradientStopEditor: UITableViewController, ColorReceiver, SettingProtocol
{
    var delegate: SettingProtocol?
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
        ColorSample.layer.borderWidth = 0.5
        ColorSample.layer.borderColor = UIColor.black.cgColor
        ColorSample.layer.cornerRadius = 5.0
        ColorSample.backgroundColor = UIColor.black
        
        LoadUI()
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
    
    func LoadUI()
    {
        ColorSample.backgroundColor = InitialColor
        LocationBox.text = String(Utility.Round(InitialLocation, ToPlaces: 2))
        LocationSlider.value = Float(InitialLocation * 1000.0)
        CurrentLocation = InitialLocation
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        switch segue.identifier
        {
        case "ToColorEditor":
            let Dest = segue.destination as? BasicColorEditor
            Dest?.CallerDelegate = self
            Dest?.InitialTitle = "Gradient Color"
            Dest?.InitialColorSpace = ColorEditorColorSpaces.RGBA
            Dest?.InitialColor = ColorSample.backgroundColor!
            Dest?.ColorSettingsString = ""
            
        default:
            break
        }
        super.prepare(for: segue, sender: self)
    }
    
    @IBOutlet weak var ColorSample: UIView!
    
    @IBOutlet weak var LocationBox: UITextField!
    
    @IBAction func HandleLocationBoxChanged(_ sender: Any)
    {
        view.endEditing(true)
        if let Raw = LocationBox.text
        {
            if let Val = Double(Raw)
            {
                CurrentLocation = Val / 1000.0
            }
            else
            {
                LocationBox.text = "1.0"
                LocationSlider.value = 1.0
            }
        }
        else
        {
            LocationBox.text = "1.0"
            LocationSlider.value = 1.0
        }
    }
    
    @IBOutlet weak var LocationSlider: UISlider!
    
    @IBAction func HandleLocationSliderChanged(_ sender: Any)
    {
        view.endEditing(true)
        let SliderVal = LocationSlider.value / 1000.0
        CurrentLocation = Double(SliderVal)
        LocationBox.text = String(Utility.Round(CurrentLocation, ToPlaces: 2))
    }
    
    func DoSet(Key: String, Value: Any?)
    {
        switch Key
        {
        case "Color":
            let TheColor = Value as! UIColor
            InitialColor = TheColor
            
        case "Location":
            let TheLocation = Value as! Double
            InitialLocation = TheLocation
            
        default:
            return
        }
    }
    
    var InitialColor: UIColor = UIColor.white
    var InitialLocation: Double = 0.0
    
    func ColorChanged(NewColor: UIColor, DidChange: Bool, Tag: String?)
    {
        if DidChange
        {
            ColorSample.backgroundColor = NewColor
        }
    }
    
    var CurrentLocation: Double = 0.0
    
    override func viewWillDisappear(_ animated: Bool)
    {
        delegate?.DoSet(Key: "Color", Value: ColorSample.backgroundColor!)
        delegate?.DoSet(Key: "Location", Value: CurrentLocation)
        super.viewWillDisappear(animated)
    }
}
