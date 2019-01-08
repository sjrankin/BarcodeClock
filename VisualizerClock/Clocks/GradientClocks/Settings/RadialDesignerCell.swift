//
//  RadialDesignerCell.swift
//  Visualizer Clock
//
//  Created by Stuart Rankin on 11/5/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class RadialDesignerCell: UITableViewCell
{
    public static let CellHeight: CGFloat = 50.0
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    init(style Style: UITableViewCell.CellStyle, reuseIdentifier ReuseIdentifier: String?, IsSmall: Bool)
    {
        super.init(style: Style, reuseIdentifier: ReuseIdentifier)
        EditImage = UIImageView(image: UIImage(named: "ColorPencil"))
        EditImage.frame = CGRect(x: 10, y: 5, width: 32, height: 32)
        contentView.addSubview(EditImage)
        ColorSample = UIView()
        let ColorSampleWidth: CGFloat = IsSmall ? 100 : 180
        ColorSample.frame = CGRect(x: 50, y: 5, width: ColorSampleWidth, height: 35.0)
        ColorSample.layer.borderColor = UIColor.black.cgColor
        ColorSample.layer.borderWidth = 0.5
        ColorSample.layer.cornerRadius = 5.0
        contentView.addSubview(ColorSample)
        LocationText = UILabel()
        LocationText.font = UIFont(name: "Avenir-Black", size: 16.0)
        LocationText.frame = CGRect(x: ColorSampleWidth + ColorSample.frame.minX + 20.0, y: 5, width: 50, height: 40)
        contentView.addSubview(LocationText)
    }
    
    var ColorSample: UIView!
    var LocationText: UILabel!
    var EditImage: UIImageView!
    
    var Parent: RadialGradientEditor!
    
    public func SetData(_ CellParent: UIViewController, DisplayColor: UIColor, Location: CGFloat, Tag: Int)
    {
        self.tag = Tag
        Parent = CellParent as? RadialGradientEditor
        ColorSample.backgroundColor = DisplayColor
        LocationText.text = String(Utility.Round(Double(Location), ToPlaces: 2))
        PencilVisibility(IsVisible: false)
    }
    
    public func PencilVisibility(IsVisible: Bool)
    {
        if IsVisible
        {
            EditImage.image = UIImage(named: "ColorPencil")
        }
        else
        {
            EditImage.image = nil
        }
    }
    
    #if false
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
            PencilVisibility(IsVisible: true)
        }
        else
        {
            contentView.backgroundColor = UIColor.white
        }
    }
    
    func DeselectCell()
    {
        contentView.backgroundColor = UIColor.white
    }
    
    func SelectCell()
    {
        contentView.backgroundColor = UIColor.atomictangerine
    }
    #endif
}
