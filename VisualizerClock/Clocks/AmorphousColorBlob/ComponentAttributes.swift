//
//  ComponentAttributes.swift
//  Barcode Clock
//
//  Created by Stuart Rankin on 9/12/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

public class ComponentAttributes
{
    init(For: ComponentTypes)
    {
        _ComponentType = For
    }
    
    init(For: ComponentTypes, Color: UIColor, Radius: Double, Radial: Double? = nil)
    {
        _ComponentType = For
        ComponentColor = Color
        ComponentRadius = Radius
        if Radial == nil
        {
            ComponentRadial = 100.0
        }
        else
        {
            ComponentRadial = Radial!
        }
    }
    
    private var _ComponentColor: UIColor = UIColor.clear
    public var ComponentColor: UIColor
    {
        get
        {
            return _ComponentColor
        }
        set
        {
            _ComponentColor = newValue
        }
    }
    
    private var _ComponentRadius: Double = 0.0
    public var ComponentRadius: Double
    {
        get
        {
            return _ComponentRadius
        }
        set
        {
            _ComponentRadius = newValue
        }
    }
    
    private var _ComponentRadial: Double = 100.0
    public var ComponentRadial: Double
    {
        get
        {
            return _ComponentRadial
        }
        set
        {
            _ComponentRadial = newValue
        }
    }
    
    private var _ComponentType: ComponentTypes
    public var ComponentType: ComponentTypes
    {
        get
        {
            return _ComponentType
        }
    }
    
    public enum ComponentTypes
    {
        case Second
        case Minute
        case Hour
    }
}
