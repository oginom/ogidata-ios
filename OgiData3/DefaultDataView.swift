//
//  DefaultDataView.swift
//  OgiData3
//
//  Created by ma on 2018/02/19.
//  Copyright © 2018年 Masahiro Ogino. All rights reserved.
//

import UIKit
import Cartography
import SwiftyJSON

class DefaultDataView : DataViewBase, UITableViewDelegate, UITableViewDataSource {
    
    //private let scroll : UIScrollView = {
    //    let ret = UIScrollView()
    //    ret.delaysContentTouches = false
    //    return ret
    //}()
    private let scroll : UITableView = {
        let ret = UITableView()
        return ret
    }()
    
    private let topview : UILabel = {
        let ret = UILabel()
        ret.text = "loading..."
        ret.textAlignment = .center
        return ret
    }()
    
    private let chartsview : UIScrollView = {
        let ret = UIScrollView()
        ret.backgroundColor = .black
        ret.bounces = false
        ret.isPagingEnabled = true
        return ret
    }()
    
    private let chartscontentview : UIView = {
        let ret = UIView()
        ret.backgroundColor = .green
        return ret
    }()
    
    required init?(coder: NSCoder? = nil) {
        super.init(coder: coder)
        self.addSubview(chartsview)
        chartsview.addSubview(chartscontentview)
        self.addSubview(topview)
        scroll.delegate = self
        scroll.dataSource = self
        self.addSubview(scroll)
    }
    
    override func setupConstraints() {
        print("DefaultDataView.setupConstraints")
        constrain(topview, chartsview, scroll) {
            topview, chartsview, scroll in
            chartsview.left == chartsview.superview!.left + 10
            chartsview.right == chartsview.superview!.right - 10
            chartsview.top == chartsview.superview!.top + 20
            topview.left == topview.superview!.left
            topview.right == topview.superview!.right
            topview.top == chartsview.bottom
            topview.height == 40
            scroll.left == scroll.superview!.left
            scroll.right == scroll.superview!.right
            scroll.bottom == scroll.superview!.bottom
            scroll.top == topview.bottom
        }
        super.setupConstraints()
    }
    
    override func setTableInfo(tableInfo : TableInfo) {
        self.tableInfo = tableInfo
        dm.getData(title: tableInfo.title, asc: false, callback: setData)
        dm.getChart(title: tableInfo.title) { imgs in
            if imgs.count > 0 {
                constrain(self.chartsview) { chartsview in
                    chartsview.height == chartsview.width * 0.625
                }
                constrain(self.chartscontentview) { con in
                    con.height == con.superview!.height
                }
                var vs : [UIView] = []
                for img in imgs {
                    let v = UIImageView()
                    v.image = img
                    self.chartscontentview.addSubview(v)
                    constrain(v) { v in
                        v.centerY == v.superview!.centerY
                        v.height == v.superview!.height
                        v.height == v.width * 0.625
                    }
                    vs.append(v)
                }
                constrain(vs) {
                    vs in
                    distribute(horizontally: vs)
                }
                constrain(vs[0]) {
                    v0 in
                    v0.left == v0.superview!.left
                }
                constrain(vs[imgs.count-1]) {
                    v1 in
                    v1.right == v1.superview!.right
                }
            } else {
                constrain(self.chartsview) { chartsview in
                    chartsview.height == 0
                }
            }
        }
    }
    
    override func VCDidLayoutSubviews(){
        chartsview.contentSize = chartscontentview.bounds.size
    }
    
    func createCView(_ linei : SwiftyJSON.JSON, _ colInfo : ColumnInfo?) -> UIView {
        if colInfo?.type == "IMG" {
            let cview = UIImageView()
            OgiDataLocalManager.lm.getImageThumbnail(Int(linei.string!)!) { thm in
                cview.image = thm
            }
            constrain(cview) {
                cview in
                cview.width == 45
                cview.height == 45
            }
            return cview
        }
        let cview = UILabel()
        cview.text = linei.stringValue
        cview.textAlignment = .left
        cview.adjustsFontSizeToFitWidth = true
        cview.minimumScaleFactor = 0.5
        cview.layer.borderColor = UIColor.black.cgColor
        cview.layer.borderWidth = 0.5
        constrain(cview) {
            cview in
            cview.width == 100
            cview.height == 45
        }
        return cview
    }
    
    func createDView(_ line : SwiftyJSON.JSON) -> UITableViewCell {
        let dview = UITableViewCell()
        
        var befcview : UIView? = nil
        for i in 3 ... line.count-1 {
            let cview = createCView(line[i], self.tableInfo?.columns[i-3])
            dview.addSubview(cview)
            constrain(cview) { cview in
                cview.centerY == cview.superview!.centerY
            }
            if befcview == nil {
                constrain(cview) { cview in
                    cview.left == cview.superview!.left + 10
                }
            } else {
                constrain(cview, befcview!) { cview, befcview in
                    cview.left == befcview.right + 10
                }
            }
            befcview = cview
        }
        dview.backgroundColor = Constant.Color.tviewColor
        //constrain(dview) {
        //    dview in
        //    dview.width == 340
        //    dview.height == 50
        //}
        return dview
    }
    
    override func setData(data : SwiftyJSON.JSON) {
        super.setData(data: data)
        topview.text = "\(data.count) data"
        //var bef : UIView = topview
        //var scrollHeight : CGFloat = 130
        //scrollHeight = scrollHeight + CGFloat(Float(data.count)) * 60
        /*
        for (_, line) in data {
            let dview = createDView(line)
            scroll.addSubview(dview)
            constrain(dview, bef) {
                dview, bef in
                dview.top == bef.bottom + 10
                dview.centerX == dview.superview!.centerX
            }
            bef = dview
            scrollHeight += 60
        }
 */
        //scroll.contentSize = CGSize(width: frame.size.width, height: scrollHeight)
        scroll.reloadData()
    }
    
    override func deleteDataView(_ index: Int) {
        super.deleteDataView(index)
        topview.text = "\(data!.count) data"
        scroll.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let line = self.data![indexPath.row]
        let ret = createDView(line)
        return ret
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        showDetail(index: indexPath.row)
    }
}
