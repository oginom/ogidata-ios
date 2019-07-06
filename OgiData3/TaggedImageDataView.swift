//
//  TaggedImageDataView.swift
//  OgiData3
//
//  Created by ma on 2018/08/05.
//  Copyright © 2018年 Masahiro Ogino. All rights reserved.
//

import UIKit
import Cartography
import SwiftyJSON

class TaggedImageDataView : DataViewBase {
    
    private let scroll : UIScrollView = {
        let ret = UIScrollView()
        ret.delaysContentTouches = false
        return ret
    }()
    
    private let topview : UILabel = {
        let ret = UILabel()
        ret.text = "loading..."
        ret.textAlignment = .center
        return ret
    }()
    
    required init?(coder: NSCoder? = nil) {
        super.init(coder: coder)
        self.addSubview(scroll)
        scroll.addSubview(topview)
    }
    
    override func setupConstraints() {
        print("DefaultDataView.setupConstraints")
        constrain(scroll) {
            scroll in
            scroll.edges == scroll.superview!.edges
        }
        constrain(topview) {
            topview in
            topview.width == 300
            topview.height == 100
            topview.centerX == topview.superview!.centerX
            topview.top == topview.superview!.top + 20
        }
        super.setupConstraints()
    }
    
    override func setTableInfo(tableInfo : TableInfo) {
        self.tableInfo = tableInfo
        dm.getData(title: tableInfo.title, asc: false, callback: setData)
    }
    
    override func setData(data : SwiftyJSON.JSON) {
        super.setData(data: data)
        topview.text = "\(data.count) data"
        var bef : UIView = topview
        var scrollHeight : CGFloat = 130
        let xCount : Int = 4
        var imageViews : [UIImageView] = []
        for (_, line) in data {
            let imageView : UIImageView = {
                let ret = UIImageView()
                ret.isUserInteractionEnabled = true
                OgiDataLocalManager.lm.getImageThumbnail(Int(line[3].string!)!) { thm in
                    ret.image = thm
                }
                constrain(ret) {
                    v in
                    v.width == 70
                    v.height == 70
                }
                return ret
            }()
            imageViews.append(imageView)
        }
        for (i, imageView) in imageViews.enumerated() {
            imageView.tag = i
            imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(TaggedImageDataView.imageViewTapped(_:))))
            scroll.addSubview(imageView)
            if i % xCount == 0 {
                constrain(imageView, bef) {
                    v, bef in
                    v.top == bef.bottom + 20
                    v.left == v.superview!.centerX - 70 * CGFloat(xCount)/2 - 20 * CGFloat(xCount-1)/2
                }
                scrollHeight += 90
            } else {
                constrain(imageView, bef) {
                    v, bef in
                    v.top == bef.top
                    v.left == bef.right + 20
                }
            }
            bef = imageView
        }
        scroll.contentSize = CGSize(width: frame.size.width, height: scrollHeight)
    }
    
    func imageViewTapped(_ sender: UITapGestureRecognizer) {
        let tag = sender.view!.tag
        showDetail(index: tag)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        for touch : UITouch in touches {
            let tag = touch.view!.tag
            showDetail(index: tag)
            break
        }
    }
}
