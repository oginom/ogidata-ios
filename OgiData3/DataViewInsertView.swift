//
//  DataViewInsertView.swift
//  OgiData3
//
//  Created by ma on 2018/04/06.
//  Copyright © 2018年 Masahiro Ogino. All rights reserved.
//

import UIKit
import Cartography
import SwiftyJSON

class DataViewEditView: UIView {
    
    var parentVC : UIViewController?
    func setParentVC(vc: UIViewController?) { parentVC = vc }
    
    private var didSetupConstraints : Bool = false
    public let dm = OgiDataManager.dm
    
    private let screenView = UIButton()
    
    let panel = UIView()
    private let panelConstraint = ConstraintGroup()
    private var isPanelShown = false
    private var isPanelAnimating = false
    
    private let insertButton = UIButton()
    
    public var forms : [InsertFormBase] = []
    
    public var tableTitle : String?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        
        self.isUserInteractionEnabled = true
        
        screenView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.125)
        screenView.addTarget(self, action: #selector(DataViewInsertView.tapScreenView), for: .touchUpInside)
        //screenView.isHidden = true
        self.addSubview(screenView)
        
        panel.backgroundColor = .white
        self.addSubview(panel)
        constrain(panel) {
            panel in
            panel.width == panel.superview!.width - 10
            panel.centerX == panel.superview!.centerX
        }
        constrain(panel, replace: panelConstraint) {
            panel in
            panel.bottom == panel.superview!.bottom
        }
        
        insertButton.setTitle("INSERT", for: .normal)
        insertButton.setTitleColor(.black, for: .normal)
        insertButton.layer.cornerRadius = 30
        insertButton.layer.borderWidth = 2
        insertButton.layer.borderColor = UIColor.black.cgColor
        insertButton.addTarget(self, action: #selector(DataViewInsertView.tapInsertButton), for: .touchUpInside)
        panel.addSubview(insertButton)
        
        NotificationCenter.default.addObserver(self, selector: #selector(DataViewInsertView.keyboardWillShow),
                                               name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(DataViewInsertView.keyboardWillHide),
                                               name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    private var bottomInsert : CGFloat = 0
    
    func keyboardWillShow(notification: NSNotification) {
        print("keyboardWillShow")
        if let userInfo = notification.userInfo {
            if let keyboard = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue{
                let keyBoardRect = keyboard.cgRectValue
                //print("keyBoardRect: \(keyBoardRect)")
                let topKeyboard = keyBoardRect.origin.y
                let distance = bottomInsert - topKeyboard + 10
                if distance >= 0 {
                    constrain(panel, replace: panelConstraint) {
                        panel in
                        panel.bottom == panel.superview!.bottom - distance
                    }
                    UIView.animate(withDuration: 0.1, animations: self.layoutIfNeeded, completion: nil)
                }
            }
        }
    }
    func keyboardWillHide(notification: NSNotification) {
        
        constrain(panel, replace: panelConstraint) {
            panel in
            panel.bottom == panel.superview!.bottom
        }
        UIView.animate(withDuration: 0.1, animations: self.layoutIfNeeded, completion: nil)
    }
    
    func setupConstraints() {
        constrain(screenView) {
            screenView in
            screenView.edges == screenView.superview!.edges
        }
        constrain(insertButton) {
            insertButton in
            insertButton.width == insertButton.superview!.width - 50
            insertButton.centerX == insertButton.superview!.centerX
            insertButton.height == 60
        }
        updateConstraints()
    }
    
    override func layoutSubviews() {
        if !didSetupConstraints {
            self.setupConstraints()
            didSetupConstraints = true
        }
    }
    
    func setButtonTitle(title : String) {
        insertButton.setTitle(title, for: .normal)
    }
    
    func setTableInfo(tableInfo : TableInfo) {
        print("DataViewInsertView.setTableInfo")
        if self.forms.count > 0 {
            fatalError("table info already set")
        }
        var isFirst = true
        var bef : UIView = self
        for column in tableInfo.columns {
            print("\(column.name), \(column.type)")
            
            var form : InsertFormBase
            if column.type == "DATE" {
                form = DateInsertForm()
            } else if column.type == "DOUBLE" {
                form = DoubleInsertForm()
            } else if column.type == "TIMESTAMP" {
                form = TimestampInsertForm()
            } else if column.type == "IMG" {
                form = ImageInsertForm()
            } else if column.type == "LONGTEXT" {
                form = LongtextInsertForm()
            } else {
                form = StringInsertForm()
            }
            form.setColumnInfo(column)
            form.editView = self
            
            forms.append(form)
            panel.addSubview(form)
            if isFirst {
                constrain(form) {
                    form in
                    form.top == form.superview!.top + 20
                    form.left == form.superview!.left + 1
                    form.right == form.superview!.right - 1
                }
                isFirst = false
            } else {
                constrain(form, bef) {
                    form, bef in
                    form.top == bef.bottom + 20
                    form.left == form.superview!.left + 1
                    form.right == form.superview!.right - 1
                }
            }
            bef = form as UIView
        }
        
        let lastform = forms[forms.count - 1]
        constrain(insertButton, lastform) {
            insertButton, lastform in
            insertButton.top == lastform.bottom + 20
        }
        constrain(panel, insertButton) {
            panel, insertButton in
            panel.bottom == insertButton.bottom + 20
        }
        
        tableTitle = tableInfo.title
        setupChoice(tableInfo)
    }
    
    func setupChoice(_ tableInfo : TableInfo) {
        dm.getChoice(title: tableInfo.title, limit: 100, callback: setChoice)
    }
    
    func setChoice(choice : SwiftyJSON.JSON) {
        for form in forms {
            if let colname = form.columnInfo?.name {
                if let choiceArray = choice[colname].array {
                    form.setChoice(choiceArray)
                }
            }
        }
    }
    
    func tapScreenView(_ sender: UIButton) {
        print(sender.title(for: .normal) ?? "NO_TITLE")
        if (true || isPanelShown) {
            for form in forms {
                if form.parentTouched() {
                    return
                }
            }
            hidePanel()
        }
    }
    
    func tapInsertButton(_ sender: UIButton) {
        print(sender.title(for: .normal) ?? "NO_TITLE")
        
        let dispatchGroup = DispatchGroup()
        var isSuccess = true
        for form in self.forms {
            print("\(form.columnInfo!.name) ENTER")
            dispatchGroup.enter()
            form.preSubmit(completion: { success in
                if !success {
                    isSuccess = false
                }
                print("\(form.columnInfo!.name) LEAVE")
                dispatchGroup.leave()
            })
        }
        dispatchGroup.notify(queue: .main) {
            if !isSuccess {
                print("FAIL")
                for form in self.forms {
                    form.cancelSubmit()
                }
                let alert = UIAlertController(title: "title", message: "not ready", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default, handler:nil)
                alert.addAction(ok)
                self.parentVC?.navigationController?.present(alert, animated: true, completion: nil)
            } else {
                print("SUCCESS")
                var insertDict = Dictionary<String, String>()
                for form in self.forms {
                    let value = form.getValue()
                    insertDict[form.columnInfo!.name] = value
                }
                let insertJSON = JSON(insertDict)
                self.dm.insertData(title: self.tableTitle!, data: insertJSON) {
                    (response : JSON) in
                    print(response)
                    if response["result"].string != "success" {
                        let alert = UIAlertController(title: "title", message: "failed", preferredStyle: .alert)
                        let ok = UIAlertAction(title: "OK", style: .default, handler:nil)
                        alert.addAction(ok)
                        self.parentVC?.navigationController?.present(alert, animated: true, completion: nil)
                    } else {
                        let alert = UIAlertController(title: "Inserted", message: "successfully inserted.", preferredStyle: .alert)
                        self.parentVC?.navigationController?.present(alert, animated: true, completion: {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                                alert.dismiss(animated: true, completion: nil)
                            })
                        })
                    }
                }
                self.hidePanel()
            }
        }
    }
    
    func showPanel() {
        if (isPanelAnimating) {
            return
        }
        isPanelAnimating = true
        screenView.isHidden = false
        constrain(panel, replace: panelConstraint) {
            panel in
            panel.bottom == panel.superview!.bottom
        }
        UIView.animate(withDuration: 0.5, animations: self.layoutIfNeeded, completion: {
            (finished: Bool) in
            self.isPanelAnimating = false
            self.isPanelShown = true
            self.isUserInteractionEnabled = true
        })
    }
    
    func startInsert(_ bottomInsert : CGFloat) {
        self.bottomInsert = bottomInsert
    }
    func endInsert() {
    }
    
    func hidePanel() {
        self.parentVC?.dismiss(animated: true, completion: nil)
        return
        if (isPanelAnimating) {
            return
        }
        isPanelAnimating = true
        screenView.isHidden = true
        constrain(panel, replace: panelConstraint) {
            panel in
            panel.top == panel.superview!.bottom
        }
        UIView.animate(withDuration: 0.5, animations: self.layoutIfNeeded, completion: {
            (finished: Bool) in
            self.isPanelAnimating = false
            self.isPanelShown = false
            self.isUserInteractionEnabled = false
        })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for form in forms {
            if form.parentTouched() {
                return
            }
        }
    }
}

class DataViewInsertView : DataViewEditView {
}

class DataViewUpdateView : DataViewEditView {
    override func setup() {
        super.setup()
        super.setButtonTitle(title: "UPDATE")
    }
    override func tapInsertButton(_ sender: UIButton) {
        print(sender.title(for: .normal) ?? "NO_TITLE")
        
        let dispatchGroup = DispatchGroup()
        var isSuccess = true
        for form in self.forms {
            print("\(form.columnInfo!.name) ENTER")
            dispatchGroup.enter()
            form.preSubmit(completion: { success in
                if !success {
                    isSuccess = false
                }
                print("\(form.columnInfo!.name) LEAVE")
                dispatchGroup.leave()
            })
        }
        dispatchGroup.notify(queue: .main) {
            if !isSuccess {
                print("FAIL")
                for form in self.forms {
                    form.cancelSubmit()
                }
                let alert = UIAlertController(title: "title", message: "not ready", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default, handler:nil)
                alert.addAction(ok)
                self.parentVC?.navigationController?.present(alert, animated: true, completion: nil)
            } else {
                print("SUCCESS")
                var insertDict = Dictionary<String, String>()
                for form in self.forms {
                    let value = form.getValue()
                    insertDict[form.columnInfo!.name] = value
                }
                let insertJSON = JSON(insertDict)
                self.dm.insertData(title: self.tableTitle!, data: insertJSON) {
                    (response : JSON) in
                    print(response)
                    if response["result"].string != "success" {
                        let alert = UIAlertController(title: "title", message: "failed", preferredStyle: .alert)
                        let ok = UIAlertAction(title: "OK", style: .default, handler:nil)
                        alert.addAction(ok)
                        self.parentVC?.navigationController?.present(alert, animated: true, completion: nil)
                    }
                }
                self.hidePanel()
            }
        }
    }
}

