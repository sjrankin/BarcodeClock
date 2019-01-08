//
//  PredefinedColorViewer.swift
//  Visualizer Clock
//
//  Created by Stuart Rankin on 11/6/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class PredefinedColorViewer: UIViewController, UITableViewDelegate, UITableViewDataSource, ColorReceiver
{
    let _Settings = UserDefaults.standard
    
    var delegate: ColorReceiver?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        ScreenWidth = UIScreen.main.bounds.size.width
        ColorSample.backgroundColor = UIColor.white
        ColorSample.layer.borderColor = UIColor.black.cgColor
        ColorSample.layer.borderWidth = 0.5
        ColorSample.layer.cornerRadius = 5.0
        ColorNameLabel.text = ""
        PreviousSortOrder = 0
        CurrentColors = PredefinedColors.ColorsInOrder(.Name)
        ColorTable.delegate = self
        ColorTable.dataSource = self
        ColorDetailLabel.text = ""
        IsSmall = UIScreen.main.bounds.size.width <= 320.0
        if IsSmall
        {
            //SizeButton.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.clear], for: UIControl.State.disabled)
            SizeButton.isEnabled = false
        }
    }
    
    public var SourceColorSpace: ColorEditorColorSpaces = .RGB
    
    var IsSmall: Bool = false
    
    var ScreenWidth: CGFloat = 0.0
    
    override func viewWillDisappear(_ animated: Bool)
    {
        if !Canceled
        {
            if SelectedColor != nil
            {
                delegate?.ColorChanged(NewColor: (SelectedColor?.Color)!, DidChange: true,
                                       Tag: (SelectedColor?.ColorName))
            }
            else
            {
                delegate?.ColorChanged(NewColor: UIColor.clear, DidChange: false, Tag: nil)
            }
        }
        super.viewWillDisappear(animated)
    }
    
    var Canceled: Bool = false
    
    var CurrentColors = [PredefinedColorGroup]()
    
    var PreviousSortOrder = 0
    
    @IBOutlet weak var SortButton: UIBarButtonItem!
    
    @IBAction func HandleSortButton(_ sender: Any)
    {
        let SortAlert = UIAlertController(title: "Sort Colors",
                                          message: "Sort the colors.",
                                          preferredStyle: UIAlertController.Style.alert)
        SortAlert.addAction(UIAlertAction(title: "By Name", style: UIAlertAction.Style.default, handler: HandleSortChange))
        SortAlert.addAction(UIAlertAction(title: "By Hue", style: UIAlertAction.Style.default, handler: HandleSortChange))
        SortAlert.addAction(UIAlertAction(title: "By Brightness", style: UIAlertAction.Style.default, handler: HandleSortChange))
        SortAlert.addAction(UIAlertAction(title: "By Palette Name", style: UIAlertAction.Style.default, handler: HandleSortChange))
        SortAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        present(SortAlert, animated: true)
    }
    
    @objc func HandleSortChange(Action: UIAlertAction!)
    {
        let Title: String = Action.title!
        switch Title
        {
        case "By Name":
            CurrentColors = PredefinedColors.ColorsInOrder(.Name)
            //SortButton.title = "\u{2699}"
            SortButton.title = "Sort by Name"
            CurrentSort = .Name
            
        case "By Hue":
            CurrentColors = PredefinedColors.ColorsInOrder(.Hue)
            SortButton.title = "Sort by Hue"
            CurrentSort = .Hue
            
        case "By Brightness":
            CurrentColors = PredefinedColors.ColorsInOrder(.Brightness)
            SortButton.title = "Sort by Brightness"
            CurrentSort = .Brightness
            
        case "By Palette Name":
            CurrentColors = PredefinedColors.ColorsInOrder(.Palette)
            SortButton.title = "Sort by Palette"
            CurrentSort = .Palette
            
        default:
            return
        }
        
        ColorTable.reloadData()
    }
    
    var CurrentSort = PredefinedColors.ColorOrders.Name
    
    @IBOutlet weak var ColorSample: UIView!
    
    @IBOutlet weak var ColorNameLabel: UILabel!
    
    @IBOutlet weak var ColorTable: UITableView!
    
    @IBAction func HandleCancelButton(_ sender: Any)
    {
        Canceled = true
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func HandleSizeButton(_ sender: Any)
    {
        let SizeAlert = UIAlertController(title: "Color View Size", message: "Set the size of the color list.",
                                          preferredStyle: UIAlertController.Style.alert)
        SizeAlert.addAction(UIAlertAction(title: "Large", style: UIAlertAction.Style.default, handler: HandleSizeChange))
        SizeAlert.addAction(UIAlertAction(title: "Medium", style: UIAlertAction.Style.default, handler: HandleSizeChange))
        SizeAlert.addAction(UIAlertAction(title: "Small", style: UIAlertAction.Style.default, handler: HandleSizeChange))
        SizeAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        present(SizeAlert, animated: true)
    }
    
    var CurrentCellSize: PredefinedColorCell.ColorCellSizes = .Large
    
    @objc func HandleSizeChange(Action: UIAlertAction!)
    {
        let Title: String = Action.title!
        switch Title
        {
        case "Large":
            CurrentCellSize = .Large
            
        case "Medium":
            CurrentCellSize = .Medium
            
        case "Small":
            CurrentCellSize = .Small
            
        default:
            return
        }
        
        ColorTable.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return CGFloat(PredefinedColorCell.CellHeight[CurrentCellSize]!)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return CurrentColors[section].ColorCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if ScreenWidth < 330
        {
            //Small screens are restricted to small cell sizes.
            CurrentCellSize = .Small
        }
        let Cell = PredefinedColorCell(style: UITableViewCell.CellStyle.default,
                                       reuseIdentifier: "PredefinedColorCell",
                                       CellSize: CurrentCellSize)
        let Group = CurrentColors[indexPath.section]
        let PredefinedColor = Group.GroupColors[indexPath.row]
        Cell.SetData(DisplayColor: PredefinedColor.Color, ColorName: PredefinedColor.ColorName,
                     AltName: PredefinedColor.AlternativeName, PaletteName: PredefinedColor.Palette,
                     ItemID: PredefinedColor.ID, Tag: 0)
        return Cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection TitleForHeaderInSection: Int) -> String?
    {
        var Final = ""
        let Group = CurrentColors[TitleForHeaderInSection]
        if CurrentSort == .Hue
        {
            Final = Group.GroupName
        }
        else
        {
            Final = Group.GroupName + "  " + Group.GroupSubTitle
        }
        return Final
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return CurrentColors.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let Cell = ColorTable.cellForRow(at: indexPath) as! PredefinedColorCell
        SelectedColor = PredefinedColors.ColorByID(Cell.ID)
        ColorSample.backgroundColor = SelectedColor!.Color
        ColorNameLabel.text = SelectedColor!.ColorName
        ShowDetails(SelectedColor!)
    }
    
    func ShowDetails(_ TheColor: PredefinedColor)
    {
        #if true
        var Final = ""
        switch SourceColorSpace
        {
        case .CMYK:
            Final = "CMYK\(UIColor.PrettyPrint(TheColor.Color, .CMYK))"
            
        case .HSB:
            Final = "HSB\(UIColor.PrettyPrint(TheColor.Color, .HSB))"
            
        case .RGB:
            Final = "RGB\(UIColor.PrettyPrint(TheColor.Color, .RGB))"
            
        case .RGBA:
            Final = "CMYK\(UIColor.PrettyPrint(TheColor.Color, .RGBA))"
        }
        ColorDetailLabel.text = Final
        #else
        ColorDetailLabel.text = ""
        let RGBString = "RGB\(UIColor.PrettyPrint(TheColor.Color, .RGB))"
        let HSBString = "HSB\(UIColor.PrettyPrint(TheColor.Color, .HSB))"
        ColorDetailLabel.text = RGBString + ", " + HSBString
        #endif
    }
    
    var SelectedColor: PredefinedColor? = nil
    
    @IBAction func HandleSearchButtonPressed(_ sender: Any)
    {
        performSegue(withIdentifier: "SearchForColor", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        switch segue.identifier
        {
        case "SearchForColor":
            let Dest = segue.destination as? ColorNameSearcher
            Dest?.delegate = self
            Dest?.ReturnTag = "ColorSearch"
            
        default:
            break
        }
        
        super.prepare(for: segue, sender: self)
    }
    
    func ColorChanged(NewColor: UIColor, DidChange: Bool, Tag: String?)
    {
        
    }
    
    @IBOutlet weak var SearchButton: UIBarButtonItem!
    @IBOutlet weak var SizeButton: UIBarButtonItem!
    @IBOutlet weak var ColorDetailLabel: UILabel!
}
