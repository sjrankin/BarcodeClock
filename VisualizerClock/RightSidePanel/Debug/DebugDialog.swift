//
//  DebugDialog.swift
//  Barcode Clock
//
//  Created by Stuart Rankin on 8/31/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class DebugDialog: UITableViewController, ColorReceiver
{
    let _Settings = UserDefaults.standard
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        ShowGridOverlaySwitch.isOn = _Settings.bool(forKey: Setting.Key.Debug.ShowDebugGrid)
        ShowOutlinesSwitch.isOn = _Settings.bool(forKey: Setting.Key.OutlineObjects)
        BarcodeTestColorSample.layer.borderColor = UIColor.black.cgColor
        BarcodeTestColorSample.layer.borderWidth = 0.5
        BarcodeTestColorSample.layer.cornerRadius = 5.0
        //print("Setting color sample color to \(Utility.ColorToString(_Settings.uicolor(forKey: Setting.Key.BarcodeTestColor)!, AsRGB: true, DeNormalize: false))")
        BarcodeTestColorSample.backgroundColor = _Settings.uicolor(forKey: Setting.Key.Debug.BarcodeTestColor)
        EnableBarcodeTests.isOn = _Settings.bool(forKey: Setting.Key.Debug.EnableBarcodeColorTests)
        BarcodeColorTestVelocitySegment.selectedSegmentIndex = _Settings.integer(forKey: Setting.Key.Debug.BarcodeColorTestVelocity)
        BarcodeColorTestType.selectedSegmentIndex = _Settings.integer(forKey: Setting.Key.Debug.BarcodeColorTestMotion)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
    }
    
    private var ColorNotYetSet: Bool = true
    
    @IBAction func HandleDonePressed(_ sender: Any)
    {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var ShowOutlinesSwitch: UISwitch!
    
    @IBAction func HandleShowOutlinesChanged(_ sender: Any)
    {
        _Settings.set(ShowOutlinesSwitch.isOn, forKey: Setting.Key.OutlineObjects)
    }
    
    @IBOutlet weak var ShowGridOverlaySwitch: UISwitch!
    
    @IBAction func HandleGridOverlayChanged(_ sender: Any)
    {
        _Settings.set(ShowGridOverlaySwitch.isOn, forKey: Setting.Key.Debug.ShowDebugGrid)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        switch segue.identifier
        {
        case "ToColor":
            let Dest = segue.destination as? BasicColorEditor
            Dest?.InitialTitle = "Barcode Test Color"
                        Dest?.InitialColorSpace = ColorEditorColorSpaces.HSB
//            Dest?.InitialColorSpaceIsHSB = true
            Dest?.ColorSettingsString = Setting.Key.Debug.BarcodeTestColor
            if let BarcodeColor = _Settings.uicolor(forKey: Setting.Key.Debug.BarcodeTestColor)
            {
                //print("Will edit \(Utility.ColorToString(BarcodeColor, AsRGB: true, DeNormalize: true))")
                Dest?.InitialColor = BarcodeColor
            }
            else
            {
                Dest?.InitialColor = UIColor.red
            }
            Dest?.CallerDelegate = self
            
        default:
            break
        }
        
        super.prepare(for: segue, sender: self)
    }
    
    func ColorChanged(NewColor: UIColor, DidChange: Bool, Tag: String?)
    {
       // if DidChange
        //{
        //    _Settings.set(NewColor, forKey: Setting.Key.BarcodeTestColor)
        //print("New color is \(Utility.ColorToString(NewColor, AsRGB: true, DeNormalize: true))")
            BarcodeTestColorSample.backgroundColor = NewColor
       // }
    }
    
    @IBOutlet weak var BarcodeTestColorSample: UIView!
    
    @IBOutlet weak var EnableBarcodeTests: UISwitch!
    
    @IBAction func HandleEnableBarcodeTestsChanged(_ sender: Any)
    {
        _Settings.set(EnableBarcodeTests.isOn, forKey: Setting.Key.Debug.EnableBarcodeColorTests)
    }
    
    @IBOutlet weak var BarcodeColorTestType: UISegmentedControl!
    
    @IBAction func HandleBarcodeColorsTestTypeChanged(_ sender: Any)
    {
        _Settings.set(BarcodeColorTestType.selectedSegmentIndex, forKey: Setting.Key.Debug.BarcodeColorTestMotion)
    }
    
    @IBOutlet weak var BarcodeColorTestVelocitySegment: UISegmentedControl!
    
    @IBAction func HandleBarcodeColorVelocityChanged(_ sender: Any)
    {
        _Settings.set(BarcodeColorTestVelocitySegment.selectedSegmentIndex, forKey: Setting.Key.Debug.BarcodeColorTestVelocity)
    }
}
