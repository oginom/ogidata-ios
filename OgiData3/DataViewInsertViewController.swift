//
//  DataViewInsertViewController.swift
//  OgiData3
//
//  Created by ma on 2018/09/16.
//  Copyright © 2018年 Masahiro Ogino. All rights reserved.
//

import UIKit
import Cartography
import SwiftyJSON

class DataViewInsertViewController : UIViewController {
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
        self.insertView.parentVC = self
    }
    
    let insertView = DataViewInsertView()
    
    func setTableInfo(tableInfo : TableInfo) {
        self.insertView.setTableInfo(tableInfo: tableInfo)
    }
    
    override func loadView() {
        view = self.insertView
    }
    override func viewDidLoad() {
        print("a")
    }
}
