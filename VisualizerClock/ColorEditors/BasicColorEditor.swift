//
//  BasicColorEditor
//  Visualizer Clock
//
//  Created by Stuart Rankin on 12/14/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class BasicColorEditor: UINavigationController, ColorEditing
{    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    func SourceColor(_ Color: UIColor)
    {
        _SourceColor0 = Color
    }
    
    func TitleForEditor(_ NewTitle: String)
    {
        _Title0 = NewTitle
    }
    
    func ColorSpace(_ ToColorSpace: ColorEditorColorSpaces)
    {
        _ColorSpace0 = ToColorSpace
    }
    
    private var _delegate: ColorReceiver? = nil
    public var CallerDelegate: ColorReceiver?
    {
        get
        {
            return _delegate
        }
        set
        {
            _delegate = newValue
        }
    }
    
    private var _InitialColorSpace: ColorEditorColorSpaces = .HSB
    public var InitialColorSpace: ColorEditorColorSpaces
    {
        get
        {
            return _InitialColorSpace
        }
        set
        {
            _InitialColorSpace = newValue
            _ColorSpace0 = newValue
        }
    }
    
    private var _InitialTitle: String = "Color Editor"
    public var InitialTitle: String
    {
        get
        {
            return _InitialTitle
        }
        set
        {
            _InitialTitle = newValue
            _Title0 = newValue
        }
    }
    
    private var _InitialColor: UIColor = UIColor.black
    public var InitialColor: UIColor
    {
        get
        {
            return _InitialColor
        }
        set
        {
            _InitialColor = newValue
            _SourceColor0 = newValue
        }
    }
    
    private var _ColorSettingsString: String = ""
    public var ColorSettingsString: String
    {
        get
        {
            return _ColorSettingsString
        }
        set
        {
            _ColorSettingsString = newValue
        }
    }
    
    private var _DelegateTag: String? = nil
    public var DelegateTag: String?
    {
        get
        {
            return _DelegateTag
        }
        set
        {
            _DelegateTag = newValue
        }
    }
    
    private var _SourceColor0: UIColor = UIColor.clear
    public var SourceColor0: UIColor
    {
        get
        {
            return _SourceColor0
        }
    }
    
    private var _Title0: String = "Color Editor"
    public var Title0: String
    {
        get
        {
            return _Title0
        }
    }
    
    private var _ColorSpace0: ColorEditorColorSpaces = .HSB
    public var ColorSpace0: ColorEditorColorSpaces
    {
        get
        {
            return _ColorSpace0
        }
    }
}
