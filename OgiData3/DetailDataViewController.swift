//
//  DetailDataViewController.swift
//  OgiData3
//
//  Created by ma on 2018/10/11.
//  Copyright © 2018年 Masahiro Ogino. All rights reserved.
//


import UIKit
import Cartography
import SwiftyJSON

class DetailDataViewController : UIViewController {
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
    }
    
    private let editButton : UIButton = {
        let ret = UIButton()
        ret.setImage(UIImage(named: "pen.png"), for: .normal)
        constrain(ret) {
            ret in
            ret.width == 40
            ret.height == 40
        }
        return ret
    }()
    
    private let deleteButton : UIButton = {
        let ret = UIButton()
        ret.addTarget(self, action: #selector(DetailDataViewController.tapDeleteButton), for: .touchUpInside)
        ret.setImage(UIImage(named: "trash.png"), for: .normal)
        constrain(ret) {
            ret in
            ret.width == 40
            ret.height == 40
        }
        return ret
    }()
    
    public var tableInfo : TableInfo?
    func setTableInfo(tableInfo : TableInfo) {
        self.tableInfo = tableInfo
    }
    
    func addCView(_ linei : SwiftyJSON.JSON, _ colInfo : ColumnInfo?, _ parent : UIView) -> UIView {
        if colInfo?.type == "IMG" {
            let cview = UIImageView()
            OgiDataLocalManager.lm.getImageThumbnail(Int(linei.string!)!) { thm in
                if cview.image == nil {
                    cview.image = thm
                }
            }
            OgiDataLocalManager.lm.getImage(Int(linei.string!)!) { img in
                cview.image = img
            }
            parent.addSubview(cview)
            constrain(cview, parent) {
                cview, parent in
                cview.width == parent.width * 0.75
                cview.height == cview.width
            }
            return cview
        }
        let cview = UILabel()
        if colInfo?.type == "DATE" {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd (E)"
            formatter.locale = Locale(identifier: "ja_JP")
            cview.text = formatter.string(from: OgiDataValue.dv.STRtoDATE(str: linei.string!)!)
        } else {
            cview.text = linei.string!
        }
        cview.textAlignment = .left
        cview.adjustsFontSizeToFitWidth = true
        cview.minimumScaleFactor = 0.5
        cview.layer.borderColor = UIColor.black.cgColor
        cview.layer.borderWidth = 0.5
        var height : CGFloat = 45
        if colInfo?.type == "LONGTEXT" {
            //height = 300
            cview.adjustsFontSizeToFitWidth = false
            cview.numberOfLines = 0
            height = cview.sizeThatFits(CGSize(width: 296, height: CGFloat.greatestFiniteMagnitude)).height
        }
        parent.addSubview(cview)
        constrain(cview, parent) {
            cview, parent in
            cview.height == height
            cview.width == parent.width - 4
        }
        return cview
    }
    
    func createDView(_ line : SwiftyJSON.JSON) -> UIView {
        let dview = UIView()
        
        var befcview : UIView? = nil
        for i in 3 ... line.count-1 {
            let cview = addCView(line[i], self.tableInfo?.columns[i-3], dview)
            constrain(cview) { cview in
                cview.centerX == cview.superview!.centerX
            }
            if befcview == nil {
                constrain(cview) { cview in
                    cview.top == cview.superview!.top + 10
                }
            } else {
                constrain(cview, befcview!) { cview, befcview in
                    cview.top == befcview.bottom + 10
                }
            }
            befcview = cview
        }
        
        dview.addSubview(editButton)
        constrain(befcview!, editButton) {
            befcview, editButton in
            befcview.bottom == editButton.top - 10
            editButton.bottom == editButton.superview!.bottom - 10
            editButton.right == editButton.superview!.right - 10
        }
        dview.addSubview(deleteButton)
        constrain(deleteButton, editButton) {
            deleteButton, editButton in
            deleteButton.bottom == editButton.bottom
            deleteButton.left == deleteButton.superview!.left + 10
        }
        
        //dview.backgroundColor = Constant.Color.tviewColor
        dview.backgroundColor = .white
        return dview
    }
    
    func setData(_ line : SwiftyJSON.JSON) {
        let dview = createDView(line)
        //let str = line[2].string!
        //let textview = UITextView()
        //textview.text = str
        //textview.text = "texttext"
        //self.view.addSubview(textview)
        self.view.addSubview(dview)
        constrain(dview) {
            v in
            v.centerX == v.superview!.centerX
            v.centerY == v.superview!.centerY
            v.width == v.superview!.width - 20
        }
    }
    
    override func loadView() {
        let screenView = UIButton()
        screenView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.125)
        screenView.addTarget(self, action: #selector(DetailDataViewController.tapScreenView), for: .touchUpInside)
        view = screenView
    }
    override func viewDidLoad() {
    }
    
    func tapScreenView() {
        hidePanel()
    }
    
    public var deleteCB : ()->(Void) = {}
    
    func tapDeleteButton() {
        
        let alert = UIAlertController(title: "confirm", message: "delete?", preferredStyle: .actionSheet)
        let can = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let del = UIAlertAction(title: "Delete", style: .destructive, handler: self.doDelete)
        alert.addAction(can)
        alert.addAction(del)
        self.present(alert, animated: true, completion: nil)
    }
    func doDelete(a : UIAlertAction) -> Void {
        self.deleteCB()
        self.hidePanel()
    }
    
    func hidePanel() {
        self.dismiss(animated: true, completion: nil)
    }
}
