//
//  NetWorkAPI.swift
//  RXSwiftDemo
//
//  Created by xiaowu on 2022/4/29.
//

import Foundation
import Moya

public enum NetWorkAPI {
    //接口参数
    case news(parameters: [String: Any])
}

extension NetWorkAPI: TargetType {
    
    /// 域名
    public var baseURL: URL {
        switch self {
        case .news(_):
            return URL(string: "https://c.m.163.com/")!
        }
    }

    /// 请求地址
    public var path: String {
        switch self {
        case.news(_):
            return "dlist/article/dynamic"
        }
    }

    /// 接口请求类型
    public var method: Moya.Method {
        switch self {
        case.news(_):
            return.get
        }
    }

    ///请求的参数在这里处理
    public var task: Task {
        switch self {
        case.news(let parameterDic):
        return .requestParameters(parameters: parameterDic, encoding: URLEncoding.default)
        }
    }
    
    public var validationType: ValidationType {
        return .successCodes
    }
    
    /// 用于单元测试
    public var sampleData: Data {
        return "{}".data(using: String.Encoding.utf8)!
    }
    
    /// 请求头
    public var headers: [String: String]? {
        return [
                "content-type": "application/json",
        ]
    }
}
