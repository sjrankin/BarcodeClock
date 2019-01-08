//
//  CARadialGradientLayer3.swift
//  Visualizer Clock
//
//  Created by Stuart Rankin on 1/4/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import CoreImage

/// Radial gradient layer to implement what iOS doesn't. This class only draws radial gradients - all clock-like functions occur
/// elsewhere in other classes.
///  -Note:
/// https://stackoverflow.com/questions/26907352/how-to-draw-radial-gradients-in-a-calayer
class CARadialGradientLayer3: CALayer
{
    let _Settings = UserDefaults.standard
    
    /// Initializer.
    ///
    /// - Parameter ColorGradient: The (single) radial gradient description.
    init(ColorGradient: RadialGradientDescriptor)
    {
        super.init()
        needsDisplayOnBoundsChange = true
        Gradients = [ColorGradient]
        GenerateHandle()
    }
    
    /// Initializer.
    ///
    /// - Parameter ColorGradients: List of radial gradient descriptions to render.
    init(ColorGradients: [RadialGradientDescriptor])
    {
        super.init()
        needsDisplayOnBoundsChange = true
        Gradients = ColorGradients
        GenerateHandle()
    }
    
    /// Initializer. Minimal initialization done. Nothing to draw until the caller adds
    /// radial gradient descriptions.
    required override init()
    {
        super.init()
        needsDisplayOnBoundsChange = true
        GenerateHandle()
    }
    
    /// Init.
    ///
    /// - Parameter aDecoder: See iOS documentation.
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    /// Init.
    ///
    /// - Parameter layer: See iOS documentation.
    required override init(layer: Any)
    {
        super.init(layer: layer)
    }
    
    private func GenerateHandle()
    {
        Handle = VectorHandle.Make()
        Handle?.RadialBlendMode = 0
        Handle?.GradientFilter = 0
    }
    
    private var _Handle: VectorHandle? = nil
    /// Get or set the handle used to instruct the layer how to draw gradients. This value may change at any time.
    public var Handle: VectorHandle?
{
    get
    {
        return _Handle
        }
        set
        {
            _Handle = newValue
        }
    }
    
    private var _GeneralBackgroundColor: UIColor = UIColor.yellow
    /// Get or set the general background color (which isn't much use when the background is a changing gradient). Used for
    /// color optimization for radial edges with semi-transparent colors.
    public var GeneralBackgroundColor: UIColor
    {
        get
        {
            return _GeneralBackgroundColor
        }
        set
        {
            _GeneralBackgroundColor = newValue
            for Gradient in Gradients
            {
                Gradient.SetGeneralBackgroundColor(_GeneralBackgroundColor)
            }
        }
    }
    
    private var _Gradients: [RadialGradientDescriptor] = [RadialGradientDescriptor]()
    /// Get or set the list of radial gradient descriptions to draw.
    public var Gradients: [RadialGradientDescriptor]
    {
        get
        {
            return _Gradients
        }
        set
        {
            _Gradients = newValue
            for Gradient in _Gradients
            {
                Gradient.SetGeneralBackgroundColor(GeneralBackgroundColor)
            }
        }
    }
    
    /// Return a blending mode for compositing radial gradients together.
    ///
    /// - Returns: The blend mode to use (based on user settings).
    private func GetBlendMode() -> CGBlendMode
    {
        switch Handle?.RadialBlendMode
        {
        case 0:
            return .plusLighter
            
        case 1:
            return .screen
            
        case 2:
            return .multiply
            
        case 3:
            return .colorDodge
            
        case 4:
            return .luminosity
            
        case 5:
            return .softLight
            
        default:
            return .plusLighter
        }
    }
    
    /// Combine the passed list of images using a blend mode to result in a rather gaudy-looking result.
    ///
    /// - Parameters:
    ///   - ImageList: List of images to combine/composite together. Assumed (but not required to be) radial
    ///                gradients generated elsewhere.
    ///   - ImageSize: The size of the final image of composited sub-images.
    /// - Returns: Image composited with the list of sub-images.
    private func CombineImages(ImageList: [UIImage], ImageSize: CGSize) -> UIImage
    {
        UIGraphicsBeginImageContext(ImageSize)
        let ImageFrame = CGRect(x: 0, y: 0, width: ImageSize.width, height: ImageSize.height)
        ImageList[0].draw(in: ImageFrame)
        for Index in 1 ..< ImageList.count
        {
            let BlendMode = GetBlendMode()
            ImageList[Index].draw(in: ImageFrame, blendMode: BlendMode, alpha: 1.0)
        }
        let Composited = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return Composited!
    }
    
    /// Apply a CIFilter to the passed image. The passed image is assumed to be (but not required to be) a composited image from
    /// at least one radial gradient description.
    ///
    /// - Parameters:
    ///   - Image: The image to which the filter will be applied.
    ///   - Center: The center of the target.
    ///   - FilterIndex: Determines the index to apply. Invalid indicies result in the original image returned unchanged.
    /// - Returns: The filtered image on success, original image on error.
    func ApplyGradientFilter(_ Image: UIImage, Center: CGPoint, FilterIndex: Int) -> UIImage?
    {
        let CGI = CIImage(cgImage: (Image.cgImage)!)
        switch FilterIndex
        {
        case 1:
            if let Filter = CIFilter(name: "CIPhotoEffectMono")
            {
                Filter.setDefaults()
                Filter.setValue(CGI, forKey: kCIInputImageKey)
                let Context = CIContext(options: nil)
                let ImageRef = Context.createCGImage(Filter.outputImage!, from: CGI.extent)
                return UIImage(cgImage: ImageRef!)
            }
            else
            {
                print("Error getting CIPhotoEffectMono.")
                return nil
            }
            
        case 2:
            if let Filter = CIFilter(name: "CICircularScreen")
            {
                Filter.setDefaults()
                let Center = CIVector(x: Center.x, y: Center.y)
                Filter.setValue(Center, forKey: kCIInputCenterKey)
                Filter.setValue(CGI, forKey: kCIInputImageKey)
                let Context = CIContext(options: nil)
                let ImageRef = Context.createCGImage(Filter.outputImage!, from: CGI.extent)
                return UIImage(cgImage: ImageRef!)
            }
            else
            {
                print("Error getting CICircularScreen")
                return nil
            }
            
        case 3:
            if let Filter = CIFilter(name: "CICMYKHalftone")
            {
                Filter.setDefaults()
                Filter.setValue(CGI, forKey: kCIInputImageKey)
                let Context = CIContext(options: nil)
                let ImageRef = Context.createCGImage(Filter.outputImage!, from: CGI.extent)
                return UIImage(cgImage: ImageRef!)
            }
            else
            {
                print("Error getting CICMYKHalftone")
                return nil
            }
            
        case 4:
            if let Filter = CIFilter(name: "CITwirlDistortion")
            {
                Filter.setDefaults()
                let Center = CIVector(x: Center.x, y: Center.y)
                Filter.setValue(Center, forKey: kCIInputCenterKey)
                Filter.setValue(CGI, forKey: kCIInputImageKey)
                Filter.setValue(Center.x, forKey: kCIInputRadiusKey)
                //                Filter.setValue(150.0, forKey: kCIInputRadiusKey)
                //                let AngleValue = SecondsInRadians() * 10.0
                //                Filter.setValue(AngleValue, forKey: kCIInputAngleKey)
                Filter.setValue(CGFloat.pi, forKey: kCIInputAngleKey)
                let Context = CIContext(options: nil)
                let ImageRef = Context.createCGImage(Filter.outputImage!, from: CGI.extent)
                return UIImage(cgImage: ImageRef!)
            }
            else
            {
                print("Error getting CITwirlDistortion")
                return nil
            }
            
        default:
            return Image
        }
    }
    
    /// Returns the number of seconds in the current minute in radians.
    ///
    /// - Returns: Seconds in Minute / 60.0 * pi / 180.0
    func SecondsInRadians() -> CGFloat
    {
        let Cal = Calendar.current
        let Seconds = Cal.component(.second, from: Date())
        let Percent: CGFloat = CGFloat(Seconds) / 60.0
        return Percent// * (CGFloat.pi / 180.0)
    }
    
    /// Draw the layer. All gradients are drawn then composited (with an optional filter applied) then drawn into the passed context.
    ///
    /// - Parameter Context: Context where the drawing will occur.
    override func draw(in Context: CGContext)
    {
        Context.clip(to: CGRect.AdjustOriginAndSize(UIScreen.main.bounds, OriginBy: 1.0, SizeBy: -2.0))
        sublayers?.forEach{$0.removeFromSuperlayer()}
        var LayerImage = [UIImage]()
        for Layer in Gradients
        {
            Layer.setNeedsDisplay()
            UIGraphicsBeginImageContext(CGSize(width: frame.width, height: frame.height))
            defer{UIGraphicsEndImageContext()}
            guard let Context = UIGraphicsGetCurrentContext()
            else
            {
                fatalError("Error getting context in CARadialGradientLayer3.draw")
            }
            Layer.render(in: Context)
            let Rendered = UIGraphicsGetImageFromCurrentImageContext()
            LayerImage.append(Rendered!)
        }
        shouldRasterize = true
        rasterizationScale = UIScreen.main.scale
        var Final = CombineImages(ImageList: LayerImage, ImageSize: CGSize(width: frame.width, height: frame.height))
        if (Handle?.GradientFilter)! > 0
        {
            let Center = CGPoint(x: frame.width / 2.0, y: frame.height / 2.0)
            Final = ApplyGradientFilter(Final, Center: Center, FilterIndex: (Handle?.GradientFilter)!)!
        }
        Context.draw(Final.cgImage!, in: frame)
    }
}
