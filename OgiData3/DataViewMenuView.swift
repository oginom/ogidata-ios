//
//  DataViewMenuView.swift
//  OgiData3
//
//  Created by ma on 2018/03/29.
//  Copyright © 2018年 Masahiro Ogino. All rights reserved.
//

import UIKit

class DataViewMenuView : MenuViewBase {
    
    private var callbackInsert : (() -> Void)?
    private var callbackColumns : (() -> Void)?
    private var callbackView : (() -> Void)?
    
    override func setupButtons() {
        let props : [(String, UIColor, Int)] = [
            ("INSERT", .green, 0),
            ("COLUMNS", .orange, 1),
            ("VIEW", .blue, 2)
        ]
        for (name, color, tag) in props {
            let button = addMenuButton(name: name, color: color)
            button.tag = tag
            button.addTarget(self, action: #selector(DataViewMenuView.tapButton), for: .touchUpInside)
        }
    }
    
    func tapButton(_ sender: UIButton) {
        print(sender.title(for: .normal) ?? "NO_TITLE")
        switch (sender.tag) {
        case 0:
            if let callbackInsert = callbackInsert {
                callbackInsert()
            }
        case 1:
            if let callbackColumns = callbackColumns {
                callbackColumns()
            }
        default:
            print("default")
        }
        if (isButtonsOpen) {
            closeButtons()
        }
    }
    
    func setCallbacks(callbackInsert: (() -> Void)?,
                      callbackColumns: (() -> Void)?,
                      callbackView: (() -> Void)?) {
        self.callbackInsert = callbackInsert
        self.callbackColumns = callbackColumns
        self.callbackView = callbackView
    }
    
}
