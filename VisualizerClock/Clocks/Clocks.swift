//
//  Clocks.swift
//  Barcode Clock
//
//  Created by Stuart Rankin on 9/13/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Actions requested by the user.
///
/// - NoAction: Take no action and make no changes.
/// - ClosePanel: Close this panel.
/// - SwitchToCode128: Switch to Code 128 barcodes.
/// - SwitchToQRCode: Switch to QR Code barcodes.
/// - SwitchToQRCode3D: Switch to 3D version of QR Code barcodes.
/// - SwitchToAztecCode: Switch to Aztec Code barcodes.
/// - SwitchToPDF417: Switch to PDF417 Code Barcodes.
/// - SwitchToDataMatrix: Switch to Data Matrix Code barcodes.
/// - SwitchToPharmaCode: Switch to Pharma Code barcodes.
/// - SwitchToPOSTNET: Switch to USPS POSTNET barcodes.
/// - SwitchToCode11: Switch to Code 11 barcodes
/// - SwitchToCircularHex: Switch to circular hex barcode (homemade).
/// - SwitchToRadialColors: Switch to radial colors clock.
/// - SwitchToRadialGrayscale: Switch to radial grayscale clock.
/// - SwitchToAmorphousColorBlob: Switch to an amorphous color blob clock.
/// - SwitchToPolarText: Switch to polar text clock.
/// - SwitchToPolarLines: Switch to polar lines clock.
/// - SwitchToPieChart: Switch to a pie chart clock.
/// - SwitchToBarChar: Switch to a bar chart clock.
/// - SwitchToOrbital: Switch to the orbital clock.
/// - SwitchToText: Swith to the text clock.
/// - SelectedClockOptions: Run selected clock options.
/// - StopClock: Stop the clock. Valid only when compiled with the DEBUG switch.
/// - StartClock: Start the clock. Valid only when compiled with the DEBUG switch.
/// - OpenDebug: Open a debug "dialog."
public enum PanelActions: Int
{
    case NoAction = -1
    case ClosePanel = -2
    case SwitchToCode128 = 0
    case SwitchToQRCode = 1
    case SwitchToQRCode3D = 2
    case SwitchToAztecCode = 3
    case SwitchToPDF417 = 4
    case SwitchToDataMatrix = 5
    case SwitchToPharmaCode = 6
    case SwitchToPOSTNET = 7
    case SwitchToCode11 = 8
    case SwitchToCircularHex = 2000
    case SwitchToRadialColors = 1000
    case SwitchToRadialGrayscale = 1002
    case SwitchToAmorphousColorBlob = 1003
    case SwitchToPolarText = 1004
    case SwitchToPolarLines = 1005
    case SwitchToPieChart = 1006
    case SwitchToBarChart = 1007
    case SwitchToOrbital = 1008
    case SwitchToText = 1009
    case SelectedClockOptions = 20000
    case TakePicture = 50000
    #if DEBUG
    case StopClock = 10000
    case StartClock = 10001
    case OpenDebug = 10002
    #endif
}

/// Manages clock descriptions and usage for options display.
public class Clocks
{
    /// Initialize the clocks manager class. Must be called before clocks are displayed or the clock selection table view is shown.
    public static func Initialize()
    {
        ClockList = [(String, ClocksInType)]()
        let BarcodeClocks = ClocksInType([("Code 128", PanelActions.SwitchToCode128),
                                          ("Pharmacode", PanelActions.SwitchToPharmaCode),
                                          ("POSTNET", PanelActions.SwitchToPOSTNET),
                                          ("Code 11", PanelActions.SwitchToCode11),
                                          ("Aztec Code", PanelActions.SwitchToAztecCode),
                                          ("PDF 417", PanelActions.SwitchToPDF417),
                                          ("QR Code", PanelActions.SwitchToQRCode),
                                          ("3D QR Code", PanelActions.SwitchToQRCode3D),
//                                          ("Data Matrix", PanelActions.SwitchToDataMatrix),
                                          ("Circular Hex", PanelActions.SwitchToCircularHex)])
        ClockList.append(("Barcodes", BarcodeClocks))
        let ColorClocks = ClocksInType([("Radial Colors", PanelActions.SwitchToRadialColors),
                                        ("Radial Grayscale", PanelActions.SwitchToRadialGrayscale),
                                        ("Amorphous Color Blob", PanelActions.SwitchToAmorphousColorBlob)])
        ClockList.append(("Colors", ColorClocks))
        let PolarClocks = ClocksInType([("Polar", PanelActions.SwitchToPolarText),
                                        ("Polar Lines", PanelActions.SwitchToPolarLines)])
        ClockList.append(("Polar", PolarClocks))
        let OrbitalClocks = ClocksInType([("Orbital Clock", PanelActions.SwitchToOrbital)])
        ClockList.append(("Orbital", OrbitalClocks))
        let ChartClocks = ClocksInType([("Pie Chart", PanelActions.SwitchToPieChart),
                                        ("Bar Chart", PanelActions.SwitchToBarChart)])
        ClockList.append(("Charts", ChartClocks))
        let TextClocks = ClocksInType([("Text", PanelActions.SwitchToText)])
        ClockList.append(("Text", TextClocks))
    }
    
    /// Map from panel actions to clock IDs.
    public static let ClockIDMap =
    [
        PanelActions.SwitchToCode128: "faa6b191-7cca-4da1-a814-819b81b7e053",
        PanelActions.SwitchToPDF417: "fb5e2f66-5f65-4c3b-97f6-df143be35f6d",
        PanelActions.SwitchToAztecCode: "1927d69a-cd6d-44e2-ab56-af40db0bde99",
        PanelActions.SwitchToQRCode: "1034c46a-767f-4dc1-a2e0-5154bd3cb128",
        PanelActions.SwitchToQRCode3D: "95330ac2-7028-48c1-8735-16e8defbb8cf",
        PanelActions.SwitchToPharmaCode: "1fa64591-c48a-40c0-a035-414be5a46468",
        PanelActions.SwitchToPOSTNET: "60f716dd-7222-4015-a60d-c7e55c2f52ff",
        PanelActions.SwitchToCode11: "6015d1a0-08bb-11e9-b568-0800200c9a66",
        PanelActions.SwitchToAmorphousColorBlob: "72035411-caab-4375-9198-fbc97cd85aed",
        PanelActions.SwitchToPolarText: "f77e005b-b962-40a9-931f-271d18957f0a",
        PanelActions.SwitchToRadialColors: "d234d6bc-8289-4800-8e43-060162f6a53e",
        PanelActions.SwitchToRadialGrayscale: "b55eb021-86ac-4dc7-b3eb-856aabae7213",
        PanelActions.SwitchToPolarLines: "071387ba-c102-4a7f-90e1-a26bce41acad",
        PanelActions.SwitchToDataMatrix: "9afc4407-aa08-4778-b4b2-1016c98cb3dc",
        PanelActions.SwitchToPieChart: "c356438d-4ea0-4d01-923a-043884dec8b5",
        PanelActions.SwitchToBarChart: "df87003c-2a73-46c6-9320-d40de9c3c2ea",
        PanelActions.SwitchToOrbital: "d867b6a0-08eb-44d2-a208-bb1bdd721b18",
        PanelActions.SwitchToText: "02cddda2-ff32-40ff-a279-06196e29d73f",
    ]
    
    /// Given a clock type, return its ID.
    ///
    /// - Parameter ClockIdentifier: The type of clock whose ID will be returned.
    /// - Returns: Th ID of the type of clock passed on success, nil on failure.
    public static func GetActualID(_ ClockIdentifier: PanelActions) -> UUID?
    {
        if let Raw = ClockIDMap[ClockIdentifier]
        {
            return UUID(uuidString: Raw)
        }
        return nil
    }
    
    /// Return the name of a clock group with the specified index.
    ///
    /// - Parameter ForIndex: Index of the clock group whose name will be returned.
    /// - Returns: Name of the clock group for the specified index. If no group found or on error, empty string is returned.
    public static func ClockGroupName(ForIndex: Int) -> String
    {
        if ForIndex < 0 || ForIndex > ClockList.count - 1
        {
            return ""
        }
        return ClockList[ForIndex].0
    }
    
    /// Returns the number of clock groups in the clock list.
    public static var ClockGroupCount: Int
    {
        get
        {
            return ClockList.count
        }
    }
    
    /// Return the number of clocks in the given group.
    ///
    /// - Parameter ForIndex: Index of the group whose number of clocks will be returned.
    /// - Returns: The number of clocks in the specified group. 0 on error.
    public static func ClockCount(ForIndex: Int) -> Int
    {
        if ForIndex < 0 || ForIndex > ClockList.count - 1
        {
            return 0
        }
        return ClockList[ForIndex].1.ClockCount
    }
    
    /// Return the number of clocks in the given group.
    ///
    /// - Parameter ForClockGroup: Name of the group whose number of clocks will be returned.
    /// - Returns: The number of clocks in the specified group. 0 on error.
    public static func ClockCount(ForClockGroup: String) -> Int
    {
        let Index = IndexOf(GroupName: ForClockGroup)
        if Index > -1
        {
            return ClockCount(ForIndex: Index)
        }
        return 0
    }
    
    /// Returns the index of the specified group name.
    ///
    /// - Parameter GroupName: Name of the group whose index value will be returned.
    /// - Returns: Index of the specified group on success, -1 on error or not found.
    public static func IndexOf(GroupName: String) -> Int
    {
        var Count = 0
        for (Name, _) in ClockList!
        {
            if Name == GroupName
            {
                return Count
            }
            Count = Count + 1
        }
        return -1
    }
    
    /// Returns the ID of the clock at the specified clock address.
    ///
    /// - Parameters:
    ///   - GroupIndex: Clock's group index.
    ///   - ClockIndex: Clock's index.
    /// - Returns: ID of the clock at the group, clock index. Empty UUID if not found or on error.
    public static func GetClockIDAt(GroupIndex: Int, ClockIndex: Int) -> UUID
    {
        if GroupIndex < 0 || GroupIndex > ClockList!.count - 1
        {
            return UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
        }
        return ClockList[GroupIndex].1.ClockIDAt(Index: ClockIndex)
    }
    
    /// Returns the name of the clock at the specified clock address.
    ///
    /// - Parameters:
    ///   - GroupIndex: Clock's group index.
    ///   - ClockIndex: Clock's index.
    /// - Returns: Name of the clock at the group, clock index. Empty string if not found or on error.
    public static func GetClockNameAt(GroupIndex: Int, ClockIndex: Int) -> String
    {
        if GroupIndex < 0 || GroupIndex > ClockList!.count - 1
        {
            return ""
        }
        return ClockList[GroupIndex].1.ClockNameAt(Index: ClockIndex)
    }
    
    /// Given a clock name, return its ID.
    ///
    /// - Parameter ClockName: Name of the clock whose ID will be returned.
    /// - Returns: ID of the named clock on success, nil if not found.
    public static func GetClockIDFromName(ClockName: String) -> UUID?
    {
        for (_, ClockGroup) in ClockList
        {
            for (Name, _, ID) in ClockGroup.ClockList!
            {
                if Name == ClockName
                {
                    return ID
                }
            }
        }
        return nil
    }

    /// Returns the panel action of the clock at the specified clock address.
    ///
    /// - Parameters:
    ///   - GroupIndex: Clock's group index.
    ///   - ClockIndex: Clock's index.
    /// - Returns: Panel action of the clock at the group, clock index. PanelActions.NoAction if not found or on error.
    public static func GetClockActionAt(GroupIndex: Int, ClockIndex: Int) -> PanelActions
    {
        if GroupIndex < 0 || GroupIndex > ClockList!.count - 1
        {
            return PanelActions.NoAction
        }
        return ClockList[GroupIndex].1.ClockActionAt(Index: ClockIndex)
    }
    
    /// List of clocks.
    public static var ClockList: [(String, ClocksInType)]!
    
    /// Determines if the passed ID is a clock ID.
    ///
    /// - Parameter TestID: ID to test.
    /// - Returns: True if the passed ID is a clock ID, false if not.
    public static func IsClockID(_ TestID: UUID) -> Bool
    {
        for(_, ID) in ClockIDMap
        {
            let SomeID: UUID = UUID(uuidString: ID)!
            if SomeID == TestID
            {
                return true
            }
        }
        return false
    }
    
    /// Given an ID, return the name of the clock associated with the ID.
    ///
    /// - Parameter WithID: ID of the clock whose name will be returned.
    /// - Returns: Name of the clock whose ID is passed to us. Nil if not found.
    public static func NameForClock(WithID: UUID) -> String?
    {
        for (_, TypeClocks) in ClockList
        {
            if let ClockName = TypeClocks.ClockNameFor(ID: WithID)
            {
                return ClockName
            }
        }
        return nil
    }
    
    /// Given an action type, return the name of the associated type's ID.
    ///
    /// - Parameter Action: The panel action type associated with the clock whose name will be returned.
    /// - Returns: Name of the clock on success, nil on failure.
    public static func NameForClock(Action: PanelActions) -> String?
    {
        if Action == .TakePicture
        {
            return "Take Screenshot"
        }
        if let ID = ClockIDMap[Action]
        {
            return NameForClock(WithID: UUID(uuidString: ID)!)
        }
        return nil
    }
    
    /// Determines if the clock address passed is valid given the current set of groups and clocks.
    ///
    /// - Parameters:
    ///   - GroupIndex: Clock's group index.
    ///   - ClockIndex: Clock's index.
    /// - Returns: True if the address is valid, false if not.
    public static func ValidClockAddress(GroupIndex: Int, ClockIndex: Int) -> Bool
    {
        if GroupIndex < 0 || ClockIndex < 0
        {
            return false
        }
        if GroupIndex > ClockList.count - 1
        {
            return false
        }
        if (ClockIndex > ClockList[GroupIndex].1.ClockCount - 1)
        {
            return false
        }
        return true
    }
}
