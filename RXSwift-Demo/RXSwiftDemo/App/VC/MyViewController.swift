//
//  MyViewController.swift
//  RXSwiftDemo
//
//  Created by xiaowu on 2022/4/27.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class MyViewController: UIViewController {

    private var viewModel = MyViewModel()
    /// 数据源
    private var dataSource: RxTableViewSectionedReloadDataSource<NewCellModel>!
    ///设置一个可观察序列，后续通过改变它的值来刷新接口。
    private let requestData = BehaviorRelay<String>(value: "0")
    
    private let disposeBag = DisposeBag()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView.init(frame: self.view.bounds, style: UITableView.Style.plain)
        tableView.register(PhotoTableViewCell.self, forCellReuseIdentifier: "PhotoTableViewCell")
        tableView.register(MorePhotoTableViewCell.self, forCellReuseIdentifier: "MorePhotoTableViewCell")
        return tableView
    }()
    
    lazy var btn: UIButton = {
        let btn = UIButton()
        btn.setTitle("刷新", for: .normal)
        btn.backgroundColor = UIColor.blue
        btn.frame = CGRect(x: 0, y: 60, width: 60, height: 25)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(self.tableView)
        self.view.addSubview(self.btn)
        bindAciton()
    }
    //MARK: - Bind
    /// 绑定数据
    func bindAciton() {
        
        //绑定数据
        let input = MyViewModel.Input(requestData: self.requestData)
        let output = viewModel.transform(input: input)
        
        //数据赋值
        self.dataSource = RxTableViewSectionedReloadDataSource<NewCellModel>  (configureCell: { (dataSource, tabView, indexPath, item) -> UITableViewCell in
            switch item {
                case .single(let model):
                    let cell = self.tableView.dequeueReusableCell(withIdentifier: "PhotoTableViewCell", for: indexPath) as? PhotoTableViewCell
                    guard let tempCell = cell else { return UITableViewCell() }
                    tempCell.setData(titleStr: model.title, sourceStr: model.source, imgStr: model.imgsrc)
        
                    tempCell.btn.rx.tap.subscribe { btn in
                        print("按钮点击里===")
                    }.disposed(by: tempCell.disposeBag)
                    return tempCell
                case .more(let moreModel):
                    let cell = self.tableView.dequeueReusableCell(withIdentifier: "MorePhotoTableViewCell", for: indexPath) as? MorePhotoTableViewCell
                cell?.setData(titleStr: moreModel.title, sourceStr: moreModel.source, imgStr: moreModel.imgsrc,imgArr: moreModel.imgnewextra)
                    return cell!
            }
        })
        
        //列表赋值
        output.results.drive(tableView.rx.items(dataSource: self.dataSource))
            .disposed(by: disposeBag)
        
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        btn.rx.tap.bind { [weak self] in
            let offsexValue = Int(self?.requestData.value ?? "")
            self?.requestData.accept("\((offsexValue ?? 0) + 1)")
        }
        .disposed(by: disposeBag)
        

    }
    
}

//MARK: - UITableViewDelegate
extension MyViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let NewCellModel = dataSource.sectionModels[indexPath.section]
        let sectionItem = NewCellModel.items[indexPath.row]
        switch sectionItem {
            case .single(_):
                return 100.0
            case .more(_):
                return 180.0
        }
    }
}

