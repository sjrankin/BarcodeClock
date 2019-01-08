//
//  OneDBarcodeNav.swift
//  Visualizer Clock
//
//  Created by Stuart Rankin on 12/23/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class OneDBarcodeNav: UINavigationController, ClockSettingsProtocol
{
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func FromClock(_ ClockType: PanelActions)
    {
        _ParentClock = ClockType
    }
    
    private var _MainDelegate: MainUIProtocol? = nil
    var MainDelegate: MainUIProtocol?
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
    
    private var _ParentClock: PanelActions? = nil
    public var ParentClock: PanelActions?
    {
        get
        {
            return _ParentClock
        }
    }
}
