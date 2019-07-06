//
//  DataViewUpdateViewController.swift
//  OgiData3
//
//  Created by ma on 2018/10/30.
//  Copyright © 2018年 Masahiro Ogino. All rights reserved.
//

import UIKit
import Cartography
import SwiftyJSON

class DataViewUpdateViewController : UIViewController {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
        super.init(nibName: nil, bundle: nil)
        setup()
    }
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    func setup() {
        self.modalTransitionStyle = .coverVertical
        self.modalPresentationStyle = .overCurrentContext
        self.updateView.parentVC = self
    }
    
    let updateView = DataViewUpdateView()
    
    func setTableInfo(tableInfo : TableInfo) {
        self.updateView.setTableInfo(tableInfo: tableInfo)
    }
    
    override func loadView() {
        view = self.updateView
    }
    override func viewDidLoad() {
        print("a")
    }
}
