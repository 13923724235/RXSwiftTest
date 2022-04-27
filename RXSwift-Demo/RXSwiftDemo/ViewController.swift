//
//  ViewController.swift
//  RXSwiftDemo
//
//  Created by xiaowu on 2022/4/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class ViewController: UIViewController {

    lazy var btn: UIButton = {
       let btn = UIButton()
       btn.setTitle("点击跳转", for: .normal)
    btn.backgroundColor = UIColor.red
       return btn
    }()
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.view.addSubview(btn)
        
        btn.snp.makeConstraints { make in
            make.center.equalTo(self.view)
            make.width.equalTo(120)
            make.height.equalTo(60.0)
        }
        
        btn.rx.tap.subscribe { btn in
            self.pushAction()
        }.disposed(by: disposeBag)
    
    }
    
    func pushAction() {
        let vc = MyViewController()
        self.present(vc, animated: true, completion: nil)
    }
}

