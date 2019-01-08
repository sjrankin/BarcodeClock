//
//  BarcodeGenerator.swift
//  Barcode Clock
//
//  Created by Stuart Rankin on 8/25/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import CoreImage

/// Barcode generation.
class BarcodeGenerator
{
    /// Map from barcode enumerations to the CIFilter name for the corresponding barcode filter generator.
    static var FilterMap =
        [
            "CodeQR3D": "CIQRCodeGenerator",
            "Code128": "CICode128BarcodeGenerator",
            "CodeAztec": "CIAztecCodeGenerator",
            "CodeQR": "CIQRCodeGenerator",
            "PDF417": "CIPDF417BarcodeGenerator",
            "DataMatrix": "CIBarcodeGenerator"
    ]
    
    /// Map between size of data and number of layers in Aztec code barcodes. First tuple value is number of characters
    /// and second tuple value is number of layers.
    /// https://www.barcodebakery.com/en/aztec/dotnet
    static let LayerMap: [(Int,Int)] =
        [
            (15, 1),
            (40, 2),
            (68, 3),
            (89, 4),
            (104, 4),
            (144, 5),
            (187, 6),
            (236, 7),
            (291, 8),
            (348, 9),
            (414, 10),
            (482, 11),
            (554, 12),
            (636, 13),
            (718, 14),
            (808, 15),
            (900, 16),
            (998, 17),
            (1104, 18),
            (1210, 19),
            (1324, 20),
            (1442, 21),
            (1566, 22),
            (1694, 23),
            (1826, 24),
            (1963, 25),
            (2107, 26),
            (2256, 27),
            (2407, 28),
            (2565, 29),
            (2728, 30),
            (2894, 31),
            (3067, 32)
    ]
    
    /// Return the number of layers needed for an Aztec barcode given the payload.
    ///
    /// - Parameter For: Payload that will determine the number of layers needed.
    /// - Returns: Number of layers needed for the payload.
    public static func AztecLayers(For: String) -> Int
    {
        let DataLength = For.count
        if DataLength <= (LayerMap.first?.0)!
        {
            return (LayerMap.first?.1)!
        }
        
        for Index in 0 ..< LayerMap.count
        {
            let LayerMax = LayerMap[Index].0
            let Layer = LayerMap[Index].1
            if DataLength <= LayerMax
            {
                return Layer
            }
        }
        return (LayerMap.last?.1)!
    }
    
    /// Return the maximum payload size for Aztec barcodes.
    ///
    /// - Returns: Maximum payload size for Aztec barcodes.
    public static func MaximumAztecPayloadSize() -> Int
    {
        return (LayerMap.last?.1)!
    }
    
    /// Used to prevent two threads from accessing the barcode creation function simultaneously.
    static let BarcodeLock = NSObject()
    
    /// Create a barcode with the passed data.
    /// https://stackoverflow.com/questions/35790028/swift-generate-qr-code-with-transparent-background
    /// https://stackoverflow.com/questions/22374971/ios-7-core-image-qr-code-generation-too-blur
    /// https://stackoverflow.com/questions/42281398/how-can-i-change-the-color-of-my-qr-code
    ///
    /// - Parameters:
    ///   - from: Data to encode in the barcode. If this is an empty string, nil is returned.
    ///   - WithType: The type of barcode to create.
    ///   - Foreground: Foreground color - defaults to black.
    ///   - Background: Background color - defaults to clear.
    ///   - OverrideSize: If provided, the size of the barcode. Otherwise, it is calculated
    ///                   for the screen and device orientation.
    ///   - Native: Location where the native-sized image is placed.
    /// - Returns: Barcode image on success, nil on failure.
    public static func Create(from: String, WithType: String,
                              Foreground: CIColor? = nil, Background: CIColor? = nil,
                              OverrideSize: CGSize? = nil,
                              Native: inout CIImage?) -> UIImage?
    {
        //No simulteneous generation of barcodes.
        objc_sync_enter(BarcodeLock)
        defer {objc_sync_exit(BarcodeLock)}
        
        if from.isEmpty
        {
            return nil
        }
        let BarcodeForeground = Foreground == nil ? CIColor.black : Foreground!
        let BarcodeBackground = Background == nil ? CIColor.clear : Background!
        let BarcodeSize: CGSize = OverrideSize == nil ? GetBarcodeSize(BarcodeType: WithType) : OverrideSize!
        if OverrideSize != nil
        {
            print("Using BarcodeSize: \(BarcodeSize) from \((OverrideSize)!)")
        }
        let d = from.data(using: .ascii)
        guard let FilterName = FilterMap[WithType] else
        {
            return nil
        }
        let Filter = CIFilter(name: FilterName)
        if Filter == nil
        {
            return nil
        }
        
        switch WithType
        {
        case "Code128":
            Filter?.setValue(d, forKey: "inputMessage")
            Filter?.setValue(0.0, forKey: "inputQuietSpace")
            
        case "CodeAztec":
            Filter?.setValue(d, forKey: "inputMessage")
            Filter?.setValue(6.0, forKey: "inputCorrectionLevel")
            let LayerCount = AztecLayers(For: from)
            Filter?.setValue(Float(LayerCount), forKey: "inputLayers")
            Filter?.setValue(0.0, forKey: "inputCompactStyle")
            
        case "CodeQR3D":
            fallthrough
        case "CodeQR":
            Filter?.setValue(d, forKey: "inputMessage")
            Filter?.setValue("H", forKey: "inputCorrectionLevel")
            
        case "PDF417":
            Filter?.setValue(d, forKey: "inputMessage")
            
        case "DataMatrix":
            #if true
            //Apparently not supported by iOS 12 and earlier.
            return nil
            #else
            let Values = CIDataMatrixCodeDescriptor(payload: d!, rowCount: 10, columnCount: 10,
                                                    eccVersion: CIDataMatrixCodeDescriptor.ECCVersion.v200)
            Filter?.setValue(Values, forKey: "inputBarcodeDescriptor")
            #endif
            
        default:
            return nil
        }
        
        let FakeColor = CIFilter(name: "CIFalseColor")
        FakeColor?.setValue(BarcodeBackground, forKey: "inputColor1")
        FakeColor?.setValue(BarcodeForeground, forKey: "inputColor0")
        FakeColor?.setValue(Filter?.outputImage, forKey: "inputImage")
        if let output = FakeColor?.outputImage
        {
            Native = output
            let FilterOutput: CIImage = output
            //print("FilterOutput0.extent=\(FilterOutput.extent)")
            let x1 = CIContext(options: nil).createCGImage(FilterOutput, from: FilterOutput.extent)
            let ContextWidth = BarcodeSize.width * UIScreen.main.scale
            let ContextHeight = BarcodeSize.height * UIScreen.main.scale
            //print("ContextWidth: \(ContextWidth), ContextHeight: \(ContextHeight)")
            UIGraphicsBeginImageContext(CGSize(width: ContextWidth, height: ContextHeight))
            let Context = UIGraphicsGetCurrentContext()
            Context!.interpolationQuality = .none
            Context?.draw(x1!, in: CGRect(x: 0.0, y: 0.0,
                                          width: Context!.boundingBoxOfClipPath.width,
                                          height: Context!.boundingBoxOfClipPath.height))
            let x2 = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            let final = UIImage(cgImage: (x2?.cgImage!)!, scale: 1.0 / UIScreen.main.scale, orientation: .up)
            
            return final
        }
        return nil
    }
    
    static var BitmapLock = NSObject()
    
    /// Return a barcode bitmap in the form of a two-dimensional boolean array. Some barcodes have only one dimension (Code 128,
    /// for example) - check the number of dimension in the result.
    ///
    /// - Parameters:
    ///   - from: Data to encode in the bitmap.
    ///   - WithType: The type of barcode to create.
    ///   - FinalWidth: Will contain the width of the resultant bitmap.
    ///   - FinalHeight: Will contain the height of the resultant bitmap.
    ///   - Native: Native-resolution barcode image.
    /// - Returns: Two-dimensional array of bits representing the "on" areas of the barcode.
    static func CreateBarcodeBitmap(from: String, WithType: String, FinalWidth: inout Int, FinalHeight: inout Int, Native: inout CIImage?) -> [[Int]]?
    {
        //No simulteneous generation of barcode bitmaps.
        objc_sync_enter(BitmapLock)
        defer {objc_sync_exit(BitmapLock)}
        
        Native = nil
        if from.isEmpty
        {
            print("No data to encode.")
            return nil
        }
        
        let d = from.data(using: .ascii)
        guard let FilterName = FilterMap[WithType] else
        {
            print("Error finding filter name.")
            return nil
        }
        let Filter = CIFilter(name: FilterName)
        if Filter == nil
        {
            print("Error retrieving filter.")
            return nil
        }
        
        switch WithType
        {
        case "Code128":
            Filter?.setValue(d, forKey: "inputMessage")
            Filter?.setValue(0.0, forKey: "inputQuietSpace")
            
        case "CodeAztec":
            Filter?.setValue(d, forKey: "inputMessage")
            Filter?.setValue(6.0, forKey: "inputCorrectionLevel")
            let LayerCount = AztecLayers(For: from)
            Filter?.setValue(Float(LayerCount), forKey: "inputLayers")
            Filter?.setValue(0.0, forKey: "inputCompactStyle")
            
        case "CodeQR3D":
            fallthrough
        case "CodeQR":
            Filter?.setValue(d, forKey: "inputMessage")
            Filter?.setValue("H", forKey: "inputCorrectionLevel")
            
        case "PDF417":
            Filter?.setValue(d, forKey: "inputMessage")
            
        case "DataMatrix":
            #if true
            //Apparently not supported by iOS 12 and earlier.
            return nil
            #else
            let Values = CIDataMatrixCodeDescriptor(payload: d!, rowCount: 10, columnCount: 10,
                                                    eccVersion: CIDataMatrixCodeDescriptor.ECCVersion.v200)
            Filter?.setValue(Values, forKey: "inputBarcodeDescriptor")
            #endif
            
        default:
            return nil
        }
        
        let FakeColor = CIFilter(name: "CIFalseColor")
        //Set background color to white.
        FakeColor?.setValue(CIColor.yellow, forKey: "inputColor1")
        //Set foreground color to black.
        FakeColor?.setValue(CIColor.black, forKey: "inputColor0")
        FakeColor?.setValue(Filter?.outputImage, forKey: "inputImage")
        if let output = FakeColor?.outputImage
        {
            Native = output
            let Context = CIContext(options: nil)
            let BCImage = Context.createCGImage(output, from: output.extent)
            //let xfname: CFString = (BCImage?.colorSpace?.name)!
            //let csname: String = xfname as String
            //print("Filter barcode format: \(csname)")
            //let ComponentsPerPixel: Int = (BCImage?.colorSpace?.numberOfComponents)!
            //print("Filter barcode components: \(ComponentsPerPixel)")
            //let BGW: Int = (BCImage?.width)!
            //let BGH: Int = (BCImage?.height)!
            //print("Filter barcode size: \(BGW)x\(BGH)")
            let BytesPerRow: Int = (BCImage?.bytesPerRow)!
            let BitsPerPixel: Int = (BCImage?.bitsPerPixel)!
            let BitsPerComponent: Int = (BCImage?.bitsPerComponent)!
            
            let PixelData = BCImage?.dataProvider!.data
            let Data: UnsafePointer<UInt8> = CFDataGetBytePtr(PixelData)
            
            let Width: Int = Int(output.extent.width)
            let Height: Int = Int(output.extent.height)
            FinalWidth = Width
            FinalHeight = Height
            var Results = Array(repeating: Array(repeating: 0, count: Width), count: Height)
            
            let ColorSize = BitsPerPixel / BitsPerComponent
            for Row in 0 ... Height - 1
            {
                let RowOffset = ((Height - 1) - Row) * BytesPerRow
                for Column in 0 ... Width - 1
                {
                    let Address: Int = RowOffset + (Column * ColorSize)
                    let R = Data[Address + 0]
                    let G = Data[Address + 1]
                    let B = Data[Address + 2]
                    let Sum: Int = Int(R) + Int(G) + Int(B)
                    Results[Row][Column] = Sum <= 100 ? 1 : 0
                }
            }
            
            return Results
        }
        //print("Error from filter output.")
        FinalWidth = 0
        FinalHeight = 0
        return nil
    }
    
    /// Given a barcode type, return the screen size of the final image of the barcode.
    ///
    /// - Parameter BarcodeType: The type of barcode that will determine the final size.
    /// - Returns: Size of the barcode to render.
    static func GetBarcodeSize(BarcodeType: String) -> CGSize
    {
        var IsPortrait = true
        if  UIDevice.current.orientation != .portrait && UIDevice.current.orientation != .portraitUpsideDown
        {
            IsPortrait = false
        }
        var NewSize = CGSize(width: 0, height: 0)
        if IsPortrait
        {
            switch BarcodeType
            {
            case "Code128":
                NewSize = CGSize(width: 400, height: 150)
                
            case "CodeQR3D":
                fallthrough
            case "CodeQR":
                NewSize = CGSize(width: 400, height: 400)
                
            case "CodeAztec":
                NewSize = CGSize(width: 400, height: 400)
                
            case "PDF417":
                NewSize = CGSize(width: 400, height: 200)
                
            case "DataMatrix":
                NewSize = CGSize(width: 400, height: 400)
                
            default:
                return CGSize(width: 0, height: 0)
            }
        }
        else
        {
            switch BarcodeType
            {
            case "Code128":
                NewSize = CGSize(width: 700, height: 200)
                
            case "CodeQR3D":
                fallthrough
            case "CodeQR":
                NewSize = CGSize(width: 350, height: 350)
                
            case "CodeAztec":
                NewSize = CGSize(width: 300, height: 300)
                
            case "PDF417":
                NewSize = CGSize(width: 350, height: 170)
                
            case "DataMatrix":
                NewSize = CGSize(width: 350, height: 350)
                
            default:
                return CGSize(width: 0, height: 0)
            }
        }
        if UIDevice.current.userInterfaceIdiom == .pad
        {
            NewSize = CGSize(width: NewSize.width * 2.5, height: NewSize.height * 2.5)
        }
        return NewSize
    }
}
