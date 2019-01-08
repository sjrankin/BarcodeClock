//
//  RadialGradientEditor.swift
//  Visualizer Clock
//
//  Created by Stuart Rankin on 11/5/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class RadialGradientEditor: UIViewController, SettingProtocol, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate,
    ColorReceiver
{
    let _Settings = UserDefaults.standard
    var CallerDelegate: SettingProtocol?
    
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
        
        GroupBox2.backgroundColor = UIColor.clear
        GroupBox2.layer.borderWidth = 0.5
        GroupBox2.layer.borderColor = UIColor.darkGray.cgColor
        GroupBox2.layer.cornerRadius = 5
        
        RadialSample.layer.borderColor = UIColor.black.cgColor
        RadialSample.layer.borderWidth = 0.5
        RadialSample.layer.cornerRadius = 5.0
        
        ColorListTable.layer.borderColor = UIColor.black.cgColor
        ColorListTable.layer.borderWidth = 0.5
        ColorListTable.layer.cornerRadius = 5.0
        
        ColorListTable.delegate = self
        ColorListTable.dataSource = self
        
        CurrentIndex = 0
        PopulateUIFrom(Working)
        ShowSample(Working)
        ColorListTable.reloadData()
        
        Background = BackgroundServer(RadialSample)
        Background.UpdateBackgroundColors()
        BGTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(UpdateBG), userInfo: nil, repeats: true)
        
        //Create a keyboard button bar that contains a button that lets the user finish editing cleanly.
        if KeyboardBar == nil
        {
            KeyboardBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 50))
            KeyboardBar?.barStyle = .default
            let FlexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let KeyboardDoneButton = UIBarButtonItem(title: "Done", style: .plain, target: self,
                                                     action: #selector(KeyboardDoneButtonHandler))
            KeyboardBar?.sizeToFit()
            KeyboardBar?.items = [FlexSpace, KeyboardDoneButton]
        }
        RadialSizeTextBox.inputAccessoryView = KeyboardBar
    }
    
    /// Required for adding a keyboard button bar to keyboards.
    ///
    /// - Parameter textField: Not used.
    /// - Returns: Always returns true.
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
        return true
    }
    
    var KeyboardBar: UIToolbar?
    
    @objc func KeyboardDoneButtonHandler()
    {
        //        DoHandleColorLocationTextChanged()
        DoHandleRadialSizeTextChanged()
        view.endEditing(true)
    }
    
    var Background: BackgroundServer!
    var BGTimer: Timer!
    
    @objc func UpdateBG()
    {
        Background.UpdateBackgroundColors()
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
    
    var ThisClockID: UUID? = nil
    var Parent: RadialGradientSettingsNav!
    var SelectCell: Int? = 0
    
    var GradientSample: RadialGradientDescriptor!
    
    func ShowSample(_ Raw: String)
    {
        do
        {
            print("ShowSample(\(Raw)")
            //Need to do some contortions to calculate the center of an arbitrarily-placed UIView.
            let X = ((RadialSample.frame.width - RadialSample.frame.minX) / 2.0) - (RadialSample.frame.minX / 2.0)
            let Y = (RadialSample.frame.height / 2.0) + (RadialSample.frame.minY / 1.0)
            let Center = CGPoint(x: X, y: Y)
            GradientSample = try RadialGradientDescriptor(Frame: RadialSample.frame, Bounds: RadialSample.bounds,
                                                          Location: Center, Description: Raw,
                                                          OuterAlphaValue: 0.0, AlphaDistance: 0.05)
            GradientSample.name = "GradientSample"
        }
        catch
        {
            print("Error returned by RadialGradientDescriptor initializer.")
            return
        }
        //Remove all previous samples from the sample view. If we didn't do this, the sample view would
        //quickly get cluttered and visually very messy. It would also be a form of a memory leak.
        if RadialSample.layer.sublayers != nil
        {
            RadialSample.layer.sublayers!.forEach{if $0.name == "GradientSample"
            {
                $0.removeFromSuperlayer()
                }
            }
        }
        RadialSample.layer.addSublayer(GradientSample)
    }
    
    func PopulateUIFrom(_ Raw: String)
    {
        print("PopulateUIFrom(\(Raw))")
        if let Parsed = RadialGradientDescriptor.ParseRawColorNode(Raw)
        {
            ColorList = Parsed.3
            LastRadialValue = Float(Parsed.1)
            RadialSizeSlider.value = LastRadialValue * 10.0
        }
        ColorListTable.reloadData()
    }
    
    var ColorList: [(Double, UIColor, Bool, UUID)]!
    
    var Working: String = ""
    
    var SettingKey: String = ""
    
    func DoSet(Key: String, Value: Any?)
    {
        switch Key
        {
        case "Title":
            title = (Value as! String)
            
        case "RawDescription":
            Working = Value as! String
            
        case "SettingKey":
            SettingKey = Value as! String
            
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return RadialDesignerCell2.CellHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return ColorList.count
    }
    
    #if true
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let ID = ColorList[indexPath.row].3
        let Cell = RadialDesignerCell2(style: UITableViewCell.CellStyle.default,
                                       reuseIdentifier: "IColorCell",
                                       ParentDelegate: self,
                                       IsSmall: false,
                                       GradientStopID: ID)
        Cell.selectionStyle = UITableViewCell.SelectionStyle.none
        let GColor = GetGradientStopColor(ID: ID)
        let GLoc = GetGradientStopLocation(ID: ID)
        Cell.GradientStopColor = GColor!
        Cell.GradientStopLocation = GLoc!
        return Cell
    }
    #else
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let Cell = RadialDesignerCell(style: UITableViewCell.CellStyle.default,
                                      reuseIdentifier: "IColorCell",
                                      IsSmall: false)
        Cell.selectionStyle = UITableViewCell.SelectionStyle.none
        Cell.SetData(self, DisplayColor: ColorList[indexPath.row].1, Location: CGFloat(ColorList[indexPath.row].0), Tag: indexPath.row)
        if let DoSelectCell = SelectCell
        {
            if  DoSelectCell == indexPath.row
            {
                SelectCell = nil
                tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
                HandleSelectedCell(Index: indexPath.row)
            }
        }
        if indexPath.row == PencilIndex
        {
            Cell.PencilVisibility(IsVisible: true)
        }
        return Cell
    }
    #endif
    
    func RunColorEditor(ForRow: Int)
    {
        performSegue(withIdentifier: "ToColorEditor", sender: self)
    }
    
    #if false
    func HandleSelectedCell(Index: Int)
    {
        SelectedGradientIndex = Index
        ColorSample.backgroundColor = ColorList[Index].1
        let ColorLocation = ColorList[Index].0
        ColorLocationTextBox.text = String(describing: ColorLocation)
        ColorLocationSlider.value = Float(1000.0 * ColorLocation)
    }
    #endif
    
    #if false
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        print("Selected row \(indexPath.row)")
        for Index in 0 ..< ColorList.count
        {
            let IsSelected = Index == indexPath.row
            ColorList[Index] = (ColorList[Index].0, ColorList[Index].1, IsSelected, ColorList[Index].3)
        }
        PreviouslySelectedCell = CurrentIndex
        CurrentIndex = indexPath.row
        HandleSelectedCell(Index: CurrentIndex)
        //Setting the pencil index to -1 clears all pencils.
        PencilIndex = -1
        ColorListTable.reloadData()
        let Selected = ColorListTable.cellForRow(at: indexPath) as? RadialDesignerCell
        Selected?.PencilVisibility(IsVisible: true)
        PencilIndex = indexPath.row
    }
    #endif
    
    var PencilIndex: Int = 0
    
    #if false
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath)
    {
        print("Deselected row \(indexPath.row)")
    }
    #endif
    
    var PreviouslySelectedCell: Int = -1
    
    var CurrentIndex = -1
    
    var SelectedGradientIndex: Int = -1
    
    private func UpdateLocation(_ NewValue: Float)
    {
        let OldColor = ColorList[SelectedGradientIndex].1
        let OldSelection = ColorList[SelectedGradientIndex].2
        let OldID = ColorList[SelectedGradientIndex].3
        ColorList[SelectedGradientIndex] = (Double(NewValue), OldColor, OldSelection, OldID)
        ColorList.sort{$0.0 > $1.0}
        ColorListTable.reloadData()
        Working = RadialGradientDescriptor.SerializeRadial(Radius: Double(LastRadialValue), IsGrayscale: false, Colors: ColorList)
        print("UpdateLocation(NewValue)=\(Working)")
        PopulateUIFrom(Working)
        ShowSample(Working)
        _Settings.set(Working, forKey: SettingKey)
    }
    
    #if false
    @IBAction func HandleColorLocationChanged(_ sender: Any)
    {
        view.endEditing(true)
        var Value = ColorLocationSlider.value
        Value = Value / 1000.0
        Value = Float(Utility.Round(Double(Value), ToPlaces: 2))
        ColorLocationTextBox.text = String(describing: Value)
        UpdateLocation(Value)
    }
    
    @IBAction func HandleColorLocationTextChanged(_ sender: Any)
    {
        DoHandleColorLocationTextChanged()
    }
    
    func DoHandleColorLocationTextChanged()
    {
        view.endEditing(true)
        let Raw = ColorLocationTextBox.text
        if let DVal = Double(Raw!)
        {
            ColorLocationSlider.value = Float(DVal / 1000.0)
            UpdateLocation(Float(DVal))
        }
        else
        {
            ColorLocationSlider.value = 1000.0
            ColorLocationTextBox.text = "1.0"
            UpdateLocation(Float(1.0))
        }
    }
    #endif
    
    /// Handle changes to the radial size from the radial slider control.
    ///
    /// - Parameter sender: Not used.
    @IBAction func HandleRadialSizeChanged(_ sender: Any)
    {
        let Value = RadialSizeSlider.value / 10.0
        let OutValue = String(Utility.Round(Double(Value), ToPlaces: 1))
        RadialSizeTextBox.text = OutValue
        Working = RadialGradientDescriptor.SerializeRadial(Radius: Double(Value), IsGrayscale: false, Colors: ColorList)
        PopulateUIFrom(Working)
        ShowSample(Working)
        _Settings.set(Working, forKey: SettingKey)
    }
    
    enum ControlPairs
    {
        case RadialSize
        case RelativePosition
    }
    
    func SetErrorDefault(For: ControlPairs, _ DefaultValue: Float)
    {
        switch For
        {
        case .RadialSize:
            let StringDefault = String(DefaultValue / 10.0)
            RadialSizeTextBox.text = StringDefault
            RadialSizeSlider.value = DefaultValue
            
        case .RelativePosition:
            break
        }
    }
    
    @IBAction func HandleRadialSizeTextChanged(_ Sender: Any)
    {
        DoHandleRadialSizeTextChanged()
    }
    
    func DoHandleRadialSizeTextChanged()
    {
        if let Raw = RadialSizeTextBox.text
        {
            if let TextValue = Double(Raw)
            {
                if Float(TextValue) < RadialSizeSlider.minimumValue
                {
                    SetErrorDefault(For: .RadialSize, 800.0)
                    LastRadialValue = 80.0
                    return
                }
                if Float(TextValue) > RadialSizeSlider.maximumValue
                {
                    SetErrorDefault(For: .RadialSize, 700.0)
                    LastRadialValue = 70.0
                    return
                }
                RadialSizeSlider.value = Float(TextValue * 10.0)
                LastRadialValue = Float(TextValue)
                Working = RadialGradientDescriptor.SerializeRadial(Radius: TextValue, IsGrayscale: false, Colors: ColorList)
                PopulateUIFrom(Working)
                ShowSample(Working)
                _Settings.set(Working, forKey: SettingKey)
            }
            else
            {
                SetErrorDefault(For: .RadialSize, 1000.0)
                LastRadialValue = 100.0
            }
        }
        else
        {
            SetErrorDefault(For: .RadialSize, 900.0)
            LastRadialValue = 90.0
        }
    }
    
    var LastRadialValue: Float = 0.0
    
    @IBAction func HandleAddColorPressed(_ sender: Any)
    {
        var AddAt: Int = 0
        var ColorOffset: Double = 0.0
        if CurrentIndex > -1
        {
            AddAt = CurrentIndex
            ColorOffset = ColorList[CurrentIndex].0
        }
        ColorList.insert((ColorOffset,UIColor.white,false, UUID()), at: AddAt)
        ColorListTable.reloadData()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == .delete
        {
            ColorList.remove(at: indexPath.row)
            ColorListTable.deleteRows(at: [indexPath], with: .fade)
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
    
    func AssignNewLocation(To: Int, NewLocation: Double)
    {
        ColorList[To] = (NewLocation, ColorList[To].1, ColorList[To].2, ColorList[To].3)
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
    {
        if StopEditingTimer != nil
        {
            StopEditingTimer.invalidate()
            StopEditingTimer = nil
        }
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
        
        ColorListTable.reloadData()
        StartAutoStopEditingTimer()
    }
    
    var EditingColorList: Bool = false
    
    override func setEditing(_ editing: Bool, animated: Bool)
    {
        super.setEditing(editing, animated: animated)
        ColorListTable.isEditing = editing
    }
    
    /// Handle the edit button pressed. This allows the user to change the order of colors as well as delete existing colors.
    /// Additionally, the title of the button changes to reflect the editing status.
    ///
    /// - Parameter sender: Not used.
    @IBAction func HandleEditPressed(_ sender: Any)
    {
        EditingColorList = !EditingColorList
        setEditing(EditingColorList, animated: true)
        EditListButton.title = EditingColorList ? "Done" : "Edit"
    }
    
    var StopEditingTimer: Timer!
    
    func StartAutoStopEditingTimer()
    {
        StopEditingTimer = Timer.scheduledTimer(timeInterval: TimeInterval(60.0), target: self, selector: #selector(StopEditing), userInfo: nil, repeats: false)
    }
    
    /// Automatically stop editing after a set amount of time.
    @objc func StopEditing ()
    {
        if StopEditingTimer == nil
        {
            return
        }
        StopEditingTimer.invalidate()
        StopEditingTimer = nil
        EditingColorList = false
        setEditing(false, animated: true)
        EditListButton.title = "Edit"
    }
    
    /// Handle the Reverse Order button pressed. The colors are reversed but not the positions.
    ///
    /// - Parameter sender: Not used.
    @IBAction func HandleReverseOrderPressed(_ sender: Any)
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
        ColorListTable.reloadData()
    }
    
    #if false
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        switch segue.identifier
        {
        case "ToColorEditor":
            let Dest = segue.destination as? BasicColorEditor
            Dest?.CallerDelegate = self
            Dest?.InitialTitle = "Gradient Color"
            Dest?.InitialColorSpace = ColorEditorColorSpaces.RGBA
            Dest?.InitialColor = ColorList[CurrentIndex].1
            Dest?.ColorSettingsString = ""
            
        default:
            break
        }
        
        super.prepare(for: segue, sender: self)
    }
    #endif
    
    #if false
    func ColorChanged(NewColor: UIColor, DidChange: Bool, Tag: String?)
    {
        if DidChange
        {
            let OldLocation = ColorList[CurrentIndex].0
            ColorList[CurrentIndex] = (OldLocation, NewColor, ColorList[CurrentIndex].2)
            ColorSample.backgroundColor = NewColor
            ColorListTable.reloadData()
            let NewDescriptor = RadialGradientDescriptor.SerializeRadial(Radius: Double(GradientSample!.Radius), Colors: ColorList)
            print("Radial descriptor: \(NewDescriptor)")
        }
    }
    #endif
    
    @IBAction func HandleEditColorSample(_ sender: Any)
    {
        performSegue(withIdentifier: "ToColorEditor", sender: self)
    }
    
    @IBAction func HandleReverseColorListButtonPressed(_ sender: Any)
    {
        ColorList.reverse()
        Working = RadialGradientDescriptor.SerializeRadial(Radius: Double(GradientSample!.Radius), IsGrayscale: false, Colors: ColorList)
        ColorListTable.reloadData()
        PopulateUIFrom(Working)
        ShowSample(Working)
        _Settings.set(Working, forKey: SettingKey)
    }
    
    @IBAction func HandleSortButtonPressed(_ sender: Any)
    {
        ColorList.sort{$0.0 < $1.0}
        ColorListTable.reloadData()
    }
    
    @IBOutlet weak var GroupBox2: UIView!
    @IBOutlet weak var EditListButton: UIBarButtonItem!
    @IBOutlet weak var RadialSizeTextBox: UITextField!
    @IBOutlet weak var RadialSizeSlider: UISlider!
    @IBOutlet weak var ColorListTable: UITableView!
    @IBOutlet weak var RadialSample: UIView!
    
    func UpdatedGradient(ID: UUID, SourceColor: UIColor, NewLocation: Double)
    {
        EditColorList(ID: ID, NewColor: SourceColor, NewLocation: NewLocation)
    }
    
    func NewLocationFor(ID: UUID, NewLocation: Double)
    {
        let OldColor = GetGradientStopColor(ID: ID)
        EditColorList(ID: ID, NewColor: OldColor!, NewLocation: NewLocation)
        let Raw = RadialGradientDescriptor.SerializeRadial(Radius: Double(GetRadialSizeFromUI()), IsGrayscale: false, Colors: ColorList)
        ShowSample(Raw)
        _Settings.set(Raw, forKey: SettingKey)
    }
    
    func GetNewColorFor(ID: UUID, SourceColor: UIColor, Requester: RadialDesignerCell2)
    {
        ColorRequestor = Requester
        NewColorFor = ID
        OldSourceColor = SourceColor
        performSegue(withIdentifier: "ToColorEditor", sender: self)
    }
    
    var NewColorFor: UUID? = nil
    var OldSourceColor: UIColor? = nil
    var ColorRequestor: RadialDesignerCell2!
    
    func ColorChanged(NewColor: UIColor, DidChange: Bool, Tag: String?)
    {
        if DidChange
        {
            let ChangedID = UUID(uuidString: Tag!)
            if ChangedID == NewColorFor
            {
                ColorRequestor.GradientStopColor = NewColor
                let OldLocation = GetGradientStopLocation(ID: ChangedID!)
                EditColorList(ID: ChangedID!, NewColor: NewColor, NewLocation: OldLocation!)
                let Raw = RadialGradientDescriptor.SerializeRadial(Radius: Double(GetRadialSizeFromUI()), IsGrayscale: false, Colors: ColorList)
                ShowSample(Raw)
                _Settings.set(Raw, forKey: SettingKey)
            }
        }
    }
    
    func GetRadialSizeFromUI() -> Float
    {
        let Value = RadialSizeSlider.value / 10.0
        return Value
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool
    {
        if identifier == "ToColorEditor"
        {
            if NewColorFor == nil || OldSourceColor == nil
            {
                return false
            }
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if NewColorFor == nil || OldSourceColor == nil
        {
            return
        }
        switch segue.identifier
        {
        case "ToColorEditor":
            let Dest = segue.destination as? BasicColorEditor
            Dest?.CallerDelegate = self
            Dest?.InitialTitle = "Gradient Color"
            Dest?.InitialColorSpace = ColorEditorColorSpaces.RGBA
            Dest?.InitialColor = OldSourceColor!
            Dest?.ColorSettingsString = ""
            Dest?.DelegateTag = NewColorFor?.uuidString
            
        default:
            break
        }
        
        super.prepare(for: segue, sender: self)
    }
    
    func ColorGradientIndex(ForID: UUID) -> Int?
    {
        var Index: Int = 0
        for SomeColor in ColorList
        {
            if SomeColor.3 == ForID
            {
                return Index
            }
            Index = Index + 1
        }
        return nil
    }
    
    func EditColorList(ID: UUID, NewColor: UIColor, NewLocation: Double)
    {
        if let Index = ColorGradientIndex(ForID: ID)
        {
            let OldBool = ColorList[Index].2
            ColorList.remove(at: Index)
            ColorList.append((NewLocation, NewColor, OldBool, ID))
            ColorList.sort{$0.0 < $1.0}
        }
        else
        {
            print("Error getting color gradient stop.")
        }
    }
    
    func GetGradientStopColor(ID: UUID) -> UIColor?
    {
        if let Index = ColorGradientIndex(ForID: ID)
        {
            return ColorList[Index].1
        }
        else
        {
            return nil
        }
    }
    
    func GetGradientStopLocation(ID: UUID) -> Double?
    {
        if let Index = ColorGradientIndex(ForID: ID)
        {
            return ColorList[Index].0
        }
        else
        {
            return nil
        }
    }
}

//https://stackoverflow.com/questions/36541764/how-to-rearrange-item-of-an-array-to-new-position-in-swift
extension Array
{
    mutating func rearrange(From: Int, To: Int)
    {
        insert(remove(at: From), at: To)
    }
}
