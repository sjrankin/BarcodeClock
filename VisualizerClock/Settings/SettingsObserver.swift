//
//  SettingsObserver.swift
//  Barcode Clock
//
//  Created by Stuart Rankin on 8/26/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Observes changes to default user settings.
class SettingsObserver: NSObject
{
    /// Reference to what we're observering.
    let _Settings = UserDefaults.standard
    
    /// Default constructor. Set up observers for each key in the setting list.
    override init()
    {
        super.init()
        for SettingKey in Setting.KeysInList()
        {
            _Settings.addObserver(self, forKeyPath: SettingKey, options: NSKeyValueObservingOptions.new, context: nil)
        }
    }
    
    /// Event handler for changed settings. Update the number of changes for the given setting.
    ///
    /// - Parameters:
    ///   - keyPath: The path of the setting that changed.
    ///   - object: Not used.
    ///   - change: Not used.
    ///   - context: Not used.
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?)
    {
        Setting.UpdateSettingChangeCount(Key: keyPath!)
    }
}
