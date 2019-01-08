//
//  BarcodeCreator.swift
//  BarcodeTest
//
//  Created by Stuart Rankin on 8/13/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Class that runs the view that lets the user create barcodes with custom content.
class BarcodeCreator: UITableViewController
{
    /// Reference to the user defaults.
    let _Settings = UserDefaults.standard
    
    #if false
    /// Tell the system that we don't want the status bar getting in the way.
    override var prefersStatusBarHidden: Bool
    {
        return true//_Settings.bool(forKey: Setting.Key.HideStatusBar)
    }
    #endif
    
    /// Setup UI.
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if let OldContents = _Settings.string(forKey: Setting.Key.LastCreatedBarcodeContents)
        {
        ToEncode.text = OldContents
        }
        else
        {
            ToEncode.text = "0123456789"
        }
        OneDHandle = VectorHandle.Make()
        UseBarcodeContentsSwitch.isOn = true
        InitializeContentUpdating(TurnOn: true)
        BarcodeSettingsSwitch.isOn = false
        AssignBarcodeImage(nil)
        SaveSizeSegment.selectedSegmentIndex = 3
        let GroupIndex = _Settings.integer(forKey: Setting.Key.LastCreatedBarcodeGroup)
        let BarcodeIndex = _Settings.integer(forKey: Setting.Key.LastCreatedBarcodeType)
        switch GroupIndex
        {
        case 1:
            BarcodeTypeSegment1.selectedSegmentIndex = BarcodeIndex
            BarcodeTypeSegment2.selectedSegmentIndex = UISegmentedControl.noSegment
            switch BarcodeIndex
            {
            case 0:
                CurrentBarcodeType = "CodeQR"
                
            case 1:
                CurrentBarcodeType = "CodeAztec"
                
            case 2:
                CurrentBarcodeType = "PDF417"
                
            default:
                CurrentBarcodeType = "CodeQR"
            }
            
        case 2:
            BarcodeTypeSegment2.selectedSegmentIndex = BarcodeIndex
            BarcodeTypeSegment1.selectedSegmentIndex = UISegmentedControl.noSegment
            switch BarcodeIndex
            {
            case 0:
                CurrentBarcodeType = "Code11"
                
            case 1:
                CurrentBarcodeType = "Code128"
                
            case 2:
                CurrentBarcodeType = "Pharma"
                
            case 3:
                CurrentBarcodeType = "POSTNET"
                
            default:
                CurrentBarcodeType = "Code128"
            }
            
        default:
            fatalError("Unexpected barcode group index encountered: \(GroupIndex)")
        }
        UpdateBarcode()
        setNeedsStatusBarAppearanceUpdate()
    }
    
    var OneDHandle: VectorHandle? = nil
    
    /// Update the barcode. Reads the contents of the text box and barcode type segment control and
    /// generates a barcode from that information. If the content of the text control is empty,
    /// no barcode is generated, and the print and save buttons are disabled.
    func UpdateBarcode()
    {
        let Contents: String = ToEncode.text!
        var NativeImage: CIImage? = nil
        
        switch CurrentBarcodeType
        {
        case "Pharma":
            let IContents = Int(Contents)
            let Size = CGSize(width: BarcodeUIView.frame.width * 0.9, height: BarcodeUIView.frame.height * 0.8)
            let BarcodeImage = Barcode1DClock.GetBarcodeImage(Handle: OneDHandle!, BarcodeType: .Pharmacode, From: IContents!, ImageSize: Size)
            if BarcodeImage == nil
            {
                print("UpdateBarcode: Pharma barcode failed.")
            }
            AssignBarcodeImage(BarcodeImage)
            LastGeneratedBarcode = BarcodeImage
            
        case "POSTNET":
            let IContents = Int(Contents)
            let Size = CGSize(width: BarcodeUIView.frame.width * 0.9, height: BarcodeUIView.frame.height * 0.20)
            let BarcodeImage = Barcode1DClock.GetBarcodeImage(Handle: OneDHandle!, BarcodeType: .POSTNET, From: IContents!, ImageSize: Size)
            if BarcodeImage == nil
            {
                print("UpdateBarcode: POSTNET barcode failed.")
            }
            AssignBarcodeImage(BarcodeImage)
            LastGeneratedBarcode = BarcodeImage
            
        default:
            if let BarcodeImage = BarcodeGenerator.Create(from: Contents, WithType: CurrentBarcodeType, Native: &NativeImage)
            {
                AssignBarcodeImage(BarcodeImage)
                LastGeneratedBarcode = BarcodeImage
            }
            else
            {
                AssignBarcodeImage(nil)
                LastGeneratedBarcode = nil
            }
        }
    }
    
    /// Saves the last successfully created barcode. Used when saving barcode images to the photo roll.
    var LastGeneratedBarcode: UIImage? = nil
    
    /// Takes a generated barcode image and displays it on the user interface. Sets the enabled state with reference
    /// to the barcode image not being nil - in other words, if the barcode image is nil, the print and save
    /// buttons are disabled.
    ///
    /// - Parameter BarcodeImage: The image to display.
    func AssignBarcodeImage(_ BarcodeImage: UIImage?)
    {
        BarcodeUIView.image = BarcodeImage
        PrintButton.isEnabled = BarcodeImage != nil
        SaveBarcodeButton.isEnabled = BarcodeImage != nil
    }
    
    /// Given an index for the save/pring size, return a pixel size for the longest dimension of the final barcode.
    ///
    /// - Parameter SizeIndex: Index from the segment control.
    /// - Returns: Number of pixels for the longest dimension for the final barcode.
    func LongestDimension(SizeIndex: Int) -> CGFloat
    {
        switch SizeIndex
        {
        case 0:
            return 10.0
            
        case 1:
            return 128.0
            
        case 2:
            return 512.0
            
        case 3:
            return 1024.0
            
        default:
            return 0.0
        }
    }
    
    func MakeFinalImage() -> UIImage?
    {
        let Contents: String = ToEncode.text!
        let Size = SaveSizeSegment.selectedSegmentIndex
        let Longest = LongestDimension(SizeIndex: Size)
        var FinalSize: CGSize!
        if Longest > -1.0
        {
            if CurrentBarcodeType == "CodeQR" || CurrentBarcodeType == "CodeAztec"
            {
                //For square (or intended to be square) barcodes.
                FinalSize = CGSize(width: Longest, height: Longest)
            }
            else
            {
                //For longer-wide than tall barcodes.
                FinalSize = CGSize(width: Longest, height: Longest * 0.33)
            }
        }
        var NativeImage: CIImage? = nil
        var BarcodeImage: UIImage? = nil
        
        switch CurrentBarcodeType
        {
        case "Pharma":
            let IContents = Int(Contents)
            let Size = CGSize(width: BarcodeUIView.frame.width * 0.95, height: BarcodeUIView.frame.height * 0.8)
            BarcodeImage = Barcode1DClock.GetBarcodeImage(Handle: OneDHandle!, BarcodeType: .Pharmacode, From: IContents!, ImageSize: Size)
            if BarcodeImage == nil
            {
                print("Pharma barcode failed.")
            }
            
        case "POSTNET":
            let IContents = Int(Contents)
            let Size = CGSize(width: BarcodeUIView.frame.width * 0.95, height: BarcodeUIView.frame.height * 0.2)
            BarcodeImage = Barcode1DClock.GetBarcodeImage(Handle: OneDHandle!, BarcodeType: .POSTNET, From: IContents!, ImageSize: Size)
            if BarcodeImage == nil
            {
                print("POSTNET barcode failed.")
            }
            
        default:
            BarcodeImage = BarcodeGenerator.Create(from: Contents, WithType: CurrentBarcodeType,
                                                   OverrideSize: FinalSize, Native: &NativeImage)
        }
        
        if let BarcodeImage = BarcodeImage
        {
            if Size == 0
            {
                //https://stackoverflow.com/questions/44864432/saving-to-user-photo-library-silently-fails
                let Context = CIContext()
                let CGImage = Context.createCGImage(NativeImage!, from: NativeImage!.extent)
                let Final = UIImage(cgImage: CGImage!)
                print("Final.size = \(Final.size)")
                return Final
            }
            return BarcodeImage
        }
        
        return nil
    }
    
    /// Reference to the save barcode butotn.
    @IBOutlet weak var SaveBarcodeButton: UIBarButtonItem!
    
    /// Handle save button press events. If there is no available barcode, nothing is printed. On success,
    /// a typical "You saved the image" alert is shown.
    ///
    /// - Parameter sender: Not used.
    @IBAction func HandleSavePressed(_ sender: Any)
    {
        if LastGeneratedBarcode == nil
        {
            return
        }
        if let LastGeneratedBarcode = MakeFinalImage()
        {
        UIImageWriteToSavedPhotosAlbum(LastGeneratedBarcode,
                                       self,
                                       #selector(image(_:didFinishSavingWithError:contextInfo:)),
                                       nil)
        }
        else
        {
            print("Error getting final barcode image.")
        }
        }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer)
    {
        if let error = error
        {
            let Alert = UIAlertController(title: "Error", message: error.localizedDescription,
                                          preferredStyle: UIAlertController.Style.alert)
            let AlertAction = UIAlertAction(title: "Close", style: .default, handler: nil)
            Alert.addAction(AlertAction)
            present(Alert, animated: true)
        }
        else
        {
            let Alert = UIAlertController(title: "Saved", message: "Your barcode was successfully saved to the photo roll.",
                                          preferredStyle: UIAlertController.Style.alert)
            let AlertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            Alert.addAction(AlertAction)
            present(Alert, animated: true)
        }
    }
    
    /// Handle the done button press by popping the view controller.
    ///
    /// - Parameter sender: Not used.
    @IBAction func HandleDonePressed(_ sender: Any)
    {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    /// Handle the print button pressed. Run standard iOS AirPrint controllers.
    ///
    /// - Parameter sender: Not used.
    @IBAction func HandlePrintPressed(_ sender: Any)
    {
        let PrintController = UIPrintInteractionController.shared
        let PrintInfo = UIPrintInfo(dictionary: nil)
        PrintInfo.outputType = UIPrintInfo.OutputType.grayscale
        PrintInfo.jobName = "Visualization Clock Barcode Print Job"
        PrintController.printInfo = PrintInfo
        PrintController.printingItem = BarcodeUIView.image
        PrintController.present(animated: true, completionHandler: nil)
    }
    
    /// Reference to the text field where the user enters his data.
    @IBOutlet weak var ToEncode: UITextField!
    
    /// Handle new text available in the text field.
    ///
    /// - Parameter sender: Not used.
    @IBAction func HandleTextAvailable(_ sender: Any)
    {
        //view.endEditing(true)
        let Contents: String = ToEncode.text!
        _Settings.set(Contents, forKey: Setting.Key.LastCreatedBarcodeContents)
        UpdateBarcode()
    }
    
    @IBAction func HandleStartedEditing(_ sender: Any)
    {
        if ContentsTimer != nil
        {
            ContentsTimer.invalidate()
            ContentsTimer = nil
        }
        UseBarcodeContentsSwitch.isOn = false
    }

    /// Reference to the barcode type segment control.
    @IBOutlet weak var BarcodeTypeSegment1: UISegmentedControl!
    
    /// Handle the barcode type changed event by re-creating the barcode in the specified type.
    ///
    /// - Parameter sender: Not used.
    @IBAction func HandleBarcodeType1Changed(_ sender: Any)
    {
        _Settings.set(BarcodeTypeSegment1.selectedSegmentIndex, forKey: Setting.Key.LastCreatedBarcodeType)
        _Settings.set(1, forKey: Setting.Key.LastCreatedBarcodeGroup)
        
        BarcodeTypeSegment2.selectedSegmentIndex = UISegmentedControl.noSegment
        
        switch BarcodeTypeSegment1.selectedSegmentIndex
        {
        case 0:
            CurrentBarcodeType = "CodeQR"
            
        case 1:
            CurrentBarcodeType = "CodeAztec"
            
        case 2:
            CurrentBarcodeType = "PDF417"
            
        default:
            CurrentBarcodeType = "CodeQR"
        }
        ContentsUpdate()
        UpdateBarcode()
    }
    
    @IBOutlet weak var BarcodeTypeSegment2: UISegmentedControl!
    
    @IBAction func HandleBarcodeType2Changed(_ sender: Any)
    {
        _Settings.set(BarcodeTypeSegment2.selectedSegmentIndex, forKey: Setting.Key.LastCreatedBarcodeType)
        _Settings.set(2, forKey: Setting.Key.LastCreatedBarcodeGroup)
        
        BarcodeTypeSegment1.selectedSegmentIndex = UISegmentedControl.noSegment
        
        switch BarcodeTypeSegment2.selectedSegmentIndex
        {
        case 0:
            CurrentBarcodeType = "Code11"
            
        case 1:
            CurrentBarcodeType = "Code128"
            
        case 2:
            CurrentBarcodeType = "Pharma"
            
        case 3:
            CurrentBarcodeType = "POSTNET"
            
        default:
            CurrentBarcodeType = "Code128"
        }
        ContentsUpdate()
        UpdateBarcode()
    }
    
    /// Current barcode type.
    var CurrentBarcodeType: String = "Code128"
    
    /// Reference to the print button.
    @IBOutlet weak var PrintButton: UIBarButtonItem!
    
    /// Reference to the UIImageView where the barcode will appear.
    @IBOutlet weak var BarcodeUIView: UIImageView!
    
    /// When the view disappears, save the contents of the input text field.
    ///
    /// - Parameter animated: Not used directly - passed to super class.
    override func viewWillDisappear(_ animated: Bool)
    {
        let Contents = ToEncode.text
        _Settings.set(Contents, forKey: Setting.Key.LastCreatedBarcodeContents)
        super.viewWillDisappear(animated)
    }
    
    @IBOutlet weak var SaveSizeSegment: UISegmentedControl!
    
    @IBAction func HandleSettingsSwitchChanged(_ sender: Any)
    {
        UpdateBarcode()
    }
    
    @IBOutlet weak var BarcodeSettingsSwitch: UISwitch!
    
    @IBOutlet weak var UseBarcodeContentsSwitch: UISwitch!
    
    func InitializeContentUpdating(TurnOn: Bool)
    {
        if TurnOn
        {
            ContentsTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(ContentsUpdate),
                                                 userInfo: nil, repeats: true)
        }
        else
        {
            if ContentsTimer != nil
            {
                ContentsTimer.invalidate()
                ContentsTimer = nil
            }
        }
    }
    
    @IBAction func HandleBarcodeContentsChanged(_ sender: Any)
    {
        InitializeContentUpdating(TurnOn: UseBarcodeContentsSwitch.isOn)
    }
    
    var ContentsTimer: Timer!
    
    @objc func ContentsUpdate()
    {
        switch CurrentBarcodeType
        {
        case "Pharma":
            ToEncode.text = "\(Utility.GetTimeStampToEncodeI(From: Date(), false))"
            
        case "POSTNET":
            ToEncode.text = "\(Utility.GetTimeStampToEncodeI(From: Date(), true))"
            
        default:
            ToEncode.text = Utility.GetTimeStampToEncode(From: Date())
        }
        UpdateBarcode()
    }
}
