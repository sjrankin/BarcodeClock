//
//  ActionPanel2.swift
//  BarcodeTest
//
//  Created by Stuart Rankin on 8/16/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Displays actions the user can take.
class ActionPanel: RightSidePanelViewController, SidePanelViewControllerDelegate, UITableViewDelegate, UITableViewDataSource
{
    /// Prepare the UI.
    override func viewDidLoad()
    {
        super.viewDidLoad()
        RightTable.delegate = self
        RightTable.dataSource = self
        IsOnPad = UIDevice.current.userInterfaceIdiom == .pad
        #if false
        let OldBounds = RightTable.bounds
        let NewBounds = CGRect(x: OldBounds.maxX + 40.0, y: 0.0, width: OldBounds.width - 40.0, height: OldBounds.height)
        RightTable.bounds = NewBounds
        #endif
        SetupBackgroundView()
    }
    
    func SetupBackgroundView()
    {
        BackgroundView.backgroundColor = UIColor.white
    }
    
    #if false
    /// Tell the system that we don't want the status bar getting in the way.
    override var prefersStatusBarHidden: Bool
    {
        return true//_Settings.bool(forKey: Setting.Key.HideStatusBar)
    }
    #endif
    
    var IsOnPad = false
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        switch section
        {
        case 0:
            return 1
            
        case 1:
            return 3
            
            #if DEBUG
        case 2:
            return 3
            #endif
            
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection TitleForHeaderInSection: Int) -> String?
    {
        switch TitleForHeaderInSection
        {
        case 0:
            return "Actions"
            
        case 1:
            return "Other"
            
            #if DEBUG
        case 2:
            return "Debug"
            #endif
            
        default:
            return "Unexpected section \(TitleForHeaderInSection)"
        }
    }
    
    func CellDataFor(Section: Int, Row: Int) -> (String?, ActionCell.UserActions)?
    {
        switch Section
        {
        case 0:
            switch Row
            {
            case 0:
                return ("Settings", ActionCell.UserActions.RunSettings)
                
            default:
                return (nil, ActionCell.UserActions.NoAction)
            }
            
        case 1:
            switch Row
            {
            case 0:
                return ("About", ActionCell.UserActions.ShowAbout)
                
            case 1:
                return ("Create barcode", ActionCell.UserActions.CreateBarcode)
                
            case 2:
                return ("Close", ActionCell.UserActions.ClosePanel)
                
            default:
                return (nil, ActionCell.UserActions.NoAction)
            }
            
            #if DEBUG
        case 2:
            switch Row
            {
            case 0:
                return ("Stop Clock", ActionCell.UserActions.StopClock)
                
            case 1:
                return ("Start Clock", ActionCell.UserActions.StartClock)
                
            case 2:
                return ("Debug Settings", ActionCell.UserActions.OpenDebug)
                
            default:
                return (nil, ActionCell.UserActions.NoAction)
            }
            #endif
            
        default:
            return (nil, ActionCell.UserActions.NoAction)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let Cell = ActionCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "RightSide")
        Cell.delegate = self
        #if DEBUG
        if indexPath.section == 2
        {
            Cell.accessoryType = .none
        }
        else
        {
            Cell.accessoryType = .disclosureIndicator
        }
        #else
        Cell.accessoryType = .disclosureIndicator
        #endif
        Cell.selectionStyle = .none
        if let (TextString, ItemAction) = CellDataFor(Section: indexPath.section, Row: indexPath.row)
        {
            Cell.textLabel!.text = TextString
            Cell.CellAction = ItemAction
            #if false
            if indexPath.section == 1 && indexPath.row == 1
            {
                Cell.textLabel!.textAlignment = .right
            }
            #endif
            if indexPath.section == 0 && indexPath.row == 0
            {
                SettingsCell = Cell
            }
            if indexPath.section == 0 && indexPath.row == 1
            {
                BarcodeCell = Cell
            }
            if indexPath.section == 1 && indexPath.row == 0
            {
                AboutCell = Cell
            }
            if indexPath.section == 2 && indexPath.row == 2
            {
                DebugCell = Cell
            }
        }
        else
        {
            Cell.textLabel!.text = "error"
        }
        return Cell as UITableViewCell
    }
    
    var SettingsCell: ActionCell? = nil
    var AboutCell: ActionCell? = nil
    var BarcodeCell: ActionCell? = nil
    var DebugCell: ActionCell? = nil
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        #if DEBUG
        return 3
        #else
        return 2
        #endif
    }
    
    func HandleUserAction(Action: ActionCell.UserActions)
    {
        switch Action
        {
        case ActionCell.UserActions.NoAction:
            return
            
        case ActionCell.UserActions.RunSettings:
            if IsOnPad
            {
                let Storyboard = UIStoryboard(name: "MainUI", bundle: nil)
                let VC = Storyboard.instantiateViewController(withIdentifier: "SettingsNavigatorStoryboard")
                VC.modalPresentationStyle = .popover
                let PopPC = VC.popoverPresentationController
                PopPC?.sourceView = SettingsCell
                PopPC?.sourceRect = CGRect(x: 32, y: 32, width: 0, height: 0)
                VC.preferredContentSize = CGSize(width: 450, height: 650)
                present(VC, animated: true)
            }
            else
            {
                performSegue(withIdentifier: "ToSettings", sender: self)
            }
            break
            
        case ActionCell.UserActions.CreateBarcode:
            if IsOnPad
            {
                let Storyboard = UIStoryboard(name: "MainUI", bundle: nil)
                let VC = Storyboard.instantiateViewController(withIdentifier: "CreateBarcodeStoryboard")
                VC.modalPresentationStyle = .popover
                let PopPC = VC.popoverPresentationController
                PopPC?.sourceView = BarcodeCell
                PopPC?.sourceRect = CGRect(x: 32, y: 32, width: 0, height: 0)
                VC.preferredContentSize = CGSize(width: 450, height: 650)
                present(VC, animated: true)
            }
            else
            {
                performSegue(withIdentifier: "ToCreateBarcode", sender: self)
            }
            break
            
        case ActionCell.UserActions.ShowAbout:
            if IsOnPad
            {
                let Storyboard = UIStoryboard(name: "MainUI", bundle: nil)
                let VC = Storyboard.instantiateViewController(withIdentifier: "AboutStoryboard")
                VC.modalPresentationStyle = .popover
                let PopPC = VC.popoverPresentationController
                PopPC?.sourceView = AboutCell
                PopPC?.sourceRect = CGRect(x: 32, y: 32, width: 0, height: 0)
                VC.preferredContentSize = CGSize(width: 450, height: 650)
                present(VC, animated: true)
            }
            else
            {
                performSegue(withIdentifier: "ToAbout", sender: self)
            }
            break
            
        case ActionCell.UserActions.ClosePanel:
            delegate?.ActionTaken(PanelAction: PanelActions.ClosePanel)
            
            #if DEBUG
        case ActionCell.UserActions.OpenDebug:
            if IsOnPad
            {
                let Storyboard = UIStoryboard(name: "MainUI", bundle: nil)
                let VC = Storyboard.instantiateViewController(withIdentifier: "DebugDialog")
                VC.modalPresentationStyle = .popover
                let PopPC = VC.popoverPresentationController
                PopPC?.sourceView = DebugCell
                PopPC?.sourceRect = CGRect(x: 32, y: 32, width: 0, height: 0)
                VC.preferredContentSize = CGSize(width: 450, height: 650)
                present(VC, animated: true)
            }
            else
            {
                performSegue(withIdentifier: "ToDebug", sender: self)
            }
            
        case ActionCell.UserActions.StopClock:
            delegate?.ActionTaken(PanelAction: PanelActions.StopClock)
            
        case ActionCell.UserActions.StartClock:
            delegate?.ActionTaken(PanelAction: PanelActions.StartClock)
            #endif
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if let SelectedCell: ActionCell = RightTable.cellForRow(at: indexPath) as? ActionCell
        {
            let CellAction = SelectedCell.CellAction
            HandleUserAction(Action: CellAction)
        }
    }
    
    override func ActionTaken(PanelAction: PanelActions)
    {
        
    }
    
    func SelectClockType(ClockID: UUID)
    {
    }
    
    func RunSettings(For: UUID)
    {
    }
    
    @IBOutlet weak var RightTable: UITableView!
    @IBOutlet weak var BackgroundView: UIView!
}
