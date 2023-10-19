import UIKit
import MarqueeLabel
class WKMVCollectionViewCell: UICollectionViewCell {
    var coverImageView = UIImageView()
    var playCountLabel = UILabel()
    var duartionLabel = UILabel()
    var titleLabel = MarqueeLabel()
    var timeLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        ({(imageView: UIImageView) in
            imageView.layer.cornerRadius = 10
            imageView.clipsToBounds = true
            self.contentView.addSubview(imageView)
            imageView.snp.makeConstraints { make in
                make.edges.equalTo(UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0))
            }
        })(coverImageView)
        
        ({(label: UILabel) in
            label.font = .systemFont(ofSize: 20)
            label.textAlignment = .left
            self.coverImageView.addSubview(label)
            label.snp.makeConstraints { make in
                make.bottom.equalTo(coverImageView).offset(-10)
                make.left.equalTo(coverImageView).offset(10)
                make.right.equalTo(coverImageView).offset(-10)
            }
        })(duartionLabel)
        
        ({(label: MarqueeLabel) in
            label.font = .systemFont(ofSize: 30)
            label.textAlignment = .center
            self.contentView.addSubview(label)
            label.snp.makeConstraints { make in
                make.top.equalTo(coverImageView.snp.bottom).offset(10)
                make.left.right.equalTo(self.contentView)
            }
        })(titleLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
        if isFocused {
            coordinator.addCoordinatedAnimations {
                self.transform = CGAffineTransformMakeScale(1.1, 1.1)
            }
        } else {
            coordinator.addCoordinatedAnimations {
                self.transform = CGAffineTransformIdentity
            }
        }
    }
    
}
