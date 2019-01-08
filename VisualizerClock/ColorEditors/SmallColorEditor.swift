//
//  SmallBasicColorEditor.swift
//  Visualizer Clock
//
//  Created by Stuart Rankin on 11/12/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class SmallColorEditor: UIViewController, ColorEditing, ColorReceiver, SettingProtocol,
    UITableViewDelegate, UITableViewDataSource
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        ColorSample.layer.borderWidth = 0.5
        ColorSample.layer.borderColor = UIColor.black.cgColor
        ColorSample.layer.cornerRadius = 5.0
        
        ChannelTable.layer.borderWidth = 0.5
        ChannelTable.layer.borderColor = UIColor.black.cgColor
        ChannelTable.layer.cornerRadius = 5.0
        
        CreateChannelTable(ForColorSpace: ColorEditorColorSpaces.HSB)
    }
    
    func CreateChannelTable(ForColorSpace: ColorEditorColorSpaces)
    {
        ChannelDataTable = [(ColorEditorColorSpaces, Channels, CGFloat, CGFloat, CGFloat)]()
        switch ForColorSpace
        {
        case .RGB:
            ChannelDataTable.append((.RGB, .RGB_R, 0.0, 255.0, 128.0))
            ChannelDataTable.append((.RGB, .RGB_G, 0.0, 255.0, 128.0))
            ChannelDataTable.append((.RGB, .RGB_B, 0.0, 255.0, 128.0))
            
        case .RGBA:
            ChannelDataTable.append((.RGBA, .RGBA_R, 0.0, 255.0, 128.0))
            ChannelDataTable.append((.RGBA, .RGBA_G, 0.0, 255.0, 128.0))
            ChannelDataTable.append((.RGBA, .RGBA_B, 0.0, 255.0, 128.0))
            ChannelDataTable.append((.RGBA, .RGBA_A, 0.0, 255.0, 255.0))
            
        case .HSB:
            ChannelDataTable.append((.HSB, .HSB_H, 0.0, 359.0, 180.0))
            ChannelDataTable.append((.HSB, .HSB_S, 0.0, 1.0, 1.0))
            ChannelDataTable.append((.HSB, .HSB_B, 0.0, 1.0, 1.0))
            
        case .CMYK:
            ChannelDataTable.append((.CMYK, .CMYK_C, 0.5, 0.0, 1.0))
            ChannelDataTable.append((.CMYK, .CMYK_M, 0.5, 0.0, 1.0))
            ChannelDataTable.append((.CMYK, .CMYK_Y, 0.5, 0.0, 1.0))
            ChannelDataTable.append((.CMYK, .CMYK_K, 0.5, 0.0, 1.0))
        }
        
        ChannelTable.reloadData()
    }
    
    var ChannelDataTable: [(ColorEditorColorSpaces, Channels, CGFloat, CGFloat, CGFloat)]!
    
    func ColorChanged(NewColor: UIColor, DidChange: Bool, Tag: String?)
    {
    }
    
    func SourceColor(_ Color: UIColor)
    {
    }
    
    func TitleForEditor(_ NewTitle: String)
    {
    }
    
    func ColorSpace(_ ToColorSpace: ColorEditorColorSpaces)
    {
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return SmallChannelCell.CellHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let Cell = SmallChannelCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "SmallColor",
                                    CellChannel: ChannelDataTable[indexPath.row].1)
        Cell.SetChannelData(NewValue: Double(ChannelDataTable[indexPath.row].4), IsNormalized: false)
        Cell.delegate = self
        return Cell
    }
    @IBOutlet weak var ColorSample: UIView!
    
    @IBOutlet weak var ColorName: UILabel!
    
    @IBOutlet weak var ChannelTable: UITableView!
    
    @IBOutlet weak var ColorSpaceSelector: UISegmentedControl!
    
    @IBAction func HandleColorSpaceChanged(_ sender: Any)
    {
    }
    
    @IBOutlet weak var NamedColorButton: UIButton!
    
    @IBAction func HandleNamedColorPressed(_ sender: Any)
    {
    }
    
    func DoSet(Key: String, Value: Any?)
    {
        switch Key
        {
        case "ChannelData":
             let ChangedRawData = Value as! String
             let Parts = ChangedRawData.split(separator: ",")
            if Parts.count != 2
            {
                return
            }
            let Channel = String(Parts[0])
            let Data = String(Parts[1])
            if let NewData = Double(Data)
            {
                NewChannelValue = CGFloat(NewData)
            }
            else
            {
                return
            }
            
        default:
            return
        }
    }
    
    var ChangedChannel: Channels = .RGB_R
    var NewChannelValue: CGFloat = 0.0
}
