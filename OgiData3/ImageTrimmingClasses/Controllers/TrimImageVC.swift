//
//  TrimImageVC.swift
//  PhotoLibraryImageTrimminger
//
//  Created by Satoshi Yoshio on 2017/10/04.
//  Copyright © 2017年 Yoshio. All rights reserved.
//

import UIKit
import Foundation
import CoreGraphics

import Cartography

class TrimImageVC: UIViewController {
    
    public var editWidth : CGFloat = 100
    public var editHeight : CGFloat = 100
    
    private var callbackFinish : ((UIImage?) -> Void)?
    func setCallback(callbackFinish: ((UIImage?) -> Void)?) {
        self.callbackFinish = callbackFinish
    }
        
//    @IBOutlet weak var mainStackView: UIStackView!
//    @IBOutlet weak var navigationLabel: UILabel!
    //@IBOutlet weak var trimImageButton: UIButton!
    //@IBOutlet weak var cancelEditButton: UIButton!
    //@IBOutlet weak var finishEditingButton: UIButton!
    //@IBOutlet weak var editPhotoView: UIView!
    //@IBOutlet weak var centerizeButton: UIButton!
//    @IBOutlet weak var headerView: UIView!
    //@IBOutlet weak var fitWidthButton: UIButton!
    //@IBOutlet weak var redoButton: UIButton!
    
    /*
    let trimImageButton : UIButton = {
        let ret = UIButton()
        ret.setTitle("trimImage", for: .normal)
        ret.setTitleColor(.black, for: .normal)
        ret.layer.borderColor = UIColor.black.cgColor
        ret.layer.borderWidth = 1
        return ret
    }()
    let centerizeButton : UIButton = {
        let ret = UIButton()
        ret.setTitle("centerize", for: .normal)
        ret.setTitleColor(.black, for: .normal)
        ret.layer.borderColor = UIColor.black.cgColor
        ret.layer.borderWidth = 1
        return ret
    }()
    */
    let fitWidthButton : UIButton = {
        let ret = UIButton()
        ret.setTitle("fitWidth", for: .normal)
        ret.setTitleColor(.black, for: .normal)
        ret.layer.borderColor = UIColor.black.cgColor
        ret.layer.borderWidth = 1
        ret.backgroundColor = .white
        return ret
    }()
    let finishEditingButton : UIButton = {
        let ret = UIButton()
        ret.setTitle("OK", for: .normal)
        ret.setTitleColor(.black, for: .normal)
        ret.layer.borderColor = UIColor.black.cgColor
        ret.layer.borderWidth = 1
        ret.backgroundColor = .white
        return ret
    }()
    /*
    let cancelEditButton : UIButton = {
        let ret = UIButton()
        ret.setTitle("cancelEdit", for: .normal)
        ret.setTitleColor(.black, for: .normal)
        ret.layer.borderColor = UIColor.black.cgColor
        ret.layer.borderWidth = 1
        return ret
    }()
    let redoButton : UIButton = {
        let ret = UIButton()
        ret.setTitle("redo", for: .normal)
        ret.setTitleColor(.black, for: .normal)
        ret.layer.borderColor = UIColor.black.cgColor
        ret.layer.borderWidth = 1
        return ret
    }()
    */
    let editPhotoView : UIView = {
        let ret = UIView()
        ret.backgroundColor = .gray
        return ret
    }()
    let waku : UIView = {
        let ret = UIView()
        ret.layer.borderColor = UIColor.black.cgColor
        ret.layer.borderWidth = 1
        return ret
    }()
    
    private var didSetupConstraints = false
    override func updateViewConstraints() {
        func setupConstraints() {
            /*
            constrain(trimImageButton, centerizeButton, fitWidthButton) {
                v1, v2, v3 in
                v2.width == v2.superview!.width * 0.3
                v2.height == 30.0
                v1.size == v2.size
                v2.size == v3.size
                align(top: v1, v2, v3)
                distribute(by: 10.0, horizontally: v1, v2, v3)
            }
            constrain(finishEditingButton, cancelEditButton, redoButton) {
                v4, v5, v6 in
                v5.width == v5.superview!.width * 0.3
                v5.height == 30.0
                v5.centerX == v5.superview!.centerX
                v4.size == v5.size
                v5.size == v6.size
                align(top: v4, v5, v6)
                distribute(by: 10.0, horizontally: v4, v5, v6)
            }
            constrain(centerizeButton, cancelEditButton) {
                v2, v4 in
                align(centerX: v2, v4)
                distribute(by: 10.0, vertically: v2, v4)
                v4.bottom == v4.superview!.bottom - 10.0
            }
            */
            constrain(fitWidthButton, finishEditingButton) {
                v1, v2 in
                v1.width == v1.superview!.width * 0.4
                v1.height == 30.0
                v2.size == v1.size
                
                align(top: v1, v2)
                distribute(by: 10.0, horizontally: v1, v2)
                v1.right == v1.superview!.centerX - 5.0
                v1.bottom == v1.superview!.bottom - 10.0
            }
            constrain(editPhotoView, finishEditingButton) {
                editPhotoView, v2 in
                //editPhotoView.width == editPhotoViewWidth
                //editPhotoView.height == editPhotoViewHeight
                //editPhotoView.centerX == editPhotoView.superview!.centerX
                //editPhotoView.centerY == editPhotoView.superview!.centerY - 35.0
                editPhotoView.top == editPhotoView.superview!.top + 20.0
                editPhotoView.left == editPhotoView.superview!.left
                editPhotoView.right == editPhotoView.superview!.right
                editPhotoView.bottom == v2.top - 10.0
            }
            constrain(waku) {
                waku in
                waku.width == waku.superview!.width * 0.75
                waku.height == waku.width * (self.editHeight / self.editWidth)
                waku.centerX == waku.superview!.centerX
                waku.centerY == waku.superview!.centerY
            }
        }
        if !didSetupConstraints {
            setupConstraints()
            didSetupConstraints = true
        }
        super.updateViewConstraints()
    }
    
    public var image : UIImage!
    var imageView : UIImageView!
    var previousImages = [UIImage]()
    var nextImages = [UIImage]()
    var scaleZoomedInOut : CGFloat = 1.0
    var previousScaleZoomedInOut = [CGFloat]()
    var nextScaleZoomedInOut = [CGFloat]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(editPhotoView)
        editPhotoView.addSubview(waku)
        //self.view.addSubview(trimImageButton)
        //self.view.addSubview(centerizeButton)
        self.view.addSubview(fitWidthButton)
        self.view.addSubview(finishEditingButton)
        //self.view.addSubview(cancelEditButton)
        //self.view.addSubview(redoButton)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateViewConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        //trimImageButton.addTarget(self, action: #selector(trimImage), for: .touchUpInside)
        //cancelEditButton.addTarget(self, action: #selector(undoEditting), for: .touchUpInside)
        //centerizeButton.addTarget(self, action: #selector(centerizeImageView), for: .touchUpInside)
        finishEditingButton.addTarget(self, action: #selector(finishEditing), for: .touchUpInside)
        fitWidthButton.addTarget(self, action: #selector(fitWidthOfImageView), for: .touchUpInside)
        //redoButton.addTarget(self, action: #selector(redoEditting), for: .touchUpInside)
        
        setUpPinchInOutAndDoubleTap()
        
        //load image and show UIImageView
        //let appDelegate = UIApplication.shared.delegate as! AppDelegate
        //image = appDelegate.photoLibraryImage
        previousScaleZoomedInOut.append(scaleZoomedInOut)
        createImageView(sourceImage: image, on: editPhotoView)
        
        //mainStackView.bringSubview(toFront: headerView)
    }
    
    func setUpPinchInOutAndDoubleTap(){
        // ピンチイン・アウトの準備
        let pinchGetsture = UIPinchGestureRecognizer(target: self, action: #selector(pinchAction(gesture:)))
        pinchGetsture.delegate = self as? UIGestureRecognizerDelegate
        
        self.editPhotoView.isUserInteractionEnabled = true
        self.editPhotoView.isMultipleTouchEnabled = true
        
        self.editPhotoView.addGestureRecognizer(pinchGetsture)
        // ダブルタップの準備
        let doubleTapGesture = UITapGestureRecognizer(target: self, action:#selector(doubleTapAction(gesture:)))
        doubleTapGesture.numberOfTapsRequired = 2
        self.editPhotoView.addGestureRecognizer(doubleTapGesture)
    }
    
    func createImageView(sourceImage: UIImage, on parentView: UIView){
        imageView = UIImageView(image: sourceImage)
        // 画像の幅・高さの取得
        let imageWidth = sourceImage.size.width
        let imageHeight = sourceImage.size.height
        let screenWidth = parentView.frame.width
        let screenHeight = parentView.frame.height
        
        if scaleZoomedInOut == 1.0{
            if imageWidth > screenWidth{
                scaleZoomedInOut = screenWidth/imageWidth
            }
        }
        
        let rect:CGRect = CGRect(x:0, y:0, width:scaleZoomedInOut*imageWidth, height:scaleZoomedInOut*imageHeight)
        // ImageView frame をCGRectで作った矩形に合わせる
        imageView.frame = rect

        // 画像の中心をスクリーンの中心位置に設定
        imageView.center = CGPoint(x:screenWidth/2, y:screenHeight/2)

        parentView.addSubview(imageView)
        parentView.sendSubview(toBack: imageView)
    }
    
    func updateImageView(){
        imageView.removeFromSuperview()
        createImageView(sourceImage: image, on: editPhotoView)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // タッチイベントを取得.
        let aTouch: UITouch = touches.first!
        
        // 移動した先の座標を取得.
        let location = aTouch.location(in: editPhotoView)
        
        // 移動する前の座標を取得.
        let prevLocation = aTouch.previousLocation(in: editPhotoView)
        
        let deltaX = location.x - prevLocation.x
        let deltaY = location.y - prevLocation.y
        
        // 移動した分の距離をmyFrameの座標にプラスする.
        imageView.frame.origin.x += deltaX
        imageView.frame.origin.y += deltaY
    }
    
    func makeTrimmingRect(targetImageView: UIImageView, trimmingAreaView: UIView) -> CGRect?{
        var width = CGFloat()
        var height = CGFloat()
        var trimmingX = CGFloat()
        var trimmingY = CGFloat()
        
        //let deltaX = targetImageView.frame.origin.x
        //let deltaY = targetImageView.frame.origin.y
        
        print("target: \(targetImageView.frame)")
        print("imgsize: \(targetImageView.image!.size)")
        print("trim: \(trimmingAreaView.frame)")
        print("screenscale: \(UIScreen.main.scale)")
        
        //width = targetImageView.frame.width
        //height = targetImageView.frame.height
        //trimmingX = 0
        //trimmingY = 0
        //let sc = targetImageView.frame.width * UIScreen.main.scale * 2 / targetImageView.image!.size.width
        let sc = targetImageView.frame.width / (targetImageView.image!.size.width * scaleZoomedInOut)
        print("sc: \(sc)")
        width = trimmingAreaView.frame.width / sc
        height = trimmingAreaView.frame.height / sc
        trimmingX = (trimmingAreaView.frame.minX - targetImageView.frame.minX) / sc
        trimmingY = (trimmingAreaView.frame.minY - targetImageView.frame.minY) / sc
        
        //空の部分ができてしまった場合、その部分を切り取る
        /*
        var xNotTrimFlag = false
        //x方向
        if targetImageView.frame.width > trimmingAreaView.frame.width {
            
            //3. 最初の時点で画面のy方向に画像がはみ出している時
            if targetImageView.frame.origin.x > 0{
                //origin.y > 0の場合、確実にy方向に画面から外れている
                //上方向にはみ出し
                width = trimmingAreaView.frame.size.width - deltaX
            }else{
                //origin.y < 0の場合、上方向には確実にはみ出している
                //下方向がはみ出していない
                if trimmingAreaView.frame.size.width > (targetImageView.frame.size.width + targetImageView.frame.origin.x) {
                    width = targetImageView.frame.size.width + targetImageView.frame.origin.x
                }else{
                    //下方向もはみ出し
                    width = trimmingAreaView.frame.size.width
                }
            }
        }else{
            //4. 最初の時点で画面のy方向に画像がすっぽり全て収まっている時
            if targetImageView.frame.origin.x > 0{
                if trimmingAreaView.frame.size.width < (targetImageView.frame.size.width + targetImageView.frame.origin.x) {
                    //下方向にはみ出し
                    width = trimmingAreaView.frame.size.width - deltaX
                }else{
                    xNotTrimFlag = true
                    width = targetImageView.frame.size.width
                }
            }else{
                //上方向にはみ出し
                width = targetImageView.frame.size.width + targetImageView.frame.origin.x
            }
        }
        //y方向
        if targetImageView.frame.height > trimmingAreaView.frame.height {
            
            //3. 最初の時点で画面のy方向に画像がはみ出している時
            if targetImageView.frame.origin.y > 0{
                //origin.y > 0の場合、確実にy方向に画面から外れている
                //下方向にはみ出し
                height = trimmingAreaView.frame.size.height - deltaY
            }else{
                //origin.y < 0の場合、上方向には確実にはみ出している
                //下方向がはみ出していない
                if trimmingAreaView.frame.size.height > (targetImageView.frame.size.height + targetImageView.frame.origin.y) {
                    height = targetImageView.frame.size.height + targetImageView.frame.origin.y
                }else{
                    //下方向もはみ出し
                    height = trimmingAreaView.frame.size.height
                }
            }
        }else{
            //4. 最初の時点で画面のy方向に画像がすっぽり全て収まっている時
            if targetImageView.frame.origin.y > 0{
                if trimmingAreaView.frame.size.height < (targetImageView.frame.size.height + targetImageView.frame.origin.y) {
                    //下方向にはみ出し
                    height = trimmingAreaView.frame.size.height - deltaY
                }else{
                    if xNotTrimFlag {
                        return nil
                    }else{
                        height = targetImageView.frame.size.height
                    }
                }
            }else{
                //上方向にはみ出し
                height = targetImageView.frame.size.height + targetImageView.frame.origin.y
            }
        }
        
        //trimmingRectの座標を決定
        if targetImageView.frame.origin.x > trimmingAreaView.frame.origin.x {
            trimmingX = 0
        }else{
            trimmingX = -deltaX
        }
        
        if targetImageView.frame.origin.y > 0 {
            trimmingY = 0
        }else{
            trimmingY = -deltaY
        }
        */
        
        return CGRect(x: trimmingX, y: trimmingY, width: width, height: height)
    }
    
    /*
    @objc func finishEdittingAlert(){
        let alert = UIAlertController(title: "確認",
                                      message: "編集を終了して画像を保存しますか？",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "保存", style: .cancel) { (_) -> Void in
            self.finishEditing()
        })
        alert.addAction(UIAlertAction(title: "キャンセル", style: .default))
        self.present(alert, animated: true)
    }
    */
    
    //はみ出したところを切り出す
    func trimImage() -> UIImage? {
        if let trimmingRect = makeTrimmingRect(targetImageView: imageView, trimmingAreaView: waku){
            previousImages.append(image)
            previousScaleZoomedInOut.append(scaleZoomedInOut)
            nextImages = Array<UIImage>()
            nextScaleZoomedInOut = Array<CGFloat>()
            image = image.trimming(to: trimmingRect, zoomedInOutScale: scaleZoomedInOut)
            //updateImageView()
            return image
        }
        return nil
    }
    
    func resizeImage(_ image : UIImage) -> UIImage? {
        //let size = image.size
        //let _size = Size(width: self.editWidth, height: self.editHeight)
        //let widthRatio = _size.width / size.width
        //let heightRatio = _size.height / size.height
        //let ratio = widthRatio < heightRatio ? widthRatio : heightRatio
        //let resizedSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        let resizedSize = CGSize(width: self.editWidth / UIScreen.main.scale, height: self.editHeight / UIScreen.main.scale)
        UIGraphicsBeginImageContextWithOptions(resizedSize, false, 0.0)
        image.draw(in: CGRect(origin: .zero, size: resizedSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }
    
    func finishEditing(){
        //saveImage()
        //moveToNextPage()
        if let image = trimImage(), let callbackFinish = callbackFinish {
            if let rimage = resizeImage(image) {
                callbackFinish(rimage)
                self.dismiss(animated: true, completion: nil)
                //self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    /*
    func saveImage(){
        print(editPhotoView.frame.width)
        print(imageView.frame.size)
        print(image.size)
        let imageListFileManager = ImageListFileManager()
        let imageFileManager = ImageFileManager()
        //if let data = UIImageJPEGRepresentation(image, 1.0) {
        if let data = UIImagePNGRepresentation(image) {
            let autoIncrementedFileName = imageListFileManager.autoIncrementedFileName()
            print(autoIncrementedFileName)
            imageFileManager.writeNewImageFile(data: data, fileName: autoIncrementedFileName)
            imageListFileManager.addNewImageFileName(fileName: autoIncrementedFileName)
        }
    }
    
    func moveToNextPage(){
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "storedImageListVC") as! StoredImageListVC
        self.present(secondViewController, animated: true)
    }
    
    @objc func undoEditting(){
        if previousScaleZoomedInOut.count > 1{
            nextScaleZoomedInOut.append(scaleZoomedInOut)
            _ = previousScaleZoomedInOut.popLast()!
            scaleZoomedInOut = previousScaleZoomedInOut.popLast()!
            previousScaleZoomedInOut.append(scaleZoomedInOut)
        }
        if previousImages.count > 0{
            nextImages.append(image)
            image = previousImages.popLast()
            updateImageView()
        }
    }
    
    @objc func redoEditting(){
        if nextScaleZoomedInOut.count > 0{
            previousScaleZoomedInOut.append(scaleZoomedInOut)
            scaleZoomedInOut = nextScaleZoomedInOut.popLast()!
            previousScaleZoomedInOut.append(scaleZoomedInOut)
        }
        if nextImages.count > 0{
            previousImages.append(image)
            image = nextImages.popLast()!
            updateImageView()
        }
    }
    */
    
    func fitWidthOfImageView(){
        // 画像の幅・高さの取得
        let imageViewWidth = imageView.frame.width
        let imageViewHeight = imageView.frame.height
        let screenWidth = editPhotoView.frame.width
        let screenHeight = editPhotoView.frame.height
        
        if imageViewWidth < screenWidth{
            let tempScale = screenWidth/imageViewWidth
            scaleZoomedInOut *= tempScale
            let rect:CGRect = CGRect(x:0, y:0, width:tempScale*imageViewWidth, height:tempScale*imageViewHeight)
            // ImageView frame をCGRectで作った矩形に合わせる
            imageView.frame = rect
            
            // 画像の中心をスクリーンの中心位置に設定
            imageView.center = CGPoint(x:screenWidth/2, y:screenHeight/2)
        }
    }
    /*
    @objc func centerizeImageView(){
        // 画像サイズをスクリーン幅に合わせる
        let screenWidth = editPhotoView.frame.width
        let screenHeight = editPhotoView.frame.height
        imageView.center = CGPoint(x:screenWidth/2, y:screenHeight/2)
    }
    */
    
    var pichCenter : CGPoint!
    var touchPoint1 : CGPoint!
    var touchPoint2 : CGPoint!
    let maxScale : CGFloat = 1
    var pinchStartImageCenter : CGPoint!
    var pinchStartScale : CGFloat = 1
    var pinchStartWidth : CGFloat = 100
    var pinchStartHeight : CGFloat = 100
    
    @objc func pinchAction(gesture: UIPinchGestureRecognizer) {
        
        
        if gesture.state == UIGestureRecognizerState.began {
            print("pinchbegan")
            // ピンチを開始したときの画像の中心点を保存しておく
            pinchStartImageCenter = imageView.center
            touchPoint1 = gesture.location(ofTouch: 0, in: self.view)
            touchPoint2 = gesture.location(ofTouch: 1, in: self.view)
            pinchStartScale = scaleZoomedInOut
            pinchStartWidth = self.imageView.frame.width
            pinchStartHeight = self.imageView.frame.height
            
            // 指の中間点を求めて保存しておく
            // UIGestureRecognizerState.Changedで毎回求めた場合、ピンチ状態で片方の指だけ動かしたときに中心点がずれておかしな位置でズームされるため
            pichCenter = CGPoint(x: (touchPoint1.x + touchPoint2.x) / 2, y: (touchPoint1.y + touchPoint2.y) / 2)
            
        } else if gesture.state == UIGestureRecognizerState.changed {
            // ピンチジェスチャー・変更中
            var pinchScale :  CGFloat// ピンチを開始してからの拡大率。差分ではない
            pinchScale = gesture.scale
            //if gesture.scale > 1 {
            //    pinchScale = 1 + gesture.scale/100
            //}else{
            //    pinchScale = gesture.scale
            //}
            //if pinchScale*self.imageView.frame.width < editPhotoView.frame.width {
            //    pinchScale = editPhotoView.frame.width/self.imageView.frame.width
            //}
            
            // ピンチした位置を中心としてズーム（イン/アウト）するように、画像の中心位置をずらす
            let newCenter = CGPoint(x: pinchStartImageCenter.x - ((pichCenter.x - pinchStartImageCenter.x) * pinchScale - (pichCenter.x - pinchStartImageCenter.x)),y: pinchStartImageCenter.y - ((pichCenter.y - pinchStartImageCenter.y) * pinchScale - (pichCenter.y - pinchStartImageCenter.y)))
            //self.imageView.frame.size = CGSize(width: pinchScale*self.imageView.frame.width, height: pinchScale*self.imageView.frame.height)
            self.imageView.frame.size = CGSize(width: pinchScale*pinchStartWidth, height: pinchScale*pinchStartHeight)
            imageView.center = newCenter
        }
    }
    
    @objc func doubleTapAction(gesture: UITapGestureRecognizer) {
        
        if gesture.state == UIGestureRecognizerState.ended {
            
            let doubleTapStartCenter = imageView.center
            let doubleTapScale: CGFloat = 2.0 // ダブルタップでは現在のスケールの2倍にする
            scaleZoomedInOut *= doubleTapScale
            let tapPoint = gesture.location(in: self.view)
            let newCenter = CGPoint(x:
                doubleTapStartCenter.x - ((tapPoint.x - doubleTapStartCenter.x) * doubleTapScale - (tapPoint.x - doubleTapStartCenter.x)),
                                    y: doubleTapStartCenter.y - ((tapPoint.y - doubleTapStartCenter.y) * doubleTapScale - (tapPoint.y - doubleTapStartCenter.y)))
            
            // 拡大・縮小とタップ位置に合わせた中心点の移動
            UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {() -> Void in
                self.imageView.frame.size = CGSize(width: doubleTapScale*self.imageView.frame.width, height: doubleTapScale*self.imageView.frame.height)
                self.imageView.center = newCenter
            }, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
