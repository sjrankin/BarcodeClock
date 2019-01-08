//
//  AmorphousColorBlobAttributes.swift
//  Barcode Clock
//
//  Created by Stuart Rankin on 9/12/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

public class AmorphousColorBlobAttributes
{
    init()
    {
        HourAttribute = ComponentAttributes(For: .Hour, Color: UIColor.red, Radius: 50.0, Radial: 60.0)
        HourAttribute = ComponentAttributes(For: .Minute, Color: UIColor.green, Radius: 40.0, Radial: 80.0)
        HourAttribute = ComponentAttributes(For: .Second, Color: UIColor.blue, Radius: 30.0, Radial: 100.0)
    }
    
    public var HourAttribute: ComponentAttributes? = nil
    public var MinuteAttribute: ComponentAttributes? = nil
    public var SecondAttribute: ComponentAttributes? = nil
}
