//
//  AllNetWorkManager.swift
//  RXSwiftDemo
//
//  Created by xiaowu on 2022/4/29.
//

import Moya
import Alamofire
import HandyJSON
import Combine

///返回数据类型
enum HTTPDataType: Int {
    case one  //单个 model
    case more //数组 model
    case text //字符串
}

enum HTTPResultType: Int {
    case failure    //请求失败
    case success    //请求成功
}
///返回数据
struct YLResponseData: HandyJSON {
    var code: String?
    var message: String?
    var result: String?
    var error_code: String?
}

/// NetworkActivityPlugin插件用来监听网络请求，界面上做相应的展示
/// 但这里我没怎么用这个。。。 loading的逻辑直接放在网络处理里面了
private let networkPlugin = NetworkActivityPlugin.init { changeType, _ in
   print("networkPlugin \(changeType)")
   // targetType 是当前请求的基本信息
   switch changeType {
   case .began:
       print("开始请求网络")

   case .ended:
       print("结束")
   }
}

/// 网络请求的基本设置,这里可以拿到是具体的哪个网络请求，可以在这里做一些设置
private let endpointClosure = {(target: TargetType) -> Endpoint in
   let url = target.baseURL.absoluteString + target.path
   var task = target.task
   var endPoint = Endpoint(url: url,
                           sampleResponseClosure: { .networkResponse(200, target.sampleData) },
                           method: target.method,
                           task: task,
                           httpHeaderFields: target.headers)
   if let apiTarget = target as? MultiTarget,
      let tar = apiTarget.target as? NetWorkAPI  {
       switch tar {
       case .news(_):
           return endPoint
       }
   }
   return endPoint
}

/// 网络请求的设置
private let requestClosure = { (endpoint: Endpoint, done: MoyaProvider.RequestResultClosure) in
   do {
       var request = try endpoint.urlRequest()
       // 设置请求时长
       request.timeoutInterval = 30
       // 打印请求参数
       if let requestData = request.httpBody {
           print("请求的url：\(request.url!)" + "\n" + "\(request.httpMethod ?? "")" + "发送参数" + "\(String(data: request.httpBody!, encoding: String.Encoding.utf8) ?? "")")
       } else {
           print("请求的url：\(request.url!)" + "\(String(describing: request.httpMethod))")
       }
       if let header = request.allHTTPHeaderFields {
           print("请求头内容\(header)")
       }

       done(.success(request))
   } catch {
       done(.failure(MoyaError.underlying(error, nil)))
   }
}

/// 网络请求发送的核心初始化方法，创建网络请求对象
private let provider = MoyaProvider<MultiTarget>(endpointClosure: endpointClosure, requestClosure: requestClosure, plugins: [networkPlugin], trackInflights: false)

public class AllNetWorkManager: NSObject {
    
    ///网络错误
    private static let msgNetError = "网络错误，请联网后点击重试"
    
    //MARK: - PublicMethod
    ///返回单 model 网络请求
    public class func request<T:HandyJSON>(target: TargetType,
                                           modelType: T.Type,
                                           successBlock: @escaping (_ code: String, _ model: T?) -> Void,
                                           failureBlock:@escaping (_ code: String, _ msg:String) -> Void){
        
        provider.request(MultiTarget(target)) { result in
            switch result {
            case let .success(response):
                if let json = try? response.mapJSON() {
                    responseData(json, { code, result in
                        return successBlock(code, modelType.deserialize(from: result))
                    }, failureBlock)
                } else {
                    return failureBlock("-1", "返回数据获取失败")
                }
            case let .failure(error):
                print("failure\(error.localizedDescription)")
                return failureBlock("-1", msgNetError)
            }
        }
    }
    
    ///返回数组 model 网络请求
    public class func request<T:HandyJSON>(target: TargetType,
                                           modelTypes: [T].Type,
                                           successBlock: @escaping (_ code: String, _ models: [T?]) -> Void,
                                           failureBlock:@escaping (_ code: String, _ msg:String) -> Void){
        
        provider.request(MultiTarget(target)) { result in
            switch result {
            case let .success(response):
                if let json = try? response.mapJSON() {
                    responseData(json, { code, result in
                        return successBlock(code, modelTypes.deserialize(from: result) ?? [])
                    }, failureBlock)
                } else {
                    return failureBlock("-1", "返回数据获取失败")
                }
            case let .failure(error):
                print("failure\(error.localizedDescription)")
                return failureBlock("-1", msgNetError)
            }
        }
    }
    
    ///返回字符串 网络请求
    public class func request(target: TargetType,
                        successBlock: @escaping (_ code: String, _ result: String) -> Void,
                        failureBlock:@escaping (_ code: String, _ msg:String) -> Void){
        
        provider.request(MultiTarget(target)) { result in
            switch result {
            case let .success(response):
                if let json = try? response.mapJSON() {
                    responseData(json, successBlock, failureBlock)
                } else {
                    return failureBlock("-1", "返回数据获取失败")
                }
            case let .failure(error):
                print("failure\(error.localizedDescription)")
                return failureBlock("-1", msgNetError)
            }
        }
    }
    
    //MARK: - PrivateMethod
    ///数据处理
    class func responseData(
        _ data: Any,
        _ successBlock: @escaping (_ code: String, _ result: String) -> Void,
        _ failureBlock:@escaping (_ code: String, _ msg:String) -> Void) {
        
        if let obj = JSONDeserializer<YLResponseData>.deserializeFrom(dict: data as? [String:Any]) {
            let message = obj.message ?? msgNetError
            var code = obj.code ?? ""
            if code.isEmpty {
                code = obj.error_code ?? ""
            }
            if code.isEmpty {
                return failureBlock("-1", message)
            }
             
            if "200" == code || code == "0" {
                guard let result:String = obj.result, !result.isEmpty else {
                    return successBlock(code, "")
                }
                successBlock(code, result)
            }else{
                return failureBlock(code, message)
            }
        }else{
            return failureBlock("-1", msgNetError)
        }
    }
}
