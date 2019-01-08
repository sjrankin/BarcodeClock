//
//  EncodedTimeFormatting.swift
//  Barcode Clock
//
//  Created by Stuart Rankin on 8/18/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class EncodedTimeFormatting: UITableViewController, SettingProtocol
{
    var delegate: SettingProtocol? = nil
    
    func DoSet(Key: String, Value: Any?)
    {

    }
    
    /// Tell the system that we don't want the status bar getting in the way.
    override var prefersStatusBarHidden: Bool
    {
        return _Settings.bool(forKey: Setting.Key.HideStatusBar)
    }
    
    let _Settings = UserDefaults.standard
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        SampleContents.text = ""
        UseScreenFormattingSwitch.isOn = _Settings.bool(forKey: Setting.Key.UseScreenFormatting)
        IncludeDateSwitch.isOn = _Settings.bool(forKey: Setting.Key.IncludeDate)
        IncludeWeekdaySwitch.isOn = _Settings.bool(forKey: Setting.Key.IncludeWeekday)
        IncludeSecondsSwitch.isOn = _Settings.bool(forKey: Setting.Key.IncludeSeconds)
        OrderSegments.selectedSegmentIndex = _Settings.integer(forKey: Setting.Key.EncodingOrder)
        UpdateTimeRelatedControls()
        UpdateDateRelatedControls()
        UpdateSample()
        SampleTimer = Timer.scheduledTimer(timeInterval: TimeInterval(1.0), target: self,
                                           selector: #selector(UpdateSample), userInfo: nil, repeats: true)
    }
    
    var SampleTimer: Timer? = nil
    
    func UpdateDateRelatedControls()
    {
        IncludeWeekdaySwitch.isEnabled = IncludeDateSwitch.isOn
        OrderSegments.isEnabled = IncludeDateSwitch.isOn
    }
    
    func UpdateTimeRelatedControls()
    {
        IncludeSecondsSwitch.isEnabled = UseScreenFormattingSwitch.isOn
    }
    
    @IBOutlet weak var UseScreenFormattingSwitch: UISwitch!
    
    @IBAction func HandleScreenFormattingChanged(_ sender: Any)
    {
        _Settings.set(UseScreenFormattingSwitch.isOn, forKey: Setting.Key.UseScreenFormatting)
        UpdateTimeRelatedControls()
        UpdateSample()
    }
    
    @IBOutlet weak var IncludeSecondsSwitch: UISwitch!
    
    @IBAction func HandleIncludeSecondsChanged(_ sender: Any)
    {
        _Settings.set(IncludeSecondsSwitch.isOn, forKey: Setting.Key.IncludeSeconds)
        UpdateSample()
    }
    
    @IBOutlet weak var IncludeDateSwitch: UISwitch!
    
    @IBAction func HandleIncludeDateChanged(_ sender: Any)
    {
        _Settings.set(IncludeDateSwitch.isOn, forKey: Setting.Key.IncludeDate)
        UpdateDateRelatedControls()
        UpdateSample()
    }
    
    @IBOutlet weak var IncludeWeekdaySwitch: UISwitch!
    
    @IBAction func HandleIncludeWeekdayChanged(_ sender: Any)
    {
        _Settings.set(IncludeWeekdaySwitch.isOn, forKey: Setting.Key.IncludeWeekday)
        UpdateSample()
    }
    
    @IBOutlet weak var OrderSegments: UISegmentedControl!
    
    @IBAction func HandleOrderChanged(_ sender: Any)
    {
        _Settings.set(OrderSegments.selectedSegmentIndex, forKey: Setting.Key.EncodingOrder)
        UpdateSample()
    }
    
    @objc func UpdateSample()
    {
        let Now = Date()
        let Sample = Utility.GetTimeStampToEncode(From: Now)
        let ISample = Utility.GetTimeStampToEncodeI(From: Now)
        let IFSample = String(ISample)
        SampleContents.text = Sample
        ISampleContents.text = IFSample
        let ILongSample = Utility.GetTimeStampToEncodeI(From: Now, true)
        let ILFSample = String(ILongSample)
        ILongSampleContents.text = ILFSample
    }
    
    @IBOutlet weak var ILongSampleContents: UILabel!
    @IBOutlet weak var ISampleContents: UILabel!
    @IBOutlet weak var SampleContents: UILabel!
    
    override func viewWillDisappear(_ animated: Bool)
    {
        if delegate != nil
        {
            delegate?.DoSet(Key: "TimeEncodingChanged", Value: nil)
        }
        super.viewWillDisappear(animated)
    }
}
