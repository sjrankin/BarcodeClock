//: A UIKit based Playground for presenting user interface
  
import UIKit
import Foundation
import PlaygroundSupport
import Accelerate

class MyViewController : UIViewController
{
    func DumpBits(_ Raw: [[Int]], Width: Int, Height: Int)
    {
        let ColumnHeader = "0123456789"
        let ColumnRepeats = (Width / 10)
        var ColumnData = ""
        for _ in 0 ... ColumnRepeats
        {
            ColumnData = ColumnData + ColumnHeader
        }
        ColumnData = "     " + ColumnData
        print(ColumnData)
        for Row in 0 ... Height - 1
        {
            var RowString = String(format: "%03d", Row) + ": "
            for Column in 0 ... Width - 1
            {
                RowString = RowString + String(Raw[Row][Column])
            }
            print(RowString)
        }
    }
    
    func CreateIndexedImage(Source: UIImage)
    {
        
    }
    
    func DumpImage(Image: UIImage)
    {
        let Width: Int = Int(Image.size.width)
        let Height: Int = Int(Image.size.height)
        let CGImg: CGImage? = Image.cgImage
        if CGImg == nil
        {
            print("Error getting cgImage.")
            return
        }
        let BPP: Int = (CGImg?.bitsPerPixel)!
        print("Image bits/pixel: \(BPP)")
        let BPC: Int = (CGImg?.bitsPerComponent)!
        print("Image bits/component: \(BPC)")
        let iw: Int = (CGImg?.width)!
        let ih: Int = (CGImg?.height)!
        print("Image dimensions: \(iw),\(ih)")
        let ByPR: Int = (CGImg?.bytesPerRow)!
        print("Image bytes/row: \(ByPR)")
        let ics: CFString = (CGImg?.colorSpace?.name)!
        let csname: String = ics as String
        print("Image colorspace: \(csname)")
        let CPP: Int = (CGImg?.colorSpace?.numberOfComponents)!
        print("Image components/pixel: \(CPP)")
        
        var Raw = Array(repeating: Array(repeating: 0, count: Width), count: Height)
        let PixelData = CGImg!.dataProvider!.data
        let Data: UnsafePointer<UInt8> = CFDataGetBytePtr(PixelData)
        
        let ColorSize = BPP / BPC
        print("ColorSize: \(ColorSize) bytes")
        
        for Row in 0 ... Height - 1
        {
            let Offset = Row * ByPR
            for Column in 0 ... Width - 1
            {
                let Address: Int = Offset + (Column * ColorSize)
                let R = Data[Address + 0]
                let G = Data[Address + 1]
                let B = Data[Address + 2]
                let Sum: Int = Int(R) + Int(G) + Int(B)
                print("RGB: (\(R),\(G),\(B)), Sum: \(Sum)")
                Raw[Row][Column] = Sum <= 100 ? 1 : 0
            }
            //DumpBits(Raw, Width: Width, Height: 1)
            //return
        }
        DumpBits(Raw, Width: Width, Height: Height)
    }
    
    override func loadView()
    {
        let view = UIView()
        view.backgroundColor = .white
        let IView = UIImageView()
        IView.backgroundColor = UIColor.clear
        IView.contentMode = .center
        IView.frame = view.frame
        IView.bounds = view.bounds
        //let Image = UIImage(named: "Code128Test.JPG")
        let Image = UIImage(named: "QRTest.JPG")
        IView.image = Image
        self.view = IView
        DumpImage(Image: Image!)
    }
}
// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()
