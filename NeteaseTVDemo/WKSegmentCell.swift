
import UIKit

class WKSegmentCell: UICollectionViewCell {
    private var bgView = UIView()
    var selectedView = UIView()
    var titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        ({(view: UIView) in
            view.backgroundColor = UIColor.systemPink
            view.layer.shadowOffset = CGSizeMake(0, 10)
            view.layer.shadowOpacity = 0.15
            view.layer.shadowRadius = 16.0
            view.layer.cornerRadius = 30
            view.layer.cornerCurve = .continuous
            view.isHidden = true
            addSubview(view)
            view.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        })(selectedView)
        
        ({(view: UIView) in
            view.backgroundColor = UIColor(white: 0.9, alpha: 0.1)
            view.layer.shadowOffset = CGSizeMake(0, 10)
            view.layer.shadowOpacity = 0.15
            view.layer.shadowRadius = 16.0
            view.layer.cornerRadius = 30
            view.layer.cornerCurve = .continuous
//            view.isHidden = !isFocused
            addSubview(view)
            view.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        })(bgView)
        
        ({(label: UILabel) in
            label.text = "歌手"
            label.textColor = .white
            label.textAlignment = .center
            contentView.addSubview(label)
            label.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        })(titleLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
//        bgView.isHidden = !isFocused
        bgView.isHidden = !selectedView.isHidden
        bgView.backgroundColor = isFocused ? .white : UIColor(white: 0.9, alpha: 0.1)
        titleLabel.textColor = isFocused ? (selectedView.isHidden ? .black : .white) : .white
    }
}
