//
//  GlobalSoundSettings.swift
//  Visualizer Clock
//
//  Created by Stuart Rankin on 11/29/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class GlobalSoundSettings: UITableViewController, SettingProtocol
{
    let _Settings = UserDefaults.standard
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        MuteAllSwitch.isOn = _Settings.bool(forKey: Setting.Key.Sounds.GlobalEnable)
        TickTockSoundLabel.text = _Settings.string(forKey: Setting.Key.Sounds.GlobalTick)
        SoundsFromSegment.selectedSegmentIndex = _Settings.bool(forKey: Setting.Key.Sounds.UseGlobalSounds) ? 0 : 1
        GlobalVolumeSlider.value = Float(1000 * _Settings.integer(forKey: Setting.Key.Sounds.GlobalVolume))
    }
    
    @IBOutlet weak var MuteAllSwitch: UISwitch!
    
    @IBAction func HandleMuteAllChanged(_ sender: Any)
    {
    }
    
    @IBOutlet weak var SoundsFromSegment: UISegmentedControl!
    
    @IBOutlet weak var TickTockSoundLabel: UILabel!
    
    @IBOutlet weak var GlobalVolumeSlider: UISlider!
    
    @IBAction func HandleGlobalVolumeSliderChanged(_ sender: Any)
    {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        switch segue.identifier
        {
        case "ToSoundPicker":
            let Dest = segue.destination as? GlobalSoundPicker
            Dest?.DoSet(Key: "NewTitle", Value: "Global Sounds")
            Dest?.DoSet(Key: "SoundList", Value: "GlobalSoundList")
            
        default:
            break
        }
        
        super.prepare(for: segue, sender: self)
    }
    
    func DoSet(Key: String, Value: Any?)
    {
        switch Key
        {
        case "NewTickTock":
            break
            
        default:
            break
        }
    }
}
