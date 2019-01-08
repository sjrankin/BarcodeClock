//
//  BarcodeDistortionTest.swift
//  Barcode Clock
//
//  Created by Stuart Rankin on 8/31/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class BarcodeDistortionTest: UITableViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        TypeSegment.selectedSegmentIndex = 0
        BarcodeOutputView.layer.borderColor = UIColor.black.cgColor
        BarcodeOutputView.layer.borderWidth = 0.5
        BarcodeOutputView.layer.cornerRadius = 5.0
        AssignBarcodeImage(nil)
    }
    
    private var _Center: CGPoint = CGPoint(x: 150.0, y: 150.0)
    public var Center: CGPoint
    {
        get
        {
            return _Center
        }
        set
        {
            _Center = newValue
        }
    }
    
    private var _Radius: CGFloat = 150.0
    public var Radius: CGFloat
    {
        get
        {
            return _Radius
        }
        set
        {
            _Radius = newValue
        }
    }
    
    private var _Angle: CGFloat = 0.0
    public var Angle: CGFloat
    {
        get
        
        {
            return _Angle
        }
        set
        {
            _Angle = newValue
        }
    }
    
    private var _Code128QuietSpace: Int = 7
    public var Code128QuietSpace: Int
    {
        get
        {
            return _Code128QuietSpace
        }
        set
        {
            _Code128QuietSpace = newValue
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        switch segue.identifier
        {
        case "ToDisortionParameters":
            break
            
        case "ToBarcodeParameters":
            break
            
        default:
            break
        }
        super.prepare(for: segue, sender: self)
    }
    
    @IBOutlet weak var BarcodeOutput: UIImageView!
    
    @IBOutlet weak var BarcodeOutputView: UIView!
    
    @IBAction func HandleExecuteButton(_ sender: Any)
    {
        var Payload = DataInput.text
        if Payload == nil
        {
            Payload = ""
        }
        if (Payload?.isEmpty)!
        {
            Payload = Utility.GetTimeStampToEncode(From: Date())
            DataInput.text = Payload
        }
        var BarcodeType: String = "Code128"
        if TypeSegment.selectedSegmentIndex == 1
        {
            BarcodeType = "PDF417"
        }
        var NotUsed: CIImage? = nil
        if let BarcodeImage = BarcodeGenerator.Create(from: Payload!, WithType: BarcodeType,
                                                      Foreground: nil, Background: nil,
                                                      OverrideSize: CGSize(width: 1200.0, height: 1200.0),
                                                      Native: &NotUsed)
        {
            LastGeneratedBarcode = BarcodeImage
            AssignBarcodeImage(BarcodeImage)
        }
        else
        {
            print("Barcode generator returned nil.")
            LastGeneratedBarcode = nil
            AssignBarcodeImage(nil)
        }
    }
    
    func AssignBarcodeImage(_ BarcodeImage: UIImage?)
    {
        BarcodeOutput.image = BarcodeImage
    }
    
    /// Saves the last successfully created barcode. Used when saving barcode images to the photo roll.
    var LastGeneratedBarcode: UIImage? = nil
    
    @IBAction func HandleSaveButton(_ sender: Any)
    {
        if LastGeneratedBarcode == nil
        {
            return
        }
        UIImageWriteToSavedPhotosAlbum(LastGeneratedBarcode!, nil, nil, nil)
        let Alert = UIAlertController(title: "Saved", message: "Your barcode was successfully saved to the photo roll.",
                                      preferredStyle: UIAlertController.Style.alert)
        let AlertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        Alert.addAction(AlertAction)
        present(Alert, animated: true)
    }
    
    @IBOutlet weak var DataInput: UITextField!
    
    @IBAction func HandleDataInputChanged(_ sender: Any)
    {
        view.endEditing(true)
    }
    
    @IBOutlet weak var TypeSegment: UISegmentedControl!
    @IBOutlet weak var AutoFillSegment: UISegmentedControl!
    
    @IBAction func HandleFillButton(_ sender: Any)
    {
        switch AutoFillSegment.selectedSegmentIndex
        {
        case 0:
            DataInput.text = Utility.MakeTimeString(TheDate: Date())
            
        case 1:
            DataInput.text = "01234567890123456789"
            
        case 2:
            DataInput.text = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
            
        case 3:
            DataInput.text = "Now is the time for all good tests to stress the testee."
            
        default:
            DataInput.text = "Unknown auto-fill option: \(AutoFillSegment.selectedSegmentIndex)"
        }
    }
}
