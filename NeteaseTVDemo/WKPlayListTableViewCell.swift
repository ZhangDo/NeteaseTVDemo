//
//  WKPlayListTableViewCell.swift
//  NeteaseTVDemo
//
//  Created by fengyn on 2023/9/15.
//

import UIKit
import MarqueeLabel
class WKPlayListTableViewCell: UITableViewCell {
    
    private var picView = UIImageView ()
    private var songNameLabel = MarqueeLabel()
    private var singerLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        ({(picView: UIImageView) in
            picView.contentMode = .scaleAspectFill
            picView.backgroundColor = .red
            picView.layer.cornerRadius = 10
            contentView.addSubview(picView)
            picView.snp.makeConstraints { make in
                make.left.equalTo(40)
                make.centerY.equalToSuperview()
                make.size.equalTo(CGSize(width: 100, height: 100))
                make.bottom.equalTo(-10)
            }
        })(picView)
        
        ({(label: MarqueeLabel) in
            label.text = "SONG NAME"
            label.textColor = UIColor(named: "titleColor")
            contentView.addSubview(label)
            label.snp.makeConstraints { make in
                make.left.equalTo(picView.snp.right).offset(20)
                make.bottom.equalTo(contentView.snp.centerY).offset(-10)
            }
        })(songNameLabel)
        
        ({(label: UILabel) in
            label.text = "SONG NAME"
            label.textColor = UIColor(named: "titleColor")
            contentView.addSubview(label)
            label.snp.makeConstraints { make in
                make.left.equalTo(picView.snp.right).offset(20)
                make.top.equalTo(contentView.snp.centerY).offset(10)
            }
        })(singerLabel)
        
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
    }
    
}
