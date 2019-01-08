//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport

class RadialGradientView: UIView
{
    #if false
    init(Frame: CGRect)
    {
        super.init(frame: Frame)
        layer.backgroundColor = UIColor.clear.cgColor
        isOpaque = false
    }
    
    init(_ ViewName: String, Frame: CGRect)
    {
        super.init(frame: Frame)
        Name = ViewName
        layer.backgroundColor = UIColor.clear.cgColor
        isOpaque = false
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    #endif
    
    private var _Name: String = ""
    public var Name: String
    {
        get
        {
            return _Name
        }
        set
        {
            _Name = newValue
        }
    }
    
    private var _Colors = [UIColor.white.cgColor, UIColor.red.cgColor]
    public var Colors: [CGColor]
    {
        get
        {
            return _Colors
        }
        set
        {
            _Colors = newValue
        }
    }
    
    private var _GradientCenter = CGPoint(x: 100, y: 100)
    public var GradientCenter: CGPoint
    {
        get
        {
            return _GradientCenter
        }
        set
        {
            _GradientCenter = newValue
        }
    }
    
    private var _Radius: CGFloat = 80.0
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
    
    private var _BGColor: UIColor = UIColor.yellow
    public var BGColor: UIColor
    {
        get
        {
            return _BGColor
        }
        set
        {
            _BGColor = newValue
        }
    }
    
    private var _Locations: [CGFloat] = [0.0, 1.0]
    public var Locations: [CGFloat]
    {
        get
        {
            return _Locations
        }
        set
        {
            _Locations = newValue
        }
    }
    
    //https://www.techotopia.com/index.php/An_iOS_8_Swift_Graphics_Tutorial_using_Core_Graphics_and_Core_Image
    //https://stackoverflow.com/questions/30584025/swift-core-graphics-and-setting-background-color
    override func draw(_ Rect: CGRect)
    {
        print("Drawing: \(Name), Frame=\(self.frame)")
        let context = UIGraphicsGetCurrentContext()
        BGColor.setFill()
        context!.fill(CGRect(x: 0, y: 0, width: Rect.width, height: Rect.height))
        
        let colorspace = CGColorSpaceCreateDeviceRGB()
        
        let gradient = CGGradient(colorsSpace: colorspace,
                                  colors: Colors as CFArray, locations: Locations)
        
        #if true
        let startPoint = GradientCenter
        let endPoint = GradientCenter
        #else
        var startPoint =  CGPoint()
        var endPoint  = CGPoint()
        
        startPoint.x = GradientCenter.x
        startPoint.y = GradientCenter.y
        endPoint.x = GradientCenter.x
        endPoint.y = GradientCenter.y
        #endif
        let startRadius: CGFloat = 0
        let endRadius: CGFloat = Radius
        
        context?.drawRadialGradient(gradient!, startCenter: startPoint,
                                    startRadius: startRadius, endCenter: endPoint,
                                    endRadius: endRadius, options: [])
    }
}
  
class MyViewController : UIViewController
{
    func MakeRadialGradient(_ Colors: [UIColor], _ Where: CGPoint, Frame: CGRect,
                            Locations: [CGFloat]) -> CAGradientLayer
    {
        var AnyColor = [Any]()
        for SomeColor in Colors
        {
            AnyColor.append(SomeColor.cgColor as Any)
        }
        var Points: [NSNumber]? = [NSNumber]()
        if Locations.count > 0
        {
        for ANumber in Locations
        {
            Points?.append(NSNumber(value: Double(ANumber)))
        }
        }
        else
        {
            Points = nil
        }
        let G = CAGradientLayer()
        G.frame = Frame
        G.bounds = Frame
        G.type = .radial
        G.colors = AnyColor
        G.allowsEdgeAntialiasing = true
        print("Where=\(Where)")
        //G.endPoint = Where
        //G.startPoint = Where
        G.locations = Points
        //G.locations = nil
        return G
    }
    
    //https://stackoverflow.com/questions/26907352/how-to-draw-radial-gradients-in-a-calayer
    class RGL: CALayer
    {
        required override init ()
        {
            super.init()
            needsDisplayOnBoundsChange = true
        }
        
        required init?(coder aDecoder: NSCoder)
        {
            super.init(coder: aDecoder)
        }
        
        required override init(layer: Any)
        {
            super.init(layer: layer)
        }
        
        public var colors = [UIColor.red.cgColor as Any, UIColor.orange.cgColor as Any, UIColor.yellow.cgColor]
        
        override func draw(in ctx: CGContext)
        {
            ctx.saveGState()
            let ColorSpace = CGColorSpaceCreateDeviceRGB()
            var locations = [CGFloat]()
            for i in 0 ... colors.count - 1
            {
                let scratch: CGFloat = CGFloat(i) / CGFloat(colors.count)
                locations.append(scratch)
            }
            let gradient = CGGradient(colorsSpace: ColorSpace,
                                      colors: colors as CFArray,
                                      locations: locations)
            print("draw: bounds=\(bounds)")
            let Scale: CGFloat = 1.0 //UIScreen.main.scale
            print("draw: scale=\(Scale)")
            //let center = CGPoint(x: (bounds.width * Scale) / 2.0, y: (bounds.height * Scale) / 2.0)
            let center = CGPoint(x: 400, y: 600)
            print("draw: center=\(center)")
//            let radius = min((bounds.width * Scale) / 2.0, (bounds.height * Scale) / 2.0)
            let radius: CGFloat = 500
            ctx.drawRadialGradient(gradient!,
                                   startCenter: center, startRadius: 0.0,
                                   endCenter: center, endRadius: radius,
                                   options: .drawsBeforeStartLocation)
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.view.frame = CGRect(x: 0, y: 0, width: 375, height: 668)
        /*
        let Boring = UIView()
        Boring.layer.backgroundColor = UIColor.yellow.cgColor
        let G = RGL()
        G.bounds = self.view.frame
        Boring.layer.addSublayer(G)
        G.setNeedsLayout()
        G.displayIfNeeded()
        self.view = Boring
 */
    }
    
    override func loadView()
    {
        #if true
        let Boring = UIView()
        Boring.layer.backgroundColor = UIColor.yellow.cgColor
        /*
        let F = CGRect(x: 0, y: 0, width: 375, height: 668)
        let G = MakeRadialGradient([UIColor.yellow,UIColor.red],
                                   CGPoint(x: 100, y: 100),
                                   Frame: F,
                                   Locations: [0.0,1.0])
 */
        let G = RGL()
        G.bounds = CGRect(x: 0, y: 0, width: 375 * UIScreen.main.scale, height: 668 * UIScreen.main.scale)
        //Boring.layer.insertSublayer(G, at: 0)
        Boring.layer.addSublayer(G)
        G.setNeedsLayout()
        G.displayIfNeeded()
        self.view = Boring
        #else
        let Boring = UIView()
        Boring.isOpaque = false
        Boring.layer.backgroundColor = UIColor.white.cgColor
        #if true
        let View1 = RadialGradientView()
        View1.Name = "View1"
        View1.BGColor = UIColor.clear
        View1.layer.backgroundColor = UIColor.clear.cgColor
        let View2 = RadialGradientView()
        View2.Name = "View2"
        View2.BGColor = UIColor.clear
        View2.layer.backgroundColor = UIColor.clear.cgColor
        #else
        let Frame = view.frame
        let View1 = RadialGradientView("View1", Frame: Frame)
        View1.BGColor = UIColor.clear
        let View2 = RadialGradientView("View2", Frame: Frame)
        View2.BGColor = UIColor.clear
        #endif
        View2.Colors = [UIColor.yellow.cgColor, UIColor.orange.cgColor]
        View2.Radius = 45.0
        View2.GradientCenter = CGPoint(x: 120, y: 200)
        //Boring.addSubview(View1)
        //Boring.addSubview(View2)
        //View1.superview?.bringSubviewToFront(View1)
        //View2.superview?.bringSubviewToFront(View2)
        self.view = Boring
        #endif
    }
}

// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()
