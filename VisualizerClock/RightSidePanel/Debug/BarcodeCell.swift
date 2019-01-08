//
//  BarcodeCell.swift
//  Barcode Clock
//
//  Created by Stuart Rankin on 9/11/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class BarcodeCell: UITableViewCell
{
    public static let CellHeight: CGFloat = 50.0
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    override init(style Style: UITableViewCell.CellStyle, reuseIdentifier ReuseIdentifier: String?)
    {
        super.init(style: Style, reuseIdentifier: ReuseIdentifier)
        self.selectionStyle = .none
        BarcodeLabel = UILabel()
        BarcodeLabel.frame = CGRect(x: 15, y: 10, width: 350, height: 30)
        BarcodeLabel.font = UIFont(name: "Avenir-Bold", size: 18.0)
        contentView.addSubview(BarcodeLabel)
        SettingsButton = UIButton()
        SettingsButton.setTitle("Settings", for: UIControl.State.normal)
        SettingsButton.frame = CGRect(x: 300, y: 10, width: 70, height: 40)
        SettingsButton.addTarget(self, action: #selector(HandleButtonPress), for: UIControl.Event.touchUpInside)
    }
    
    @objc func HandleButtonPress(_ Sender: Any)
    {
        
    }
    
    var BarcodeLabel: UILabel!
    var SettingsButton: UIButton!
    
    public func SetData(BarcodeName: String, BarcodeID: UUID, IsSelected: Bool)
    {
        ID = BarcodeID
        BarcodeLabel.text = BarcodeName
        SetSelectedState(IsSelected)
    }
    
    private var _ID: UUID = UUID()
    public var ID: UUID
    {
        get
        {
            return _ID
        }
        set
        {
            _ID = newValue
        }
    }
    
    public func SetSelectedState(_ IsSelected: Bool)
    {
        isSelected = IsSelected
        if (IsSelected)
        {
            backgroundColor = UIColor.yellow
        }
        else
        {
            backgroundColor = UIColor.clear
        }
    }
}
