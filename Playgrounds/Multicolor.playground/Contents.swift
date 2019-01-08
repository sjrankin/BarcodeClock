//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport

class MyViewController : UIViewController
{
    func MakeSquares(Frame: CGRect, Color1: UIColor, Color2: UIColor, Color3: UIColor) -> [CAShapeLayer]
    {
        var LayerList = [CAShapeLayer]()
        let Layer1 = MakeSquare(Frame: Frame, X: 60, Y: 60, Width: 80, Height: 80, Color1: Color1)
        let Layer2 = MakeSquare(Frame: Frame, X: 100, Y: 75, Width: 45, Height: 100, Color1: Color2)
        let Layer3 = MakeSquare(Frame: Frame, X: 180, Y: 97, Width: 100, Height: 14, Color1: Color3)
        LayerList.append(Layer1)
        LayerList.append(Layer2)
        LayerList.append(Layer3)
        return LayerList
    }
    
    func MakeSquare(Frame: CGRect, X: Int, Y: Int, Width: Int, Height: Int, Color1: UIColor) -> CAShapeLayer
    {
        let Layer = CAShapeLayer()
        Layer.frame = Frame
        Layer.bounds = Layer.frame
        Layer.backgroundColor = UIColor.yellow.cgColor
        let Rect1 = CGRect(x: X, y: Y, width: Width, height: Height)
        Layer.path = CGPath(rect: Rect1, transform: nil)
        Layer.fillColor = Color1.cgColor
        return Layer
    }
    
    override func loadView() {
        let view = UIView()
        view.backgroundColor = .clear

        let label = UILabel()
        label.frame = CGRect(x: 150, y: 200, width: 200, height: 20)
        label.text = "Hello World!"
        label.textColor = .black
        
        //view.addSubview(label)
        let Frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        let Layers = MakeSquares(Frame: Frame, Color1: UIColor.green, Color2: UIColor.orange, Color3: UIColor.purple)
        for SomeLayer in Layers
        {
            view.layer.addSublayer(SomeLayer)
        }
        self.view = view
    }
}
// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()
