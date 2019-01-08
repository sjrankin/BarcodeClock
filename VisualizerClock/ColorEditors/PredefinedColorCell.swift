//
//  PredefinedColorCell.swift
//  Visualizer Clock
//
//  Created by Stuart Rankin on 11/6/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class PredefinedColorCell: UITableViewCell
{
    public enum ColorCellSizes
    {
        case Small
        case Medium
        case Large
    }
    
    public static let CellHeight =
        [
            ColorCellSizes.Small: 40.0,
            ColorCellSizes.Medium: 70.0,
            ColorCellSizes.Large: 75.0
    ]
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    func GetSampleHeight(_ Size: ColorCellSizes) -> CGFloat
    {
        switch Size
        {
        case .Large:
            return 45.0
            
        case .Medium:
            return 50.0
            
        case .Small:
            return 30.0
        }
    }
    
    init(style Style: UITableViewCell.CellStyle, reuseIdentifier ReuseIdentifier: String?, CellSize: ColorCellSizes)
    {
        super.init(style: Style, reuseIdentifier: ReuseIdentifier)
        _CurrentCellSize = CellSize
        switch CellSize
        {
        case .Small:
            ColorSample = UIView()
            ColorSample.frame = CGRect(x: 10, y: 7, width: 100, height: GetSampleHeight(CellSize))
            ColorSample.layer.borderColor = UIColor.black.cgColor
            ColorSample.layer.borderWidth = 0.5
            ColorSample.layer.cornerRadius = 5.0
            contentView.addSubview(ColorSample)
            ColorNameLabel = UILabel()
            ColorNameLabel.font = UIFont(name: "Avenir-Book", size: 17.0)
            ColorNameLabel.frame = CGRect(x: 120, y: 5, width: 220, height: 30)
            contentView.addSubview(ColorNameLabel)
            
        case .Medium:
            ColorSample = UIView()
            ColorSample.frame = CGRect(x: 10, y: 7, width: 160, height: GetSampleHeight(CellSize))
            ColorSample.layer.borderColor = UIColor.black.cgColor
            ColorSample.layer.borderWidth = 0.5
            ColorSample.layer.cornerRadius = 5.0
            contentView.addSubview(ColorSample)
            ColorNameLabel = UILabel()
            ColorNameLabel.font = UIFont(name: "Avenir-Black", size: 18.0)
            ColorNameLabel.frame = CGRect(x: 180, y: 5, width: 220, height: 30)
            contentView.addSubview(ColorNameLabel)
            AltColorNameLabel = UILabel()
            AltColorNameLabel.font = UIFont(name: "Avenir-Book", size: 16.0)
            AltColorNameLabel.frame = CGRect(x: 180, y: 30, width: 160, height: 30)
            //AltColorNameLabel.layer.borderColor = UIColor.green.cgColor
            //AltColorNameLabel.layer.borderWidth = 0.5
            contentView.addSubview(AltColorNameLabel)
            
        case .Large:
            ColorSample = UIView()
            ColorSample.frame = CGRect(x: 10, y: 7, width: 160, height: GetSampleHeight(CellSize))
            ColorSample.layer.borderColor = UIColor.black.cgColor
            ColorSample.layer.borderWidth = 0.5
            ColorSample.layer.cornerRadius = 5.0
            contentView.addSubview(ColorSample)
            ColorNameLabel = UILabel()
            ColorNameLabel.font = UIFont(name: "Avenir-Black", size: 18.0)
            ColorNameLabel.frame = CGRect(x: 180, y: 5, width: 220, height: 30)
            contentView.addSubview(ColorNameLabel)
            AltColorNameLabel = UILabel()
            AltColorNameLabel.font = UIFont(name: "Avenir-Book", size: 16.0)
            AltColorNameLabel.frame = CGRect(x: 180, y: 30, width: 220, height: 30)
            //AltColorNameLabel.layer.borderColor = UIColor.green.cgColor
            //AltColorNameLabel.layer.borderWidth = 0.5
            contentView.addSubview(AltColorNameLabel)
            PaletteNameLabel = UILabel()
            let PalY = GetSampleHeight(CellSize) + ColorSample.frame.minY
            PaletteNameLabel.font = UIFont(name: "Avenir-Book", size: 12.0)
            PaletteNameLabel.frame = CGRect(x: 10, y: PalY, width: 250, height: 20)
            PaletteNameLabel.textAlignment = .left
            //PaletteNameLabel.layer.borderColor = UIColor.red.cgColor
            //PaletteNameLabel.layer.borderWidth = 0.5
            contentView.addSubview(PaletteNameLabel)
        }
    }
    
    private var _CurrentCellSize: ColorCellSizes = .Large
    public var CurrentCellSize: ColorCellSizes
    {
        get
        {
            return _CurrentCellSize
        }
    }
    
    var ColorSample: UIView!
    var ColorNameLabel: UILabel!
    var AltColorNameLabel: UILabel!
    var PaletteNameLabel: UILabel!
    
    /// Populate the cell with data - in this case a color.
    ///
    /// - Parameters:
    ///   - DisplayColor: The color to display.
    ///   - ColorName: The name of the color.
    ///   - AltName: The alternative name of the color.
    ///   - PaletteName: The name of the palette.
    ///   - ItemID: The ID of the color.
    ///   - Tag: Tag value - not used by this class.
    ///   - SortedName: Which name was used to sort (eg, standard name or alternative name).
    ///   - HighlightSortedName: If true, the name used to sort the color will be highlighted.
    ///   - SortedNameColor: The color to use to highlight the sorted name.
    public func SetData(DisplayColor: UIColor, ColorName: String, AltName: String, PaletteName: String, ItemID: UUID, Tag: Int,
                        SortedName: PredefinedColor.SortedNames = PredefinedColor.SortedNames.PrimaryName, HighlightSortedName: Bool = false,
                        SortedNameColor: UIColor = UIColor.blue)
    {
        self.tag = Tag
        CellID = ItemID
        ColorSample.backgroundColor = DisplayColor
        ColorNameLabel.text = ColorName
        if CurrentCellSize == .Large
        {
            PaletteNameLabel.text = PaletteName
            AltColorNameLabel.text = AltName.isEmpty ? ColorName : AltName
        }
        if CurrentCellSize == .Medium
        {
            AltColorNameLabel.text = AltName
        }
        if HighlightSortedName
        {
            switch SortedName
            {
            case PredefinedColor.SortedNames.PrimaryName:
                ColorNameLabel.textColor = SortedNameColor
                
            case PredefinedColor.SortedNames.AlternativeName:
                AltColorNameLabel.textColor = SortedNameColor
            }
        }
    }
    
    private var CellID: UUID = UUID()
    public var ID: UUID
    {
        return CellID
    }
    
    /// Overriding setSelected lets us prevent iOS from ruining all of the colors of the various components with the
    /// global cell selection color.
    ///
    /// - Note: https://medium.com/@imho_ios/why-uitableviewcell-highlight-and-selection-styling-are-such-a-mystery-1ae1599e660a
    ///
    /// - Parameters:
    ///   - selected: Determines if the cell is selected or not.
    ///   - animated: Not used.
    override func setSelected(_ selected: Bool, animated: Bool)
    {
        if selected
        {
            contentView.backgroundColor = UIColor.atomictangerine
        }
        else
        {
            contentView.backgroundColor = UIColor.white
        }
    }
}
