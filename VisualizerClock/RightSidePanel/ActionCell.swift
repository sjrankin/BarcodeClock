//
//  ActionCell.swift
//  BarcodeTest
//
//  Created by Stuart Rankin on 8/16/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class ActionCell: UITableViewCell
{
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    public static let CellHeight: CGFloat = 45.0
    
    public var delegate: ActionPanel? = nil
    
    override init(style Style: UITableViewCell.CellStyle, reuseIdentifier ReuseIdentifier: String?)
    {
        super.init(style: Style, reuseIdentifier: ReuseIdentifier)
    }
    
    private var _CellAction: UserActions = .NoAction
    public var CellAction: UserActions
    {
        get
        {
            return _CellAction
        }
        set
        {
            _CellAction = newValue
            if _CellAction == .ClosePanel
            {
                self.accessoryType = .none
                self.textLabel!.textColor = UIColor.blue
            }
        }
    }
    
    /// Actions the user can request that another part of the program has to deal with.
    ///
    /// - NoAction: Do nothing.
    /// - RunSettings: Run the settings dialog.
    /// - CreateBarcode: Create a barcode.
    /// - ShowAbout: Show the About dialog.
    /// - ClosePanel: Close the right-side panel.
    /// - StartClock: Start the clock running. Valid only when compiled with the DEBUG switch.
    /// - StopClock: Stop the clock. Valid only when compiled with the DEBUG switch.
    /// - OpenDebug: Show the debug "dialog."
    enum UserActions
    {
        case NoAction
        case RunSettings
        case CreateBarcode
        case ShowAbout
        case ClosePanel
        #if DEBUG
        case StartClock
        case StopClock
        case OpenDebug
        #endif
    }
}
