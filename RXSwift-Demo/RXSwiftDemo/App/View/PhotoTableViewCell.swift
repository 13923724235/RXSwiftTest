//
//  PhotoTableViewCell.swift
//  RXSwiftDemo
//
//  Created by xiaowu on 2022/4/27.
//

import Kingfisher
import RxSwift
import UIKit
class PhotoTableViewCell: UITableViewCell {
    private lazy var newsImageView: UIImageView = {
        UIImageView(frame: .zero)
    }()

    private lazy var title: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18.0)
        label.numberOfLines = 2
        return label
    }()

    private lazy var source: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13.0)
        label.textColor = .gray
        return label
    }()

    lazy var btn: UIButton = {
        let btn = UIButton()
        btn.setTitle("按钮", for: .normal)
        btn.backgroundColor = UIColor.orange
        return btn
    }()

    var disposeBag = DisposeBag()

    // MARK: - override

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }

    /*
     每次 prepareForReuse() 方法执行时都会初始化一个新的 disposeBag，这是因为 cell 是可以复用的，这样当 cell 每次重用的时候，便会自动释放之前的 disposeBag，从而保证 cell 被重用的时候不会被多次订阅，避免错误发生。
     可以创建一个baseTabLeviewCell， prepareForReuse 和 disposeBag写在基类里面，省的后续在写。
     */
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }

    // 赋值
    func setData(titleStr: String,
                 sourceStr: String,
                 imgStr: String) {
        var str = ""
        if imgStr.hasPrefix("http:") {
            str = imgStr.replacingOccurrences(of: "http:", with: "https:")
        }
        let url = URL(string: str)
        newsImageView.kf.setImage(with: url, placeholder: UIImage(named: "placeholder"))
        title.text = titleStr
        source.text = sourceStr
    }

    // MARK: - UI

    private func setupUI() {
        contentView.addSubview(newsImageView)
        contentView.addSubview(title)
        contentView.addSubview(source)
        contentView.addSubview(btn)

        newsImageView.snp.makeConstraints { make in
            make.width.equalTo(120.0)
            make.height.equalTo(80.0)
            make.centerY.equalTo(contentView)
            make.trailing.equalTo(contentView).offset(-10.0)
        }

        title.snp.makeConstraints { make in
            make.leading.top.equalTo(contentView).offset(10.0)
            make.trailing.equalTo(newsImageView.snp_leadingMargin).offset(-10.0)
        }

        source.snp.makeConstraints { make in
            make.leading.equalTo(title)
            make.bottom.equalTo(contentView).offset(-10.0)
            make.height.equalTo(15.0)
        }

        btn.snp.makeConstraints { make in
            make.right.equalTo(self.newsImageView.snp.left).offset(-10)
            make.bottom.equalTo(contentView).offset(-10.0)
            make.height.equalTo(30.0)
            make.width.equalTo(60.0)
        }
    }
}
