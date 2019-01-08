//
//  VectorBarcodeTest.swift
//  Visualizer Clock
//
//  Created by Stuart Rankin on 9/17/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class VectorBarcodeTest: UITableViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        TestOutput.backgroundColor = UIColor.white
        TestOutput.layer.borderColor = UIColor.black.cgColor
        TestOutput.layer.borderWidth = 0.5
        TestOutput.layer.cornerRadius = 5.0
        KnownGood.backgroundColor = UIColor.yellow
        NodeWidthLabel.text = ""
        NodeHeightLabel.text = ""
    }
    
    @IBOutlet weak var TestData: UITextField!
    @IBAction func HandleTextEditingDone(_ sender: Any)
    {
        view.endEditing(true)
    }
    
    var EncodeMe: String = ""
    
    var VectorImageAvailable: Bool = false
    
    @IBAction func HandleGoButton(_ sender: Any)
    {
        view.endEditing(true)
        EncodeMe = TestData.text!
        if EncodeMe.isEmpty
        {
            EncodeMe = Utility.MakeTimeString(TheDate: Date())
        }
        var FinalWidth: Int = 0
        var FinalHeight: Int = 0
        var TypeName = ""
        switch BarcodeSegments.selectedSegmentIndex
        {
        case 0:
            TypeName = "Code128"
            
        case 1:
            TypeName = "CodeQR"
            
        case 2:
            TypeName = "CodeAztec"
            
        case 3:
            TypeName = "PDF417"
            
        default:
            TypeName = "CodeQR"
        }
        let Bits = BarcodeGenerator.CreateBarcodeBitmap(from: EncodeMe, WithType: TypeName, FinalWidth: &FinalWidth, FinalHeight: &FinalHeight,
                                                        Native: &NativeBarcode)
        if NativeBarcode == nil
        {
            print("Native image returned as nil.")
            return
        }
        NodeWidthLabel.text = "X Nodes: \(FinalWidth)"
        NodeHeightLabel.text = "Y Nodes: \(FinalHeight)"
        print("FinalWidth: \(FinalWidth), FinalHeight: \(FinalHeight)")
        let Vector = BarcodeVector(Bitmap: Bits!, Width: FinalWidth, Height: FinalHeight)
        Vector.DumpBitmap()
        let OutWidth: Int = Int(TestOutput.frame.width)
        let OutHeight: Int = Int(TestOutput.frame.height)
        print("Output width: \(OutWidth), Output height: \(OutHeight)")
        let BarcodeView = Vector.MakeView(Foreground: UIColor.black, Background: UIColor.white, Highlight: UIColor.yellow, ViewWidth: OutWidth, ViewHeight: OutHeight, Previous: &Previous)
        TestOutput.addSubview(BarcodeView!)
        
        var NotUsed: CIImage? = nil
        let Standard = BarcodeGenerator.Create(from: EncodeMe, WithType: TypeName, Foreground: nil, Background: CIColor.red, Native: &NotUsed)
        KnownGood.image = Standard
        
        EncodeMe = ""
        VectorImageAvailable = true
    }
    
    private var Previous: [[Int]]? = nil
    
    var NativeBarcode: CIImage? = nil
    
    @IBOutlet weak var BarcodeSegments: UISegmentedControl!
    
    @IBAction func HandleBarcodeChanged(_ sender: Any)
    {
    }
    
    @IBAction func HandleSaveVectorButton(_ sender: Any)
    {
        if VectorImageAvailable
        {
            TestOutput.layer.borderColor = UIColor.clear.cgColor
            TestOutput.layer.borderWidth = 0.0
            TestOutput.layer.cornerRadius = 0.0
            let Renderer = UIGraphicsImageRenderer(size: TestOutput.bounds.size)
            let Vector = Renderer.image {ctx in TestOutput.drawHierarchy(in: TestOutput.bounds, afterScreenUpdates: true)}
            self.TestOutput.layer.borderColor = UIColor.black.cgColor
            self.TestOutput.layer.borderWidth = 0.5
            self.TestOutput.layer.cornerRadius = 5.0
            UIImageWriteToSavedPhotosAlbum(Vector, nil, nil, nil)
            let Alert = UIAlertController(title: "Saved", message: "Vector image saved to the photo roll (as rasterized image).",
                                          preferredStyle: UIAlertController.Style.alert)
            #if true
            let AlertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            #else
            let AlertAction = UIAlertAction(title: "OK", style: .default, handler: {
                action in
                self.TestOutput.layer.borderColor = UIColor.black.cgColor
                self.TestOutput.layer.borderWidth = 0.5
                self.TestOutput.layer.cornerRadius = 5.0
            })
            #endif
            Alert.addAction(AlertAction)
            present(Alert, animated: true)
        }
    }
    
    @IBAction func HandleSaveImageButton(_ sender: Any)
    {
        if NativeBarcode == nil
        {
            print("Tried to save nil barcode.")
            return
        }
        let context = CIContext()
        let CGI = context.createCGImage(NativeBarcode!, from: NativeBarcode!.extent)
        let final = UIImage(cgImage: CGI!)
            UIImageWriteToSavedPhotosAlbum(final, self,
                                           #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer)
    {
    if let error = error
    {
        let Alert = UIAlertController(title: "Error", message: error.localizedDescription,
                                      preferredStyle: UIAlertController.Style.alert)
        let AlertAction = UIAlertAction(title: "Hey!", style: .default, handler: nil)
        Alert.addAction(AlertAction)
        present(Alert, animated: true)
        }
        else
    {
        let Alert = UIAlertController(title: "Saved", message: "Raster image in native resolution saved to the photo roll.",
                                      preferredStyle: UIAlertController.Style.alert)
        let AlertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        Alert.addAction(AlertAction)
        present(Alert, animated: true)
        }
    }
    
    @IBOutlet weak var NodeWidthLabel: UILabel!
    @IBOutlet weak var NodeHeightLabel: UILabel!
    @IBOutlet weak var TestOutput: UIView!
    @IBOutlet weak var KnownGood: UIImageView!
}
