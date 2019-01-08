//
//  ColorEditorManager.swift
//  Visualizer Clock
//
//  Created by Stuart Rankin on 12/15/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Helper class to run color editor view controllers. Automatically selects the proper
/// view controller/storyboard depending on the size of the device.
class ColorEditorManager
{
    static let _Settings = UserDefaults.standard
    
    public static func Show(Segue: UIStoryboardSegue,
                            Receiver: ColorReceiver,
                            Title: String = "Color Editor",
                            InitialColor: UIColor = UIColor.black,
                            ColorSpace: ColorEditorColorSpaces = .HSB,
                            Tag: String? = nil,
                            SettingString: String = "") -> UIStoryboardSegue
    {
        if _Settings.bool(forKey: Setting.Key.Device.IsSmallDevice)
        {
            #if DEBUG
            print("Initializing color editor for small-sized device.")
            let NewSegueName = Segue.identifier! + "_SMALL"
            let NewSegue = UIStoryboardSegue(identifier: NewSegueName,
                                             source: Receiver as! UIViewController,
                                             destination: SmallBasicColorEditor() as UIViewController)
            let Dest = NewSegue.destination as? SmallBasicColorEditor
            Dest?.CallerDelegate = Receiver
            Dest?.InitialTitle = Title
            Dest?.InitialColorSpace = ColorSpace
            Dest?.InitialColor = InitialColor
            Dest?.DelegateTag = Tag
            Dest?.ColorSettingsString = SettingString
            return NewSegue
            #endif
        }
        else
        {
            #if DEBUG
            print("Initializing color editor for medium-sized device.")
            #endif
            let Dest = Segue.destination as? BasicColorEditor
            Dest?.CallerDelegate = Receiver
            Dest?.InitialTitle = Title
            Dest?.InitialColorSpace = ColorSpace
            Dest?.InitialColor = InitialColor
            Dest?.DelegateTag = Tag
            Dest?.ColorSettingsString = SettingString
            return Segue
        }
    }
}
