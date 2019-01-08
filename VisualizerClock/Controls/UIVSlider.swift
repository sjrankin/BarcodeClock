//
//  UIVSlider.swift
//  Barcode Clock
//
//  Created by Stuart Rankin on 8/29/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class UIVSlider: UISlider
{
    override init(frame: CGRect)
    {
        super.init(frame: frame)
OrientControl()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        OrientControl()
    }
    
    func OrientControl()
    {
                self.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi / 2))
    }

    #if false
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        OrientControl()
    }
    #endif

}
