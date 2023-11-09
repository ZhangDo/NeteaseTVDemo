
import UIKit

class WKCommentTableViewCell: UITableViewCell {
    
    var avatarImageView = UIImageView()
    var nameLabel = UILabel()
    var commentLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        ({(view: UIImageView) in
            view.layer.cornerRadius = 15
            view.clipsToBounds = true
            view.contentMode = .scaleAspectFill
            contentView.addSubview(view)
            view.snp.makeConstraints { make in
                make.left.equalToSuperview().offset(30)
                make.top.equalToSuperview().offset(30)
                make.size.equalTo(80)
            }
        })(avatarImageView)
        
        ({(label: UILabel)in
            label.numberOfLines = 0
            contentView.addSubview(label)
            label.snp.makeConstraints { make in
                make.left.equalTo(avatarImageView.snp.right).offset(30)
                make.top.equalTo(avatarImageView)
                make.right.equalToSuperview().offset(-30)
            }
        })(nameLabel)
        
        
        ({(label: UILabel)in
            label.numberOfLines = 0
            contentView.addSubview(label)
            label.snp.makeConstraints { make in
                make.left.equalTo(avatarImageView.snp.right).offset(30)
                make.top.equalTo(nameLabel.snp.bottom).offset(30)
                make.right.bottom.equalToSuperview().offset(-30)
            }
        })(commentLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
        if isFocused {
            nameLabel.textColor = .black
            commentLabel.textColor = .black
        } else {
            nameLabel.textColor = UIColor(dynamicProvider: { (traitCollection: UITraitCollection) -> UIColor in
                return traitCollection.userInterfaceStyle == UIUserInterfaceStyle.dark ?
                    .white : .black
            })
            commentLabel.textColor = UIColor(dynamicProvider: { (traitCollection: UITraitCollection) -> UIColor in
                return traitCollection.userInterfaceStyle == UIUserInterfaceStyle.dark ?
                    .white : .black
            })
        }
    }
    
}
