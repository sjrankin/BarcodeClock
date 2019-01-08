//
//  AppDelegate.swift
//  BarcodeTest
//
//  Created by Stuart Rankin on 7/30/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import UIKit

@UIApplicationMain class AppDelegate: UIResponder, UIApplicationDelegate
{
    var window: UIWindow?
    let _Settings = UserDefaults.standard
    
    /// Primary location of initial set up before the main screen appears.
    ///
    /// - Parameters:
    ///   - application: Application handle.
    ///   - launchOptions: Launch options.
    /// - Returns: Always returns true
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        // Override point for customization after application launch.
        window = UIWindow(frame: UIScreen.main.bounds)
        Container = ContainerViewController()
        window!.rootViewController = Container
        window!.makeKeyAndVisible()
        
        //Initialize settings - this is especially important if we're running for the first time.
        Setting.Initialize()
        
        var OnSimulator = false
        #if targetEnvironment(simulator)
        OnSimulator = true
        #endif
        _Settings.set(OnSimulator, forKey: Setting.Key.RunningOnSimulator)
        
        //Override selected UITableViewCell selection color, app-wide.
        //https://www.natashatherobot.com/ios-change-uitableviewcell-selection-color-app-wide/
        let ColorView = UIView()
        ColorView.backgroundColor = UIColor.atomictangerine
        UITableViewCell.appearance().selectedBackgroundView = ColorView
        
        External.Initialize()
        
        //https://developer.apple.com/documentation/uikit/windows_and_screens/displaying_content_on_a_connected_screen
        //Watch for screen connect events.
        NotificationCenter.default.addObserver(forName: UIScreen.didConnectNotification, object: nil, queue: nil)
        {
            (notification) in
            let NewScreen = notification.object as! UIScreen
            #if true
            External.AddScreen(NewScreen)
            #else
            let NewScreenBounds = NewScreen.bounds
            print("New screen of \(NewScreen.bounds) connected.")
            let NewWindow = UIWindow(frame: NewScreenBounds)
            NewWindow.screen = NewScreen
            NewWindow.isHidden = false
            self.AdditionalWindows.append(NewWindow)
            #endif
        }
        
        //Watch for screen disconnect events.
        NotificationCenter.default.addObserver(forName: UIScreen.didDisconnectNotification, object: nil, queue: nil, using:
            {
                (notification) in
                let RemoveMe = notification.object as! UIScreen
                #if true
                External.RemoveScreen()
                #else
                print("Screen of size \(RemoveMe.bounds) disconnected.")
                for Window in self.AdditionalWindows
                {
                    if Window.screen == RemoveMe
                    {
                        let Index = self.AdditionalWindows.index(of: Window)
                        self.AdditionalWindows.remove(at: Index!)
                    }
                }
                #endif
        }
                )
        
        //Watch for screen change events.
        NotificationCenter.default.addObserver(forName: UIScreen.modeDidChangeNotification, object: nil, queue: nil, using:
            {
                (notification) in
                let ChangedScreen = notification.object as! UIScreen
                #if true
                External.ScreenChanged(ChangedScreen)
                #else
                print("New size of screen \(ChangedScreen.bounds).")
                #endif
        }
        )
        
        return true
    }
    
    #if false
    var AdditionalWindows = [UIWindow]()
    
    public func GetExternalWindow() -> UIWindow?
    {
        if AdditionalWindows.isEmpty
        {
            return nil
        }
        return AdditionalWindows.first
    }
    #endif
    
    public var Container: ContainerViewController? = nil
    
    func applicationWillResignActive(_ application: UIApplication)
    {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        if _Settings.bool(forKey: Setting.Key.ShowSillyMessages)
        {
            Container?.OverrideTimeText(WithString: ByeByes.randomElement()!, DoLock: true)
        }
    }
    
    func applicationDidEnterBackground(_ application: UIApplication)
    {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    func applicationWillEnterForeground(_ application: UIApplication)
    {
        if _Settings.bool(forKey: Setting.Key.ShowSillyMessages)
        {
            Container?.OverrideTimeText(WithString: "Zounds!", DoLock: false)
        }
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        if _Settings.bool(forKey: Setting.Key.StayAwake)
        {
            UIApplication.shared.isIdleTimerDisabled = true
        }
    }
    
    func applicationDidBecomeActive(_ application: UIApplication)
    {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        Container?.OverrideTimeText(WithString: Greetings.randomElement()!, DoLock: false)
    }
    
    func applicationWillTerminate(_ application: UIApplication)
    {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    let Greetings = ["Hello!", "Hi!", "Hey!", "こんにちは"]
    let ByeByes = ["Bye!", "See you!", "Later"]
}

