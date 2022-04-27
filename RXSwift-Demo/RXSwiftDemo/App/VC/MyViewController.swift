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
            if item.imgnewextra?.isEmpty ?? true {
                let cell = self.tableView.dequeueReusableCell(withIdentifier: "PhotoTableViewCell", for: indexPath) as? PhotoTableViewCell
                cell?.setData(titleStr: item.title, sourceStr: item.source, imgStr: item.imgsrc)
                return cell!
            } else {
                let cell = self.tableView.dequeueReusableCell(withIdentifier: "MorePhotoTableViewCell", for: indexPath) as? MorePhotoTableViewCell
                cell?.setData(titleStr: item.title, sourceStr: item.source, imgStr: item.imgsrc,imgArr: item.imgnewextra)
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
        let newsSection = dataSource.sectionModels[indexPath.section]
        let news = newsSection.items[indexPath.row]
        if news.imgnewextra?.isEmpty ?? true {
            return 100.0
        }
        return 180.0
    }
}

