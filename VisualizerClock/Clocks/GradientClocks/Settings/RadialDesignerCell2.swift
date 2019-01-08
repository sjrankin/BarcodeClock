//
//  RadialDesignerCell2.swift
//  Visualizer Clock
//
//  Created by Stuart Rankin on 1/3/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class RadialDesignerCell2: UITableViewCell
{
    public static let CellHeight: CGFloat = 100.0
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    weak var delegate: RadialGradientEditor? = nil
    var ColorSample: UIView!
    var LocationText: UILabel!
    var EditButton: UIButton!
    var LocationSlider: UISlider!
    var ColorID: UUID!
    var CurrentColor: UIColor!
    var Location: Double!
    var PercentLabel: UILabel!
    
    init(style Style: UITableViewCell.CellStyle, reuseIdentifier ReuseIdentifier: String?, ParentDelegate: RadialGradientEditor? = nil, IsSmall: Bool,
         GradientStopID: UUID)
    {
        super.init(style: Style, reuseIdentifier: ReuseIdentifier)
        delegate = ParentDelegate
        ColorID = GradientStopID
        
        ColorSample = UIView()
        let ColorSampleWidth: CGFloat = IsSmall ? 100 : 180
        ColorSample.frame = CGRect(x: 15, y: 10, width: ColorSampleWidth, height: 35.0)
        ColorSample.layer.borderColor = UIColor.black.cgColor
        ColorSample.layer.borderWidth = 0.5
        ColorSample.layer.cornerRadius = 5.0
        contentView.addSubview(ColorSample)
        
        EditButton = UIButton(type: .roundedRect)
        EditButton.frame = CGRect(x: ColorSample.frame.maxX + 30, y: 15, width: 60, height: 25)
        EditButton.setTitle("Edit", for: .normal)
        EditButton.titleLabel?.font = UIFont(name: "Avenir-Black", size: 16.0)
        EditButton.addTarget(self, action: #selector(HandleEditColorPressed), for: .touchUpInside)
        EditButton.contentHorizontalAlignment = .left
        contentView.addSubview(EditButton)
        
        LocationSlider = UISlider()
        LocationSlider.frame = CGRect(x: 15 + 20, y: ColorSample.frame.maxY + 10, width: ColorSampleWidth, height: 30)
        LocationSlider.addTarget(self, action: #selector(HandleNewSliderValue), for: .primaryActionTriggered)
        LocationSlider.minimumValue = 0.0
        LocationSlider.maximumValue = 1000.0
        contentView.addSubview(LocationSlider)
        
        PercentLabel = UILabel()
        let px: CGFloat = 15.0
        let py: CGFloat = CGFloat(ColorSample.frame.maxY + 10.0)
        PercentLabel.frame = CGRect(x: px, y: py, width: CGFloat(20.0), height: CGFloat(30.0))
        PercentLabel.text = "%"
        PercentLabel.textAlignment = .left
        PercentLabel.font = UIFont(name: "Avenir-Black", size: 16.0)
        contentView.addSubview(PercentLabel)
        
        LocationText = UILabel()
        LocationText.text = "0%"
        LocationText.textAlignment = .left
        LocationText.font = UIFont(name: "Avenir-Black", size: 16.0)
        LocationText.frame = CGRect(x: ColorSample.frame.maxX + 30, y: ColorSample.frame.maxY + 5, width: 60, height: 40)
        contentView.addSubview(LocationText)
    }
    
    @objc func HandleNewSliderValue(_ sender: Any?)
    {
        let Value = LocationSlider.value
        delegate?.NewLocationFor(ID: ColorID, NewLocation: Double(Value / 1000.0))
        UpdateLocationValue(Value / 1000.0)
    }
    
    @objc func HandleEditColorPressed(_ sender: Any?)
    {
        delegate?.GetNewColorFor(ID: ColorID, SourceColor: CurrentColor, Requester: self)
    }
    
    public var GradientStopID: UUID
    {
        get
        {
            return ColorID
        }
    }
    
    public var GradientStopColor: UIColor
    {
        get
        {
            return CurrentColor
        }
        set
        {
            CurrentColor = newValue
            ColorSample.backgroundColor = CurrentColor
        }
    }
    
    public var GradientStopLocation: Double
    {
        get
        {
            return Location
        }
        set
        {
            Location = newValue
            LocationSlider.value = Float(Location * 1000.0)
            UpdateLocationValue(Float(Location))
        }
    }
    
    func UpdateLocationValue(_ Value: Float)
    {
        let FinalValue = Utility.Round(Double(Value * 100.0), ToPlaces: 0)
        let Final = "\(FinalValue)%"
        LocationText.text = Final
    }
}
