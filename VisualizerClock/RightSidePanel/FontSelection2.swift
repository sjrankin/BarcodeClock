//
//  FontSelection2.swift
//  Visualizer Clock
//
//  Created by Stuart Rankin on 11/13/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class FontSelection2: UIViewController, UITableViewDelegate, UITableViewDataSource, SettingProtocol
{
    let _Settings = UserDefaults.standard
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        FontList = [FontEncapsulation]()
        #if false
        //if let FontName = _Settings.string(forKey: Setting.Key.TimeFontName)
        if let FontName = _Settings.string(forKey: Setting.Key.Text.FontName)
        {
            CurrentFont = FontName
        }
        else
        {
            CurrentFont = "Avenir-Black"
        }
        #endif
        SelectedFontName = CurrentFont
        PopulateFontList()
        FontTable.layer.borderColor = UIColor.black.cgColor
        FontTable.layer.borderWidth = 1.0
        FontTable.layer.cornerRadius = 5.0
        SampleContainer.layer.borderColor = UIColor.black.cgColor
        SampleContainer.layer.borderWidth = 0.5
        SampleContainer.layer.cornerRadius = 5.0
        FontTable.delegate = self
        FontTable.dataSource = self
        ScrollToSelectedRow()
        SampleText.adjustsFontSizeToFitWidth = true
        if let SampleTextValue = SampleTextValue
        {
            SampleText.text = SampleTextValue
        }
        else
        {
            SampleText.text = ""
            SampleTimer = Timer.scheduledTimer(timeInterval: TimeInterval(1.0), target: self,
                                               selector: #selector(UpdateSample), userInfo: nil, repeats: true)
        }
    }
    
    var SampleTimer: Timer!
    
    var SampleTextValue: String? = nil
    
    var CurrentFont: String = ""
    var FontList: [FontEncapsulation]!
    
    func DoSet(Key: String, Value: Any?)
    {
        switch Key
        {
        case "FontName":
            CurrentFont = Value as! String
            
        case "SampleText":
            SampleTextValue = Value as? String
            
        default:
            break
        }
    }
    
    func ScrollToSelectedRow()
    {
        if InitialSelectedRow < 0
        {
            InitialSelectedRow = 0
        }
        let SelectedFontRow: IndexPath = IndexPath(row: InitialSelectedRow, section: 0)
        FontTable.scrollToRow(at: SelectedFontRow, at: .middle, animated: true)
    }
    
    /// Populate the list of fonts in the UI.
    func PopulateFontList()
    {
        print("First selected font name: \(CurrentFont)")
        var Index = 0
        for FontName in FontManager.CurrentFonts!
        {
            var IsSelected = false
            if FontName == CurrentFont
            {
                print("Selected \(FontName) when populating list.")
                IsSelected = true
                InitialSelectedRow = Index
            }
            var FinalDisplayName: String = ""
            if let DisplayName = FontManager.FullNames![FontName]
            {
                FinalDisplayName = DisplayName
            }
            else
            {
                FinalDisplayName = FontName
            }
            let EncapsulatedFont = FontEncapsulation(Name: FontName, FullName: FinalDisplayName, Selected: IsSelected)
            FontList.append(EncapsulatedFont)
            Index = Index + 1
        }
    }
    
    var InitialSelectedRow: Int = -1
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return FontCell.CellHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return FontList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let Cell = FontCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "Fonts")
        let Index = indexPath.row
        let DisplayName = FontManager.FullNames![FontList[Index].FontName]
        Cell.SetData(DisplayName: DisplayName!, FontName: FontList[Index].FontName,
                     IsSelected: FontList[Index].IsSelected)
        return Cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let Index = indexPath.row
        SelectedFontName = FontList[Index].FontName
        UpdateFontList(SelectedFontName: SelectedFontName)
        //print("Selected font name: \(SelectedFontName)")
    }
    
    func UpdateFontList(SelectedFontName: String)
    {
        for SomeFont in FontList
        {
            SomeFont.IsSelected = SomeFont.FontName == SelectedFontName
        }
        FontTable.reloadData()
        UpdateSample()
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        if DoSelect
        {
            print("Saving \(SelectedFontName) as text font.")
            _Settings.set(SelectedFontName, forKey: Setting.Key.Text.FontName)
            //            _Settings.set(SelectedFontName, forKey: Setting.Key.TimeFontName)
            super.viewWillDisappear(animated)
        }
    }
    
    var SelectedFontName = ""
    
    @IBAction func HandleCancelButton(_ sender: Any)
    {
        DoSelect = false
        navigationController?.popViewController(animated: true)
    }
    
    var DoSelect: Bool = true
    
    @objc func UpdateSample()
    {
        if let SampleTextValue = SampleTextValue
        {
            let UseFontName = SelectedFontName.isEmpty ? "Avenir-Black" : SelectedFontName
            let FontSize = Utility.RecommendedFontSize(HorizontalConstraint: SampleText.frame.width,
                                                       VerticalConstraint: SampleText.frame.height, TheString: SampleTextValue, FontName: UseFontName)
            let NewFont = UIFont(name: UseFontName, size: FontSize)
            SampleText.font = NewFont
        }
        else
        {
            let Now = Date()
            let SampleTime = Utility.MakeTimeString(TheDate: Now)
            let UseFontName = SelectedFontName.isEmpty ? "Avenir-Black" : SelectedFontName
            let FontSize = Utility.RecommendedFontSize(HorizontalConstraint: SampleText.frame.width,
                                                       VerticalConstraint: SampleText.frame.height, TheString: "00:00:00", FontName: UseFontName)
            let NewFont = UIFont(name: UseFontName, size: FontSize)
            SampleText.font = NewFont
            SampleText.text = SampleTime
        }
    }
    
    @IBOutlet weak var FontTable: UITableView!
    @IBOutlet weak var SampleContainer: UIView!
    @IBOutlet weak var SampleText: UILabel!
}
