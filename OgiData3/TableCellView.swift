//
//  TableCellView.swift
//  OgiData3
//
//  Created by ma on 2018/01/27.
//  Copyright © 2018年 Masahiro Ogino. All rights reserved.
//

import UIKit

class TableCellView : UIButton {
    public let tableInfo : TableInfo?
    init?(tableInfo: TableInfo? = nil, coder: NSCoder? = nil) {
        
        if let tableInfo = tableInfo {
            self.tableInfo = tableInfo
        } else {
            return nil
        }
        
        if let coder = coder {
            super.init(coder: coder)!
        } else {
            super.init(frame: CGRect())
        }
        
        //self.text = self.tableInfo?.title
        //self.textAlignment = .center
        self.backgroundColor = Constant.Color.tviewColor
    
    }
    required convenience init(coder: NSCoder) {
        self.init(coder: coder)
    }
}
