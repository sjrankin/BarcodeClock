//
//  BarcodePharmaCodeClock.swift
//  Visualizer Clock
//
//  Created by Stuart Rankin on 12/20/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// One-dimensional barcodes used as clocks. The barcodes returned by this clock are all drawn "by-hand," eg, in code in this
/// class rather than using CIFilter or other libraries.
class Barcode1DClock: ClockProtocol, SupportsIndirectSettings
{
    /// Types of barcodes that we draw "by hand" rather than relying on CIFilter to draw for us. This is
    /// because CIFilter doesn't handle these barcodes so we have to do it ourselves.
    ///
    /// - Pharmacode: Pharmacode barcode.
    /// - POSTNET: USPS POSTNET barcode.
    /// - Code11: Code 11 barcode.
    enum DrawnBarcodes
    {
        case Pharmacode
        case POSTNET
        case Code11
    }
    
    let _Settings = UserDefaults.standard
    
    /// Initialize the clock.
    ///
    /// - Parameters:
    ///   - SurfaceSize: The surface rectangle where the clock will be drawn.
    ///   - BarcodeType: The type of clock to draw.
    init(SurfaceSize: CGSize, BarcodeType: DrawnBarcodes = .Pharmacode)
    {
        _DrawType = BarcodeType
        CommonInitialization(SurfaceSize)
    }
    
    weak var delegate: MainUIProtocol? = nil
    
    /// Execute common initialization.
    ///
    /// - Parameter SurfaceSize: Surface size of where to draw the clock.
    private func CommonInitialization(_ SurfaceSize: CGSize)
    {
        Handle = VectorHandle.Make()
        switch DrawType
        {
        case .Pharmacode:
            _ClockName = "Pharmacode"
            _SegueID = "ToOneDBarcodeSettings"
            _ClockType = PanelActions.SwitchToPharmaCode
            _ClockID = UUID(uuidString: Clocks.ClockIDMap[PanelActions.SwitchToPharmaCode]!)!
            
        case .POSTNET:
            _ClockName = "POSTNET"
            _SegueID = "ToOneDBarcodeSettings"
            _ClockType = PanelActions.SwitchToPOSTNET
            _ClockID = UUID(uuidString: Clocks.ClockIDMap[PanelActions.SwitchToPOSTNET]!)!
            
        case .Code11:
            break
        }
        ViewPortSize = SurfaceSize
        ViewPortCenter = CGPoint(x: ViewPortSize.width / 2, y: ViewPortSize.height / 2)
        delegate?.ClockStarted(ID: ClockID)
        print("Instantiated clock \(ClockName)")
    }
    
    var _ClockType = PanelActions.SwitchToPharmaCode
    /// Returns the type of clock.
    func GetClockType() -> PanelActions
    {
        return _ClockType
    }
    
    private var _DrawType: DrawnBarcodes = .Pharmacode
    public var DrawType: DrawnBarcodes
    {
        get
        {
            return _DrawType
        }
    }
    
    private var _ClockName: String = "Pharmacode"
    public var ClockName: String
    {
        get
        {
            return _ClockName
        }
    }
    
    /// Will contain the ID of the clock.
    private var _ClockID: UUID = UUID(uuidString: Clocks.ClockIDMap[PanelActions.SwitchToPharmaCode]!)!
    /// Get the ID of the clock.
    public var ClockID: UUID
    {
        get
        {
            return _ClockID
        }
    }
    
    private var ViewPortSize: CGSize!
    private var ViewPortCenter: CGPoint!
    private var ClockTimer: Timer? = nil
    
    private func InitializeClockTimer()
    {
        let Interval = TimeInterval(1.0)
        ClockTimer = Timer.scheduledTimer(timeInterval: Interval, target: self,
                                          selector: #selector(UpdateClock), userInfo: nil, repeats: true)
    }
    
    @objc func UpdateClock()
    {
        let TheTime = Date()
        if NewSecond(TheTime)
        {
            delegate?.OneSecondTick(ID: ClockID, Time: TheTime)
        }
        delegate?.CheckForDarkMode(TheTime)
        DrawClock(WithTime: TheTime)
    }
    
    /// Determines if a new second has occurred.
    ///
    /// - Parameter Time: The time used to check for new second state.
    /// - Returns: True if a new second occurred, false if not.
    func NewSecond(_ Time: Date) -> Bool
    {
        let Cal = Calendar.current
        let Second = Cal.component(.second, from: Time)
        if Second != PreviousSecond
        {
            PreviousSecond = Second
            return true
        }
        return false
    }
    
    var PreviousSecond: Int = -1
    
    /// Object used to synchronize the function that draws the clock.
    var ClockLock = NSObject()
    
    /// Draw the clock. Notifies the Main UI of major tasks.
    ///
    /// - Parameter WithTime: Time to use to draw the clock.
    func DrawClock(WithTime: Date)
    {
        objc_sync_enter(ClockLock)
        defer {objc_sync_exit(ClockLock)}
        
        delegate?.PreparingClockUpdate(ID: ClockID)
        DoDrawClock(WithTime)
        delegate?.UpdateMainView(ID: ClockID, WithView: SurfaceView)
        delegate?.FinishedClockUpdate(ID: ClockID)
    }
    
    public func DoDrawClock(_ WithTime: Date)
    {
        if PreviousTime == nil
        {
            PreviousTime = WithTime
        }
        else
        {
            if SecondsEqual(PreviousTime!, WithTime)
            {
                return
            }
        }
        PreviousTime = WithTime
        
        SurfaceView = UIView()
        SurfaceView.frame = CGRect(x: 0, y: 0, width: ViewPortSize.width, height: ViewPortSize.height)
        SurfaceView.backgroundColor = UIColor.clear
        var Final: Int = 0
        switch DrawType
        {
        case .Pharmacode:
            Final = Utility.GetTimeStampToEncodeI(From: WithTime, false)
            
        case .POSTNET:
            Final = Utility.GetTimeStampToEncodeI(From: WithTime, true)
            
        case .Code11:
            break
        }
        
        let BarcodeView = UIView()
        BarcodeView.contentMode = .scaleAspectFit
        BarcodeView.backgroundColor = UIColor.clear
        BarcodeView.clipsToBounds = true
        BarcodeView.bounds = SurfaceView.bounds
        BarcodeView.frame = SurfaceView.frame
        var BarcodeWidth: CGFloat = 0.0
        var BarcodeHeight: CGFloat = 0.0
        let MinDim = min(BarcodeView.frame.height, BarcodeView.frame.width)
        
        switch DrawType
        {
        case .Pharmacode:
            BarcodeWidth = BarcodeView.frame.width * 0.9
            BarcodeHeight = MinDim * 0.9 * CGFloat(_Settings.double(forKey: Setting.Key.Pharma.BarcodeHeight))
            Handle!.TargetCenter = CGPoint(x: BarcodeView.frame.width / 2.0, y: BarcodeView.frame.height / 2.0)
            Handle!.Foreground = _Settings.uicolor(forKey: Setting.Key.Pharma.BarcodeForegroundColor1)!
            Handle!.HighlightColor = _Settings.uicolor(forKey: Setting.Key.Pharma.BarcodeForegroundColor2)!
            Handle!.ViewHeight = Int(BarcodeHeight)
            Handle!.ViewWidth = Int(BarcodeWidth)
            let Radius = (MinDim * 0.90) / 2.0
            Handle!.InnerRadius = Double(CGFloat(_Settings.double(forKey: Setting.Key.Pharma.InnerRadius)) * Radius)
            Handle!.OuterRadius = Double(CGFloat(_Settings.double(forKey: Setting.Key.Pharma.OuterRadius)) * Radius)
            Handle!.WaveEffects = _Settings.integer(forKey: Setting.Key.Pharma.WavyHeights)
            Handle!.BarcodeShape = _Settings.integer(forKey: Setting.Key.Pharma.BarcodeShape)
            Handle!.ShadowLevel = _Settings.integer(forKey: Setting.Key.Pharma.ShadowEffect)
            Handle!.HighlightStyle = _Settings.integer(forKey: Setting.Key.Pharma.SpecialEffect)
            Handle!.ShowDigits = _Settings.bool(forKey: Setting.Key.Pharma.IncludeDigits)
            Handle!.VaryColorByLength = _Settings.bool(forKey: Setting.Key.Pharma.ColorsVaryByThickness)
            Handle!.ShortColor = _Settings.uicolor(forKey: Setting.Key.Pharma.ThickForeground)
            Handle!.LongColor = _Settings.uicolor(forKey: Setting.Key.Pharma.ThinForeground)
            Handle!.HeightMultiplier = _Settings.double(forKey: Setting.Key.Pharma.BarcodeHeight)
            Handle!.EnablePrint = true
            Handle!.PrintPrefix = "Clock"
            
        case .POSTNET:
            switch _Settings.integer(forKey: Setting.Key.POSTNET.BarcodeShape)
            {
            case 0:
                BarcodeWidth = BarcodeView.frame.width * 0.95
                BarcodeHeight = MinDim * 0.35
                
            case 1:
                fallthrough
            case 2:
                BarcodeWidth = MinDim * 0.95
                BarcodeHeight = BarcodeWidth

            default:
                fatalError("Unknown barcode shape encountered.")
            }
            Handle!.TargetCenter = CGPoint(x: BarcodeView.frame.width / 2.0, y: BarcodeView.frame.height / 2.0)
            Handle!.Foreground = _Settings.uicolor(forKey: Setting.Key.POSTNET.BarcodeForegroundColor1)!
            Handle!.HighlightColor = _Settings.uicolor(forKey: Setting.Key.POSTNET.BarcodeForegroundColor2)!
            Handle!.ViewHeight = Int(BarcodeHeight)
            Handle!.ViewWidth = Int(BarcodeWidth)
            let Radius = (MinDim * 0.95) / 2.0
            Handle!.InnerRadius = Double(CGFloat(_Settings.double(forKey: Setting.Key.POSTNET.InnerRadius)) * Radius)
            Handle!.OuterRadius = Double(CGFloat(_Settings.double(forKey: Setting.Key.POSTNET.OuterRadius)) * Radius)
            Handle!.WaveEffects = _Settings.integer(forKey: Setting.Key.POSTNET.WavyHeights)
            Handle!.BarcodeShape = _Settings.integer(forKey: Setting.Key.POSTNET.BarcodeShape)
            Handle!.ShadowLevel = _Settings.integer(forKey: Setting.Key.POSTNET.ShadowEffect)
            Handle!.HighlightStyle = _Settings.integer(forKey: Setting.Key.POSTNET.SpecialEffect)
            Handle!.IncludeCheckDigit = _Settings.bool(forKey: Setting.Key.POSTNET.IncludeCheckDigit)
            Handle!.VaryColorByLength = _Settings.bool(forKey: Setting.Key.POSTNET.ColorsVaryOnLength)
            Handle!.ShortColor = _Settings.uicolor(forKey: Setting.Key.POSTNET.ShortForeground)
            Handle!.LongColor = _Settings.uicolor(forKey: Setting.Key.POSTNET.LongForeground)
            Handle!.HeightMultiplier = _Settings.double(forKey: Setting.Key.POSTNET.BarcodeHeight)
            Handle!.EnablePrint = false
            Handle!.PrintPrefix = "Clock"
            Handle?.fprint("Radius=\(Radius)")
            
        case .Code11:
            break
        }
        let FinalSize = CGSize(width: BarcodeWidth, height: BarcodeHeight)
        if let BarView = Barcode1DClock.MakeBarcode(Handle: Handle!, BarcodeType: DrawType, From: Final, ImageSize: FinalSize)
        {
            BarcodeView.addSubview(BarView)
            SurfaceView.addSubview(BarcodeView)
        }
        else
        {
            print("No view returned from MakeBarcode")
        }
    }
    
    var Handle: VectorHandle? = nil
    
    public func MakeBarcode(Handle: VectorHandle, From: Int, _ TargetView: UIView) -> UIView?
    {
        return Barcode1DClock.MakeBarcode(Handle: Handle, BarcodeType: DrawType, From: From, TargetView)
    }
    
    static var BarcodeCreationLock = NSObject()
    
    /// Create a Pharma Code barcode and return it in the returned view.
    ///
    /// - Parameters:
    ///   - From: The data to encode (must be in the range of 3 to 131070).
    ///   - TargetView: Description of where the return view will be placed.
    /// - Returns: UIView with the Pharma Code barcode. Nil on error.
    public static func MakeBarcode(Handle: VectorHandle, BarcodeType: DrawnBarcodes, From: Int, _ TargetView: UIView) -> UIView?
    {
        objc_sync_enter(BarcodeCreationLock)
        defer{objc_sync_exit(BarcodeCreationLock)}
        let NewView = UIView()
        NewView.backgroundColor = UIColor.clear
        NewView.frame = TargetView.frame
        NewView.bounds = TargetView.bounds
        let RSize = min(NewView.frame.width, NewView.frame.height)
        let FinalSize = CGSize(width: RSize, height: RSize)
        var BarcodeLayer: CAShapeLayer!
        switch BarcodeType
        {
        case .Pharmacode:
            BarcodeLayer = GetPharmaBarcodeLayer(Handle: Handle, From: From, ImageSize: FinalSize,
                                                 ParentSize: CGSize(width: TargetView.frame.width, height: TargetView.frame.height))
            
        case .POSTNET:
            BarcodeLayer = GetPOSTNETBarcodeLayer(Handle: Handle, From: From, ImageSize: FinalSize,
                                                  ParentSize: CGSize(width: TargetView.frame.width, height: TargetView.frame.height))
            
        case .Code11:
            break
        }
        
        NewView.layer.addSublayer(BarcodeLayer!)
        return NewView
    }
    
    static var MakeBarcodeLock = NSObject()
    
    public static func MakeBarcode(Handle: VectorHandle, BarcodeType: DrawnBarcodes, From: Int, TargetFrame: CGRect, TargetBounds: CGRect) -> UIView?
    {
        objc_sync_enter(MakeBarcodeLock)
        defer{objc_sync_exit(MakeBarcodeLock)}
        let NewView = UIView()
        NewView.backgroundColor = UIColor.clear
        NewView.frame = TargetFrame
        NewView.bounds = TargetBounds
        //print("MakeBarcode: Frame=\(TargetFrame), Bounds=\(TargetBounds)")
        let RSize = min(NewView.frame.width, NewView.frame.height)
        let FinalSize = CGSize(width: RSize, height: RSize)
        var BarcodeLayer: CAShapeLayer!
        switch BarcodeType
        {
        case .Pharmacode:
            BarcodeLayer = GetPharmaBarcodeLayer(Handle: Handle, From: From, ImageSize: FinalSize,
                                                 ParentSize: CGSize(width: TargetFrame.width, height: TargetFrame.height))
            
        case .POSTNET:
            BarcodeLayer = GetPOSTNETBarcodeLayer(Handle: Handle, From: From, ImageSize: FinalSize,
                                                  ParentSize: CGSize(width: TargetFrame.width, height: TargetFrame.height))
            
        case .Code11:
            break
        }
        NewView.layer.addSublayer(BarcodeLayer!)
        return NewView
    }
    
    public static func MakeBarcode(Handle: VectorHandle, BarcodeType: DrawnBarcodes, From: Int, ImageSize: CGSize, ParentSize: CGSize? = nil) -> UIView?
    {
        objc_sync_enter(MakeBarcodeLock)
        defer{objc_sync_exit(MakeBarcodeLock)}
        var FinalParentSize: CGSize!
        if let ParentSize = ParentSize
        {
            FinalParentSize = ParentSize
        }
        else
        {
            FinalParentSize = UIScreen.main.bounds.size
        }
        let NewView = UIView()
        NewView.backgroundColor = UIColor.clear
        NewView.frame = CGRect(origin: CGPoint.zero, size: ImageSize)
        NewView.bounds = CGRect(origin: CGPoint.zero, size: ImageSize)
        if let BarcodeLayer = GetBarcodeLayer(Handle: Handle, BarcodeType: BarcodeType, From: From, ImageSize: ImageSize, ParentSize: FinalParentSize)
        {
            NewView.layer.addSublayer(BarcodeLayer)
            return NewView
        }
        return nil
    }
    
    public static func GetBarcodeImage(Handle: VectorHandle, BarcodeType: DrawnBarcodes, From: Int, ImageSize: CGSize? = nil) -> UIImage?
    {
        if let BarcodeLayer = Barcode1DClock.GetBarcodeLayer(Handle: Handle, BarcodeType: BarcodeType, From: From, ImageSize: ImageSize, ParentSize: nil)
        {
            UIGraphicsBeginImageContextWithOptions(ImageSize!, false, UIScreen.main.scale)
            defer {UIGraphicsEndImageContext()}
            guard let Context = UIGraphicsGetCurrentContext() else
            {
                print("Error getting graphics context.")
                return nil
            }
            BarcodeLayer.render(in: Context)
            return UIGraphicsGetImageFromCurrentImageContext()
        }
        else
        {
            print("Error returned from BarcodePharmaCodeClock.GetBarcodeLayer")
            return nil
        }
    }
    
    /// Returns a shape layer with the specified barcode in it.
    ///
    /// - Parameters:
    ///   - Handle: Describes how to draw the barcode.
    ///   - BarcodeType: The type of barcode to generate.
    ///   - From: Data to encode in the barcode.
    ///   - ImageSize: Image size. If nil, native image size is used.
    ///   - ParentSize: The size of the parent, if present.
    /// - Returns: CAShapeLayer with the barcode encoded as sub-layers. Nil returned on error.
    public static func GetBarcodeLayer(Handle: VectorHandle, BarcodeType: DrawnBarcodes, From: Int, ImageSize: CGSize? = nil,
                                       ParentSize: CGSize? = nil) -> CAShapeLayer?
    {
        switch BarcodeType
        {
        case .Pharmacode:
            return GetPharmaBarcodeLayer(Handle: Handle, From: From, ImageSize: ImageSize, ParentSize: ParentSize)
            
        case .POSTNET:
            return GetPOSTNETBarcodeLayer(Handle: Handle, From: From, ImageSize: ImageSize, ParentSize: ParentSize)
            
        default:
            return CAShapeLayer()
        }
    }
    
    // MARK: Pharmacode drawing functions.
    
    /// Create a pharma barcode shape layer. The shape of the resultant barcode is dependent on the Handle.
    ///
    /// - Parameters:
    ///   - Handle: Describes how to draw the barcode.
    ///   - From: The contents of the barcode.
    ///   - ImageSize: Image size of the barcode (eg, target size).
    ///   - ParentSize: Size of the parent where the barcode will be placed.
    /// - Returns: Shape layer with the contents of the barcode.
    public static func GetPharmaBarcodeLayer(Handle: VectorHandle, From: Int, ImageSize: CGSize? = nil,
                                             ParentSize: CGSize? = nil) -> CAShapeLayer?
    {
        switch Handle.BarcodeShape
        {
        case 0:
            return GetLinearPharmacodeBarcodeLayer(Handle: Handle, From: From, ImageSize: ImageSize, ParentSize: ParentSize)
            
        case 1:
            return GetRadialPharmacodeBarcodeLayer(Handle: Handle, From: From, ImageSize: ImageSize, ParentSize: ParentSize)
            
        case 2:
            return GetTargetPharmacodeBarcodeLayer(Handle: Handle, From: From, ImageSize: ImageSize, ParentSize: ParentSize)
            
        default:
            fatalError("Invalid barcode shape specified in GetPharmaBarcodeLayer")
        }
    }
    
    /// Create a node shape layer. Each node in a barcode gets its own shape layer.
    ///
    /// - Parameters:
    ///   - Handle: Describes how to draw the barcode.
    ///   - Frame: The frame of the returned shape layer. Should be as large as the parent UIView.
    ///   - Path: Path that describes the location and size of the node.
    ///   - NodeShape: Determines the shape of the node to draw.
    ///   - IsDelta: Determines if the layer being drawn is a delta layer (eg, different from the previous barcode).
    ///   - IsThick: Determines if the layer is thick or thin.
    /// - Returns: Shape layer with the node.
    private static func CreatePharmaCodeLayer(Handle: VectorHandle, Frame: CGRect, Path: CGPath,
                                              NodeShape: Int = 0, IsDelta: Bool = false, IsThick: Bool = false) -> CAShapeLayer
    {
        let Layer = CAShapeLayer()
        Layer.frame = Frame
        Layer.bounds = Frame
        Layer.backgroundColor = UIColor.clear.cgColor
        Layer.fillColor = Handle.Foreground.cgColor
        
        if Handle.HighlightStyle > 0 && IsDelta
        {
            Layer.fillColor = Handle.HighlightColor.cgColor
        }
        else
        {
            if Handle.VaryColorByLength
            {
                if IsThick
                {
                    Layer.fillColor = Handle.LongColor!.cgColor
                }
                else
                {
                    Layer.fillColor = Handle.ShortColor!.cgColor
                }
            }
        }
        
        Layer.path = Path
        
        if Handle.HighlightStyle > 0 && IsDelta
        {
            let Anim = CABasicAnimation(keyPath: "fillColor")
            Anim.isRemovedOnCompletion = false
            Anim.fillMode = CAMediaTimingFillMode.forwards
            if Handle.VaryColorByLength
            {
                if IsThick
                {
                    Layer.fillColor = Handle.LongColor!.cgColor
                }
                else
                {
                    Layer.fillColor = Handle.ShortColor!.cgColor
                }
            }
            else
            {
                Layer.fillColor = Handle.Foreground.cgColor
            }
            Anim.duration = CFTimeInterval(1.0)
            Anim.repeatCount = 0
            Anim.autoreverses = false
            Layer.add(Anim, forKey: nil)
        }
        
        return Layer
    }
    
    public static func DebugMap(_ Vector: [BarThicknesses], _ Data: Int) -> String
    {
        var Final = "\(Data): "
        for Thickness in Vector
        {
            switch Thickness
            {
            case .Space:
                Final = Final + "_"
                
            case .Thin:
                Final = Final + "|"
                
            case .Thick:
                Final = Final + "#"
            }
        }
        return Final
    }
    
    /// Create a layer consisting of a set of sub-layers the make the overall Pharma Code barcode, linear in shape.
    /// Thin bars are 1 unit in thickness. Thick bars are 3 units in thickness. Gaps are 2 units in thickness.
    /// Height is 12 units in height.
    ///
    /// - Parameters:
    ///   - Handle: Describes how to draw the barcode.
    ///   - From: Data to encode in the barcode.
    ///   - ImageSize: Image size. If nil, native image size is used.
    /// - Returns: CAShapeLayer with the barcode encoded as sub-layers. Nil returned on error.
    public static func GetLinearPharmacodeBarcodeLayer(Handle: VectorHandle, From: Int, ImageSize: CGSize? = nil, ParentSize: CGSize? = nil) -> CAShapeLayer?
    {
        let Layer = CAShapeLayer()
        Layer.isOpaque = false
        Layer.backgroundColor = UIColor.clear.cgColor
        var VectorThickness: Int = 0
        var CheckDigit: Int? = nil
        var FinalFrom = From
        if Handle.IncludeCheckDigit
        {
            CheckDigit = POSTNETCheckDigit(String(From))
            FinalFrom = (From * 10) + CheckDigit!
        }
        if let VectorMap = GeneratePharmacodeBarcode(RawData: FinalFrom, CanonicalThickness: &VectorThickness)
        {
            var FinalSize: CGSize!
            if let ImageSize = ImageSize
            {
                FinalSize = ImageSize
            }
            else
            {
                FinalSize = CGSize(width: CGFloat(VectorThickness), height: 6.0)
            }
            
            var BarcodeMap = [Int](repeating: 0, count: VectorMap.count)
            for Index in 0 ..< VectorMap.count
            {
                let Value = VectorMap[Index]
                switch Value
                {
                case .Thick:
                    BarcodeMap[Index] = 1
                    
                case .Thin:
                    BarcodeMap[Index] = 0
                    
                case .Space:
                    BarcodeMap[Index] = -1
                }
            }
            
            let Delta = Handle.GetGaplessDelta(NewVector: BarcodeMap)
            
            var Offset: CGPoint!
            let PS = ParentSize! * 0.5
            let BS = FinalSize * 0.5
            Offset = CGSize.ToPoint(PS - BS)
            let Frame = CGRect(origin: Offset, size: BS)
            //Handle.fprint("ParentSize: \(CGSize.Print(ParentSize!)), FinalSize=\(CGSize.Print(FinalSize!)), Offset=\(CGPoint.Print(Offset!)), Frame=\(CGRect.Print(Frame))")
            
            let HRatio = FinalSize.width / CGFloat(VectorThickness)
            var Location: CGFloat = 0.0
            var Index = 0
            for Thickness in VectorMap
            {
                var NodeLayer: CAShapeLayer? = nil
                var IsDelta: Bool = false
                if Delta != nil
                {
                    IsDelta = Delta![Index]
                }
                switch Thickness
                {
                case .Thick:
                    let PixelRect = CGRect(x: Location + Offset.x, y: 0 + Offset.y, width: (ThicknessMap[.Thick]! * HRatio), height: FinalSize.height)
                    NodeLayer = CreatePharmaCodeLayer(Handle: Handle, Frame: Frame,
                                                      Path: CGPath(rect: PixelRect, transform: nil),
                                                      IsDelta: IsDelta, IsThick: true)
                    Location = Location + (ThicknessMap[.Thick]! * HRatio)
                    
                case .Thin:
                    let PixelRect = CGRect(x: Location + Offset.x, y: 0 + Offset.y, width: (ThicknessMap[.Thin]! * HRatio), height: FinalSize.height)
                    NodeLayer = CreatePharmaCodeLayer(Handle: Handle, Frame: Frame,
                                                      Path: CGPath(rect: PixelRect, transform: nil),
                                                      IsDelta: IsDelta, IsThick: false)
                    Location = Location + (ThicknessMap[.Thin]! * HRatio)
                    
                case .Space:
                    Location = Location + (ThicknessMap[.Space]! * HRatio)
                }
                if NodeLayer != nil
                {
                    Layer.addSublayer(NodeLayer!)
                }
                Index = Index + 1
            }
            Layer.frame = CGRect(Layer.frame, WithOrigin: Offset)
            Layer.bounds = Layer.frame
            if Handle.ShowBorder
            {
                Layer.borderColor = Handle.BorderColor.cgColor
                Layer.borderWidth = Handle.BorderThickness
            }
            return Layer
        }
        return nil
    }
    
    /// Create a layer consisting of a set of sub-layers the make the overall Pharma Code barcode, radial in shape.
    /// Thin bars are 1 unit in thickness. Thick bars are 3 units in thickness. Gaps are 2 units in thickness.
    /// Height is 12 units in height.
    ///
    /// - Parameters:
    ///   - Handle: Describes how to draw the barcode.
    ///   - From: Data to encode in the barcode.
    ///   - ImageSize: Image size. If nil, native image size is used.
    /// - Returns: CAShapeLayer with the barcode encoded as sub-layers. Nil returned on error.
    public static func GetRadialPharmacodeBarcodeLayer(Handle: VectorHandle, From: Int, ImageSize: CGSize? = nil, ParentSize: CGSize? = nil) -> CAShapeLayer?
    {
        let Layer = CAShapeLayer()
        Layer.isOpaque = false
        Layer.backgroundColor = UIColor.clear.cgColor
        var VectorThickness: Int = 0
        var CheckDigit: Int? = nil
        var FinalFrom = From
        if Handle.IncludeCheckDigit
        {
            CheckDigit = POSTNETCheckDigit(String(From))
            FinalFrom = (From * 10) + CheckDigit!
        }
        if let VectorMap = GeneratePharmacodeBarcode(RawData: FinalFrom, CanonicalThickness: &VectorThickness)
        {
            var FinalSize: CGSize!
            if let ImageSize = ImageSize
            {
                FinalSize = ImageSize
            }
            else
            {
                FinalSize = CGSize(width: CGFloat(VectorThickness), height: 6.0)
            }
            
            var BarcodeMap = [Int](repeating: 0, count: VectorMap.count)
            var CumulativeBarThickness = 0
            for Index in 0 ..< VectorMap.count
            {
                let Value = VectorMap[Index]
                CumulativeBarThickness = CumulativeBarThickness + Int(ThicknessMap[Value]!)
                switch Value
                {
                case .Thick:
                    BarcodeMap[Index] = 1
                    
                case .Thin:
                    BarcodeMap[Index] = 0
                    
                case .Space:
                    BarcodeMap[Index] = -1
                }
            }
            
            let Delta = Handle.GetGaplessDelta(NewVector: BarcodeMap)
            
            var Offset: CGPoint!
            let PS = ParentSize! * 0.5
            let BS = FinalSize * 0.5
            Offset = CGSize.ToPoint(PS - BS)
            
            var Index = 0
            var Accumulator: CGFloat = 0.0
            let UnitMultiplier = CGFloat(360.0 / Double(CumulativeBarThickness))
            let ViewFrame = CGRect(x: 0, y: 0, width: Handle.ViewWidth, height: Handle.ViewHeight)
            
            for Thickness in VectorMap
            {
                var NodeLayer: CAShapeLayer? = nil
                var IsDelta: Bool = false
                if Delta != nil
                {
                    IsDelta = Delta![Index]
                }
                
                if Thickness == .Space
                {
                    Accumulator = Accumulator + (ThicknessMap[.Space]! * UnitMultiplier)
                    Index = Index + 1
                    continue
                }
                
                let LineHeight: CGFloat = CGFloat(Handle.OuterRadius)
                let InnerPoint1 = MakePoint(Radius: CGFloat(Handle.InnerRadius), Angle: Accumulator, Center: Handle.TargetCenter!)
                let OuterPoint1 = MakePoint(Radius: LineHeight, Angle: Accumulator, Center: Handle.TargetCenter!)
                Accumulator = Accumulator + (ThicknessMap[Thickness]! * UnitMultiplier)
                let InnerPoint2 = MakePoint(Radius: CGFloat(Handle.InnerRadius), Angle: Accumulator, Center: Handle.TargetCenter!)
                let OuterPoint2 = MakePoint(Radius: LineHeight, Angle: Accumulator, Center: Handle.TargetCenter!)
                
                NodeLayer = CreateRadialLayer(Frame: ViewFrame, Points: [InnerPoint1, InnerPoint2, OuterPoint2, OuterPoint1],
                                              Handle: Handle, IsLong: Thickness == .Thick, IsDelta: IsDelta,
                                              RoundJoins: true)
                
                if NodeLayer != nil
                {
                    Layer.addSublayer(NodeLayer!)
                }
                Index = Index + 1
            }
            Layer.frame = CGRect(Layer.frame, WithOrigin: Offset)
            Layer.bounds = Layer.frame
            if Handle.ShowBorder
            {
                Layer.borderColor = Handle.BorderColor.cgColor
                Layer.borderWidth = Handle.BorderThickness
            }
            return Layer
        }
        return nil
    }
    
    public static func GetTargetPharmacodeBarcodeLayer(Handle: VectorHandle, From: Int, ImageSize: CGSize? = nil, ParentSize: CGSize? = nil) -> CAShapeLayer?
    {
        let Layer = CAShapeLayer()
        Layer.isOpaque = false
        Layer.backgroundColor = UIColor.clear.cgColor
        var VectorThickness: Int = 0
        var CheckDigit: Int? = nil
        var FinalFrom = From
        if Handle.IncludeCheckDigit
        {
            CheckDigit = POSTNETCheckDigit(String(From))
            FinalFrom = (From * 10) + CheckDigit!
        }
        
        let (Top, _, Bottom, _) = Handle.EffectiveMargins()
        let BarcodeHeight = CGFloat(Handle.ViewHeight - (Top + Bottom))
        let BarcodeHalfHeight = BarcodeHeight / 2.0
        var TopOfBarcode: CGFloat = 0.0
        var Center: CGPoint!
        #if true
        Center = Handle.TargetCenter!
        #else
        if Handle.FinalCenter == nil
        {
            print("Center not specified")
            Center = CGPoint(x: UIScreen.main.bounds.width / 2.0, y: UIScreen.main.bounds.height / 2.0)
        }
        else
        {
            TopOfBarcode = Handle.FinalCenter! - BarcodeHalfHeight
            Center = CGPoint(x: Handle.ViewWidth / 2, y: Handle.ViewHeight / 2 + Int(TopOfBarcode))
        }
        #endif
        
        if let VectorMap = GeneratePharmacodeBarcode(RawData: FinalFrom, CanonicalThickness: &VectorThickness)
        {
            var FinalSize: CGSize!
            if let ImageSize = ImageSize
            {
                FinalSize = ImageSize
            }
            else
            {
                FinalSize = CGSize(width: CGFloat(VectorThickness), height: 6.0)
            }
            let Frame = CGRect(origin: CGPoint.zero, size: FinalSize)
            Layer.frame = Frame
            Layer.bounds = Frame
            
            var BarcodeMap = [Int](repeating: 0, count: VectorMap.count)
            var Cumulative = 0
            for Index in 0 ..< VectorMap.count
            {
                let Value = VectorMap[Index]
                Cumulative = Cumulative + Int(ThicknessMap[Value]!)
                switch Value
                {
                case .Thick:
                    BarcodeMap[Index] = 1
                    
                case .Thin:
                    BarcodeMap[Index] = 0
                    
                case .Space:
                    BarcodeMap[Index] = -1
                }
            }
            
            let Delta = Handle.GetGaplessDelta(NewVector: BarcodeMap)
            
            var RadialMultiplier = Handle.OuterRadius / Handle.InnerRadius
            RadialMultiplier = (Handle.OuterRadius - Handle.InnerRadius) / Double(Cumulative)
            var Index = 0
            var RAccumulator: CGFloat = CGFloat(Handle.InnerRadius)
            for Tallness in VectorMap
            {
                var NodeLayer: CAShapeLayer? = nil
                var IsDelta = false
                if Delta != nil
                {
                    IsDelta = Delta![Index]
                }
                
                if Tallness != .Space
                {
                    let InnerRadius = RAccumulator
                    let RingThickness = ThicknessMap[Tallness]! * CGFloat(RadialMultiplier)
                    let OuterRadius = InnerRadius + RingThickness
                    NodeLayer = CreateTargetPharmaLayer(Frame: Frame, Center: Center, Handle: Handle, InnerRadius: InnerRadius,
                                                        OuterRadius: OuterRadius, IsDelta: IsDelta, IsBig: Tallness == .Thick)
                    if NodeLayer != nil
                    {
                        Layer.addSublayer(NodeLayer!)
                    }
                }
                RAccumulator = RAccumulator + (ThicknessMap[Tallness]! * CGFloat(RadialMultiplier))
                //Handle.fprint("RAccumulator[\(Index)]=\(RAccumulator)")
                Index = Index + 1
            }
            return Layer
        }
        return nil
    }
    
    static let ThicknessMap: [BarThicknesses: CGFloat] =
        [
            .Thin: 1.0,
            .Space: 2.0,
            .Thick: 3.0
    ]
    
    enum BarThicknesses
    {
        case Thin
        case Thick
        case Space
    }
    
    /// Create a virtual Pharmacode barcode based on the passed raw data.
    ///
    /// - Notes: Algorithm from http://www.gomaro.ch/ftproot/Laetus_PHARMA-CODE.pdf, page 34.
    ///
    /// - Parameters:
    ///   - RawData: The data to encode. Valid range is 3 to 131070, inclusive. Data outside of this range
    ///              will result in a nil being returned.
    ///   - CanonicalThickness: The canonical thickness assuming no size changes.
    ///   - InsertTrailingSpace: If true, a space will be guarenteed to trail the barcode.
    /// - Returns: Array of barcode thicknesses on success, nil on failure.
    public static func GeneratePharmacodeBarcode(RawData: Int, CanonicalThickness: inout Int,
                                                 InsertTrailingSpace: Bool = true) -> [BarThicknesses]?
    {
        if RawData < 3
        {
            print("Invalid data - must be three or greater.")
            return nil
        }
        if RawData > 131070
        {
            print("Invalid data - must be less than or equal to 131070.")
            return nil
        }
        
        var Result = [BarThicknesses]()
        var Z = RawData
        
        while Z > 0
        {
            if Z % 2 == 0
            {
                Result.append(.Thick)
                Result.append(.Space)
                Z = (Z - 2) / 2
            }
            else
            {
                Result.append(.Thin)
                Result.append(.Space)
                Z = (Z - 1) / 2
            }
        }
        if InsertTrailingSpace
        {
            if Result.last != .Space
            {
                Result.append(.Space)
            }
        }
        else
        {
            if Result.last == .Space
            {
                Result.removeLast()
            }
        }
        if Result.first == .Space
        {
            Result.removeFirst()
        }
        var FinalThickness = 0
        for Thickness in Result
        {
            switch Thickness
            {
            case .Thick:
                FinalThickness = FinalThickness + 3
                
            case .Thin:
                FinalThickness = FinalThickness + 1
                
            case .Space:
                FinalThickness = FinalThickness + 2
            }
        }
        CanonicalThickness = FinalThickness
        return Result.reversed()
    }
    
    // MARK: POSTNET drawing code.
    
    /// Create a POSTNET barcode shape layer. The shape of the resultant barcode is dependent on the Handle.
    ///
    /// - Parameters:
    ///   - Handle: Describes how to draw the barcode.
    ///   - From: The contents of the barcode.
    ///   - ImageSize: Image size of the barcode (eg, target size).
    ///   - ParentSize: Size of the parent where the barcode will be placed.
    /// - Returns: Shape layer with the contents of the barcode.
    public static func GetPOSTNETBarcodeLayer(Handle: VectorHandle, From: Int, ImageSize: CGSize? = nil,
                                              ParentSize: CGSize? = nil) -> CAShapeLayer?
    {
        switch Handle.BarcodeShape
        {
        case 0:
            return GetLinearPOSTNETBarcodeLayer(Handle: Handle, From: From, ImageSize: ImageSize, ParentSize: ParentSize)
            
        case 1:
            return GetRadialPOSTNETBarcodeLayer(Handle: Handle, From: From, ImageSize: ImageSize, ParentSize: ParentSize)
            
        case 2:
            return GetTargetPOSTNETBarcodeLayer(Handle: Handle, From: From, ImageSize: ImageSize, ParentSize: ParentSize)
            
        default:
            return nil
        }
    }
    
    /// Create a layer consisting of a set of sub-layers the make the overall POSTNET barcode. The resultant barcode is linear.
    ///
    /// - Parameters:
    ///   - Handle: Describes how to draw the barcode.
    ///   - From: Data to encode in the barcode.
    ///   - ImageSize: Image size. If nil, native image size is used.
    /// - Returns: CAShapeLayer with the barcode encoded as sub-layers. Nil returned on error.
    private static func GetLinearPOSTNETBarcodeLayer(Handle: VectorHandle, From: Int, ImageSize: CGSize? = nil,
                                                     ParentSize: CGSize? = nil) -> CAShapeLayer?
    {
        let Layer = CAShapeLayer()
        Layer.isOpaque = false
        Layer.backgroundColor = UIColor.clear.cgColor
        var VectorThickness: Int = 0
        var CheckDigit: Int? = nil
        var FinalFrom = From
        if Handle.IncludeCheckDigit
        {
            CheckDigit = POSTNETCheckDigit(String(From))
            FinalFrom = (From * 10) + CheckDigit!
        }
        if let VectorMap = GeneratePOSTNETBarcode(RawData: FinalFrom, CanonicalThickness: &VectorThickness)
        {
            var FinalSize: CGSize!
            if let ImageSize = ImageSize
            {
                FinalSize = ImageSize
            }
            else
            {
                FinalSize = CGSize(width: CGFloat(VectorThickness), height: 6.0)
            }
            let Frame = CGRect(origin: CGPoint.zero, size: FinalSize)
            Layer.frame = Frame
            Layer.bounds = Frame
            let HRatio = FinalSize.width / CGFloat(VectorMap.count)
            var Location: CGFloat = 0.0
            
            var BarcodeMap = [Int](repeating: 0, count: VectorMap.count)
            for Index in 0 ..< VectorMap.count
            {
                let Value = VectorMap[Index]
                switch Value
                {
                case .High:
                    BarcodeMap[Index] = 1
                    
                case .Low:
                    BarcodeMap[Index] = 0
                    
                case .Space:
                    BarcodeMap[Index] = -1
                }
            }
            
            let Delta = Handle.GetGaplessDelta(NewVector: BarcodeMap)
            var Offset: CGPoint!
            let PS = ParentSize! * 0.5
            let BS = FinalSize * 0.5
            Offset = CGSize.ToPoint(PS - BS)
            Handle.fprint("ParentSize: \((ParentSize)!), FinalSize=\((FinalSize)!), Offset=\((Offset)!)")
            
            var Index = -1
            for Tallness in VectorMap
            {
                Index = Index + 1
                var NodeLayer: CAShapeLayer? = nil
                var IsDelta = false
                if Delta != nil
                {
                    IsDelta = Delta![Index]
                }
                switch Tallness
                {
                case .High:
                    let BarHeight = FinalSize.height// * CGFloat(Handle.HeightMultiplier * 2.0)
                    let PixelRect = CGRect(x: Location + Offset.x, y:  Offset.y,
                                           width: HRatio, height: BarHeight)
                    NodeLayer = CreatePOSTNETCodeLayer(Handle: Handle, Frame: Frame, IsLong: true, IsDelta: IsDelta,
                                                       Path: CGPath(rect: PixelRect, transform: nil))
                    Location = Location + HRatio
                    
                case .Low:
                    let BarHeight = (FinalSize.height / 2.0) //* CGFloat(Handle.HeightMultiplier * 2.0)
                    let PixelRect = CGRect(x: Location + Offset.x, y: Offset.y + BarHeight,
                                           width: HRatio, height: BarHeight)
                    NodeLayer = CreatePOSTNETCodeLayer(Handle: Handle, Frame: Frame, IsLong: false, IsDelta: IsDelta,
                                                       Path: CGPath(rect: PixelRect, transform: nil))
                    Location = Location + HRatio
                    
                case .Space:
                    Location = Location + HRatio
                }
                if NodeLayer != nil
                {
                    Layer.addSublayer(NodeLayer!)
                }
            }
            Layer.frame = CGRect(Layer.frame, WithOrigin: Offset)
            Layer.bounds = Layer.frame
            if Handle.ShowBorder
            {
                Layer.borderColor = Handle.BorderColor.cgColor
                Layer.borderWidth = Handle.BorderThickness
            }
            return Layer
        }
        return nil
    }
    
    /// Create a layer consisting of a set of sub-layers the make the overall POSTNET barcode. The resultant barcode is radial.
    ///
    /// - Parameters:
    ///   - Handle: Describes how to draw the barcode.
    ///   - From: Data to encode in the barcode.
    ///   - ImageSize: Image size. If nil, native image size is used.
    /// - Returns: CAShapeLayer with the barcode encoded as sub-layers. Nil returned on error.
    private static func GetRadialPOSTNETBarcodeLayer(Handle: VectorHandle, From: Int, ImageSize: CGSize? = nil, ParentSize: CGSize? = nil) -> CAShapeLayer?
    {
        let Layer = CAShapeLayer()
        Layer.isOpaque = false
        Layer.backgroundColor = UIColor.clear.cgColor
        var VectorThickness: Int = 0
        var CheckDigit: Int? = nil
        var FinalFrom = From
        if Handle.IncludeCheckDigit
        {
            CheckDigit = POSTNETCheckDigit(String(From))
            FinalFrom = (From * 10) + CheckDigit!
        }
        if let VectorMap = GeneratePOSTNETBarcode(RawData: FinalFrom, CanonicalThickness: &VectorThickness)
        {
            var FinalSize: CGSize!
            if let ImageSize = ImageSize
            {
                FinalSize = ImageSize
            }
            else
            {
                FinalSize = CGSize(width: CGFloat(VectorThickness), height: 6.0)
            }
            let Frame = CGRect(origin: CGPoint.zero, size: FinalSize)
            Layer.frame = Frame
            Layer.bounds = Frame
            let UnitMultiplier = 360.0 / CGFloat(VectorMap.count)
            var Accumulator: CGFloat = 0.0
            let ViewFrame = CGRect(x: 0, y: 0, width: Handle.ViewWidth, height: Handle.ViewHeight)
            
            var BarcodeMap = [Int](repeating: 0, count: VectorMap.count)
            for Index in 0 ..< VectorMap.count
            {
                let Value = VectorMap[Index]
                switch Value
                {
                case .High:
                    BarcodeMap[Index] = 1
                    
                case .Low:
                    BarcodeMap[Index] = 0
                    
                case .Space:
                    BarcodeMap[Index] = -1
                }
            }
            
            let Delta = Handle.GetGaplessDelta(NewVector: BarcodeMap)
            
            var Index = -1
            for Tallness in VectorMap
            {
                Index = Index + 1
                if Tallness == .Space
                {
                    Accumulator = Accumulator + UnitMultiplier
                    continue
                }
                var NodeLayer: CAShapeLayer? = nil
                var LineHeight: CGFloat = CGFloat(Handle.OuterRadius)
                if Tallness == .Low
                {
                    LineHeight = CGFloat(Handle.OuterRadius) * 0.65
                }
                let InnerPoint1 = MakePoint(Radius: CGFloat(Handle.InnerRadius), Angle: Accumulator, Center: Handle.TargetCenter!)
                let OuterPoint1 = MakePoint(Radius: LineHeight, Angle: Accumulator, Center: Handle.TargetCenter!)
                Accumulator = Accumulator + UnitMultiplier
                let InnerPoint2 = MakePoint(Radius: CGFloat(Handle.InnerRadius), Angle: Accumulator, Center: Handle.TargetCenter!)
                let OuterPoint2 = MakePoint(Radius: LineHeight, Angle: Accumulator, Center: Handle.TargetCenter!)
                
                var IsDelta = false
                if Delta != nil
                {
                    IsDelta = Delta![Index]
                }
                
                NodeLayer = CreateRadialLayer(Frame: ViewFrame, Points: [InnerPoint1, InnerPoint2, OuterPoint2, OuterPoint1],
                                              Handle: Handle, IsLong: Tallness == .High, IsDelta: IsDelta)
                
                if NodeLayer != nil
                {
                    Layer.addSublayer(NodeLayer!)
                }
            }
            if Handle.ShowBorder
            {
                Layer.borderColor = Handle.BorderColor.cgColor
                Layer.borderWidth = Handle.BorderThickness
            }
            return Layer
        }
        return nil
    }
    
    /// Convert from a polar coordinate to a cartesian coordinate.
    ///
    /// - Parameters:
    ///   - Radius: Radial length of the point.
    ///   - Angle: Angle of the point (in degrees).
    ///   - Center: Center of the coordinate universe.
    /// - Returns: Cartesian point calculated from the passed polar coordinate.
    private static func MakePoint(Radius: CGFloat, Angle: CGFloat, Center: CGPoint) -> CGPoint
    {
        let RadialAngle: CGFloat = Angle * .pi / 180.0
        let X: CGFloat = (Radius * cos(RadialAngle)) + Center.x
        let Y: CGFloat = (Radius * sin(RadialAngle)) + Center.y
        return CGPoint(x: X, y: Y)
    }
    
    /// Create a layer consisting of a set of sub-layers the make the overall POSTNET barcode. The resultant barcode is target-shaped.
    ///
    /// - Parameters:
    ///   - Handle: Describes how to draw the barcode.
    ///   - From: Data to encode in the barcode.
    ///   - ImageSize: Image size. If nil, native image size is used.
    /// - Returns: CAShapeLayer with the barcode encoded as sub-layers. Nil returned on error.
    private static func GetTargetPOSTNETBarcodeLayer(Handle: VectorHandle, From: Int, ImageSize: CGSize? = nil, ParentSize: CGSize? = nil) -> CAShapeLayer?
    {
        let Layer = CAShapeLayer()
        Layer.isOpaque = false
        Layer.backgroundColor = UIColor.clear.cgColor
        var VectorThickness: Int = 0
        var CheckDigit: Int? = nil
        var FinalFrom = From
        if Handle.IncludeCheckDigit
        {
            CheckDigit = POSTNETCheckDigit(String(From))
            FinalFrom = (From * 10) + CheckDigit!
        }
        
        let (Top, _, Bottom, _) = Handle.EffectiveMargins()
        let BarcodeHeight = CGFloat(Handle.ViewHeight - (Top + Bottom))
        let BarcodeHalfHeight = BarcodeHeight / 2.0
        var TopOfBarcode: CGFloat = 0.0
        var Center: CGPoint!
        #if true
        Center = Handle.TargetCenter!
        #else
        if Handle.FinalCenter == nil
        {
            Center = CGPoint(x: UIScreen.main.bounds.width / 2.0, y: UIScreen.main.bounds.height / 2.0)
        }
        else
        {
            TopOfBarcode = Handle.FinalCenter! - BarcodeHalfHeight
            Center = CGPoint(x: Handle.ViewWidth / 2, y: Handle.ViewHeight / 2 + Int(TopOfBarcode))
        }
        #endif
        
        if let VectorMap = GeneratePOSTNETBarcode(RawData: FinalFrom, CanonicalThickness: &VectorThickness)
        {
            var FinalSize: CGSize!
            if let ImageSize = ImageSize
            {
                FinalSize = ImageSize
            }
            else
            {
                FinalSize = CGSize(width: CGFloat(VectorThickness), height: 6.0)
            }
            let Frame = CGRect(origin: CGPoint.zero, size: FinalSize)
            Layer.frame = Frame
            Layer.bounds = Frame
            
            var BarcodeMap = [Int](repeating: 0, count: VectorMap.count)
            for Index in 0 ..< VectorMap.count
            {
                let Value = VectorMap[Index]
                switch Value
                {
                case .High:
                    BarcodeMap[Index] = 1
                    
                case .Low:
                    BarcodeMap[Index] = 0
                    
                case .Space:
                    BarcodeMap[Index] = -1
                }
            }
            
            let Delta = Handle.GetGaplessDelta(NewVector: BarcodeMap)

            let UnitMultiplier = BarcodeHalfHeight / CGFloat(VectorMap.count)
            var Index = 0
            for Tallness in VectorMap
            {
                var NodeLayer: CAShapeLayer? = nil
                var IsDelta = false
                if Delta != nil
                {
                    IsDelta = Delta![Index]
                }
                
                if Tallness != .Space
                {
                    let InnerRadius = CGFloat(Index) * UnitMultiplier / 1.0
                    let OuterRadius = InnerRadius + (UnitMultiplier / 2.0)
                    //print("Index=\(Index), InnerRadius=\(InnerRadius), OuterRadius=\(OuterRadius), Delta=\(OuterRadius - InnerRadius), Tallness=\(Tallness)")
                    NodeLayer = CreateTargetLayer(Frame: Frame, Center: Center, Handle: Handle, InnerRadius: InnerRadius,
                                                  OuterRadius: OuterRadius, IsBig: Tallness == .High, IsDelta: IsDelta,
                                                  LineThickness: UnitMultiplier / 2.0)
                    if NodeLayer != nil
                    {
                        Layer.addSublayer(NodeLayer!)
                    }
                }
                Index = Index + 1
            }
            return Layer
        }
        return nil
    }
    
    /// Create a "vector" (more like a virtual) POSTNET barcode from the passed data. The passed data must be an integer.
    ///
    /// - Parameters:
    ///   - RawData: Integer data to encode into the POSTNET barcode.
    ///   - CanonicalThickness: On return will contain the number of visible and invisible (eg, spacing) bars.
    /// - Returns: Array of bar types that describes the POSTNET barcode for the passed data.
    private static func GeneratePOSTNETBarcode(RawData: Int, CanonicalThickness: inout Int) -> [BarTypes]?
    {
        var Thickness = 0
        var Final = [BarTypes]()
        let Data = String(RawData)
        var Count: Int = 0
        AddPOSTNETDigit(DigitToAdd: -1, &Final, &Count)
        Thickness = Thickness + Count
        for Char in Data
        {
            let Digit = Int(String(Char))
            AddPOSTNETDigit(DigitToAdd: Digit!, &Final, &Count)
            Thickness = Thickness + Count
        }
        AddPOSTNETDigit(DigitToAdd: -1, &Final, &Count)
        Thickness = Thickness + Count
        #if false
        //If this is removed and the user selects a circular barcode, two bars will be next to each other
        //without an intervening space.
        CanonicalThickness = Thickness - 1
        Final.removeLast()
        #else
        CanonicalThickness = Thickness
        #endif
        return Final
    }
    
    /// Add a POSTNET digit to the array accumulating digits. Specify -1 to add leading and trailing stop bars.
    ///
    /// - Parameters:
    ///   - DigitToAdd: The digit to add. Decoded via the DigitMap.
    ///   - ToArray: Where the digit will be added. From one to more bars will be added to the array.
    ///   - DigitsAdded: Number of bars added to the array for the given digit.
    private static func AddPOSTNETDigit(DigitToAdd: Int, _ ToArray: inout [BarTypes], _ DigitsAdded: inout Int)
    {
        DigitsAdded = DigitMap[DigitToAdd]!.count
        for BarType in DigitMap[DigitToAdd]!
        {
            ToArray.append(BarType)
            ToArray.append(BarTypes.Space)
        }
    }
    
    /// Calculate the check digit value of the raw value passed as a string. POSTNET check digits are a single value that
    /// when added to the sum of the payload, causes the final sum to be evenly divisible by 10.
    ///
    /// - Parameter Raw: String representation of the value used to generate a check digit. Only digits are allowed to be in
    ///                  this parameter. Invalid characters cause a nil to be returned.
    /// - Returns: Check digit for the passed value. Nil returned on error (most likely due to finding a non-digit character).
    public static func POSTNETCheckDigit(_ Raw: String) -> Int?
    {
        var stemp = Raw
        var Digits = [Int]()
        while stemp.count > 0
        {
            let char = stemp.removeFirst()
            if char < "0" || char > "9"
            {
                return nil
            }
            Digits.append(Int(String(char))!)
        }
        var Sum = 0
        Digits.forEach{Sum = Sum + $0}
        let Mod = Sum % 10
        let Final = 10 - Mod
        return Final
    }
    
    /// Describes bar types for digits.
    ///
    /// - High: High bar (eg, tall)
    /// - Low: Low bar (eg, short)
    /// - Space: Spacing
    enum BarTypes
    {
        case High
        case Low
        case Space
    }
    
    /// Map of digits to a list of bar types. The -1 entry is for the
    /// start/stop bar.
    static let DigitMap: [Int: [BarTypes]] =
        [
            -1: [.High],
            0: [.High, .High, .Low, .Low, .Low],
            1: [.Low, .Low, .High, .High, .High],
            2: [.Low, .Low, .High, .Low, .High],
            3: [.Low, .Low, .High, .High, .Low],
            4: [.Low, .High, .Low, .Low, .High],
            5: [.Low, .High, .Low, .High, .Low],
            6: [.Low, .High, .High, .Low, .Low],
            7: [.High, .Low, .Low, .Low, .High],
            8: [.High, .Low, .Low, .High, .Low],
            9: [.High, .Low, .High, .Low, .Low],
            ]
    
    /// Create a node shape layer. Each node in a barcode gets its own shape layer.
    ///
    /// - Parameters:
    ///   - Handle: Describes how to draw the barcode.
    ///   - Frame: The frame of the returned shape layer. Should be as large as the parent UIView.
    ///   - NodeShape: Determines the shape of the node to draw.
    ///   - IsLong: Describes the length of the barcode. Used for highlighting.
    ///   - IsDelta: Determines whether this layer is a delta layer or not.
    ///   - Path: The path to create.
    /// - Returns: Shape layer with the node.
    private static func CreatePOSTNETCodeLayer(Handle: VectorHandle, Frame: CGRect, NodeShape: Int = 0, IsLong: Bool, IsDelta: Bool,
                                               Path: CGPath) -> CAShapeLayer
    {
        #if true
        let Layer = CAShapeLayer()
        Layer.frame = Frame
        Layer.bounds = Frame
        Layer.backgroundColor = UIColor.clear.cgColor
        Layer.fillColor = Handle.Foreground.cgColor
        if Handle.HighlightStyle > 0 && IsDelta
        {
            Layer.fillColor = Handle.HighlightColor.cgColor
        }
        else
        {
            if Handle.VaryColorByLength
            {
                if IsLong
                {
                    Layer.fillColor = Handle.LongColor!.cgColor
                }
                else
                {
                    Layer.fillColor = Handle.ShortColor!.cgColor
                }
            }
        }
        
        Layer.path = Path
        
        if Handle.HighlightStyle > 0 && IsDelta
        {
            let Anim = CABasicAnimation(keyPath: "fillColor")
            Anim.isRemovedOnCompletion = false
            Anim.fillMode = CAMediaTimingFillMode.forwards
            if Handle.VaryColorByLength
            {
                if IsLong
                {
                    Anim.toValue = Handle.LongColor!.cgColor
                }
                else
                {
                    Anim.toValue = Handle.ShortColor!.cgColor
                }
            }
            else
            {
                Anim.toValue = Handle.Foreground.cgColor
            }
            Anim.duration = CFTimeInterval(1.0)
            Anim.repeatCount = 0
            Anim.autoreverses = false
            Layer.add(Anim, forKey: nil)
        }
        
        return Layer
        #else
        let Layer = CAShapeLayer()
        Layer.frame = Frame
        Layer.bounds = Frame
        Layer.backgroundColor = UIColor.clear.cgColor
        if let Foreground = Foreground
        {
            Layer.fillColor = Foreground.cgColor
        }
        else
        {
            Layer.fillColor = Utility.RandomColor(HueRange: 0.0 ... 360.0, Saturation: 0.70, Brightness: 0.65)!.cgColor
        }
        
        Layer.path = Path
        
        if IsDelta
        {
            if let FinalColor = Final
            {
                let Anim = CABasicAnimation(keyPath: "fillColor")
                Anim.isRemovedOnCompletion = false
                Anim.fillMode = CAMediaTimingFillMode.forwards
                Anim.toValue = FinalColor.cgColor
                Anim.duration = CFTimeInterval(1.0)
                Anim.repeatCount = 0
                Anim.autoreverses = false
                Layer.add(Anim, forKey: nil)
            }
        }
        
        return Layer
        #endif
    }
    
    /// Add a radial line to a barcode.
    ///
    /// - Parameters:
    ///   - Frame: Frame that describes the size and bounds of the layer.
    ///   - Points: Points that make up the radial bar. If the number of points is not four, nil is returned.
    ///   - Handle: Describes visual attributes.
    ///   - IsLong: If true, the layer is for a long line. Otherwise, a short line.
    ///   - IsDelta: If true, the layer is a delta from a previous barcode. If false, there is no delta.
    ///   - RoundJoins: If true, lines are joined with rounded corners.
    /// - Returns: Radial bar in a shape layer. Nil on error.
    private static func CreateRadialLayer(Frame: CGRect, Points: [CGPoint], Handle: VectorHandle,
                                          IsLong: Bool, IsDelta: Bool,
                                          RoundJoins: Bool = false) -> CAShapeLayer?
    {
        if Points.count != 4
        {
            return nil
        }
        let Layer = CAShapeLayer()
        Layer.frame = Frame
        Layer.bounds = Frame
        Layer.backgroundColor = UIColor.clear.cgColor
        Layer.fillColor = Handle.Foreground.cgColor
        if Handle.HighlightStyle > 0 && IsDelta
        {
            Layer.fillColor = Handle.HighlightColor.cgColor
        }
        else
        {
            if Handle.VaryColorByLength
            {
                if IsLong
                {
                    Layer.fillColor = Handle.LongColor!.cgColor
                }
                else
                {
                    Layer.fillColor = Handle.ShortColor!.cgColor
                }
            }
        }
        
        let Lines = UIBezierPath()
        if RoundJoins
        {
            Lines.lineJoinStyle = .round
        }
        Lines.move(to: Points[0])
        Lines.addLine(to: Points[1])
        Lines.addLine(to: Points[2])
        Lines.addLine(to: Points[3])
        Lines.addLine(to: Points[0])
        Layer.path = Lines.cgPath
        
        if Handle.HighlightStyle > 0 && IsDelta
        {
            let Anim = CABasicAnimation(keyPath: "fillColor")
            Anim.isRemovedOnCompletion = false
            Anim.fillMode = CAMediaTimingFillMode.forwards
            if Handle.VaryColorByLength
            {
                if IsLong
                {
                    Anim.toValue = Handle.LongColor!.cgColor
                }
                else
                {
                    Anim.toValue = Handle.ShortColor!.cgColor
                }
            }
            else
            {
                Anim.toValue = Handle.Foreground.cgColor
            }
            Anim.duration = CFTimeInterval(1.0)
            Anim.repeatCount = 0
            Anim.autoreverses = false
            Layer.add(Anim, forKey: nil)
        }
        
        return Layer
    }
    
    private static func CreateTargetLayer(Frame: CGRect, Center: CGPoint, Handle: VectorHandle, InnerRadius: CGFloat,
                                          OuterRadius: CGFloat, IsBig: Bool, IsDelta: Bool, Override: UIColor? = nil,
                                          LineThickness: CGFloat) -> CAShapeLayer
    {
        let Layer = CAShapeLayer()
        Layer.frame = Frame
        Layer.bounds = Frame
        Layer.backgroundColor = UIColor.clear.cgColor
        Layer.fillColor = UIColor.clear.cgColor
        let FinalRect = CGRect(x: Center.x - CGFloat(OuterRadius), y: Center.y - CGFloat(OuterRadius),
                               width: CGFloat(OuterRadius * 2.0), height: CGFloat(OuterRadius * 2.0))
        if Handle.HighlightStyle == 1 && IsDelta
        {
            Layer.strokeColor = Handle.HighlightColor.cgColor
        }
        else
        {
            if IsBig
            {
                Layer.strokeColor = Handle.LongColor!.cgColor
            }
            else
            {
                Layer.strokeColor = Handle.ShortColor!.cgColor
            }
        }
        if let Over = Override
        {
            Layer.strokeColor = Over.cgColor
        }
        Layer.lineWidth = LineThickness
        let Circle = UIBezierPath(ovalIn: FinalRect)
        Layer.path = Circle.cgPath
        
        if Handle.HighlightStyle == 1 && IsDelta
        {
            let Anim = CABasicAnimation(keyPath: "strokeColor")
            Anim.isRemovedOnCompletion = false
            Anim.fillMode = CAMediaTimingFillMode.forwards
            if IsBig
            {
                Layer.strokeColor = Handle.LongColor!.cgColor
            }
            else
            {
                Layer.strokeColor = Handle.ShortColor!.cgColor
            }
            Anim.duration = CFTimeInterval(0.5)
            Anim.repeatCount = 0
            Anim.autoreverses = false
            Layer.add(Anim, forKey: nil)
        }
        
        return Layer
    }
    
    private static func CreateTargetPharmaLayer(Frame: CGRect, Center: CGPoint, Handle: VectorHandle, InnerRadius: CGFloat,
                                                OuterRadius: CGFloat, IsDelta: Bool, IsBig: Bool) -> CAShapeLayer
    {
        let Layer = CAShapeLayer()
        Layer.frame = Frame
        Layer.bounds = Frame
        Layer.backgroundColor = UIColor.clear.cgColor
        Layer.fillColor = UIColor.clear.cgColor
        let FinalRect = CGRect(x: Center.x - CGFloat(OuterRadius), y: Center.y - CGFloat(OuterRadius),
                               width: CGFloat(OuterRadius * 2.0), height: CGFloat(OuterRadius * 2.0))
        if Handle.HighlightStyle == 1 && IsDelta
        {
            Layer.strokeColor = Handle.HighlightColor.cgColor
        }
        else
        {
            if IsBig
            {
                Layer.strokeColor = Handle.LongColor!.cgColor
            }
            else
            {
                Layer.strokeColor = Handle.ShortColor!.cgColor
            }
        }

        Layer.lineWidth = OuterRadius - InnerRadius
        let Circle = UIBezierPath(ovalIn: FinalRect)
        Layer.path = Circle.cgPath
        
        if Handle.HighlightStyle == 1 && IsDelta
        {
            let Anim = CABasicAnimation(keyPath: "strokeColor")
            Anim.isRemovedOnCompletion = false
            Anim.fillMode = CAMediaTimingFillMode.forwards
            if IsBig
            {
                Layer.strokeColor = Handle.LongColor!.cgColor
            }
            else
            {
                Layer.strokeColor = Handle.ShortColor!.cgColor
            }
            Anim.duration = CFTimeInterval(0.5)
            Anim.repeatCount = 0
            Anim.autoreverses = false
            Layer.add(Anim, forKey: nil)
        }
        
        return Layer
    }
    
    var PreviousTime: Date? = nil
    
    /// Determines if the seconds component in the two passed dates are equal.
    ///
    /// - Parameters:
    ///   - Time1: First time structure.
    ///   - Time2: Second time structure.
    /// - Returns: True if the second components are equal, false if not.
    func SecondsEqual(_ Time1: Date, _ Time2: Date) -> Bool
    {
        let Cal = Calendar.current
        let Sec1 = Cal.component(.second, from: Time1)
        let Sec2 = Cal.component(.second, from: Time2)
        return Sec1 == Sec2
    }
    
    /// Returns the number of seconds this clock was active.
    func SecondsDisplayed() -> Int
    {
        let Now = Date()
        let Elapsed: Int = Int(Now.timeIntervalSince(StartTime))
        return Elapsed
    }
    
    /// Start time of the clock.
    private var StartTime = Date()
    
    /// Should be called by the Main UI when another clock is selected. Shut down this clock and clean
    /// things up.
    func FinishedWithClock()
    {
        if ClockTimer != nil
        {
            ClockTimer?.invalidate()
            ClockTimer = nil
        }
        delegate?.ClockClosed(ID: ClockID)
        _IsValid = false
    }
    
    /// Contains the is valid flag.
    private var _IsValid: Bool = true
    /// Get the is valid flag. If false is returned, do not use the clock - reinstantiate it first.
    public var IsValid: Bool
    {
        return _IsValid
    }
    
    /// Holds the value that determines if callers can update colors asynchronously.
    private var _CanUpdateColorsAsynchronously: Bool = true
    /// Get the flag that indicates the clock can update colors asynchronously.
    public var CanUpdateColorsAsynchronously: Bool
    {
        get
        {
            return _CanUpdateColorsAsynchronously
        }
    }
    
    /// Sets the foreground color of the clock (where it makes sense) to the passed color, asynchronously.
    ///
    /// - Parameter Color: New foreground color.
    func SetForegroundColorAsynchronously(_ Color: UIColor)
    {
        if !UpdateColorsAsynchronously
        {
            return
        }
        AsynchronousForeground = CIColor(color: Color)
        DrawClock(WithTime: Date())
    }
    
    var AsynchronousForeground: CIColor = CIColor.black
    
    /// Holds the flag that lets callers update colors asynchronously.
    private var _UpdateColorsAsynchronously: Bool = false
    /// Enables or disables usage of asynchronous colors.
    public var UpdateColorsAsynchronously: Bool
    {
        get
        {
            return _UpdateColorsAsynchronously
        }
        set
        {
            _UpdateColorsAsynchronously = newValue
        }
    }
    
    /// Update the specified nodes with associated colors.
    ///
    /// - Parameter Data: List of tuples. First item is the node index (0-based) and the second item is the color to
    ///                   apply to the node. If there are insufficient nodes in the bitmap, excess node data will be ignored.
    public func UpdateNodeColors(_ Data: [(Int, UIColor)])
    {
        
    }
    
    /// This clock is vector based...
    public var IsVectorBased: Bool
    {
        return true
    }
    
    /// Holds the is full screen flag.
    private var _IsFullScreen: Bool = false
    /// Get the full screen flag.
    public var IsFullScreen: Bool
    {
        get
        {
            return _IsFullScreen
        }
    }
    
    /// Holds the handles taps flag.
    private var _HandlesTaps: Bool = false
    /// Get or set the handles tap flag.
    public var HandlesTaps: Bool
    {
        get
        {
            return _HandlesTaps
        }
        set
        {
            _HandlesTaps = newValue
        }
    }
    
    /// Handle taps on the screen by the user. Sent to us by the main UI.
    ///
    /// -Paramter At: Where the tap occured in the clock view.
    public func WasTapped(At: CGPoint)
    {
    }
    
    /// Run clock-specific settings.
    public func RunClockSettings()
    {
        
    }
    
    /// Contains the ID of the segue to run to execute settings for a clock.
    private var _SegueID = "ToOneDBarcodeSettings"
    /// Get the segue ID of the settings view controller.
    ///
    /// - Returns: ID of the settings view controller. Nil if none available.
    func SettingsSegueID() -> String?
    {
        return _SegueID
    }
    
    /// Convenience function to allow the Main UI to display a different time than the clock timer.
    ///
    /// - Parameter NewTime: The time to display.
    func UpdateTime(NewTime: Date)
    {
        DrawClock(WithTime: NewTime)
    }
    
    /// Set the clock state to run or halt. The state of the clock does not affect the validity (IsValid) flag.
    ///
    /// - Parameter ToRunning: Pass true to set the clock state to running, false to stop the clock.
    func SetClockState(ToRunning: Bool, Animation: Int = 0)
    {
        _IsRunning = ToRunning
        if ToRunning
        {
            InitializeClockTimer()
            StartTime = Date()
            UpdateClock()
        }
        else
        {
            ClockTimer?.invalidate()
            ClockTimer = nil
            delegate?.ClockStopped(ID: ClockID)
        }
    }
    
    /// Holds the running state of the clock.
    private var _IsRunning: Bool = false
    /// Get the running state of the clock.
    public var IsRunning: Bool
    {
        get
        {
            return _IsRunning
        }
    }
    
    /// Update the viewport where the clock is drawn. Called when the user changes the orientation of the device.
    ///
    /// - Parameters:
    ///   - NewWidth: New viewport width.
    ///   - NewHeight: New viewport height.
    func UpdateViewPort(NewWidth: Int, NewHeight: Int)
    {
        ViewPortSize = CGSize(width: NewWidth, height: NewHeight)
        ViewPortCenter = CGPoint(x: NewWidth / 2, y: NewHeight / 2)
        UpdateClock()
    }
    
    /// Holds the UIView passed to the Main UI.
    private var SurfaceView: UIView!
    
    /// Holds the UIImageView of the actual barcode to display.
    private var BarcodeView: UIImageView!
    
    private var _VectorNodeCount: Int = 0
    var VectorNodeCount: Int
    {
        get
        {
            return _VectorNodeCount
        }
    }
    
    /// Return a settings indirection map. Used by SettingHandle instantiations to allow for the same
    /// dialog/ViewController to represent different clocks.
    ///
    /// - Parameter FromClock: The clock from which the setting indirection map will be returnted.
    /// - Returns: Dictionary of indirections. The key is the settings-specific key, and the value
    ///            is the clock-specific key.
    static func GetIndirectionMap(FromClock: PanelActions) -> [String: String]?
    {
        var Final = [String: String]()
        switch FromClock
        {
        case PanelActions.SwitchToPharmaCode:
            Final[SettingKey.BarcodeShape] = Setting.Key.Pharma.BarcodeShape
            Final[SettingKey.BarcodeHeight] = Setting.Key.Pharma.BarcodeHeight
            Final[SettingKey.BarcodeOuterRadius] = Setting.Key.Pharma.OuterRadius
            Final[SettingKey.BarcodeInnerRadius] = Setting.Key.Pharma.InnerRadius
            Final[SettingKey.SpecialEffects] = Setting.Key.Pharma.SpecialEffect
            Final[SettingKey.Shadows] = Setting.Key.Pharma.ShadowEffect
            Final[SettingKey.WavyHeights] = Setting.Key.Pharma.WavyHeights
            Final[SettingKey.BarcodeStroked] = Setting.Key.Pharma.BarcodeStroked
            Final[SettingKey.BarcodeStrokeColor] = Setting.Key.Pharma.BarcodeStrokeColor
            Final[SettingKey.BarcodeForegroundColor] = Setting.Key.Pharma.BarcodeForegroundColor1
            Final[SettingKey.BarcodeAttentionColor] = Setting.Key.Pharma.BarcodeForegroundColor2
            Final[SettingKey.IncludeDigits] = Setting.Key.Pharma.IncludeDigits
            Final[SettingKey.ColorsVaryOnLength] = Setting.Key.Pharma.ColorsVaryByThickness
            Final[SettingKey.LongBarColor] = Setting.Key.Pharma.ThickForeground
            Final[SettingKey.ShortBarColor] = Setting.Key.Pharma.ThinForeground
            
        case PanelActions.SwitchToPOSTNET:
            Final[SettingKey.BarcodeShape] = Setting.Key.POSTNET.BarcodeShape
            Final[SettingKey.BarcodeHeight] = Setting.Key.POSTNET.BarcodeHeight
            Final[SettingKey.BarcodeOuterRadius] = Setting.Key.POSTNET.OuterRadius
            Final[SettingKey.BarcodeInnerRadius] = Setting.Key.POSTNET.InnerRadius
            Final[SettingKey.SpecialEffects] = Setting.Key.POSTNET.SpecialEffect
            Final[SettingKey.Shadows] = Setting.Key.POSTNET.ShadowEffect
            Final[SettingKey.WavyHeights] = Setting.Key.POSTNET.WavyHeights
            Final[SettingKey.BarcodeStroked] = Setting.Key.POSTNET.BarcodeStroked
            Final[SettingKey.BarcodeStrokeColor] = Setting.Key.POSTNET.BarcodeStrokeColor
            Final[SettingKey.BarcodeForegroundColor] = Setting.Key.POSTNET.BarcodeForegroundColor1
            Final[SettingKey.BarcodeAttentionColor] = Setting.Key.POSTNET.BarcodeForegroundColor2
            Final[SettingKey.IncludeCheckDigits] = Setting.Key.POSTNET.IncludeCheckDigit
            Final[SettingKey.LongBarColor] = Setting.Key.POSTNET.LongForeground
            Final[SettingKey.ShortBarColor] = Setting.Key.POSTNET.ShortForeground
            Final[SettingKey.ColorsVaryOnLength] = Setting.Key.POSTNET.ColorsVaryOnLength
            
        default:
            fatalError("Invalid clock specified in GetIndirectionMap.")
        }
        return Final
    }
    
    /// Get changed settings.
    ///
    /// - Parameter Changed: List of changed settings. If nil, possibly no settings changed
    ///                      or too many to list.
    func ChangedSettings(_ Changed: [String])
    {
    }
}
