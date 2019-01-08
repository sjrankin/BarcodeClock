//
//  AboutBarcode.swift
//  BarcodeTest
//
//  Created by Stuart Rankin on 8/16/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Runs the about dialog.
class AboutBarcode: UIViewController, UITabBarDelegate
{
    let _Settings = UserDefaults.standard
    #if false
    /// Tell the system that we don't want the status bar getting in the way.
    override var prefersStatusBarHidden: Bool
    {
        return _Settings.bool(forKey: Setting.Key.HideStatusBar)
    }
    #endif
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        InfoSegment.selectedSegmentIndex = 0
        TextContainer.layer.borderColor = UIColor.black.cgColor
        TextContainer.layer.borderWidth = 1.0
        TextContainer.layer.cornerRadius = 5.0
        ShowVersionText()
        let TapGesture = UITapGestureRecognizer(target: self, action: #selector(TogglePicture))
        AuthorImage.addGestureRecognizer(TapGesture)
        let OtherTapGesture = UITapGestureRecognizer(target: self, action: #selector(ToggleAgain))
        AboutTitle.addGestureRecognizer(OtherTapGesture)
        AuthorPicture = UIImage(imageLiteralResourceName: "YoursTruly.jpg")
        AuthorImage.image = AuthorPicture
    }
    
    @objc func ToggleAgain()
    {
        IsShowingPicture = !IsShowingPicture
        UIView.animate(withDuration: TimeInterval(0.5), animations:
            {
                self.AuthorImage.alpha = self.IsShowingPicture ? 0.0 : 1.0
        })
    }
    
    var IsShowingPicture: Bool = false
    var AuthorPicture: UIImage? = nil
    
    @objc func TogglePicture()
    {
        IsShowingPicture = !IsShowingPicture
        UIView.animate(withDuration: TimeInterval(0.5), animations:
            {
                self.AuthorImage.alpha = self.IsShowingPicture ? 0.0 : 1.0
        })
    }
    
    @IBAction func HandleInfoChanged(_ sender: Any)
    {
        switch InfoSegment.selectedSegmentIndex
        {
        case 0:
            ShowVersionText()
            
        case 1:
            DoShowBarcodeText()
            
        case 2:
            ShowLegalText()
            
        default:
            break
        }
    }
    
    func ShowVersionText()
    {
        let IText = "Initialized \(_Settings.string(forKey: Setting.Key.InitializeTimeStamp)!)" + "\n\n"
        let VText = Versioning.MakeVersionString() + "\n"
        let BText = Versioning.MakeBuildString() + "\n"
        let CRight = Versioning.CopyrightText()
        DisplayText.text = VText + BText + IText + CRight
    }
    
    func DoShowBarcodeText()
    {
        DisplayText.text = "Various clocks are displayed in sometimes non-traditional fashion, such as barcodes. (Barcodes do not contain URLs.)"
    }
    
    func ShowLegalText()
    {
        DisplayText.text = "Copyright, legal, and license text here."
    }
    
    @IBAction func HandleBackButton(_ sender: Any)
    {
        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var DisplayText: UITextView!
    @IBOutlet weak var TextContainer: UIView!
    @IBOutlet weak var AuthorImage: UIImageView!
    @IBOutlet weak var AboutTitle: UILabel!
    @IBOutlet weak var InfoSegment: UISegmentedControl!
}

extension UIImage
{
    func alpha(_ Value: CGFloat) -> UIImage
    {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: CGPoint.zero, blendMode: .normal, alpha: Value)
        let NewImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return NewImage!
    }
}
