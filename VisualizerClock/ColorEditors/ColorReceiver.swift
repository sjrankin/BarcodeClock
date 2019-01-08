//
//  ColorReceiver.swift
//  Visualizer Clock
//
//  Created by Stuart Rankin on 9/17/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

protocol ColorReceiver
{
    func ColorChanged(NewColor: UIColor, DidChange: Bool, Tag: String?)
}
