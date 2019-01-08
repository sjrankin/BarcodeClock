//
//  SmallChannelCell.swift
//  Visualizer Clock
//
//  Created by Stuart Rankin on 11/12/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

//https://stackoverflow.com/questions/30009788/in-swift-is-it-possible-to-convert-a-string-to-an-enum
enum Channels: String, CaseIterable
{
    case RGB_R = "rgbr"
    case RGB_G = "rgbg"
    case RGB_B = "rgbb"
    case RGBA_R = "rgbar"
    case RGBA_G = "rgbag"
    case RGBA_B = "rgbab"
    case RGBA_A = "rgbaa"
    case HSB_H = "hsbh"
    case HSB_S = "hsbs"
    case HSB_B = "hsbb"
    case CMYK_C = "cmykc"
    case CMYK_M = "cmykm"
    case CMYK_Y = "cmyky"
    case CMYK_K = "cmykk"
    
    static func WithLabel(_ Label: String) -> Channels?
    {
        return self.allCases.first{"\($0)" == Label}
    }
}

class SmallChannelCell: UITableViewCell
{
    public static var CellHeight: CGFloat = 50.0
    
    public var delegate: SettingProtocol?
    
    public var ChannelNames =
        [
            Channels.RGB_R: "Red",
            Channels.RGB_G: "Green",
            Channels.RGB_B: "Blue",
            Channels.RGBA_R: "Red",
            Channels.RGBA_G: "Green",
            Channels.RGBA_B: "Blue",
            Channels.RGBA_A: "Alpha",
            Channels.HSB_H: "Hue",
            Channels.HSB_S: "Saturation",
            Channels.HSB_B: "Brightness",
            Channels.CMYK_C: "Cyan",
            Channels.CMYK_M: "Magenta",
            Channels.CMYK_Y: "Yellow",
            Channels.CMYK_K: "Black"
    ]
    
    public var ChannelRanges: [Channels: (CGFloat, CGFloat)] =
        [
            Channels.RGB_R: (0, 255),
            Channels.RGB_G: (0, 255),
            Channels.RGB_B: (0, 255),
            Channels.RGBA_R: (0, 255),
            Channels.RGBA_G: (0, 255),
            Channels.RGBA_B: (0, 255),
            Channels.RGBA_A: (0, 255),
            Channels.HSB_H: (0, 359),
            Channels.HSB_S: (0, 1),
            Channels.HSB_B: (0, 1),
            Channels.CMYK_C: (0, 1),
            Channels.CMYK_M: (0, 1),
            Channels.CMYK_Y: (0, 1),
            Channels.CMYK_K: (0, 1),
            ]
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    init(style Style: UITableViewCell.CellStyle, reuseIdentifier ReuseIdentifier: String?,
         CellChannel: Channels)
    {
        super.init(style: Style, reuseIdentifier: ReuseIdentifier)
        ChannelName = UILabel()
        ChannelName.frame = CGRect(x: 10, y: 5, width: 90, height: 40)
        ChannelName.text = ChannelNames[CellChannel]
        ChannelName.font = UIFont.systemFont(ofSize: 16.0)
        contentView.addSubview(ChannelName)
        ChannelSlider = UISlider()
        ChannelSlider.frame = CGRect(x: 115, y: 5, width: 111, height: 40)
        ChannelSlider.minimumValue = 0
        ChannelSlider.maximumValue = 1000
        ChannelSlider.addTarget(self, action: #selector(HandleSlider), for: .primaryActionTriggered)
        contentView.addSubview(ChannelSlider)
        ChannelBox = UITextField()
        ChannelBox.frame = CGRect(x: 235, y: 6, width: 65, height: 30)
        ChannelBox.text = ""
        ChannelBox.font = UIFont.systemFont(ofSize: 16.0)
        ChannelBox.addTarget(self, action: #selector(HandleTextBox), for: .primaryActionTriggered)
    }
    
    var ChannelName: UILabel!
    var ChannelSlider: UISlider!
    var ChannelBox: UITextField!
    
    public var Channel: Channels = Channels.RGB_R
    
    @objc func HandleTextBox(sender: UITextField!)
    {
        
    }
    
    @objc func HandleSlider(sender: UISlider!)
    {
        
    }
    
    func UpdateParent(NewValue: CGFloat)
    {
        let Raw = "\(Channel),\(NewValue)"
        delegate?.DoSet(Key: "ChannelData", Value: Raw)
    }
    
    func SetChannelData(NewValue: Double, IsNormalized: Bool)
    {
        let RangeLow = ChannelRanges[Channel]!.0
        let RangeHigh = ChannelRanges[Channel]!.1
        var Value: CGFloat = CGFloat(NewValue)
        if Value < RangeLow
        {
            Value = RangeLow
        }
        if Value > RangeHigh
        {
            Value = RangeHigh
        }
        
    }
}
