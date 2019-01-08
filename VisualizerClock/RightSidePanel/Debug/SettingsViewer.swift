//
//  SettingsViewer.swift
//  Barcode Clock
//
//  Created by Stuart Rankin on 8/25/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Dumps the settings.
class SettingsViewer: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    /// UI entry point for initialization.
    override func viewDidLoad()
    {
        super.viewDidLoad()
        SettingTypes = Setting.GetSettingTypes()
        SettingTypes?.sort()
        SettingValues = Setting.DumpSettings()
        SettingValues?.sort(by: {$0.1 < $1.1})
        SettingsTable.delegate = self
        SettingsTable.dataSource = self
    }
    
    /// Holds all of the types in the settings.
    var SettingTypes: [String]? = nil
    /// Holds all of the values in the settings.
    var SettingValues: [(String,String,String)]? = nil
    
    /// Returns the number of settings in the specified setting type.
    ///
    /// - Parameter LookFor: The type whose setting count will be returned.
    /// - Returns: Number of settings in the given type.
    func CountForType(_ LookFor: String) -> Int
    {
        let NotUsed = Setting.SettingsFor(TypeOf: LookFor)
        return NotUsed.count
    }
    
    /// Returns the setting name and value.
    ///
    /// - Parameters:
    ///   - SettingIndex: Index of the setting in the section (eg, type).
    ///   - SectionIndex: Index of the section (eg, type).
    /// - Returns: Tuple of a setting name and type.
    func GetSettingAndValue(SettingIndex: Int, SectionIndex: Int) -> (String, String)
    {
        let TypeName = SettingTypes![SectionIndex]
        let SettingTable = Setting.SettingsFor(TypeOf: TypeName)
        let SettingName = SettingTable[SettingIndex]
        let Dumped = Setting.DumpSetting(ForKey: SettingName, AndType: TypeName)
        return (SettingName, Dumped!)
    }
    
    /// Reference to the table view.
    @IBOutlet weak var SettingsTable: UITableView!
    
    /// Returns the number of sections to display in the table view.
    ///
    /// - Parameter tableView: The table view that wants to know how many sections to display.
    /// - Returns: Number of sections to display.
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return (SettingTypes?.count)!
    }
    
    /// Returns the header for the specified section.
    ///
    /// - Parameters:
    ///   - tableView: Table view that wants the header section string.
    ///   - section: The section that determines which string to return.
    /// - Returns: String of the header section name.
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return SettingTypes![section]
    }
    
    /// Return the number of rows in a given section.
    ///
    /// - Parameters:
    ///   - tableView: The table view that wants the number of rows in a section (eg, the number of settings in a type).
    ///   - section: The section index that determines how many rows.
    /// - Returns: Number of rows for the specified section.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return CountForType(SettingTypes![section])
    }
    
    /// Populate the table view with setting names/values.
    ///
    /// - Parameters:
    ///   - tableView: The table view to populate
    ///   - indexPath: Determines the table view cell to populate
    /// - Returns: Populated table view cell.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let Cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "SettingCell")
        let (SettingName, SettingValue) = GetSettingAndValue(SettingIndex: indexPath.row, SectionIndex: indexPath.section)
        Cell.textLabel!.text = SettingName
        var SettingString = ""
        if SettingValue.isEmpty
        {
            SettingString = "{empty}"
            Cell.detailTextLabel!.textColor = UIColor.darkGray
        }
        else
        {
            SettingString = SettingValue
            Cell.detailTextLabel!.textColor = UIColor.blue
        }
        Cell.detailTextLabel!.text = SettingString
        return Cell
    }
}
