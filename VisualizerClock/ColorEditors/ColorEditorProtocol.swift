//
//  ColorEditorProtocol.swift
//  Visualizer Clock
//
//  Created by Stuart Rankin on 9/17/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

protocol ColorEditing
{
    func SourceColor(_ Color: UIColor)
    func TitleForEditor(_ NewTitle: String)
    func ColorSpace(_ ToColorSpace: ColorEditorColorSpaces)
}
