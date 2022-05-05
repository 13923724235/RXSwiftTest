//
//  NewModel.swift
//  RXSwiftDemo
//
//  Created by xiaowu on 2022/4/27.
//

import UIKit
import RxDataSources
import SwiftyJSON
import HandyJSON

//单元格类型
enum NewModelsSectionItem {
    case single(model: NewModel)
    case more(model: NewMoreModel)
}

//接口返回数据模型
struct NewModel: HandyJSON {
    var title: String = ""
    var imgsrc: String = ""
    var replyCount: String = ""
    var source: String = ""
}

//设置多不一样模型
struct NewMoreModel: HandyJSON {
    var title: String = ""
    var imgsrc: String = ""
    var replyCount: String = ""
    var source: String = ""
    var imgnewextra: [Imgnewextra]?
}

struct Imgnewextra {
    var imgsrc: String = ""
}

//主体
struct NewCellModel {
    var header: String?
    var items: [NewModelsSectionItem]
}

extension NewCellModel: SectionModelType {
    
    typealias Item = NewModelsSectionItem
    
    init(original: NewCellModel, items: [Item]) {
        self = original
        self.items = items
    }
}
