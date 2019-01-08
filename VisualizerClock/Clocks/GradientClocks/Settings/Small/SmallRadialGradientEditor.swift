//
//  SmallRadialGradientEditor.swift
//  Visualizer Clock
//
//  Created by Stuart Rankin on 11/12/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class SmallRadialGradientEditor: UIViewController, UITableViewDelegate, UITableViewDataSource, SettingProtocol
{
    var CallerDelegate: SettingProtocol?
    var Parent: RadialGradientSettingsNav!
    var ThisClockID: UUID? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        Parent = parent as? RadialGradientSettingsNav
        if Parent == nil
        {
            fatalError("Unable to retrieve parent from RadialGradientSettingsNav.")
        }
        MainDelegate = Parent.MainDelegate
        ThisClockID = Clocks.GetActualID(PanelActions.SwitchToRadialColors)
        if ThisClockID == nil
        {
            fatalError("Unable to get ID of the radial colors clock: \(Clocks.ClockIDMap[PanelActions.SwitchToRadialColors]!)")
        }
        
        RadialSample.layer.borderColor = UIColor.black.cgColor
        RadialSample.layer.borderWidth = 0.5
        RadialSample.layer.cornerRadius = 5.0
        RadialSample.backgroundColor = UIColor.black
        
        GradientStopTable.layer.borderColor = UIColor.black.cgColor
        GradientStopTable.layer.borderWidth = 0.5
        GradientStopTable.layer.cornerRadius = 5.0
        
        GradientStopTable.delegate = self
        GradientStopTable.dataSource = self
        
        CurrentIndex = 0
        PopulateUIFrom(Raw)
        ShowSample(Raw)
        GradientStopTable.reloadData()
    }
    
    private weak var _MainDelegate: MainUIProtocol? = nil
    weak var MainDelegate: MainUIProtocol?
        {
        get
        {
            return _MainDelegate
        }
        set
        {
            _MainDelegate = newValue
        }
    }
    
    var Raw: String = ""
    
    func DoSet(Key: String, Value: Any?)
    {
        switch Key
        {
        case "RawDescription":
            //Description from the parent navigation controller.
            Raw = Value as! String
            
        case "Color":
            //Color from the gradient stop color editor.
            break
            
        case "Location":
            //Location from the gradient stop color editor.
            break
            
        default:
            return
        }
    }
    
    func PopulateUIFrom(_ Raw: String)
    {
        print("PopulateUIFrom(\(Raw)")
        if let Parsed = RadialGradientDescriptor.ParseRawColorNode(Raw)
        {
            ColorList = Parsed.3
        }
        GradientStopTable.reloadData()
    }
    
    var ColorList: [(Double, UIColor, Bool, UUID)]!
    
    var CurrentIndex: Int = 0
    var GradientSample: RadialGradientDescriptor!
    
    var SelectCell: Int? = 0
    
    func ShowSample(_ Raw: String)
    {
        do
        {
            //Need to do some contortions to calculate the center of an arbitrarily-placed UIView.
            let X = ((RadialSample.frame.width - RadialSample.frame.minX) / 2.0) - (RadialSample.frame.minX / 2.0)
            let Y = (RadialSample.frame.height / 2.0) + (RadialSample.frame.minY / 1.0)
            let Center = CGPoint(x: X, y: Y)
            print("ShowSample: X=\(X), Y=\(Y), Frame: \(RadialSample.frame), Bounds: \(RadialSample.bounds)")
            GradientSample = try RadialGradientDescriptor(Frame: RadialSample.frame, Bounds: RadialSample.bounds,
                                                          Location: Center, Description: Raw,
                                                          OuterAlphaValue: 0.0, AlphaDistance: 0.05)
        }
        catch
        {
            print("Error returned by RadialGradientDescriptor initializer.")
            return
        }
        RadialSample.layer.addSublayer(GradientSample)
    }
    
    @IBOutlet weak var GradientStopTable: UITableView!
    
    @IBAction func HandleSizeSelected(_ sender: Any)
    {
    }
    
    @IBOutlet weak var SizeSelector: UISegmentedControl!
    
    @IBOutlet weak var RadialSample: UIView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return ColorList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let Cell = RadialDesignerCell(style: UITableViewCell.CellStyle.default,
                                      reuseIdentifier: "SmallGradientStop",
                                      IsSmall: true)
        Cell.SetData(self, DisplayColor: ColorList[indexPath.row].1, Location: CGFloat(ColorList[indexPath.row].0), Tag: indexPath.row)
        if let DoSelectCell = SelectCell
        {
            if  DoSelectCell == indexPath.row
            {
                SelectCell = nil
                tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            }
        }
        if ColorList[indexPath.row].2
        {
//            Cell.SelectCell()
        }
        else
        {
//            Cell.DeselectCell()
        }
        return Cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        for Index in 0 ..< ColorList.count
        {
            let IsSelected = Index == indexPath.row
            ColorList[Index] = (ColorList[Index].0, ColorList[Index].1, IsSelected, ColorList[Index].3)
        }
        PreviouslySelectedCell = CurrentIndex
        CurrentIndex = indexPath.row
        performSegue(withIdentifier: "ToGradientStopEditor", sender: self)
    }
    
    var PreviouslySelectedCell: Int = -1
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        switch segue.identifier
        {
        case "ToGradientStopEditor":
            let Dest = segue.destination as? SmallGradientStopEditor
            Dest?.DoSet(Key: "Color", Value: ColorList[CurrentIndex].1)
            Dest?.DoSet(Key: "Location", Value: ColorList[CurrentIndex].0)
            
        default:
            break
        }
        
        super.prepare(for: segue, sender: self)
    }
    
    @IBAction func HandleAddGradientStop(_ sender: Any)
    {
        var AddAt: Int = 0
        var ColorOffset: Double = 0.0
        if CurrentIndex > -1
        {
            AddAt = CurrentIndex
            ColorOffset = ColorList[CurrentIndex].0
        }
        ColorList.insert((ColorOffset,UIColor.white,false, UUID()), at: AddAt)
        GradientStopTable.reloadData()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == .delete
        {
            ColorList.remove(at: indexPath.row)
            GradientStopTable.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle
    {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
    {
        var ValStorage = [Double]()
        for (Val, _, _, _) in ColorList
        {
            ValStorage.append(Val)
        }
        
        ColorList.rearrange(From: sourceIndexPath.row, To: destinationIndexPath.row)
        
        var Index = 0
        for Val in ValStorage
        {
            AssignNewLocation(To: Index, NewLocation: Val)
            Index = Index + 1
        }
        
        GradientStopTable.reloadData()
    }
    
    func AssignNewLocation(To: Int, NewLocation: Double)
    {
        ColorList[To] = (NewLocation, ColorList[To].1, ColorList[To].2, ColorList[To].3)
    }
    
    override func setEditing(_ editing: Bool, animated: Bool)
    {
        super.setEditing(editing, animated: animated)
        GradientStopTable.isEditing = editing
    }
    
    @IBAction func HandleEditGradientStopList(_ sender: Any)
    {
        EditingColorList.toggle()
        if EditingColorList
        {
            EditListButton.title = "Done"
            //            EditListButton.setTitle("Done", for: .normal)
        }
        else
        {
            EditListButton.title = "Edit List"
            //            EditListButton.setTitle("Edit", for: .normal)
        }
        setEditing(EditingColorList, animated: true)
    }
    
    var EditingColorList: Bool = false
    
    @IBOutlet weak var EditListButton: UIBarButtonItem!
    
    @IBAction func HandleReverseGradientStopList(_ sender: Any)
    {
        var Hold = [Double]()
        for Color in ColorList
        {
            Hold.append(Color.0)
        }
        ColorList.reverse()
        for Index in 0 ..< ColorList.count
        {
            ColorList[Index] = (Hold[Index], ColorList[Index].1, ColorList[Index].2, ColorList[Index].3)
        }
        GradientStopTable.reloadData()
    }
}
