//
//  Round256BitBarcode.swift
//  Barcode Clock
//
//  Created by Stuart Rankin on 9/11/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class Round256BitBarcode: HomemadeBarcodeProtocol
{
    public var BarcodeName: String
    {
        get
        {
            return "Circular 256 Bits"
        }
    }
    
    public static var BarcodeID: UUID
    {
        get
        {
            return UUID(uuidString: "2123c00a-29df-43e1-b82c-26c73213d8aa")!
        }
    }
}
