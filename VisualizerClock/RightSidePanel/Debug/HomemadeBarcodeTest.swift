//
//  HomemadeBarcodeTest.swift
//  Barcode Clock
//
//  Created by Stuart Rankin on 9/11/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class HomemadeBarcodeTest: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        BarcodeTestView.layer.borderWidth = 0.5
        BarcodeTestView.layer.borderColor = UIColor.black.cgColor
        BarcodeTestView.layer.cornerRadius = 5.0
        BarcodeTestView.backgroundColor = UIColor.orange
        HomemadeBarcodeList.layer.borderColor = UIColor.black.cgColor
        HomemadeBarcodeList.layer.borderWidth = 0.5
        HomemadeBarcodeList.layer.cornerRadius = 5.0
        MakeBarcodeList()
        HomemadeBarcodeList.delegate = self
        HomemadeBarcodeList.dataSource = self
    }
    
    var BarcodeIDs: [UUID]? = nil
    
    func MakeBarcodeList()
    {
        if !HomemadeBarcodeManager.Initialized
        {
            HomemadeBarcodeManager.Initialize()
        }
        BarcodeIDs = HomemadeBarcodeManager.BarcodeIDs
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return (BarcodeIDs?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let Cell = BarcodeCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "HomemadeBarcodes")
        Cell.SetData(BarcodeName: HomemadeBarcodeManager.GetBarcodeName(FromID: BarcodeIDs![indexPath.row])!,
                     BarcodeID: BarcodeIDs![indexPath.row], IsSelected: false)
        return (Cell as UITableViewCell)
    }
    
    @IBOutlet weak var HomemadeBarcodeList: UITableView!
    @IBOutlet weak var BarcodeTestView: UIView!
}
