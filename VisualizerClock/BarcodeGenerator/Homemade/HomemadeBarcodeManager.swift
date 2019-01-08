//
//  HomemadeBarcodeManager.swift
//  Barcode Clock
//
//  Created by Stuart Rankin on 9/11/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class HomemadeBarcodeManager
{
    public static func Initialize()
    {
        _BarcodeIDs = [UUID]()
        _BarcodeList = [(UUID, HomemadeBarcodeProtocol)]()
        AddBarcodes()
        _Initialized = true
    }
    
    private static var _Initialized: Bool = false
    public static var Initialized: Bool
    {
        get
        {
            return _Initialized
        }
    }
    
    private static func AddBarcodes()
    {
        
        _BarcodeIDs.append(Round256BitBarcode.BarcodeID)
        _BarcodeList?.append((Round256BitBarcode.BarcodeID, Round256BitBarcode()))
    }
    
    private static var _BarcodeList: [(UUID, HomemadeBarcodeProtocol)]? = nil
    
    private static var _BarcodeIDs: [UUID]!
    public static var BarcodeIDs: [UUID]
    {
        get
        {
            return _BarcodeIDs
        }
    }
    
    public static func GetBarcodeName(FromID: UUID) -> String?
    {
        for (ID, Barcode) in _BarcodeList!
        {
            if ID == FromID
            {
                return Barcode.BarcodeName
            }
        }
        return nil
    }
}
