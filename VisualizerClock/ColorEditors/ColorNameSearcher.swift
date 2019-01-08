//
//  ColorNameSearcher.swift
//  Visualizer Clock
//
//  Created by Stuart Rankin on 11/30/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Implements a view that allows users to search for colors by name.
class ColorNameSearcher: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate
{
    var delegate: ColorReceiver? = nil
    var ReturnTag: String? = nil

    /// Set up the UI.
    override func viewDidLoad()
    {
        super.viewDidLoad()
        CurrentColors = PredefinedColors.ColorsInOrder(.NameList)
        PartialMatchSwitch.isOn = true
        SelectedColorName.text = ""
        ResultTable.layer.borderColor = UIColor.black.cgColor
        ResultTable.layer.borderWidth = 0.5
        ResultTable.layer.cornerRadius = 5.0
        SelectedColorSample.layer.borderColor = UIColor.black.cgColor
        SelectedColorSample.layer.borderWidth = 0.5
        SelectedColorSample.layer.cornerRadius = 5.0
        SelectedColorSample.backgroundColor = UIColor.white
        ResultTable.delegate = self
        ResultTable.dataSource = self
        SearchBar.delegate = self
        //https://stackoverflow.com/questions/28394933/how-do-i-check-when-a-uitextfield-changes
        SearchBar.addTarget(self, action: #selector(SearchTextChanged), for: .editingChanged)
    }
    
    var CurrentColors = [PredefinedColorGroup]()
    
    private var _ColorSelected: Bool = false
    /// Get the flag that indicates a color is selected.
    public var ColorSelected: Bool
    {
        get
        {
            return _ColorSelected
        }
    }
    
    //https://medium.com/@KaushElsewhere/how-to-dismiss-keyboard-in-a-view-controller-of-ios-3b1bfe973ad1
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        self.view.endEditing(true)
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        var FinalColor = UIColor.clear
        var HaveNewColor = false
        if let Color = SelectedColor
        {
            FinalColor = Color.Color
            HaveNewColor = true
        }
        else
        {
            FinalColor = UIColor.clear
            HaveNewColor = false
        }
        delegate?.ColorChanged(NewColor: FinalColor, DidChange: HaveNewColor, Tag: ReturnTag)
        super.viewWillDisappear(animated)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return CGFloat(PredefinedColorCell.CellHeight[.Large]!)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return FoundNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let Cell = PredefinedColorCell(style: UITableViewCell.CellStyle.default,
                                       reuseIdentifier: "PredefinedColorCell",
                                       CellSize: .Large)
        let SomeColor = FoundNames[indexPath.row]
        Cell.SetData(DisplayColor: SomeColor.Color, ColorName: SomeColor.ColorName,
                     AltName: SomeColor.AlternativeName, PaletteName: SomeColor.Palette,
                     ItemID: SomeColor.ID, Tag: 0, SortedName: SomeColor.SortedName,
                     HighlightSortedName: true, SortedNameColor: UIColor.blue)
        return Cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        SelectedColor = FoundNames[indexPath.row]
        SelectedColorSample.backgroundColor = SelectedColor!.Color
        SelectedColorName.text = SelectedColor!.SortedName == .PrimaryName ? SelectedColor!.ColorName : SelectedColor!.AlternativeName
    }
    
    var SelectedColor: PredefinedColor? = nil
    
    @IBAction func HandleCancelPressed(_ sender: Any)
    {
        _ColorSelected = false
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func HandleSearchButtonPressed(_ sender: Any)
    {
        view.endEditing(true)
        SearchForText()
    }
    
    //https://medium.com/@KaushElsewhere/how-to-dismiss-keyboard-in-a-view-controller-of-ios-3b1bfe973ad1
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        self.view.endEditing(true)
        return true
    }
    
    @IBAction func HandleTextChanged(_ sender: Any)
    {
        SearchForText()
    }
    
    @IBAction func HandleSearchTextEntered(_ sender: Any)
    {
        SearchForText()
    }
    
    @objc func SearchTextChanged(_ textField: UITextField)
    {
        SearchForText()
    }
    
    func SearchForText()
    {
        let SearchText = SearchBar.text
        if (SearchText?.isEmpty)!
        {
            ResetResults()
            return
        }
        let PartialMatchOK = PartialMatchSwitch.isOn
        let SearchAlternative = SearchAlternativeNamesSwitch.isOn
        FoundNames.removeAll()
        ResultTable.reloadData()
        
        let SearchFor = SearchText?.lowercased()
        
        for SomeColor in CurrentColors[0].GroupColors
        {
            if PartialMatchOK
            {
                if SomeColor.ColorName.lowercased().range(of: SearchFor!) != nil
                {
                    FoundNames.append(SomeColor)
                    SomeColor.SortedName = PredefinedColor.SortedNames.PrimaryName
                }
                else
                {
                    if SearchAlternative
                    {
                        if SomeColor.AlternativeName.lowercased().range(of: SearchFor!) != nil
                        {
                            FoundNames.append(SomeColor)
                            SomeColor.SortedName = PredefinedColor.SortedNames.AlternativeName
                        }
                    }
                }
            }
            else
            {
                if SomeColor.ColorName.lowercased() == SearchFor
                {
                    FoundNames.append(SomeColor)
                    SomeColor.SortedName = PredefinedColor.SortedNames.PrimaryName
                }
                else
                {
                    if SearchAlternative
                    {
                        if SomeColor.AlternativeName.lowercased() == SearchFor
                        {
                            FoundNames.append(SomeColor)
                            SomeColor.SortedName = PredefinedColor.SortedNames.AlternativeName
                        }
                    }
                }
            }
        }
        
        if FoundNames.count == 0
        {
            SearchMatchTitle.text = "Search matches - 0 found"
        }
        else
        {
            SearchMatchTitle.text = "Search matches - \(FoundNames.count) found"
            ResultTable.reloadData()
        }
    }
    
    var FoundNames = [PredefinedColor]()
    
    @IBAction func HandleClearResultsPressed(_ sender: Any)
    {
        ResetResults()
    }
    
    func ResetResults()
    {
        FoundNames.removeAll()
        SelectedColorSample.backgroundColor = UIColor.white
        SelectedColorName.text = ""
        SearchMatchTitle.text = "Search matches"
        SearchBar.text = ""
        SelectedColor = nil
        ResultTable.reloadData()
    }
    
    @IBOutlet weak var SearchButton: UIButton!
    @IBOutlet weak var SearchBar: UITextField!
    @IBOutlet weak var SearchAlternativeNamesSwitch: UISwitch!
    @IBOutlet weak var SearchMatchTitle: UILabel!
    @IBOutlet weak var PartialMatchSwitch: UISwitch!
    @IBOutlet weak var ResultTable: UITableView!
    @IBOutlet weak var SelectedColorSample: UIView!
    @IBOutlet weak var SelectedColorName: UILabel!
}
