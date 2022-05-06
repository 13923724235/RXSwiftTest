//
//  MyViewModel.swift
//  RXSwiftDemo
//
//  Created by xiaowu on 2022/4/27.
//

import RxCocoa
import RxSwift
import SwiftyJSON
import UIKit

class MyViewModel: NSObject {
    /// 输入
    struct Input {
        // BehaviorRelay 跟 BehaviorSubject 很像，只是不是发出complete、error事件
        var requestData: BehaviorRelay<String>
    }

    /// 输出
    struct Output {
        let results: Driver<[NewCellModel]>
    }

    /// 网络对象
    lazy var netWorkManager: NetWorkManager = {
        NetWorkManager.shareInstance
    }()

    /// 上传接口参数
    private var dic = ["from": "T1348649079062",
                       "devId": "H71eTNJGhoHeNbKnjt0%2FX2k6hFppOjLRQVQYN2Jjzkk3BZuTjJ4PDLtGGUMSK%2B55",
                       "version": "54.6",
                       "spever": "false",
                       "net": "wifi",
                       "ts": "\(Date().timeStamp)",
                       "sign": "BWGagUrUhlZUMPTqLxc2PSPJUoVaDp7JSdYzqUAy9WZ48ErR02zJ6%2FKXOnxX046I",
                       "encryption": "1",
                       "canal": "appstore",
                       "offset": "0",
                       "size": "10",
                       "fn": "3"]

    /// 输入转输出
    func transform(input: MyViewModel.Input) -> MyViewModel.Output {
        let driver: Driver = input.requestData.asObservable()
            .throttle(RxTimeInterval.seconds(Int(0.3)), scheduler: MainScheduler.instance)
            .distinctUntilChanged() // 直到元素的值发生变化，才发出新的元素，offset发生变化即触发网络请求
            .flatMap { (str) -> Observable<[NewCellModel]> in
                self.dic["offset"] = str
                return Observable<[NewCellModel]>.create { (obsever) -> Disposable in
                    self.getRequest(obsever: obsever)
                    //  self.getMoyaRequest(obsever: obsever)
                    return Disposables.create()
                }
            }.asDriver(onErrorJustReturn: [])
        return Output(results: driver)
    }

    /// 获取网络请求 使用 Alamofire
    private func getRequest(obsever: AnyObserver<[NewCellModel]>) {
        netWorkManager.requestNetworkData(.get, hostType: .Base, urlString: .GetNewsList, dic, nil) { _, json, _ in
            let news = self.getObserval(json: json)
            obsever.onNext(news)
        } falseHandler: { error in
            if error != nil {
                obsever.onError(error!)
            } else {
                obsever.onError(error!)
            }
        }
    }

    /// 获取网络请求 使用 Moya 未完成
    private func getMoyaRequest(obsever: AnyObserver<[NewCellModel]>) {
        AllNetWorkManager.request(target: NetWorkAPI.news(parameters: dic), modelTypes: [NewMoreModel].self) { _, _ in

        } failureBlock: { _, _ in
        }
    }

    /// 数据组装
    private func getObserval(json: JSON) -> [NewCellModel] {
        guard let json = json["T1348649079062"].array else { return [] }
        var news: [NewModelsSectionItem] = []
        json.forEach {
            guard !$0.isEmpty else { return }
            var imgnewextras: [Imgnewextra] = []
            if let imgnewextraJsonArray = $0["imgnewextra"].array {
                imgnewextraJsonArray.forEach {
                    let subItem = Imgnewextra(imgsrc: $0["imgsrc"].string ?? "")
                    imgnewextras.append(subItem)
                }
            }
            if imgnewextras.count > 0 {
                let model = NewMoreModel(title: $0["title"].string ?? "", imgsrc: $0["imgsrc"].string ?? "", replyCount: $0["replyCount"].string ?? "", source: $0["source"].string ?? "", imgnewextra: imgnewextras)
                news.append(.more(model: model))
            } else {
                let model = NewModel(title: $0["title"].string ?? "", imgsrc: $0["imgsrc"].string ?? "", replyCount: $0["replyCount"].string ?? "", source: $0["source"].string ?? "")
                news.append(.single(model: model))
            }
        }
        return [NewCellModel(header: "1", items: news)]
    }
}
