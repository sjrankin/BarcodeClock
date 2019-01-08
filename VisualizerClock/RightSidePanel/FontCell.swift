//
//  FontCell.swift
//  Barcode Clock
//
//  Created by Stuart Rankin on 8/23/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class FontCell: UITableViewCell
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
        FontLabel = UILabel()
        FontLabel.frame = CGRect(x: 15, y: 10, width: 350, height: 30)
        FontLabel.font = UIFont.systemFont(ofSize: 18.0)
        contentView.addSubview(FontLabel)
    }
    
    var FontLabel: UILabel!
    
    public func SetData(DisplayName: String, FontName: String, IsSelected: Bool)
    {
        TheFontName = FontName
        FontLabel.text = DisplayName
        #if true
        SetSelectedState(IsSelected)
        #else
        if IsSelected
        {
            self.accessoryType = .checkmark
        }
        else
        {
            self.accessoryType = .none
        }
        #endif
    }
    
    var TheFontName: String!
    
    public func GetFontName() -> String
    {
        return TheFontName!
    }
    
    public func SetSelectedState(_ IsSelected: Bool)
    {
        isSelected = IsSelected
        if IsSelected
        {
            backgroundColor = UIColor.yellow
            print("Font \(TheFontName!) selected")
        }
        else
        {
            backgroundColor = UIColor.clear
            //print("Font \(TheFontName!) deselected")
        }
    }
}
