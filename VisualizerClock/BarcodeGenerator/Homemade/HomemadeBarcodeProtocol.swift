//
//  HomemadeBarcodeProtocol.swift
//  Barcode Clock
//
//  Created by Stuart Rankin on 9/11/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation

protocol HomemadeBarcodeProtocol: class
{
    var BarcodeName: String {get}
    static var BarcodeID: UUID {get}
}
