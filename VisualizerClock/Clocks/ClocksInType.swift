//
//  ClocksInType.swift
//  Barcode Clock
//
//  Created by Stuart Rankin on 9/13/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Maintains a list (and ancillary functions) for related clocks. Used in Clocks.
public class ClocksInType
{
    /// Initializer.
    ///
    /// - Parameter List: List of clocks and associated actions.
    public init(_ List: [(String, PanelActions)])
    {
        ClockList = [(String, PanelActions, UUID)]()
        for (ClockName, ClockAction) in List
        {
            if let ID = Clocks.ClockIDMap[ClockAction]
            {
                ClockList?.append((ClockName, ClockAction, UUID(uuidString: ID)!))
            }
        }
    }
    
    /// Get the number of clocks in the list.
    public var ClockCount: Int
    {
        get
        {
            return _ClockList == nil ? 0 : (_ClockList?.count)!
        }
    }
    
    /// Holds the list of associated clocks for the type.
    private var _ClockList: [(String, PanelActions, UUID)]? = nil
    /// Get the list of clocks in the type.
    public var ClockList: [(String, PanelActions, UUID)]?
    {
        get
        {
            return _ClockList
        }
        set
        {
            _ClockList = newValue
        }
    }
    
    /// Returns the name of the clock at the specified index.
    ///
    /// - Parameter Index: Index of the clock whose name will be returned.
    /// - Returns: Name of the clock at the specified index. Empty string on error.
    public func ClockNameAt(Index: Int) -> String
    {
        if Index < 0 || Index > (ClockList?.count)! - 1
        {
            return ""
        }
        return ClockList![Index].0
    }
    
    /// Returns the name of the clock with the given ID.
    ///
    /// - Parameter ID: ID of the clock whose name will be returned.
    /// - Returns: Name of the clock with the specified ID. Nil if not found.
    public func ClockNameFor(ID: UUID) -> String?
    {
        for (Name, _, SomeID) in ClockList!
        {
            if SomeID == ID
            {
                return Name
            }
        }
        return nil
    }
    
    /// Returns the action of the clock at the specified ID.
    ///
    /// - Parameter Index: Index of the clock whose action will be returned.
    /// - Returns: Action of the specified clock. PanelActions.NoAction if not found.
    public func ClockActionAt(Index: Int) -> PanelActions
    {
        if Index < 0 || Index > (ClockList?.count)! - 1
        {
            return PanelActions.NoAction
        }
        return ClockList![Index].1
    }
    
    /// Returns the ID of the clock at the specified index.
    ///
    /// - Parameter Index: Index of the clock whose ID will be returned.
    /// - Returns: ID of the clock at the specified index. Empty UUID if not found.
    public func ClockIDAt(Index: Int) -> UUID
    {
        if Index < 0 || Index > (ClockList?.count)! - 1
        {
            return UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
        }
        return ClockList![Index].2
    }
}
