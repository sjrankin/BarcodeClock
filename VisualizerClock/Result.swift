//
//  Result.swift
//  Visualizer Clock
//
//  Created by Stuart Rankin on 11/5/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation

/// Simple result type.
class Result<T>
{
    /// Alternative ways of using true and false to represent success and failure.
    ///
    /// - Failed: Operation failed - equivalent to false.
    /// - Succeeded: Operation succeeded - equivalent to true.
    /// - Indeterminate: Operation has yet to occur.
    public enum Results
    {
        case Failed
        case Succeeded
        case Indeterminate
    }
    
    /// Initializer. No value assigned here.
    ///
    /// - Parameter SimpleResults: Description of result.
    init(_ SimpleResults: Results)
    {
        _Succeeded = SimpleResults == .Succeeded
    }
    
    /// Initializer. No value assigned here.
    ///
    /// - Parameter Success: True for success, false for failure.
    init(_ Success: Bool)
    {
        _Succeeded = Success
    }
    
    /// Initializer.
    ///
    /// - Parameters:
    ///   - SimpleResults: Description of result.
    ///   - ResultValue: Result value.
    init(_ SimpleResults: Results, _ ResultValue: T?)
    {
        _Succeeded = SimpleResults == .Succeeded
        _Value = ResultValue
    }
    
    /// Initializer.
    ///
    /// - Parameters:
    ///   - Success: True for success, false for failure.
    ///   - ResultValue: Result value.
    init(_ Success: Bool, _ ResultValue: T?)
    {
        _Succeeded = Success
        _Value = ResultValue
    }
    
    /// Holds the operation succeeded flag.
    private var _Succeeded: Bool = false
    /// Get or set the succeeded state of the operation.
    public var Succeeded: Bool
    {
        get
        {
        return _Succeeded
        }
        set
        {
            _Succeeded = newValue
        }
    }
    
    /// Holds the return result/value of the operation.
    private var _Value: T? = nil
    /// Get or set the return value of the operation.
    public var Value: T?
    {
        get
        {
            return _Value
        }
        set
        {
            _Value = newValue
        }
    }
    
    /// Determines if the Value property has an actual value in it or not.
    public var HasValue: Bool
    {
        get
        {
            return _Value != nil
        }
    }
}
