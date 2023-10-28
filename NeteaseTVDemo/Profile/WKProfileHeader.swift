import UIKit
import MarqueeLabel
class WKProfileHeader: UITableViewHeaderFooterView {
    var avatarView = WKAvatarView()
    var nameLabel = MarqueeLabel()
    var followedsLabel = UILabel()
    var followsLabel = UILabel()
    var levelLabel = UILabel()
    var signatureView = WKDescView()
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
        
        ({(label: UILabel) in
            label.font = .systemFont(ofSize: 25, weight: .semibold)
            label.textColor = .gray
            self.contentView.addSubview(label)
            label.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalTo(nameLabel.snp.bottom).offset(10)
            }
        })(followedsLabel)
        
        ({(label: UILabel) in
            label.font = .systemFont(ofSize: 25, weight: .semibold)
            label.textColor = .gray
            self.contentView.addSubview(label)
            label.snp.makeConstraints { make in
                make.right.equalTo(followedsLabel.snp.left).offset(-10)
                make.centerY.equalTo(followedsLabel)
            }
        })(followsLabel)
        
        ({(label: UILabel) in
            label.font = .systemFont(ofSize: 25, weight: .semibold)
            label.textColor = .gray
            self.contentView.addSubview(label)
            label.snp.makeConstraints { make in
                make.left.equalTo(followedsLabel.snp.right).offset(10)
                make.centerY.equalTo(followedsLabel)
            }
        })(levelLabel)
        
        ({(view: WKDescView) in
            self.contentView.addSubview(view)
            view.snp.makeConstraints { make in
                make.left.equalTo(contentView).offset(10)
                make.right.equalTo(contentView).offset(-10)
                make.top.equalTo((followedsLabel.snp.bottom)).offset(10)
                make.height.equalTo(100)
            }
        })(signatureView)
    }

    
}
