//
//  DateDoubleDataView.swift
//  OgiData3
//
//  Created by ma on 2018/02/19.
//  Copyright © 2018年 Masahiro Ogino. All rights reserved.
//

import UIKit
import Cartography
import SwiftyJSON

import CoreGraphics

class DateDoubleDataView : PlotDataViewBase {
    
    override func lineToXY(line: JSON) -> (Double, Double) {
        let x = OgiDataValue.dv.STRtoDATE(str: line[3].string!)!.timeIntervalSince1970 as Double
        let y = Double(line[4].string!)!
        return (x, y)
    }
    
    override func calcXTicks(lim: [Double]) -> [(Double, String)] {
        return calcTicks(lim: lim, type: "DATE")
    }
    
}

