//
//  DateExtensions.swift
//  Visualizer Clock
//
//  Created by Stuart Rankin on 12/23/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation

/// Extensions for Date.
extension Date
{
    /// Returns a date with the supplied date components.
    ///
    /// - Parameters:
    ///   - Year: Year of the date.
    ///   - Month: Month of the date (1-based).
    ///   - Day: Day of the date.
    ///   - Hour: Hour of the date. Defaults to 0.
    ///   - Minute: Minute of the date. Defaults to 0.
    ///   - Second: Second of the date. Defaults to 0
    /// - Returns: Date with the specified components.
    static func DateFrom (Year: Int, Month: Int, Day: Int, Hour: Int = 0, Minute: Int = 0, Second: Int = 0) -> Date
    {
        var Components = DateComponents()
        Components.setValue(Year, for: .year)
        Components.setValue(Month, for: .month)
        Components.setValue(Day, for: .day)
        Components.setValue(Hour, for: .hour)
        Components.setValue(Minute, for: .minute)
        Components.setValue(Second, for: .second)
        let Cal = Calendar.current
        let Final = Cal.date(from: Components)
        return Final!
    }
    
    /// Return the number of days between the two supplied dates.
    ///
    /// - Parameters:
    ///   - Date1: First date.
    ///   - Date2: Second date.
    /// - Returns: Number of days between the two dates.
    static func DaysBetween(_ Date1: Date, _ Date2: Date) -> Int
    {
        let Delta = Calendar.current.dateComponents([.day], from: Date1, to: Date2).day
        return abs(Delta!)
    }
    
    /// Return the number of seconds between the two supplied dates.
    ///
    /// - Parameters:
    ///   - Date1: First date.
    ///   - Date2: Second date.
    /// - Returns: Number of seconds between the two dates.
    static func SecondsBetween(_ Date1: Date, _ Date2: Date) -> Int
    {
        let Delta = Calendar.current.dateComponents([.second], from: Date1, to: Date2).second
        return abs(Delta!)
    }
    
    /// Returns the date of the start of the 20th century.
    ///
    /// - Parameter StartsOn1: If true (default), the year is 1901. If false, the year is 1900.
    /// - Returns: Starting date of the 20th century.
    static func StartOfTwentiethCentury(_ StartsOn1: Bool = true) -> Date
    {
        let Year = StartsOn1 ? 1901 : 1900
        return DateFrom(Year: Year, Month: 1, Day: 1)
    }
    
    /// Returns the date of the start of the 21st century.
    ///
    /// - Parameter StartsOn1: If true (default), the year is 2001. If false, the year is 2000.
    /// - Returns: Starting date of the 21st century.
    static func StartOfTwentyFirstCentury(_ StartsOn1: Bool = true) -> Date
    {
        let Year = StartsOn1 ? 2001 : 2000
        return DateFrom(Year: Year, Month: 1, Day: 1)
    }
}
