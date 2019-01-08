//
//  MediumColorEditor.swift
//  Visualizer Clock
//
//  Created by Stuart Rankin on 9/17/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Available color spaces in which to edit colors.
///
/// - HSB: HSB color space.
/// - RGB: RGB color space.
/// - RGBA: RGB with alpha color space.
/// - CMYK: CMYK color space.
public enum ColorEditorColorSpaces
{
    case HSB
    case RGB
    case RGBA
    case CMYK
}

/// Implements a basic color editor.
class MediumColorEditor: UITableViewController, ColorEditing, ColorReceiver
{
    let _Settings = UserDefaults.standard
    
    /// Initial color space of the editor.
    public var InitialColorSpace: ColorEditorColorSpaces = .HSB
    /// Initial color to edit.
    public var InitialColor: UIColor = UIColor.black
    /// Initial title.
    public var InitialTitle: String = "Color Editor"
    /// The setting string to save the color in the user settings database. If empty, nothing is saved in the data base - it's up
    /// to the caller to do that.
    public var ColorSettingString: String = ""
    /// Tag supplied by the caller and returned via the delegate.ColorChanged function.
    public var DelegateTag: String? = nil
    
    #if false
    /// Populate the toolbar we added programmatically to the basic color editor.
    /// - Note: https://stackoverflow.com/questions/35106022/adding-buttons-to-toolbar-programmatically-in-swift
    func PopulateToolbar()
    {
        var Items = [UIBarButtonItem]()
        Items.append(UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(HandleSearchButtonPressed)))
        Items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
        Items.append(UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(HandleCancelButtonPressed)))
        //self.navigationController?.toolbar.setItems(Items, animated: false)
        self.toolbarItems = Items
    }
    #endif
    
    @IBAction func HandleToolbarSearchPressed(_ sender: Any)
    {
        performSegue(withIdentifier: "SearchForColorName", sender: self)
    }
    
    @IBAction func HandleToolbarCancelPressed(_ sender: Any)
    {
        WasCanceled = true
                dismiss(animated: true, completion: nil)
//        navigationController?.popViewController(animated: true)
    }
    
    #if false
    /// Handle the search button press in the tool bar. This jumps to the color name searcher.
    @objc func HandleSearchButtonPressed()
    {
        performSegue(withIdentifier: "SearchForColorName", sender: self)
    }
    
    /// Handle the cancel button press in the tool bar. This closes the basic color editor and reports no color editing.
    @objc func HandleCancelButtonPressed()
    {
        WasCanceled = true
        //dismiss(animated: true, completion: nil)
        navigationController?.popViewController(animated: true)
    }
    
    /// Programmatically add a toolbar to the basic color editor at the view will appear event. This is done because it's really
    /// hard to add one at design-time when the navigation controller isn't showing toolbars in general.
    /// -Note: https://stackoverflow.com/questions/19625416/how-to-add-a-toolbar-to-the-bottom-of-a-uitableviewcontroller-in-storyboards
    ///
    /// - Parameter animated: Passed to the super-class function without change.
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        //self.navigationController?.setToolbarHidden(false, animated: animated)
        //PopulateToolbar()
    }
    #endif
    
    private var _Parent: BasicColorEditor? = nil
    var Parent: BasicColorEditor?
    {
        get
        {
            return _Parent
        }
        set
        {
            _Parent = newValue
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        ColorSample.layer.borderColor = UIColor.black.cgColor
        ColorSample.layer.borderWidth = 0.5
        ColorSample.layer.cornerRadius = 5.0
        #if true
        Parent = navigationController as? BasicColorEditor
        if Parent == nil
        {
            print("Could not find parent for color editor.")
            return
        }
        else
        {
            print("Found parent.")
        }
        InitialColor = (Parent?.InitialColor)!
        InitialTitle = (Parent?.InitialTitle)!
        InitialColorSpace = (Parent?.InitialColorSpace)!
        delegate = Parent?.CallerDelegate
        DelegateTag = Parent?.DelegateTag
        ColorSettingString = (Parent?.ColorSettingsString)!
        SetColorSpace(InitialColorSpace)
        title = InitialTitle
        navigationController?.title = InitialTitle
        ColorSpace(InitialColorSpace)
        SourceColor(InitialColor)
        #else
        SetColorSpace(InitialColorSpace)
        title = InitialTitle
        ColorSpace(InitialColorSpace)
        SourceColor(InitialColor)
        #endif
        
        ChannelDInputHome = ChannelDInput.frame.minX
        ChannelDLabelHome = ChannelDLabel.frame.minX
        ChannelDSliderHome = ChannelDSlider.frame.minX
        ChannelDDescriptionHome = ChannelDDescription.frame.minX
        
        if let SomeColorName = PredefinedColors.NameFrom(Color: InitialColor)
        {
            ColorNameLabel.text = SomeColorName
            ColorNameHint.text = SomeColorName
        }
        else
        {
            ColorNameLabel.text = ""
            ColorNameHint.text = ""
        }
        
        PopulateUI()
    }
    
    var ChannelDInputHome: CGFloat = 0.0
    var ChannelDLabelHome: CGFloat = 0.0
    var ChannelDSliderHome: CGFloat = 0.0
    var ChannelDDescriptionHome: CGFloat = 0.0
    
    override func viewWillDisappear(_ animated: Bool)
    {
        if PushingView
        {
            PushingView = false
            super.viewWillAppear(animated)
            return
        }
        print("At MediumColorEditor.viewWillDisappear")
        var DidChange = true
        if WasCanceled
        {
            DidChange = false
            CurrentColor = OriginalColor
        }
        else
        {
            DidChange = CurrentColor != OriginalColor
            let (Ro, Go, Bo, Ao) = Utility.GetRGBA(OriginalColor)
            let (Rc, Gc, Bc, Ac) = Utility.GetRGBA(CurrentColor)
            print("Original color: (\(Ro),\(Go),\(Bo),\(Ao)), Current color: (\(Rc),\(Gc),\(Bc),\(Ac)), DidChange=\(DidChange)")
            if !ColorSettingString.isEmpty
            {
                print("Saving color to \(ColorSettingString)")
                _Settings.set(CurrentColor, forKey: ColorSettingString)
            }
        }
        delegate?.ColorChanged(NewColor: CurrentColor, DidChange: DidChange, Tag: DelegateTag)
        //self.navigationController?.setToolbarHidden(true, animated: animated)
        super.viewWillDisappear(animated)
    }
    
    var WasCanceled: Bool = false
    
    var delegate: ColorReceiver? = nil
    
    /// Set the source color.
    ///
    /// - Parameter Color: The source color to edit.
    func SourceColor(_ Color: UIColor)
    {
        OriginalColor = Color
        CurrentColor = Color
        ColorSample.backgroundColor = OriginalColor
        #if false
        let (R, G, B) = Utility.GetRGB(OriginalColor)
        let (H, S, Br) = Utility.GetHSB(SourceColor: OriginalColor)
        print("BasicColorEditor: Initial color is RGB:\(R),\(G),\(B), HSB:\(H),\(S),\(Br)")
        #endif
    }
    
    var CurrentColor: UIColor = UIColor.clear
    
    var OriginalColor: UIColor = UIColor.clear
    
    /// Populate the UI with color data.
    func PopulateUI()
    {
        switch CurrentColorSpace
        {
        case .RGB:
            let (R, G, B) = Utility.GetRGB(CurrentColor)
            
            let RText = String(describing: R)
            ChannelAInput.text = RText
            let RValue: Float = Float((Double(R) * (1000.0 / 255.0)))
            ChannelASlider.value = RValue
            
            let GText = String(describing: G)
            ChannelBInput.text = GText
            let GValue: Float = Float((Double(G) * (1000.0 / 255.0)))
            ChannelBSlider.value = GValue
            
            let BText = String(describing: B)
            ChannelCInput.text = BText
            let BValue: Float = Float((Double(B) * (1000.0 / 255.0)))
            ChannelCSlider.value = BValue
            
        case .RGBA:
            let (R, G, B, A) = Utility.GetRGBA(CurrentColor)
            
            let RText = String(describing: R)
            ChannelAInput.text = RText
            let RValue: Float = Float((Double(R) * (1000.0 / 255.0)))
            ChannelASlider.value = RValue
            
            let GText = String(describing: G)
            ChannelBInput.text = GText
            let GValue: Float = Float((Double(G) * (1000.0 / 255.0)))
            ChannelBSlider.value = GValue
            
            let BText = String(describing: B)
            ChannelCInput.text = BText
            let BValue: Float = Float((Double(B) * (1000.0 / 255.0)))
            ChannelCSlider.value = BValue
            
            let AVal = Double(A) / 255.0
            let AText = String(describing: AVal)
            ChannelDInput.text = AText
            let AValue: Float = Float((Double(A) * 1000.0))
            ChannelDSlider.value = AValue
            
        case .HSB:
            let (H, S, B) = Utility.GetHSB(SourceColor: CurrentColor)
            
            let HText = String(describing: Int(Utility.Round(H * 360.0, ToPlaces: 0)))
            ChannelAInput.text = HText
            let HValue: Float = Float((Double(H) * 360.0) * (1000.0 / 360.0))
            ChannelASlider.value = HValue
            
            let SText = String(describing: Utility.Round(S, ToPlaces: 2))
            ChannelBInput.text = SText
            let SValue: Float = Float((Double(S) * (1000.0 / 1.0)))
            ChannelBSlider.value = SValue
            
            let BText = String(describing: Utility.Round(B, ToPlaces: 2))
            ChannelCInput.text = BText
            let BValue: Float = Float((Double(B) * (1000.0 / 1.0)))
            ChannelCSlider.value = BValue
            
        case .CMYK:
            let (C, M, Y, K) = Utility.ToCMYK(CurrentColor)
            
            let CText = String(describing: Utility.Round(C, ToPlaces: 2))
            ChannelAInput.text = CText
            ChannelASlider.value = Float(C * 1000.0)
            
            let MText = String(describing: Utility.Round(M, ToPlaces: 2))
            ChannelBInput.text = MText
            ChannelBSlider.value = Float(M * 1000.0)
            
            let YText = String(describing: Utility.Round(Y, ToPlaces: 2))
            ChannelCInput.text = YText
            ChannelCSlider.value = Float(Y * 1000.0)
            
            let KText = String(describing: Utility.Round(K, ToPlaces: 2))
            ChannelDInput.text = KText
            ChannelDSlider.value = Float(K * 1000.0)
        }
    }
    
    /// Set the title for the editor.
    ///
    /// - Parameter NewTitle: New title string.
    func TitleForEditor(_ NewTitle: String)
    {
        title = NewTitle
    }
    
    /// Set the colorspace to the passed colorspace type.
    ///
    /// - Parameter ToColorSpace: The colorspace to switch to.
    func ColorSpace(_ ToColorSpace: ColorEditorColorSpaces)
    {
        SetColorSpace(ToColorSpace)
    }
    
    /// Set the color space.
    ///
    /// - Parameter ToColorSpace: Determines the color space to display.
    private func SetColorSpace(_ ToColorSpace: ColorEditorColorSpaces)
    {
        
        CurrentColorSpace = ToColorSpace
        switch ToColorSpace
        {
        case .RGB:
            SetRGBColorSpace()
            ColorSpaceSegment.selectedSegmentIndex = 0
            
        case .RGBA:
            SetRGBAColorSpace()
            ColorSpaceSegment.selectedSegmentIndex = 1
            
        case .HSB:
            SetHSBColorSpace()
            ColorSpaceSegment.selectedSegmentIndex = 2
            
        case .CMYK:
            SetCMYKColorSpace()
            ColorSpaceSegment.selectedSegmentIndex = 3
        }
        
        UpdateUIForChannels()
        PreviousColorSpace = CurrentColorSpace
    }
    
    var PreviousColorSpace: ColorEditorColorSpaces? = nil
    
    /// Update the user interface with new channel values.
    private func UpdateUIForChannels()
    {
        switch CurrentColorSpace
        {
        case .HSB:
            fallthrough
        case .RGB:
            //Hide fourth channel entry controls.
            UIView.animate(withDuration: 0.45, delay: 0.0,
                           usingSpringWithDamping: 0.2, initialSpringVelocity: 1.0,
                           options: .curveEaseIn,
                           animations:
                {
                    self.ChannelDInput.alpha = 0.0
                    self.ChannelDLabel.alpha = 0.0
                    self.ChannelDSlider.alpha = 0.0
                    self.ChannelDDescription.alpha = 0.0
                    self.ChannelDInput.center.x = 400
                    self.ChannelDLabel.center.x = 400
                    self.ChannelDSlider.center.x = 400
                    self.ChannelDDescription.center.x = 400
            },
                           completion:
                {
                    finished in
                    self.ChannelDSlider.isUserInteractionEnabled = false
                    self.ChannelDInput.isUserInteractionEnabled = false
            })
            
        case .CMYK:
            fallthrough
        case .RGBA:
            //Display fourth channel entry controls.
            UIView.animate(withDuration: 0.25, delay: 0.0,
                           usingSpringWithDamping: 0.2, initialSpringVelocity: 1.0,
                           options: .curveEaseOut,
                           animations:
                {
                    self.ChannelDInput.alpha = 1.0
                    self.ChannelDLabel.alpha = 1.0
                    self.ChannelDSlider.alpha = 1.0
                    self.ChannelDDescription.alpha = 1.0
                    self.ChannelDInput.center.x = self.ChannelCInput.frame.minX + (self.ChannelCInput.frame.width / 2.0)
                    self.ChannelDLabel.center.x = self.ChannelCLabel.frame.minX + (self.ChannelCLabel.frame.width / 2.0)
                    self.ChannelDSlider.center.x = self.ChannelCSlider.frame.minX + (self.ChannelCSlider.frame.width / 2.0)
                    self.ChannelDDescription.center.x = self.ChannelCDescription.frame.minX + (self.ChannelCDescription.frame.width / 2.0)
            },
                           completion:
                {
                    finished in
                    self.ChannelDSlider.isUserInteractionEnabled = true
                    self.ChannelDInput.isUserInteractionEnabled = true
            })
        }
    }
    
    private var Showing4Channels: Bool = true
    
    /// Set HSB color space. This means changing labels and slider values as well as color data displayed on the screen.
    private func SetHSBColorSpace()
    {
        let (H, S, B) = Utility.GetHSB(SourceColor: CurrentColor)
        ChannelALabel.text = "Hue"
        ChannelADescription.text = "The value of the hue component of the color: 0 to 360."
        let FinalH = Utility.Round(H, ToPlaces: 0)
        ChannelAInput.text = String(describing: FinalH)
        ChannelASlider.value = Float(H * (1000.0 / 360.0))
        ChannelBLabel.text = "Saturation"
        ChannelBDescription.text = "The value of the saturation component of the color: 0 to 1."
        let FinalS = Utility.Round(S, ToPlaces: 2)
        ChannelBInput.text = String(describing: FinalS)
        ChannelBSlider.value = Float(S * 1000.0)
        ChannelCLabel.text = "Brightness"
        ChannelCDescription.text = "The value of the brightness component of the color: 0 to 1."
        let FinalB = Utility.Round(B, ToPlaces: 2)
        ChannelCInput.text = String(describing: FinalB)
        ChannelCSlider.value = Float(B * 1000.0)
    }
    
    /// Set RGB color space. This means changing labels and slider values as well as color data displayed on the screen.
    private func SetRGBColorSpace()
    {
        let (R, G, B) = Utility.GetRGB(CurrentColor)
        //print("RGB color is (\(R),\(G),\(B))")
        ChannelALabel.text = "Red"
        ChannelADescription.text = "The value of the red component of the color: 0 to 255."
        ChannelAInput.text = String(describing: R)
        ChannelASlider.value = Float(Double(R) * (1000.0 / 255.0))
        ChannelBLabel.text = "Green"
        ChannelBDescription.text = "The value of the green component of the color: 0 to 255."
        ChannelBInput.text = String(describing: G)
        ChannelBSlider.value = Float(Double(G) * (1000.0 / 255.0))
        ChannelCLabel.text = "Blue"
        ChannelCDescription.text = "The value of the blue component of the color: 0 to 255."
        ChannelCInput.text = String(describing: B)
        ChannelCSlider.value = Float(Double(B) * (1000.0 / 255.0))
    }
    
    /// Set RGBA color space. This means changing labels and slider values as well as color data displayed on the screen.
    private func SetRGBAColorSpace()
    {
        let (R, G, B, A) = Utility.GetRGBA(CurrentColor)
        //print("RGB color is (\(R),\(G),\(B))")
        ChannelALabel.text = "Red"
        ChannelADescription.text = "The value of the red component of the color: 0 to 255."
        ChannelAInput.text = String(describing: R)
        ChannelASlider.value = Float(Double(R) * (1000.0 / 255.0))
        ChannelBLabel.text = "Green"
        ChannelBDescription.text = "The value of the green component of the color: 0 to 255."
        ChannelBInput.text = String(describing: G)
        ChannelBSlider.value = Float(Double(G) * (1000.0 / 255.0))
        ChannelCLabel.text = "Blue"
        ChannelCDescription.text = "The value of the blue component of the color: 0 to 255."
        ChannelCInput.text = String(describing: B)
        ChannelCSlider.value = Float(Double(B) * (1000.0 / 255.0))
        ChannelDLabel.text = "Alpha"
        ChannelDDescription.text = "The value of the alpha component: 0 to 1."
        let AVal = (Double(A) / 255.0)
        ChannelDInput.text = String(describing: AVal)
        ChannelDSlider.value = Float(Double(AVal) * 1000.0)
    }
    
    /// Set CMYK color space. This means changing labels and slider values as well as color data displayed on the screen.
    private func SetCMYKColorSpace()
    {
        let (C, M, Y, K) = Utility.ToCMYK(CurrentColor)
        //print("CMYK color is (\(C),\(M),\(Y),\(K))")
        ChannelALabel.text = "Cyan"
        ChannelADescription.text = "The value of the cyan component of the color: 0 to 1."
        ChannelAInput.text = String(describing: C)
        ChannelASlider.value = Float(Double(C) * 1000.0)
        ChannelBLabel.text = "Magenta"
        ChannelBDescription.text = "The value of the magenta component of the color: 0 to 1."
        ChannelBInput.text = String(describing: M)
        ChannelBSlider.value = Float(Double(M) * 1000.0)
        ChannelCLabel.text = "Yellow"
        ChannelCDescription.text = "The value of the yellow component of the color: 0 to 1."
        ChannelCInput.text = String(describing: Y)
        ChannelCSlider.value = Float(Double(Y) * 1000.0)
        ChannelDLabel.text = "Black"
        ChannelDDescription.text = "The value of the black (K) component: 0 to 1."
        ChannelDInput.text = String(describing: K)
        ChannelDSlider.value = Float(Double(K) * 1000.0)
    }
    
    private var CurrentColorSpace: ColorEditorColorSpaces = .HSB
    
    @IBOutlet weak var ColorSpaceSegment: UISegmentedControl!
    
    /// Handle changes to th color space from the user.
    ///
    /// - Parameter sender: Not used.
    @IBAction func HandleChangesToColorSpace(_ sender: Any)
    {
        switch ColorSpaceSegment.selectedSegmentIndex
        {
        case 0:
            CurrentColorSpace = .RGB
            
        case 1:
            CurrentColorSpace = .RGBA
            
        case 2:
            CurrentColorSpace = .HSB
            
        case 3:
            CurrentColorSpace = .CMYK
            
        default:
            CurrentColorSpace = .HSB
        }
        SetColorSpace(CurrentColorSpace)
        tableView.reloadData()
    }
    
    /// Get text from an text input control, validate it (potentially changing the context of the text field), and return the results
    /// as a number.
    ///
    /// - Parameters:
    ///   - TextField: The text field input control.
    ///   - MaxValue: Maximum value allowed. (Minimum value is always 0.0.)
    /// - Returns: Validated value between 0.0 and MaxValue.
    func GetValidatedChannelValue(_ TextField: UITextField, MaxValue: CGFloat) -> CGFloat
    {
        if let Text = TextField.text
        {
            if let DNumber = Double(Text)
            {
                var Final = CGFloat(DNumber)
                if Final < 0.0
                {
                    Final = 0.0
                    TextField.text = "0.0"
                }
                if Final > MaxValue
                {
                    Final = MaxValue
                    TextField.text = String(describing: Final)
                }
                return Final
            }
            else
            {
                TextField.text = "0.0"
                return 0.0
            }
        }
        else
        {
            TextField.text = "0.0"
            return 0.0
        }
    }
    
    /// Update the HSB color. Color channel values are read from the text fields.
    func UpdateHSBColor()
    {
        let H = GetValidatedChannelValue(ChannelAInput, MaxValue: 360.0) / 360.0
        let S = GetValidatedChannelValue(ChannelBInput, MaxValue: 1.0)
        let B = GetValidatedChannelValue(ChannelCInput, MaxValue: 1.0)
        //print("Udating HSB color to (\(H),\(S),\(B))")
        CurrentColor = UIColor(hue: H, saturation: S, brightness: B, alpha: 1.0)
        UpdateSampleColor(CurrentColor)
    }
    
    /// Update the CMYK color. Color channel values are read from the text fields.
    func UpdateCMYKColor()
    {
        let C = GetValidatedChannelValue(ChannelAInput, MaxValue: 1.0)
        let M = GetValidatedChannelValue(ChannelBInput, MaxValue: 1.0)
        let Y = GetValidatedChannelValue(ChannelCInput, MaxValue: 1.0)
        let K = GetValidatedChannelValue(ChannelDInput, MaxValue: 1.0)
        CurrentColor = Utility.FromCMYK(C, M, Y, K)
        UpdateSampleColor(CurrentColor)
    }
    
    /// Update the RGB color. Color channel values are read from the text fields. Also updates
    /// RGBA colors.
    func UpdateRGBColor()
    {
        //print("Updating RGB color.")
        switch CurrentColorSpace
        {
        case .RGB:
            let R = GetValidatedChannelValue(ChannelAInput, MaxValue: 255.0) / 255.0
            let G = GetValidatedChannelValue(ChannelBInput, MaxValue: 255.0) / 255.0
            let B = GetValidatedChannelValue(ChannelCInput, MaxValue: 255.0) / 255.0
            CurrentColor = UIColor(red: R, green: G, blue: B, alpha: 1.0)
            UpdateSampleColor(CurrentColor)
            
        case .RGBA:
            let R = GetValidatedChannelValue(ChannelAInput, MaxValue: 255.0) / 255.0
            let G = GetValidatedChannelValue(ChannelBInput, MaxValue: 255.0) / 255.0
            let B = GetValidatedChannelValue(ChannelCInput, MaxValue: 255.0) / 255.0
            let A = GetValidatedChannelValue(ChannelDInput, MaxValue: 1.0)
            CurrentColor = UIColor(red: R, green: G, blue: B, alpha: A)
            UpdateSampleColor(CurrentColor)
            
        default:
            break
        }
    }
    
    /// Update the sample color and color name.
    ///
    /// - Parameter Sample: The sample color. Also used to retrieve the color name (if any).
    func UpdateSampleColor(_ Sample: UIColor)
    {
        ColorSample.backgroundColor = Sample
        if let ColorName = PredefinedColors.NameFrom(Color: Sample)
        {
            ColorNameLabel.text = ColorName
            ColorNameHint.text = ColorName
        }
        else
        {
            ColorNameLabel.text = ""
            ColorNameHint.text = ""
        }
    }
    
    /// Handle changes to the value of the text field for channel A (Hue or Red). UI and colors are updated.
    ///
    /// - Parameter sender: Not used.
    @IBAction func HandleChannelATextChanged(_ sender: Any)
    {
        view.endEditing(true)
        switch CurrentColorSpace
        {
        case .HSB:
            let ChannelAValue = GetValidatedChannelValue(sender as! UITextField, MaxValue: 360.0)
            let NewSliderValue: Float = Float(ChannelAValue * (1000.0 / 360.0))
            ChannelASlider.value = NewSliderValue
            UpdateHSBColor()
            
        case .CMYK:
            let ChannelAValue = GetValidatedChannelValue(sender as! UITextField, MaxValue: 1.0)
            let NewSliderValue: Float = Float(ChannelAValue * 1000.0)
            ChannelASlider.value = NewSliderValue
            UpdateCMYKColor()
            
        case .RGB:
            fallthrough
        case .RGBA:
            let ChannelAValue = GetValidatedChannelValue(sender as! UITextField, MaxValue: 255.0)
            let NewSliderValue: Float = Float(ChannelAValue * (1000.0 / 255.0))
            ChannelASlider.value = NewSliderValue
            UpdateRGBColor()
        }
    }
    
    /// Handle changes to the value of the text field for channel B (Saturation or Green). UI and colors are updated.
    ///
    /// - Parameter sender: Not used.
    @IBAction func HandleChannelBTextChanged(_ sender: Any)
    {
        view.endEditing(true)
        switch CurrentColorSpace
        {
        case .HSB:
            let ChannelBValue = GetValidatedChannelValue(sender as! UITextField, MaxValue: 360.0)
            let NewSliderValue: Float = Float(ChannelBValue * (1000.0 / 360.0))
            ChannelBSlider.value = NewSliderValue
            UpdateHSBColor()
            
        case .CMYK:
            let ChannelBValue = GetValidatedChannelValue(sender as! UITextField, MaxValue: 1.0)
            let NewSliderValue: Float = Float(ChannelBValue * 1000.0)
            ChannelBSlider.value = NewSliderValue
            UpdateCMYKColor()
            
        case .RGB:
            fallthrough
        case .RGBA:
            let ChannelBValue = GetValidatedChannelValue(sender as! UITextField, MaxValue: 255.0)
            let NewSliderValue: Float = Float(ChannelBValue * (1000.0 / 255.0))
            ChannelBSlider.value = NewSliderValue
            UpdateRGBColor()
        }
    }
    
    /// Handle changes to the value of the text field for channel C (Brightness or Blue). UI and colors are updated.
    ///
    /// - Parameter sender: Not used.
    @IBAction func HandleChannelCTextChanged(_ sender: Any)
    {
        view.endEditing(true)
        switch CurrentColorSpace
        {
        case .HSB:
            let ChannelCValue = GetValidatedChannelValue(sender as! UITextField, MaxValue: 360.0)
            let NewSliderValue: Float = Float(ChannelCValue * (1000.0 / 360.0))
            ChannelCSlider.value = NewSliderValue
            UpdateHSBColor()
            
        case .CMYK:
            let ChannelCValue = GetValidatedChannelValue(sender as! UITextField, MaxValue: 1.0)
            let NewSliderValue: Float = Float(ChannelCValue * 1000.0)
            ChannelCSlider.value = NewSliderValue
            UpdateCMYKColor()
            
        case .RGB:
            fallthrough
        case .RGBA:
            let ChannelCValue = GetValidatedChannelValue(sender as! UITextField, MaxValue: 255.0)
            let NewSliderValue: Float = Float(ChannelCValue * (1000.0 / 255.0))
            ChannelCSlider.value = NewSliderValue
            UpdateRGBColor()
        }
    }
    
    /// Handle changes to the value of the text field for channel C (Brightness or Blue). UI and colors are updated.
    ///
    /// - Parameter sender: Not used.
    @IBAction func HandleChannelDTextChanged(_ sender: Any)
    {
        view.endEditing(true)
        switch CurrentColorSpace
        {
        case .CMYK:
            let ChannelDValue = GetValidatedChannelValue(sender as! UITextField, MaxValue: 1.0)
            let NewSliderValue: Float = Float(ChannelDValue * 1000.0)
            ChannelDSlider.value = NewSliderValue
            UpdateCMYKColor()
            
        case .RGBA:
            let ChannelDValue = GetValidatedChannelValue(sender as! UITextField, MaxValue: 1.0)
            let NewSliderValue: Float = Float(ChannelDValue * 1000.0)
            ChannelDSlider.value = NewSliderValue
            UpdateRGBColor()
            
        default:
            return
        }
    }
    
    /// Handle slider A changes (changes to Hue or Red, depending on the color space). UI values and colors
    /// are updated.
    ///
    /// - Parameter sender: Not used.
    @IBAction func HandleSliderAChanged(_ sender: Any)
    {
        let Slider = sender as! UISlider
        var SliderValue = CGFloat(Slider.value)
        switch CurrentColorSpace
        {
        case .HSB:
            SliderValue = SliderValue * (360.0 / 1000.0)
            //print("Hue Slider.value(\(Slider.value)) converts to \(SliderValue)")
            SliderValue = Utility.Round(SliderValue, ToPlaces: 0)
            ChannelAInput.text = Utility.StripDecimalPortion(From: String(describing: SliderValue))
            UpdateHSBColor()
            
        case .CMYK:
            SliderValue = SliderValue / 1000.0
            SliderValue = Utility.Round(SliderValue, ToPlaces: 2)
            ChannelAInput.text = String(describing: SliderValue)
            UpdateCMYKColor()
            
        case .RGB:
            fallthrough
        case .RGBA:
            SliderValue = SliderValue * (255.0 / 1000.0)
            SliderValue = Utility.Round(SliderValue, ToPlaces: 0)
            let ISliderValue = Int(SliderValue)
            ChannelAInput.text = String(describing: ISliderValue)
            UpdateRGBColor()
        }
    }
    
    /// Handle slider B changes (changes to Saturation or Green, depending on the color space). UI values and colors
    /// are updated.
    ///
    /// - Parameter sender: Not used.
    @IBAction func HandleSliderBChanged(_ sender: Any)
    {
        let Slider = sender as! UISlider
        var SliderValue = CGFloat(Slider.value)
        switch CurrentColorSpace
        {
        case .HSB:
            SliderValue = SliderValue / 1000.0
            SliderValue = Utility.Round(SliderValue, ToPlaces: 2)
            ChannelBInput.text = String(describing: SliderValue)
            UpdateHSBColor()
            
        case .CMYK:
            SliderValue = SliderValue / 1000.0
            SliderValue = Utility.Round(SliderValue, ToPlaces: 2)
            ChannelBInput.text = String(describing: SliderValue)
            UpdateCMYKColor()
            
        case .RGB:
            fallthrough
        case .RGBA:
            SliderValue = SliderValue * (255.0 / 1000.0)
            SliderValue = Utility.Round(SliderValue, ToPlaces: 0)
            let ISliderValue = Int(SliderValue)
            ChannelBInput.text = String(describing: ISliderValue)
            UpdateRGBColor()
        }
    }
    
    /// Handle slider C changes (changes to Brightness or Blue, depending on the color space). UI values and colors
    /// are updated.
    ///
    /// - Parameter sender: Not used.
    @IBAction func HandleSliderCChanged(_ sender: Any)
    {
        let Slider = sender as! UISlider
        var SliderValue = CGFloat(Slider.value)
        switch CurrentColorSpace
        {
        case .HSB:
            SliderValue = SliderValue / 1000.0
            SliderValue = Utility.Round(SliderValue, ToPlaces: 2)
            ChannelCInput.text = String(describing: SliderValue)
            UpdateHSBColor()
            
        case .CMYK:
            SliderValue = SliderValue / 1000.0
            SliderValue = Utility.Round(SliderValue, ToPlaces: 2)
            ChannelCInput.text = String(describing: SliderValue)
            UpdateCMYKColor()
            
        case .RGB:
            fallthrough
        case .RGBA:
            SliderValue = SliderValue * (255.0 / 1000.0)
            SliderValue = Utility.Round(SliderValue, ToPlaces: 0)
            let ISliderValue = Int(SliderValue)
            ChannelCInput.text = String(describing: ISliderValue)
            UpdateRGBColor()
        }
    }
    
    /// Handle slider D changes (changes to alpha, depending on the color space). UI values and colors
    /// are updated.
    ///
    /// - Parameter sender: Not used.
    @IBAction func HandleSliderDChanged(_ sender: Any)
    {
        let Slider = sender as! UISlider
        var SliderValue = CGFloat(Slider.value)
        switch CurrentColorSpace
        {
        case .CMYK:
            SliderValue = SliderValue / 1000.0
            SliderValue = Utility.Round(SliderValue, ToPlaces: 2)
            ChannelDInput.text = String(describing: SliderValue)
            UpdateCMYKColor()
            
        case .RGBA:
            SliderValue = SliderValue / 1000.0
            SliderValue = Utility.Round(SliderValue, ToPlaces: 2)
            ChannelDInput.text = String(describing: SliderValue)
            UpdateRGBColor()
            
        default:
            break
        }
    }
    
    /// Someone we called is telling us we have a new color.
    ///
    /// - Parameters:
    ///   - NewColor: The new color.
    ///   - DidChange: If true, the color is different from the original color. If false, it's the same.
    ///   - Tag: In our case, this is the name of the new color.
    func ColorChanged(NewColor: UIColor, DidChange: Bool, Tag: String?)
    {
        if DidChange
        {
            if Tag == "SearchForName"
            {
                CurrentColor = NewColor
                PopulateUI()
                UpdateSampleColor(CurrentColor)
                return
            }
            CurrentColor = NewColor
            ColorNameHint.text = Tag!
            ColorNameLabel.text = Tag!
            PopulateUI()
            UpdateSampleColor(CurrentColor)
        }
    }
    
    /// Perpare for a seque.
    ///
    /// - Parameters:
    ///   - segue: The segue that will be run.
    ///   - sender: Not used.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        switch segue.identifier
        {
        case "ToPredefinedColorEditor":
            let Dest = segue.destination as? PredefinedColorViewer
            Dest?.delegate = self
            Dest?.SourceColorSpace = CurrentColorSpace
            
        case "SearchForColorName":
            let Dest = segue.destination as? ColorNameSearcher
            Dest?.delegate = self
            Dest?.ReturnTag = "SearchForName"
            
        default:
            break
        }
        
        PushingView = true
        super.prepare(for: segue, sender: self)
    }
    
    private var PushingView: Bool = false
    
    @IBAction func HandleDoneButtonPressed(_ sender: Any)
    {
        PushingView = false
        if Parent == nil
        {
            print("Parent is nil in HandleDoneButtonPressed.")
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func unwindToStep1ViewController(_ segue: UIStoryboardSegue)
    {
        PushingView = false
    }
    
    @IBOutlet weak var ColorNameHint: UILabel!
    @IBOutlet weak var ColorNameLabel: UILabel!
    @IBOutlet weak var ColorSample: UIView!
    @IBOutlet weak var ChannelALabel: UILabel!
    @IBOutlet weak var ChannelBLabel: UILabel!
    @IBOutlet weak var ChannelCLabel: UILabel!
    @IBOutlet weak var ChannelDLabel: UILabel!
    @IBOutlet weak var ChannelADescription: UILabel!
    @IBOutlet weak var ChannelBDescription: UILabel!
    @IBOutlet weak var ChannelCDescription: UILabel!
    @IBOutlet weak var ChannelDDescription: UILabel!
    @IBOutlet weak var ChannelAInput: UITextField!
    @IBOutlet weak var ChannelBInput: UITextField!
    @IBOutlet weak var ChannelCInput: UITextField!
    @IBOutlet weak var ChannelDInput: UITextField!
    @IBOutlet weak var ChannelASlider: UISlider!
    @IBOutlet weak var ChannelBSlider: UISlider!
    @IBOutlet weak var ChannelCSlider: UISlider!
    @IBOutlet weak var ChannelDSlider: UISlider!
    @IBOutlet weak var AlphaCell: UITableViewCell!
}
