//
//  NewModel.swift
//  RXSwiftDemo
//
//  Created by xiaowu on 2022/4/27.
//

import UIKit
import RxDataSources
import SwiftyJSON

//接口返回数据模型
struct NewModel {
    var title: String
    var imgsrc: String
    var replyCount: String
    var source: String
    var imgnewextra: [Imgnewextra]?
}

struct Imgnewextra {
    var imgsrc: String
}

struct NewCellModel {
    var header: String?
    var items: [NewModel]
}

extension NewCellModel: SectionModelType {
    
    typealias Item = NewModel
    
    init(original: NewCellModel, items: [NewModel]) {
        self = original
        self.items = items
    }
}
