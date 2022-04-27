//
//  PhotoTableViewCell.swift
//  RXSwiftDemo
//
//  Created by xiaowu on 2022/4/27.
//

import UIKit
import Kingfisher
class PhotoTableViewCell: UITableViewCell {
    
    private lazy var newsImageView: UIImageView = {
        return UIImageView(frame: .zero)
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

    //MARK: - override
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    //赋值
    func setData(titleStr: String,
                 sourceStr: String,
                 imgStr: String) {
        var str = ""
        if imgStr.hasPrefix("http:") {
            str = imgStr.replacingOccurrences(of: "http:", with: "https:")
        }
        let url = URL(string: str)
        newsImageView.kf.setImage(with: url, placeholder:  UIImage(named: "placeholder"))
        title.text = titleStr
        source.text = sourceStr
    }
    
    //MARK: - UI
    private func setupUI() {
        contentView.addSubview(newsImageView)
        contentView.addSubview(title)
        contentView.addSubview(source)

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
    }

}
