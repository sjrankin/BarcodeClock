//
//  LeftSideTableCell.swift
//  Visualizer Clock
//
//  Created by Stuart Rankin on 9/16/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Implementation of a table cell for items in the left-side panel table view.
class LeftSideTableCell: UITableViewCell
{
    /// The height of each cell.
    public static let CellHeight: CGFloat = 50.0
    private let SettingsSize: Int = 32
    private var ButtonY: CGFloat = 5.0
    
    /// Required initializer.
    ///
    /// - Parameter aDecoder: See iOS documentation.
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        ButtonY = (LeftSideTableCell.CellHeight / 2.0) - (CGFloat(SettingsSize) / 2.0) - 2.0
    }
    
    /// Initializer.
    ///
    /// - Parameters:
    ///   - Style: Cell style.
    ///   - ReuseIdentifier: Reuse identifier.
    override init(style Style: UITableViewCell.CellStyle, reuseIdentifier ReuseIdentifier: String?)
    {
        super.init(style: Style, reuseIdentifier: ReuseIdentifier)
        ButtonY = (LeftSideTableCell.CellHeight / 2.0) - (CGFloat(SettingsSize) / 2.0) - 2.0
        self.selectionStyle = .none
        CellTitle = UILabel()
        CellTitle.frame = CGRect(x: 24, y: 0, width: 250, height: 45)
        CellTitle.font = UIFont.systemFont(ofSize: 17.0)
        contentView.addSubview(CellTitle)
        SettingButton = UIButton()
        SettingButton.setBackgroundImage(UIImage(named: "SettingsIcon"), for: UIControl.State.normal)
        SettingButton.frame = CGRect(x: 100, y: Int(ButtonY), width: SettingsSize, height: SettingsSize)
        SettingButton.isUserInteractionEnabled = false
        SettingButton.alpha = 0.0
        SettingButton.addTarget(self, action: #selector(HandleSettings), for: .touchUpInside)
        contentView.addSubview(SettingButton)
    }
    
    @objc func HandleSettings(sender: UIButton!)
    {
        delegate?.RunSettingsForClock(ID: CellID!)
    }
    
    private var CellTitle: UILabel!
    private var SettingButton: UIButton!
    public weak var delegate: MainUIProtocol!
    
    /// Set cell data.
    ///
    /// - Parameter ClockID: ID of the clock (or action) the cell represents.
    /// - Parameter IncludeSettingButton: Determines if a setting button is included in the cell.
    public func SetData(Title: String, FullWidth: CGFloat, ClockID: UUID, IncludeSettingButton: Bool = true)
    {
        SomeID = ClockID
        CellWidth = FullWidth
        CellTitle.text = Title
        if Title == "Close"
        {
            CellTitle.textColor = UIColor.blue
        }
        if IncludeSettingButton
        {
            let ButtonX = FullWidth - 50.0
            SettingButton.frame = CGRect(x: ButtonX, y: ButtonY, width: CGFloat(SettingsSize), height: CGFloat(SettingsSize))
            SettingButton.alpha = 1.0
            SettingButton.isUserInteractionEnabled = true
        }
    }
    
    private var CellWidth: CGFloat = 0.0
    
    /// Get the ID of the clock (or action) previously (hopefully) set in SetData.
    public var CellID: UUID?
    {
        get
        {
            return SomeID
        }
    }
    
    /// Holds the ID.
    private var SomeID: UUID? = nil
    
    /// Determines if the passed ID has the same ID as was set earlier.
    ///
    /// - Parameter As: The ID to check against CellID.
    /// - Returns: True if the IDs are the same, false if not.
    public func HasSameID(As: UUID) -> Bool
    {
        if SomeID == nil
        {
            return false
        }
        return SomeID == As
    }
}
