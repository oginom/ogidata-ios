//
//  InsertFormBase.swift
//  OgiData3
//
//  Created by ma on 2018/04/11.
//  Copyright © 2018年 Masahiro Ogino. All rights reserved.
//

import UIKit
import Photos
import Cartography
import SwiftyJSON

class InsertFormBase: UIView {
    
    var editView : DataViewEditView?
    
    var columnInfo : ColumnInfo?
    
    private var didSetupConstraints : Bool = false
    
    var titleLabel : UILabel = {
        let ret = UILabel()
        ret.layer.borderWidth = 1
        ret.layer.borderColor = UIColor.black.cgColor
        return ret
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        print("InsertFormBase.setup")
        self.backgroundColor = .lightGray
        titleLabel.text = "col name"
        self.addSubview(titleLabel)
    }
    
    func setColumnInfo(_ col : ColumnInfo) {
        columnInfo = col
        titleLabel.text = col.name
    }
    
    func setChoice(_ choiceArray : [JSON]) {
        print("InsertFormBase.setChoice")
    }
    
    func setupConstraints() {
        print("InsertFormBase.setupConstraints")
        constrain(titleLabel) {
            titleLabel in
            titleLabel.top == titleLabel.superview!.top
            titleLabel.left == titleLabel.superview!.left
            titleLabel.right == titleLabel.superview!.right
            titleLabel.height == 30
        }
        updateConstraints()
    }
    
    override func layoutSubviews() {
        if !didSetupConstraints {
            self.setupConstraints()
            didSetupConstraints = true
        }
    }
    
    func preSubmit(completion : @escaping (Bool) -> Void) {
        completion(true)
    }
    func cancelSubmit() {
        
    }
    
    func getValue() -> String {
        let ret = ""
        return ret
    }
    
    func parentTouched() -> Bool {
        return false
    }

}

class StringInsertForm: InsertFormBase, UITextFieldDelegate, UIToolbarDelegate {
    
    public let textField : UITextField = {
        let ret = UITextField()
        return ret
    }()
    
    private let textToolBar = UIToolbar()
    
    override func setup() {
        super.setup()
        
        textField.backgroundColor = .white
        textField.delegate = self
        
        //ボタンの設定
        let spaceBarBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace,target: self,action: nil)
        let toolBarBtn = UIBarButtonItem(title: "完了", style: .done, target: self, action: #selector(StringInsertForm.toolBarBtnPush))
        textToolBar.items = [spaceBarBtn, toolBarBtn]
        textField.inputAccessoryView = textToolBar
        
        self.addSubview(textField)
    }
    
    override func setupConstraints() {
        constrain(textField, titleLabel) {
            textField, titleLabel in
            textField.left == textField.superview!.left + 5
            textField.right == textField.superview!.right - 55
            textField.top == titleLabel.bottom + 10
            textField.bottom == textField.superview!.bottom - 10
            textField.height == 50
        }
        constrain(textToolBar) {
            textToolBar in
            textToolBar.height == 40.0
        }
        super.setupConstraints()
    }
    
    override func setChoice(_ choiceArray: [JSON]) {
        if choiceArray.count > 0 {
            textField.text = choiceArray[0].string
        }
        
        let defaultTitle = "这是一个下拉框，请选择"
        let choices = choiceArray.map { $0.string! }
        let rect = CGRect(x: 50, y: 100, width: 500, height: 50)
        let dropBoxView = TGDropBoxView(parentVC: editView!.parentVC!, title: defaultTitle, items: choices, frame: rect)
        dropBoxView.isHightWhenShowList = true
        dropBoxView.willShowOrHideBoxListHandler = { (isShow) in
            if isShow {
                if self.textField.isFirstResponder {
                    self.textField.resignFirstResponder()
                }
            }
        }
        dropBoxView.didSelectBoxItemHandler = { (row) in
            self.textField.text = dropBoxView.getTitle(row)
        }
        self.addSubview(dropBoxView)
        dropBoxView.setParentView(textField)
        constrain(dropBoxView, textField) {
            drop, text in
            drop.left == text.right
            drop.top == text.top
            drop.width == text.height
            drop.height == text.height
        }
        
        super.setChoice(choiceArray)
    }
    
    override func getValue() -> String {
        let ret = textField.text ?? ""
        return ret
    }
    
    //return key to exit input mode
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func toolBarBtnPush(sender: UIBarButtonItem){
        textField.resignFirstResponder()
    }
    
    override func parentTouched() -> Bool {
        if textField.isFirstResponder {
            textField.resignFirstResponder()
            return true
        }
        return false
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if let v = editView {
            let ivframe = self.convert(textField.frame, to: nil)
            let bottomTextField = ivframe.origin.y + ivframe.height
            v.startInsert(bottomTextField)
        }
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        if let v = editView {
            v.endInsert()
        }
    }
    
}

class DoubleInsertForm : StringInsertForm {
    override func setup() {
        super.setup()
        textField.keyboardType = .numbersAndPunctuation
    }
}

class IntInsertForm : StringInsertForm {
    override func setup() {
        super.setup()
        textField.keyboardType = .numberPad
    }
}

class LongtextInsertForm : InsertFormBase, UITextViewDelegate {
    
    public let textView : UITextView = {
        let ret = UITextView()
        ret.font = UIFont.systemFont(ofSize: 18)
        return ret
    }()
    private let textToolBar = UIToolbar()
    
    override func setup() {
        super.setup()
        
        textView.backgroundColor = .white
        textView.delegate = self
        //textView.addTarget(self, action: #selector(LongtextInsertForm.editBegin), for: .editingDidBegin)
        //textView.addTarget(self, action: #selector(LongtextInsertForm.editEnd), for: .editingDidEnd)
        
        //ボタンの設定
        let spaceBarBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace,target: self,action: nil)
        let toolBarBtn = UIBarButtonItem(title: "完了", style: .done, target: self, action: #selector(LongtextInsertForm.toolBarBtnPush))
        textToolBar.items = [spaceBarBtn, toolBarBtn]
        textView.inputAccessoryView = textToolBar
        
        self.addSubview(textView)
        
        //NotificationCenter.default.addObserver(self, selector: #selector(StringInsertForm.keyboardWillShow),
        //                                       name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(StringInsertForm.keyboardWillHide),
        //                                       name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func setupConstraints() {
        constrain(textView, titleLabel) {
            textView, titleLabel in
            textView.left == textView.superview!.left + 1
            textView.bottom == textView.superview!.bottom - 5
            textView.right == textView.superview!.right - 1
            textView.top == titleLabel.bottom + 5
            textView.height == 200
        }
        constrain(textToolBar) {
            textToolBar in
            textToolBar.height == 40.0
        }
        super.setupConstraints()
    }
    
    override func getValue() -> String {
        let ret = textView.text ?? ""
        return ret
    }
    
    func toolBarBtnPush(sender: UIBarButtonItem){
        textView.resignFirstResponder()
    }
    
    override func parentTouched() -> Bool {
        if textView.isFirstResponder {
            textView.resignFirstResponder()
            return true
        }
        return false
    }
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if let v = editView {
            print("\(textView.frame)")
            print("\(self.frame)")
            print("\(v.superview!.frame)")
            let ivframe = self.convert(textView.frame, to: nil)
            let bottomTextView = ivframe.origin.y + ivframe.height
            v.startInsert(bottomTextView)
        }
        return true
    }
    func textViewDidEndEditing(_ tV: UITextView) {
        if let v = editView {
            v.endInsert()
        }
    }
    //func editBegin() {
    //}
    //func editEnd() {
    //}
}

class TimestampInsertForm : StringInsertForm {
    private let dateFormat : DateFormatter = {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormat.locale     = Locale(identifier: "ja")
        return dateFormat
    }()
    override func setChoice(_ choiceArray: [JSON]) {
        super.setChoice(choiceArray)
        textField.text = dateFormat.string(from: Date())
    }
}

class ImageInsertForm : InsertFormBase, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var imageID : Int?
    var rawImage : UIImage?
    let imageView : UIImageView = {
        let ret = UIImageView()
        ret.backgroundColor = .white
        ret.contentMode = .scaleAspectFit
        return ret
    }()
    let imagePicker : UIImagePickerController = {
        let ret = UIImagePickerController()
        ret.sourceType = .camera
        return ret
    }()
    let imageButton : UIButton = {
        let ret = UIButton()
        ret.setTitle("add", for: .normal)
        ret.setTitleColor(.black, for: .normal)
        ret.layer.borderColor = UIColor.black.cgColor
        ret.layer.borderWidth = 1
        ret.addTarget(self, action: #selector(ImageInsertForm.tapImageButton), for: .touchUpInside)
        return ret
    }()
    let trimButton : UIButton = {
        let ret = UIButton()
        ret.setTitle("trim", for: .normal)
        ret.setTitleColor(.black, for: .normal)
        ret.layer.borderColor = UIColor.black.cgColor
        ret.layer.borderWidth = 1
        ret.addTarget(self, action: #selector(ImageInsertForm.tapTrimButton), for: .touchUpInside)
        return ret
    }()
    
    override func setup() {
        super.setup()
        self.addSubview(imageView)
        self.addSubview(imageButton)
        self.addSubview(trimButton)
        imagePicker.delegate = self
    }
    
    override func setupConstraints() {
        constrain(imageView, titleLabel) {
            imageView, titleLabel in
            imageView.left == imageView.superview!.left + 5
            imageView.top == titleLabel.bottom + 5
            imageView.bottom == imageView.superview!.bottom - 5
            imageView.width == 80
            imageView.height == 80
        }
        constrain(imageButton, trimButton) {
            imageButton, trimButton in
            imageButton.bottom == imageButton.superview!.bottom - 5
            trimButton.bottom == trimButton.superview!.bottom - 5
            imageButton.right == trimButton.left - 20
            trimButton.right == trimButton.superview!.right - 20
            imageButton.width == 50
            imageButton.height == 30
            trimButton.width == 50
            trimButton.height == 30
        }
        super.setupConstraints()
    }
    
    func imageFromPhotoLibrary(_ : UIAlertAction) {
        PHPhotoLibrary.requestAuthorization { status in
            if status != .authorized {
                return
            }
            self.imagePicker.sourceType = .photoLibrary
            self.editView?.parentVC?.present(self.imagePicker, animated: true, completion: nil)
        }
    }
    
    func imageFromCamera(_ : UIAlertAction) {
        AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo){ response in
            if !response {
                return
            }
            self.imagePicker.sourceType = .camera
            self.editView?.parentVC?.present(self.imagePicker, animated: true, completion: nil)
        }
    }
    
    func tapImageButton() {
        let alert = UIAlertController(title: "data source", message: "from which?", preferredStyle: .actionSheet)
        let lib = UIAlertAction(title: "PhotoLibrary", style: .default, handler: self.imageFromPhotoLibrary)
        let camera = UIAlertAction(title: "Camera", style: .default, handler: self.imageFromCamera)
        alert.addAction(lib)
        alert.addAction(camera)
        self.editView?.parentVC!.present(alert, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        self.rawImage = image
        self.imageView.image = image
        picker.dismiss(animated: true, completion: nil)
    }
    
    func tapTrimButton() {
        if let rawImage = self.rawImage {
            let iv = TrimImageVC()
            if let type_detail = self.columnInfo?.type_detail {
                if type_detail["img_width"] != nil && type_detail["img_height"] != nil {
                    iv.editWidth = CGFloat(type_detail["img_width"]!.intValue)
                    iv.editHeight = CGFloat(type_detail["img_height"]!.intValue)
                }
            }
            iv.image = rawImage
            iv.setCallback { image in
                self.imageView.image = image
                print("\(image?.size)")
            }
            //self.insertView!.parentVC?.navigationController?.pushViewController(iv, animated: true)
            self.editView!.parentVC?.present(iv, animated: true, completion: nil)
        }
    }
    
    override func preSubmit(completion: @escaping (Bool) -> Void) {
        if let image = self.imageView.image {
            OgiDataManager.dm.uploadImage(image: image) {
                imageID in
                if let imageID = imageID {
                    self.imageID = imageID
                    completion(true)
                } else {
                    completion(false)
                }
            }
        } else {
            completion(false)
        }
    }
    
    override func getValue() -> String {
        if let imageID = self.imageID {
            let ret = String(imageID)
            return ret
        } else {
            return ""
        }
    }
}

class DateInsertForm : InsertFormBase, UITextFieldDelegate, UIToolbarDelegate {
    
    private var textField = UITextField()
    private let inputDatePicker = UIDatePicker()
    private let pickerToolBar = UIToolbar()
    private let dateFormat : DateFormatter = {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd"
        dateFormat.locale     = Locale(identifier: "ja")
        return dateFormat
    }()
    
    override func setup() {
        super.setup()
        
        textField.backgroundColor = .white
        textField.delegate = self
        textField.inputView = inputDatePicker
        textField.text = dateFormat.string(from: Date())
        textField.delegate = self
        
        //ボタンの設定
        let spaceBarBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace,target: self,action: nil)
        let toolBarBtnToday = UIBarButtonItem(title: "今日", style: .plain, target: self, action: #selector(DateInsertForm.toolBarBtnTodayPush))
        let toolBarBtn = UIBarButtonItem(title: "完了", style: .done, target: self, action: #selector(DateInsertForm.toolBarBtnPush))
        pickerToolBar.items = [toolBarBtnToday, spaceBarBtn, toolBarBtn]
        textField.inputAccessoryView = pickerToolBar
        
        // DatePickerの設定(日付用)
        inputDatePicker.datePickerMode = UIDatePickerMode.date
        
        self.addSubview(textField)
    }
    
    override func setupConstraints() {
        constrain(textField, titleLabel) {
            textField, titleLabel in
            textField.left == textField.superview!.left + 5
            textField.right == textField.superview!.right - 5
            textField.top == titleLabel.bottom + 10
            textField.bottom == textField.superview!.bottom - 5
            textField.height == 50
        }
        constrain(pickerToolBar) {
            pickerToolBar in
            pickerToolBar.height == 40.0
        }
        super.setupConstraints()
    }
    
    override func getValue() -> String {
        let ret = textField.text ?? ""
        return ret
    }
    
    func toolBarBtnTodayPush(sender: UIBarButtonItem){
        inputDatePicker.date = Date()
        textField.text = dateFormat.string(from: inputDatePicker.date)
    }
    
    func toolBarBtnPush(sender: UIBarButtonItem){
        textField.text = dateFormat.string(from: inputDatePicker.date)
        textField.resignFirstResponder()
    }
    
    override func parentTouched() -> Bool {
        if textField.isFirstResponder {
            textField.resignFirstResponder()
            return true
        }
        return false
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if let v = editView {
            let ivframe = self.convert(textField.frame, to: nil)
            let bottomTextField = ivframe.origin.y + ivframe.height
            v.startInsert(bottomTextField)
        }
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        if let v = editView {
            v.endInsert()
        }
    }
}
