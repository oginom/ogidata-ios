//
//  ViewController.swift
//  OgiData3
//
//  Created by ma on 2018/01/05.
//  Copyright © 2018年 Masahiro Ogino. All rights reserved.
//

import UIKit

import Cartography
import SwiftyJSON

final class Constant {
    final class Inset {
        static let M : CGFloat = 10
    }
    final class Color {
        static let tviewColor : UIColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0)
    }
}

class ViewController: UIViewController {
    
    private var didSetupConstraints = false
    
    private let dm = OgiDataManager.dm
    
    private let scroll : UIScrollView = {
        let ret = UIScrollView()
        ret.delaysContentTouches = false
        return ret
    }()
    
    private let label : UILabel = {
        let l = UILabel()
        l.text = "loading..."
        l.textAlignment = .center
        //l.backgroundColor = .green
        l.font = l.font.withSize(l.font.pointSize * 2)
        return l
    }()
    
    private var menuView = TablesMenuView()
    
    //override func loadView() {
    //    view = UIView()
    //}

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.title = "Tables"
        
        view.addSubview(scroll)
        scroll.addSubview(label)
        
        view.addSubview(menuView)
        //menuView.isUserInteractionEnabled=false
        
        dm.getTables(callback: setTables)
        
        view.setNeedsUpdateConstraints()
    }
    
    override func updateViewConstraints() {
        func setupConstraints() {
            constrain(scroll) {
                scroll in
                scroll.center == scroll.superview!.center
                scroll.size == scroll.superview!.size
            }
            constrain(label) {
                label in
                label.width == 300
                label.height == 100
                label.centerX == label.superview!.centerX
                label.top == label.superview!.top + 20
            }
            constrain(menuView as UIView) {
                menuView in
                menuView.edges == menuView.superview!.edges
            }
        }
        
        if !didSetupConstraints {
            setupConstraints()
            didSetupConstraints = true
        }
        
        super.updateViewConstraints()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setTables(tables : [TableInfo]) {
            
        //TODO: remove tviews before
        
        label.text = "\(tables.count) tables"
        var bef : UIView = label
        
        var scrollHeight : CGFloat = 20 + 120
        for tableInfo in tables {
            let tview = TableCellView(tableInfo : tableInfo)!
            //let tview = UIButton()
            tview.layer.borderWidth = 1.0
            tview.layer.borderColor = UIColor.black.cgColor
            tview.setTitle(tableInfo.title, for: .normal)
            tview.setTitleColor(.black, for: .normal)
            tview.addTarget(self, action: #selector(ViewController.tapTableB(sender:)), for: .touchUpInside)
            //tview.isUserInteractionEnabled = false
            //let gesture = UITapGestureRecognizer(
            //    target: self,
            //    action: #selector(ViewController.tapTable(sender:))
            //)
            //gesture.cancelsTouchesInView = false
            //tview.addGestureRecognizer(gesture)
            scroll.addSubview(tview)
            constrain(tview, bef) {
                tview, bef in
                tview.width == 300
                tview.height == 100
                tview.top == bef.bottom + 20
                tview.centerX == tview.superview!.centerX
            }
            bef = tview
            scrollHeight += 120
        }
        scroll.contentSize = CGSize(width: view.frame.size.width,height: scrollHeight)
    }

    func tapTable(sender: UITapGestureRecognizer) {
        if let tview : TableCellView = sender.view as? TableCellView {
            print(tview.tableInfo!.title)
            let next = OgiTableViewController()
            next.title = tview.tableInfo!.title
            self.navigationController?.pushViewController(next, animated: true)
        }
    }
    func tapTableB(sender: TableCellView?) {
        if let tview : TableCellView = sender {
            print(tview.tableInfo!.title)
            let next = OgiTableViewController()
            next.title = tview.tableInfo!.title
            self.navigationController?.pushViewController(next, animated: true)
        }
    }

}

