//
//  DataViewBase.swift
//  OgiData3
//
//  Created by ma on 2018/02/19.
//  Copyright © 2018年 Masahiro Ogino. All rights reserved.
//

import UIKit
import Cartography
import SwiftyJSON

class DataViewBase : UIView {
    
    public var parentVC : UIViewController?
    
    public var data : SwiftyJSON.JSON?
    public var tableInfo : TableInfo?
    
    private var didSetupConstraints : Bool = false
    public let dm = OgiDataManager.dm
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder? = nil) {
        if let coder = coder {
            super.init(coder: coder)
        } else {
            super.init(frame: CGRect.zero)
        }
    }
    
    func setupConstraints() {
        print("DataViewBase.setupConstraints")
        updateConstraints()
    }
    
    override func layoutSubviews() {
        if !didSetupConstraints {
            self.setupConstraints()
            didSetupConstraints = true
        }
    }
    
    func setTableInfo(tableInfo : TableInfo) {
        self.tableInfo = tableInfo
        dm.getData(title: tableInfo.title, callback: setData)
    }
    
    func setData(data : SwiftyJSON.JSON) {
        self.data = data
    }
    
    func addDataView(line : JSON) {
        self.data!.arrayObject?.insert(line, at: 0)
    }
    
    func deleteDataView(_ index : Int) {
        self.data!.arrayObject?.remove(at: index)
    }
    
    func showDetail(index : Int) {
        let detail = DetailDataViewController()
        detail.setTableInfo(tableInfo: tableInfo!)
        detail.setData(self.data![index])
        detail.deleteCB = {
            if let title = self.tableInfo?.title {
                OgiDataManager.dm.deleteData(title: title, data_id: self.data![index][0].intValue) {
                    (response : JSON) in
                    print(response)
                    if response.string != "success" {
                        print("delete fail")
                    } else {
                        print("delete success")
                    }
                }
            }
            self.deleteDataView(index)
        }
        self.parentVC!.present(detail, animated: true, completion: nil)
    }
    
    func VCDidLayoutSubviews() {}
}

