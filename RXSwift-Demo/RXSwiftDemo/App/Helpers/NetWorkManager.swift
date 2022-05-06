//
//  NetWorkManager.swift
//  RXSwiftDemo
//
//  Created by xiaowu on 2022/4/27.
//

import Alamofire
import SwiftyJSON
import UIKit

class NetWorkManager: NSObject {
    public enum UrlHostType: String {
        case Base = "https://c.m.163.com/"
    }

    enum RequestUrlType: String {
        case GetNewsList = "dlist/article/dynamic"
    }

    /// 单利
    static let shareInstance = NetWorkManager()
    /// 网络请求对象
    var sessionManager: Session!

    override private init() {
        super.init()
        sessionManager = Session()
    }

    // 数据请求
    open func requestNetworkData(_ method: HTTPMethod,
                                 hostType: UrlHostType,
                                 urlString: RequestUrlType,
                                 _ parameters: Parameters? = nil,
                                 _ body: String? = nil,
                                 successHandler: @escaping (_ code: Int, _ datas: JSON, _ desc: String) -> Swift.Void,
                                 falseHandler: @escaping (_ error: Error?) -> Swift.Void) {
        let url = "\(hostType.rawValue)\(urlString.rawValue)"
        var printUrl = ""
        printUrl += url
        printUrl += "?"
        if parameters != nil {
            for key in parameters!.keys {
                printUrl += key
                printUrl += "="
                let value = parameters![key]
                printUrl += "\(value!)"
                printUrl += "&"
            }
            printUrl = printUrl.subString(to: printUrl.count - 1)
        }

        printUrl = printUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        var originalRequest: URLRequest?
        if let url = URL(string: printUrl) {
            originalRequest = URLRequest(url: url)
        } else {
            falseHandler(nil)
            return
        }

        originalRequest?.httpMethod = method.rawValue
        if let bodyStr = body {
            originalRequest?.httpBody = bodyStr.data(using: .utf8, allowLossyConversion: false)
            originalRequest?.setValue("application/json", forHTTPHeaderField: "Content-Type")
        } else {
            originalRequest?.setValue("x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        }

        sessionManager.request(originalRequest!).responseJSON { response in
            if let value = response.value {
                let json = JSON(value)
                successHandler(200, json, "")
            } else {
                //   ProgressHUD.showTextPrompt("网络异常")
                falseHandler(response.error ?? nil)
            }
        }
    }
}
