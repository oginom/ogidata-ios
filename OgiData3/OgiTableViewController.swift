//
//  OgiTableViewController.swift
//  OgiData3
//
//  Created by ma on 2018/01/27.
//  Copyright © 2018年 Masahiro Ogino. All rights reserved.
//

import UIKit
import Cartography
import SwiftyJSON

class OgiTableViewController : UIViewController {
    
    private var didSetupConstraints = false
    private let dm = OgiDataManager.dm
    
    private var tableInfo : TableInfo?
    
    private var dataView : DataViewBase? = nil
    
    private var menuView = DataViewMenuView()
    
    private let insertVC = DataViewInsertViewController()
    //private var nav : UINavigationController? = nil
    
    override func loadView() {
        view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = .white
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        dm.getTableInfo(title: self.title!, callback: setTableInfo)
        view.setNeedsUpdateConstraints()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    override func viewDidLayoutSubviews() {
        if let dataView = dataView {
            dataView.VCDidLayoutSubviews()
        }
    }
    
    func setTableInfo(tableInfo : TableInfo) {
        self.tableInfo = tableInfo
        //if (tableInfo.columns.count == 2 && tableInfo.columns[0].type == "DATE" && tableInfo.columns[1].type == "DOUBLE") {
        //    dataView = DateDoubleDataView()
        //} else
        if (tableInfo.columns.count == 2 && tableInfo.columns[0].type == "IMG" && tableInfo.columns[1].type == "TAGS") {
            dataView = TaggedImageDataView()
        } else {
            dataView = DefaultDataView()
        }
        view.addSubview(dataView!)
        constrain(dataView!) {
            dataView in
            dataView.edges == inset(dataView.superview!.edges, 50, 0, 0, 0) // top, leading, bottom, trailing
        }
        dataView!.parentVC = self
        
        view.addSubview(menuView)
        constrain(menuView as UIView) {
            menuView in
            menuView.edges == menuView.superview!.edges
        }
        
        //view.addSubview(insertView)
        //constrain(insertView) {
        //    insertView in
        //    insertView.edges == insertView.superview!.edges
        //}
        //insertView.parentVC = self
        
        menuView.setCallbacks(callbackInsert: {
            //if self.nav == nil {
            //    self.nav = UINavigationController(rootViewController: self.insertVC)
            //}
            self.navigationController?.present(self.insertVC, animated: true, completion: nil)
        }, callbackColumns: {
            //let storyboard = UIStoryboard(name: "TrimImageVC", bundle: nil)
            //let iv = storyboard.instantiateViewController(withIdentifier: "trimImageVC") as! TrimImageVC
            let iv = TrimImageVC()
            //iv.image = UIImage(named: "ic_more_down")
            iv.image = UIImage(named: "mes.png")
            //self.navigationController?.present(iv, animated: true)
            self.navigationController?.pushViewController(iv, animated: true)
        }, callbackView: {
        })
        
        dataView!.setTableInfo(tableInfo: tableInfo)
        insertVC.setTableInfo(tableInfo: tableInfo)
        //insertView.setParentVC(vc: self)
    }
    
}
