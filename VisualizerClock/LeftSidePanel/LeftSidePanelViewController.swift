//
//  LeftSidePanelViewController2.swift
//  Barcode Clock
//
//  Created by Stuart Rankin on 8/17/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

/// Copyright (c) 2017 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit

/// Controller for the left-side panel. This panel allows the user to select the type of clock to view.
class LeftSidePanelViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    /// Tell the system that we don't want the status bar getting in the way.
    override var prefersStatusBarHidden: Bool
    {
        return _Settings.bool(forKey: Setting.Key.HideStatusBar)
    }
    
    let _Settings = UserDefaults.standard
    
    var delegate: SidePanelViewControllerDelegate?
    weak var MainDelegate: MainUIProtocol?
    
    /// Main setup function.
    override func viewDidLoad()
    {
        super.viewDidLoad()
        LeftTable.delegate = self
        LeftTable.dataSource = self
        MostRecentlySelectedType = -1
    }
    
    /// Returns the number of sections in the table view. The returned value is equal to the number of groups in the clock
    /// list + 2. The +2 is for: 1 for the overall header and 1 for the Actions group.
    ///
    /// - Parameter tableView: The table view in question. Since there is only one table view in this controller, this
    ///                        parameter is ignored.
    /// - Returns: Number of sections in the table view.
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return Clocks.ClockGroupCount + 1 + 1
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection: Int)
    {
        let Header = view as? UITableViewHeaderFooterView
        if forSection == 0
        {
            Header?.textLabel?.font = UIFont(name: "Avenir-Black", size: 18.0)
            Header?.textLabel?.textColor = UIColor.black
        }
        else
        {
            Header?.textLabel?.textColor = UIColor.darkGray
        }
    }
    
    /// Returns the number of rows in each section in the table view control.
    ///
    /// - Parameters:
    ///   - tableView: The table view in question. Not used as there is only one table view we're worried about.
    ///   - section: Index of the section that determines the number of rows returned.
    /// - Returns: Number of rows in the specified section.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        switch section
        {
        case 0:
            //Main header section - nothing underneath
            return 0
            
        case 1 ... 6:
            return Clocks.ClockCount(ForIndex: section - 1)
            
        case 7:
            //Action section
            return 2
            
        default:
            return 0
        }
    }
    
    /// Returns the header title for the specified section.
    ///
    /// - Parameters:
    ///   - tableView: Table view control - not used because there is only one table view we're concerned about.
    ///   - TitleForHeaderInSection: Index of the section for which the title will be returned.
    /// - Returns: The title for the specified section header.
    func tableView(_ tableView: UITableView, titleForHeaderInSection TitleForHeaderInSection: Int) -> String?
    {
        switch TitleForHeaderInSection
        {
        case 0:
            return "Select Clock"
            
        case 1 ... 6:
            return Clocks.ClockGroupName(ForIndex: TitleForHeaderInSection - 1)
            
        case 7:
            return "Actions"
            
        default:
            return "Unexpected section \(TitleForHeaderInSection)"
        }
    }
    
    private let CloseID: UUID = UUID(uuidString: "3cd6250d-45b9-4c62-9bf4-d9794d095107")!
    private let SettingsID: UUID = UUID(uuidString: "c9499612-ef29-4d1b-b62e-faed6e23f61c")!
    
    /// Return a table cell for the specified IndexPath.
    /// - Note: Need to remember that the first section (section 0) is empty so table view sections that we populate start
    ///         at index 1, not 0.
    ///
    /// - Parameters:
    ///   - tableView: Table view control. Not used because there is only one we are worried about.
    ///   - indexPath: The path to the cell.
    /// - Returns: Cell for the table at the specified IndexPath.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let FullWidth = tableView.frame.width
        let Cell = LeftSideTableCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "LeftSideCell")
        Cell.delegate = MainDelegate
        if !Clocks.ValidClockAddress(GroupIndex: indexPath.section - 1, ClockIndex: indexPath.row)
        {
            if indexPath.section == 7
            {
                if indexPath.row == 0
                {
                    Cell.SetData(Title: "Close", FullWidth: FullWidth, ClockID: CloseID, IncludeSettingButton: false)
                }
            }
        }
        else
        {
            //Handle clock commands.
            let ClockName = Clocks.GetClockNameAt(GroupIndex: indexPath.section - 1, ClockIndex: indexPath.row)
            Cell.SetData(Title: ClockName, FullWidth: FullWidth, ClockID: Clocks.GetClockIDAt(GroupIndex: indexPath.section - 1, ClockIndex: indexPath.row))
            if Cell.HasSameID(As: _Settings.uuid(forKey: Setting.Key.DisplayClock))
            {
                Cell.backgroundColor = UIColor.yellow
                SelectedClockID = Cell.CellID
            }
            else
            {
                Cell.backgroundColor = UIColor.clear
            }
        }
        return Cell as UITableViewCell
    }
    
    /// Handle cell selection events. Clock selection events are sent to the main UI code immediately.
    ///
    /// - Parameters:
    ///   - tableView: Table where the selection occurred. Ignored - there is only one table view to worry about.
    ///   - indexPath: IndexPath that indicates which cell was selected.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let SelectedCell = tableView.cellForRow(at: indexPath) as! LeftSideTableCell
        if let CellID: UUID = SelectedCell.CellID
        {
            if Clocks.IsClockID(CellID)
            {
                _Settings.set(CellID, forKey: Setting.Key.DisplayClock)
                SelectedClockID = CellID
                delegate?.SelectClockType(ClockID: CellID)
                LeftTable.reloadData()
                return
            }
            if CellID == CloseID
            {
                delegate?.ActionTaken(PanelAction: .ClosePanel)
                return
            }
        }
    }
    
    /// Holds the currently selected clock.
    private var SelectedClockID: UUID? = nil
    
    /// Handle the close panel button press.
    ///
    /// - Parameter sender: Not used.
    @IBAction func HandleDismissedPressed(_ sender: Any)
    {
        delegate?.ActionTaken(PanelAction: PanelActions.ClosePanel) 
    }
    
    /// Given an IndexPath, return the associated panel action.
    ///
    /// - Parameter Raw: The IndexPath that determines the panel action returned.
    /// - Returns: Panel action enumeration associated with the cell at IndexPath.
    func GetAction(_ Raw: IndexPath) -> PanelActions
    {
        return Clocks.GetClockActionAt(GroupIndex: Raw.section - 1, ClockIndex: Raw.row)
    }
    
    @IBOutlet weak var LeftTable: UITableView!
    var MostRecentlySelectedType: Int!
}



