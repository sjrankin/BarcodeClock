//
//  ContainerViewController.swift
//  BarcodeTest
//
//  Created by Stuart Rankin on 8/13/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

class ContainerViewController: UIViewController
{
    let _Settings = UserDefaults.standard
    
    public func OverrideTimeText(WithString: String, DoLock: Bool)
    {
        CenterViewController.OverWriteTimeText(WithString, DoLock: DoLock)
    }
    
    /// Tell the system that we don't want the status bar getting in the way.
    override var prefersStatusBarHidden: Bool
    {
        return true//_Settings.bool(forKey: Setting.Key.HideStatusBar)
    }
    /*
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return UIStatusBarStyle.default
    }
    */
    /// States a panel may be in.
    ///
    /// - Collapsed: Collapsed - eg, not visible.
    /// - LeftExpanded: Left-side panel expanded.
    /// - RightExpanded: Right-side panel expanded.
    enum SlidingStates
    {
        case Collapsed
        case LeftExpanded
        case RightExpanded
    }
    
    /// Holds the center navigation controller.
    var CenterNavigationController: UINavigationController!
    
    /// Holds the center view controller.
    var CenterViewController: MainUICode!
    
        public weak var MainDelegate: MainUIProtocol?
    
    /// Get the state of the panels.
    var CurrentState: SlidingStates = .Collapsed
    {
        didSet
        {
            let ShowShadow = CurrentState != .Collapsed
            ShowShadowForCenterViewController(ShowShadow)
        }
    }
    
    /// Determines if the left-side panel is showing.
    ///
    /// - Returns: True if the left-side panel is showing, false if not.
    func LeftSidePanelShowing() -> Bool
    {
        return CurrentState == .LeftExpanded
    }
    
    /// Determines if the right-side panel is showing.
    ///
    /// - Returns: True if the right-side panel is showing, false if not.
    func RightSidePanelShowing() -> Bool
    {
        return CurrentState == .RightExpanded
    }
    
    /// Holds the right-side panel.
    var RightSlidePanel: RightSidePanelViewController?
    
    /// Holds the left-side panel.
    var LeftSlidePanel: LeftSidePanelViewController?
    
    /// Holds the current expanded offset value.
    var _ExpandedOffset: CGFloat = 0
    /// Get the expanded offset value.
    var ExpandedOffset: CGFloat
    {
        get
        {
            #if true
            return 60.0
            #else
            return UIDevice.current.userInterfaceIdiom == .pad ? 100.0 : 60.0
            #endif
        }
    }
    
    /// Initialize container.
    override func viewDidLoad()
    {
        super.viewDidLoad()
        CenterViewController = UIStoryboard.CenterViewController()
        CenterViewController.delegate = self
        
        CenterNavigationController = UINavigationController(rootViewController: CenterViewController)
        view.addSubview(CenterNavigationController.view)
        addChild(CenterNavigationController)
        CenterNavigationController.didMove(toParent: self)
        
        let PanGesture = UIPanGestureRecognizer(target: self, action: #selector(HandlePanGesture(_:)))
        CenterNavigationController.view.addGestureRecognizer(PanGesture)
        
        //https://stackoverflow.com/questions/37648924/how-to-hide-navigation-bar-immediately-in-swift
        CenterNavigationController.setNavigationBarHidden(true, animated: false)
    }
}

/// Identifies side panels.
///
/// - Left: The left side panel. Contains barcodes the user can select.
/// - Right: The right side panel. Contains settings.
enum SidePanels: Int
{
    case Left = 0
    case Right = 1
}

extension ContainerViewController: CenterViewControllerDelegate
{
    /// Called when the left-side panel is collapsing. Pass on the call to the center view controller.
    func LeftPanelCollapsing()
    {
        CenterViewController.HandleLeftPanelCollapsing()
    }
    
    /// Called when the right-side panel is collapsing. Pass on the call to the center view controller.
    func RightPanelCollapsing()
    {
        CenterViewController.HandleRightPanelCollapsing()
    }
    
    /// Returns true if either side panel is visible, false otherwise.
    func SidePanelShowing() -> Bool
    {
        return CurrentState != .Collapsed
    }
    
    /// Toggle the visibility of the left-side panel.
    func ToggleLeftPanel()
    {
        let NotExpanded = (CurrentState != .LeftExpanded)
        if NotExpanded
        {
            AddLeftSidePanel()
        }
        else
        {
            SendStatus(.LeftClosed)
        }
        AnimateLeftPanel(shouldExpand: NotExpanded)
    }
    
    /// Toggle the visibility of the right-side panel.
    func ToggleRightPanel()
    {
        let NotExpanded = (CurrentState != .RightExpanded)
        if NotExpanded
        {
            AddRightSidePanel()
        }
        else
        {
            SendStatus(.RightClosed)
        }
        AnimateRightPanel(shouldExpand: NotExpanded)
    }
    
    /// Collapse any side panels that are visible.
    func CollapseSidePanels()
    {
        switch CurrentState
        {
        case .LeftExpanded:
            ToggleLeftPanel()
            SendStatus(.LeftClosed)
            
        case .RightExpanded:
            ToggleRightPanel()
            SendStatus(.RightClosed)
            
        default:
            break;
        }
    }
    
    func SendStatus(_ Status: PanelStatuses)
    {
        let AD = UIApplication.shared.delegate as! AppDelegate
        AD.Container?.CenterViewController.ReportPanelStatus(Status: Status)
    }
    
    /// Create then add the left-side panel.
    func AddLeftSidePanel()
    {
        guard LeftSlidePanel == nil else
        {
            return
        }
        if let VC = UIStoryboard.LeftSlidePanel()
        {
            VC.MainDelegate = MainDelegate
            AddLeftChildSidePanel(VC)
            LeftSlidePanel = VC
            SendStatus(.LeftOpen)
        }
    }
    
    /// Create then add the right-side panel.
    func AddRightSidePanel()
    {
        guard RightSlidePanel == nil else
        {
            return
        }
        if let VC = UIStoryboard.RightSlidePanel()
        {
            AddRightChildSidePanel(VC)
            RightSlidePanel = VC
            SendStatus(.RightOpen)
        }
    }
    
    /// Add the left-side child panel.
    func AddLeftChildSidePanel(_ SideController: LeftSidePanelViewController)
    {
        SideController.MainDelegate = MainDelegate
        SideController.delegate = CenterViewController
        view.insertSubview(SideController.view, at: 0)
        addChild(SideController)
        SideController.didMove(toParent: self)
    }
    
    /// Add the right-side child panel.
    func AddRightChildSidePanel(_ SideController: RightSidePanelViewController)
    {
        SideController.delegate = CenterViewController
        view.insertSubview(SideController.view, at: 0)
        addChild(SideController)
        SideController.didMove(toParent: self)
    }
    
    /// Animate the left-side panel.
    ///
    /// - Parameter shouldExpand: Determines if the panel is expanding or collapsing.
    func AnimateLeftPanel(shouldExpand: Bool)
    {
        if shouldExpand
        {
            CurrentState = .LeftExpanded
            AnimateCenterPanelXPosition(targetPosition: CenterNavigationController.view.frame.width - ExpandedOffset)
        }
        else
        {
            AnimateCenterPanelXPosition(targetPosition: 0)
            {
                _ in
                self.LeftPanelCollapsing()
                self.CurrentState = .Collapsed
                self.LeftSlidePanel?.view.removeFromSuperview()
                self.LeftSlidePanel = nil
            }
        }
    }
    
    /// Animate the right-side panel.
    ///
    /// - Parameter shouldExpand: Determines if the panel is expanding or collapsing.
    func AnimateRightPanel(shouldExpand: Bool)
    {
        if shouldExpand
        {
            CurrentState = .RightExpanded
            AnimateCenterPanelXPosition(targetPosition: -CenterNavigationController.view.frame.width + ExpandedOffset)
        }
        else
        {
            AnimateCenterPanelXPosition(targetPosition: 0)
            {
                _ in
                self.RightPanelCollapsing()
                self.CurrentState = .Collapsed
                self.RightSlidePanel?.view.removeFromSuperview()
                self.RightSlidePanel = nil
            }
        }
    }
    
    /// Animate the center panel X position.
    ///
    /// - Parameters:
    ///   - targetPosition: New X position.
    ///   - completion: Completion handler.
    func AnimateCenterPanelXPosition(targetPosition: CGFloat, completion: ((Bool) -> Void)? = nil)
    {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations:
            {
                self.CenterNavigationController.view.frame.origin.x = targetPosition
        }, completion: completion
        )
    }
    
    /// Show or hide a shadow on the center panel.
    ///
    /// - Parameter shouldShowShadow: Determines if a shadow is visible or not.
    func ShowShadowForCenterViewController(_ shouldShowShadow: Bool)
    {
        if shouldShowShadow
        {
            CenterNavigationController.view.layer.shadowOpacity = 0.8
        }
        else
        {
            CenterNavigationController.view.layer.shadowOpacity = 0.0
        }
    }
}

extension ContainerViewController: UIGestureRecognizerDelegate
{
    @objc func HandlePanGesture(_ recognizer: UIPanGestureRecognizer)
    {
        let IsLeftToRight = (recognizer.velocity(in: view).x > 0)
        switch recognizer.state
        {
        case .began:
            if CurrentState == .Collapsed
            {
                if IsLeftToRight
                {
                    AddLeftSidePanel()
                }
                else
                {
                    AddRightSidePanel()
                }
            }
            ShowShadowForCenterViewController(true)
            
        case .changed:
            if let RView = recognizer.view
            {
                RView.center.x = RView.center.x + recognizer.translation(in: view).x
                recognizer.setTranslation(CGPoint.zero, in: view)
            }
            
        case .ended:
            if let _ = LeftSlidePanel,
                let RView = recognizer.view
            {
                let IsMoreThanHalf = RView.center.x > view.bounds.size.width
                AnimateLeftPanel(shouldExpand: IsMoreThanHalf)
                CenterViewController.RotateButton(CenterViewController.LeftButton, Degrees: 180.0)
            }
            if let _ = RightSlidePanel,
                let RView = recognizer.view
            {
                let IsMoreThanHalf = RView.center.x < 0
                AnimateRightPanel(shouldExpand: IsMoreThanHalf)
                CenterViewController.RotateButton(CenterViewController.RightButton, Degrees: -180.0)
            }
            
        default:
            break
        }
    }
}

private extension UIStoryboard
{
    static func main() -> UIStoryboard
    {
        return UIStoryboard(name: "MainUI", bundle: Bundle.main)
    }
    
    static func LeftSlidePanel() -> LeftSidePanelViewController?
    {
        return main().instantiateViewController(withIdentifier: "SettingsPanel2") as? LeftSidePanelViewController
    }
    
    static func RightSlidePanel() -> RightSidePanelViewController?
    {
        return main().instantiateViewController(withIdentifier: "ActionPanel2") as? RightSidePanelViewController
    }
    
    static func CenterViewController() -> MainUICode?
    {
        return main().instantiateViewController(withIdentifier: "CenterMainUI2") as? MainUICode
    }
}


/// Used to report panel status changes with respect to visibility.
///
/// - Unknown: Unknown/default status.
/// - LeftOpen: Left panel is open.
/// - LeftClosed: Left panel is closed.
/// - RightOpen: Right panel is open.
/// - RightClosed: Right panel is closed.
enum PanelStatuses
{
    case Unknown
    case LeftOpen
    case LeftClosed
    case RightOpen
    case RightClosed
}
