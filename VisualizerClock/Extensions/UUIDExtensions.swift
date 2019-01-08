//
//  UUIDExtensions.swift
//  Visualizer Clock
//
//  Created by Stuart Rankin on 12/22/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation

/// Extend UUID functionality.
extension UUID
{
    /// Determines if the passed UUID is empty (eg, all fields are 0).
    ///
    /// - Parameter Test: The UUID to test.
    /// - Returns: True if the UUID is empty (everything is a 0), false if not.
    static func IsEmpty(_ Test: UUID) -> Bool
    {
        if Test == UUID.Empty()
        {
            return true
        }
        return false
    }
    
    /// Create and return an empty UUID.
    static func Empty() -> UUID
    {
        return UUID(uuidString: EmptyUUIDString)!
        //        return UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
    }
    
    /// Get a string value of an empty UUID.
    static var EmptyUUIDString: String
    {
        get
        {
            return "00000000-0000-0000-0000-000000000000"
        }
    }
    
    /// Return a string representation of the passed UUID, which may be nil. If nil, the returned value is controlled by the EmptyIfNil parameter.
    ///
    /// - Parameters:
    ///   - Value: The UUID to convert to a string.
    ///   - EmptyIfNil: If true, an empty string is returned if Value is nil. Otherwise, if value is nil, an empty UUID (eg, all zeroes) is returned.
    /// - Returns: String representation of the passed UUID (except if nil and EmptyIfNil is true).
    static func ToString(_ Value: UUID?, EmptyIfNil: Bool = true) -> String
    {
        if Value == nil
        {
            if EmptyIfNil
            {
                return ""
            }
            return UUID.ToString(UUID.Empty())
        }
        return String(describing: Value)
    }
}
