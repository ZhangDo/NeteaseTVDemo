//
//  WKPlayListTableViewCell.swift
//  NeteaseTVDemo
//
//  Created by fengyn on 2023/9/15.
//

import UIKit
import MarqueeLabel
import NeteaseRequest
class WKPlayListTableViewCell: UITableViewCell {
    
    private var picView = UIImageView ()
    private var songNameLabel = MarqueeLabel()
    private var singerLabel = UILabel()
    private var timeLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        ({(picView: UIImageView) in
            picView.contentMode = .scaleAspectFill
            picView.layer.cornerRadius = 10
            picView.clipsToBounds = true
            contentView.addSubview(picView)
            picView.snp.makeConstraints { make in
                make.left.equalTo(contentView)
                make.top.bottom.equalTo(contentView)
                make.size.equalTo(100)
            }
        })(picView)
        
        ({(label: MarqueeLabel) in
            label.textColor = UIColor(named: "titleColor")
            contentView.addSubview(label)
            label.snp.makeConstraints { make in
                make.left.equalTo(picView.snp.right).offset(20)
                make.right.equalTo(-140)
                make.bottom.equalTo(contentView.snp.centerY).offset(-5)
            }
        })(songNameLabel)
        
        ({(label: UILabel) in
            label.textColor = UIColor(named: "titleColor")
            label.font = .systemFont(ofSize: 30)
            contentView.addSubview(label)
            label.snp.makeConstraints { make in
                make.left.equalTo(picView.snp.right).offset(20)
                make.right.equalTo(-140)
                make.top.equalTo(contentView.snp.centerY).offset(5)
            }
        })(singerLabel)
        
        ({(label: UILabel) in
            label.textColor = .lightGray
            label.font = .systemFont(ofSize: 30)
            contentView.addSubview(label)
            label.snp.makeConstraints { make in
                make.right.equalToSuperview().offset(-20)
                make.centerY.equalToSuperview()
            }
        })(timeLabel)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
        if isFocused {
            songNameLabel.textColor = .black
            singerLabel.textColor = .black
        } else {
            songNameLabel.textColor = UIColor(named: "titleColor")
            singerLabel.textColor = UIColor(named: "titleColor")
        }
    }
    
    
    func setModel(_ model: CustomAudioModel) {
        self.picView.kf.setImage(with: URL(string: model.wk_audioPic ?? ""))
        self.songNameLabel.text = model.wk_sourceName
        self.singerLabel.text = model.wk_singerName
        self.timeLabel.text = model.audioTime
    }
}
