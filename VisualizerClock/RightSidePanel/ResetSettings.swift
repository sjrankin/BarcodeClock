//
//  ResetSettings.swift
//  Visualizer Clock
//
//  Created by Stuart Rankin on 1/5/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class ResetSettings: UITableViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    @IBAction func HandleCancelButton(_ sender: Any)
    {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func HandleResetButton(_ sender: Any)
    {
        let Warning = UIAlertController(title: "WARNING", message: "If you continue, you will lose your customization; all settings will be reset to factory settings. Press cancel to return without resetting.",
                                        preferredStyle: UIAlertController.Style.alert)
        let CancelAction = UIAlertAction(title: "Cancel", style: .default, handler:
        {
            action in
            self.navigationController?.popViewController(animated: true)
        })
        let ResetAction = UIAlertAction(title: "Reset", style: .destructive, handler: ResetEverything)
        Warning.addAction(CancelAction)
        Warning.addAction(ResetAction)
        present(Warning, animated: true)
    }
    
    func ResetEverything(Action: UIAlertAction)
    {
        
    }
}
