//
//  SoundManager.swift
//  Visualizer Clock
//
//  Created by Stuart Rankin on 11/29/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class SoundManager
{
    public static func Initialize()
{
    
    }
    
    private static var _Muted: Bool = true
    public static var Muted: Bool
    {
        get
        {
            return _Muted
        }
        set
        {
            _Muted = newValue
        }
    }
    
    private static var _Volume: Int = 0
    public static var Volume: Int
    {
        get
        {
            return _Volume
        }
        set
        {
            _Volume = newValue
        }
    }
}
