//
//  WKProfileHeader.swift
//  NeteaseTVDemo
//
//  Created by fengyn on 2023/10/21.
//

import UIKit
import MarqueeLabel
class WKProfileHeader: UITableViewHeaderFooterView {
    var avatarView = WKAvatarView()
    var nameLabel = MarqueeLabel()
    var clickAvatarAction: (() -> Void)?
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        ({(view: WKAvatarView) in
            view.onPrimaryAction = { [weak self] view in
                self!.clickAvatarAction!()
            }
            self.contentView.addSubview(view)
            view.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalToSuperview()
                make.size.equalTo(200)
//                make.height.equalTo(self.contentView).multipliedBy(0.5)
//                make.width.equalTo(view.snp.height).multipliedBy(1.0)
            }
        })(avatarView)
        
        ({(label: MarqueeLabel) in
            label.textAlignment = .center
            self.contentView.addSubview(label)
            label.snp.makeConstraints { make in
                make.left.equalTo(self.contentView).offset(10)
                make.right.equalTo(self.contentView).offset(-10)
                make.top.equalTo(self.avatarView.snp.bottom).offset(10)
            }
        })(nameLabel)
    }

    
}
