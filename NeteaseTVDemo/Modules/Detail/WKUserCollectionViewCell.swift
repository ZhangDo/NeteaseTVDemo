
import UIKit

class WKUserCollectionViewCell: UICollectionViewCell {
    private let bgView = UIView()
    var nameLabel = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        ({(view: UIView) in
            view.backgroundColor = UIColor(white: 0.9, alpha: 0.1)
            view.layer.shadowOffset = CGSizeMake(0, 10)
            view.layer.shadowOpacity = 0.15
            view.layer.shadowRadius = 16.0
            view.layer.cornerRadius = 20
            view.layer.cornerCurve = .continuous
            view.isHidden = !isFocused
            addSubview(view)
            view.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        })(bgView)
        
        ({(label: UILabel) in
            label.font = .systemFont(ofSize: 30)
            label.numberOfLines = 0
            label.textAlignment = .center
            contentView.addSubview(label)
            label.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            
        })(nameLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
        bgView.isHidden = !isFocused
    }
}
