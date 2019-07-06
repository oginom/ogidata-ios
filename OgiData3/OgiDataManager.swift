//
//  OgiDataManager.swift
//  OgiData3
//
//  Created by ma on 2018/01/27.
//  Copyright © 2018年 Masahiro Ogino. All rights reserved.
//

import Alamofire
import SwiftyJSON

final class ColumnInfo {
    var name : String
    var name_db : String
    var type : String
    var type_detail : [String:JSON]?
    var unit : String?
    init(name: String, name_db: String, type: String, type_detail: [String:JSON]?, unit: String?) {
        self.name = name
        self.name_db = name_db
        self.type = type
        self.type_detail = type_detail
        self.unit = unit
    }
    init?() {
        return nil
    }
}

final class TableInfo {
    var title : String
    var tableID : Int?
    var columns: [ColumnInfo] = []
    init(title: String, tableID : Int? = nil) {
        self.title = title
        self.tableID = tableID
    }
    init?(json: SwiftyJSON.JSON) {
        if let title = json["title"].string {
            self.title = title
        } else {
            return nil
        }
        self.columns = []
        for (_, line) in json["columns"] {
            let col = ColumnInfo(
                name: line["name"].string!,
                name_db: line["name_db"].string!,
                type: line["type"].string!,
                type_detail: line["type_detail"].dictionary,
                unit: line["unit"].string
            )
            self.columns.append(col)
        }
    }
    init?() {
        return nil
    }
}

final class OgiDataValue {
    static var dv : OgiDataValue = {
        return OgiDataValue()
    }()
    private init() {}
    func STRtoDATE(str: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: str)
    }
}

final class OgiDataLocalManager {
    private let imgurl : String = Config.imgurl
    
    static var lm : OgiDataLocalManager = {
        return OgiDataLocalManager()
    }()
    
    func getImageThumbnail(_ imgID : Int,  callback : @escaping (UIImage?) -> Void) {
        if let image = self.loadImageThumbnail(imgID) {
            callback(image)
            return
        }
        OgiDataManager.dm.getImageInfo(imgID: imgID) {
            imageInfo in
            print(imageInfo)
            if imageInfo["thumbnail_filename"].string != nil {
                let url = URL(string: self.imgurl + imageInfo["thumbnail_filename"].string!)!
                do {
                    let imageData = try Data(contentsOf: url)
                    let img = UIImage(data:imageData)!;
                    callback(img)
                    _ = self.saveImageThumbnail(img, imgID: imgID)
                } catch {
                    callback(nil)
                }
            }
        }
    }
    
    func getImage(_ imgID : Int,  callback : @escaping (UIImage?) -> Void) {
        OgiDataManager.dm.getImageInfo(imgID: imgID) {
            imageInfo in
            if imageInfo["img_filename"].string != nil {
                let url = URL(string: self.imgurl + imageInfo["img_filename"].string!)!
                do {
                    let imageData = try Data(contentsOf: url)
                    let img = UIImage(data:imageData)!;
                    callback(img)
                } catch {
                    callback(nil)
                }
            }
        }
    }
    
    private func saveImageThumbnail(_ image : UIImage, imgID : Int) -> Bool {
        let jpgImageData = UIImageJPEGRepresentation(image, 1.0)
        let documentsURL = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent("thm-\(imgID).jpg")
        if FileManager.default.fileExists(atPath: fileURL.path) { return false }
        do { try jpgImageData!.write(to: fileURL) }
        catch { return false }
        return true
    }
    private func loadImageThumbnail(_ imgID : Int) -> UIImage? {
        let documentsURL = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent("thm-\(imgID).jpg")
        if !FileManager.default.fileExists(atPath: fileURL.path) { return nil }
        return UIImage(contentsOfFile: fileURL.path)
    }
}

final class OgiDataManager {
    private let apiurl : String = Config.apiurl
    
    static var dm : OgiDataManager = {
        return OgiDataManager()
    }()
    
    private init() {
    }
    
    func getTables(callback: @escaping ([TableInfo]) -> Void) {
        let url = apiurl + "gettables"
        Alamofire.request(url).responseJSON { response in
            guard let object = response.result.value else {
                return
            }
            let json = JSON(object)
            if json["ErrorMessage"].exists() {
                print("OgiDataManager.getTables Error")
                print(json["ErrorMessage"].string ?? "No Error Message")
                return
            }
            var ret : [TableInfo] = []
            json.forEach { _, l in
                let title = l[0]
                let tableID = l[1]
                print(tableID.int as Any)
                let t = TableInfo(title: title.stringValue, tableID: tableID.intValue)
                ret.append(t)
            }
            callback(ret)
        }
    }
    
    func getTableInfo(title: String, callback: @escaping (TableInfo) -> Void) {
        let url = apiurl + "gettableinfo"
        let params = [
            "title" : title
        ]
        Alamofire.request(url, parameters: params).responseJSON { response in
            guard let object = response.result.value else {
                return
            }
            let json = JSON(object)
            if let ret = TableInfo(json: json) {
                callback(ret)
            }
        }
    }
    
    func getData(title: String, asc: Bool = false, callback: @escaping (SwiftyJSON.JSON) -> Void) {
        let url = apiurl + "getdata"
        let params = [
            "title" : title,
            "asc" : asc ? "TRUE" : "FALSE",
            "limit" : "500"
        ]
        Alamofire.request(url, parameters: params).responseJSON { response in
            guard let object = response.result.value else {
                return
            }
            let json = JSON(object)
            callback(json)
        }
    }
    
    func getChoice(title: String, limit: Int = 10, callback: @escaping (SwiftyJSON.JSON) -> Void) {
        let url = apiurl + "getchoice"
        let params : [String : Any] = [
            "title" : title,
            "limit" : limit
        ]
        Alamofire.request(url, parameters: params).responseJSON { response in
            guard let object = response.result.value else {
                return
            }
            let json = JSON(object)
            callback(json)
        }
    }
    
    func insertData(title: String, data: JSON, callback: @escaping (JSON) -> Void) {
        let url = apiurl + "insertdata"
        let params : [String : String] = [
            "title" : title,
            "data" : data.rawString()!
        ]
        Alamofire.request(url, method: .post, parameters: params).responseJSON { response in
            guard let object = response.result.value else {
                return
            }
            let json = JSON(object)
            callback(json)
        }
    }
    
    func deleteData(title: String, data_id: Int,_ callback: @escaping (JSON) -> Void) {
        let url = apiurl + "deletedata"
        let params : [String : Any] = [
            "title" : title,
            "data_id" : data_id
        ]
        Alamofire.request(url, method: .post, parameters: params).responseJSON { response in
            guard let object = response.result.value else {
                return
            }
            let json = JSON(object)
            callback(json)
        }
    }
    
    func getChart(title: String, callback: @escaping ([UIImage]) -> Void) {
        let url = apiurl + "getchart"
        let params : [String : Any] = [
            "title" : title
        ]
        Alamofire.request(url, parameters: params).responseJSON { response in
            guard let object = response.result.value else {
                return
            }
            let json = JSON(object)
            var ret : [UIImage] = []
            json["urls"].forEach({ _, urljson in
                let url = URL(string: urljson.stringValue)!
                do {
                    let imageData = try Data(contentsOf: url)
                    let img = UIImage(data:imageData)!;
                    ret.append(img)
                } catch {
                }
            });
            callback(ret)
        }
    }
    
    func uploadImage(image : UIImage, callback: @escaping (Int?) -> Void) {
        let url = apiurl + "uploadimage"
        let params : [String : String] = [:]
        let data = UIImageJPEGRepresentation(image, 0.75)!
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(data, withName: "file", fileName: "upload.jpg", mimeType: "image/jpeg")
        },
            to: url,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        guard let object = response.result.value else {
                            callback(nil)
                            return
                        }
                        let json = JSON(object)
                        if json["result"].string == "success" {
                            let imageID = json["img_id"].intValue
                            callback(imageID)
                        } else {
                            callback(nil)
                        }
                    }
                case .failure(let encodingError):
                    print(encodingError)
                    callback(nil)
                }
            }
        )
    }
    
    func getImageInfo(imgID: Int, callback: @escaping (JSON) -> Void) {
        let url = apiurl + "getimageinfo"
        let params = [
            "img_id" : imgID
        ]
        Alamofire.request(url, parameters: params).responseJSON { response in
            guard let object = response.result.value else {
                return
            }
            let json = JSON(object)
            callback(json)
        }
    }
    
}
