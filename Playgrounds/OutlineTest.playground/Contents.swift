//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport

class MyViewController : UIViewController
{
    func GetHSB(SourceColor: UIColor) -> (CGFloat, CGFloat, CGFloat)
    {
        let Hue = UnsafeMutablePointer<CGFloat>.allocate(capacity: 1)
        Hue.initialize(to: 0.0)
        let Saturation = UnsafeMutablePointer<CGFloat>.allocate(capacity: 1)
        Saturation.initialize(to: 0.0)
        let Brightness = UnsafeMutablePointer<CGFloat>.allocate(capacity: 1)
        Brightness.initialize(to: 0.0)
        let UnusedAlpha = UnsafeMutablePointer<CGFloat>.allocate(capacity: 1)
        UnusedAlpha.initialize(to: 0.0)
        
        SourceColor.getHue(Hue, saturation: Saturation, brightness: Brightness, alpha: UnusedAlpha)
        
        let FinalHue = Hue.move()
        let FinalSaturation = Saturation.move()
        let FinalBrightness = Brightness.move()
        let _ = UnusedAlpha.move()
        
        //Clean up.
        Hue.deallocate()
        Saturation.deallocate()
        Brightness.deallocate()
        UnusedAlpha.deallocate()
        
        return (FinalHue, FinalSaturation, FinalBrightness)
    }
    
    func MakeDarkColor(_ Source: UIColor) -> UIColor
    {
        let (H, S, B) = GetHSB(SourceColor: Source)
        let NewB = B * 0.75
        let NewColor = UIColor(hue: H, saturation: S, brightness: NewB, alpha: 1.0)
        return NewColor
    }
    
    func MakeVariantColor(_ Source: UIColor, Base: UIColor, Variant: CGFloat) -> UIColor
    {
        let (_, S, B) = GetHSB(SourceColor: Source)
        let (BH, _, _) = GetHSB(SourceColor: Base)
        var NewH = Variant + BH
        NewH = fmod(NewH, 1.0)
        return UIColor(hue: NewH, saturation: S, brightness: B, alpha: 1.0)
    }
    
    func GetAttributes() -> [NSAttributedString.Key: Any]
    {
        let VarC = MakeVariantColor(UIColor.yellow, Base: UIColor.red, Variant: 270 / 360)
        return [
            NSAttributedString.Key.strokeColor: MakeDarkColor(UIColor.white),
            NSAttributedString.Key.strokeWidth: -6,
            NSAttributedString.Key.foregroundColor: VarC,
            NSAttributedString.Key.font: UIFont(name: "Avenir-Black", size: 60.0)!
        ]
    }
    
    override func loadView()
    {
        let view = UIView()
        view.backgroundColor = UIColor.red

        let label = UILabel()
        label.frame = CGRect(x: 10, y: 10, width: 500, height: 200)
        let Test = NSAttributedString(string: "Test test test", attributes: GetAttributes())
        label.attributedText = Test
        
        view.addSubview(label)
        self.view = view
    }
}
// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()
