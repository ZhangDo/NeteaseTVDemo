import UIKit

class WKMoreView: UIControl {
    let moreLabel = UILabel()
    let moreImageView = UIImageView()
    var onPrimaryAction: ((WKMoreView) -> Void)?
    private let backgroundView = UIView()
    
    init() {
        super.init(frame: .zero)
        setupViews()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    func setupViews() {
        ({(view: UIView) in
            view.backgroundColor = UIColor(white: 1.0, alpha: 0.9)
            view.layer.shadowOffset = CGSizeMake(0, 10)
            view.layer.shadowOpacity = 0.15
            view.layer.shadowRadius = 16.0
            view.layer.cornerRadius = 20
            view.layer.cornerCurve = .continuous
            view.isHidden = !isFocused
            addSubview(view)
            view.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview()
                make.left.equalToSuperview().offset(-20)
                make.right.equalToSuperview().offset(20)
            }
        })(backgroundView)
        
        ({(label: UILabel) in
            label.numberOfLines = 0
//            label.text = "更多"
            label.font = UIFont.systemFont(ofSize: 60, weight: .medium)
            label.textColor = UIColor(named: "titleColor")
            label.textAlignment = .center
            addSubview(label)
            label.snp.makeConstraints { make in
                make.leading.equalToSuperview()
                make.centerY.equalToSuperview()
            }
        })(moreLabel)
        ({(imageView: UIImageView) in
            imageView.image = UIImage(systemName: "chevron.right")
            imageView.tintColor = UIColor(named: "titleColor")
            addSubview(imageView)
            imageView.snp.makeConstraints { make in
//                make.right.equalToSuperview().offset(-12)
                make.center.equalToSuperview()
                make.size.equalTo(CGSize(width: 40, height: 50))
            }
        })(moreImageView)
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
        if isFocused {
            self.moreLabel.textColor = UIColor.black
            self.moreImageView.tintColor = UIColor.black
        } else {
            self.moreLabel.textColor = UIColor(named: "titleColor")
            self.moreImageView.tintColor = UIColor(named: "titleColor")
        }
        backgroundView.isHidden = !isFocused
    }
    
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        super.pressesBegan(presses, with: event)
        for press in presses {
            if press.type == .select {
                self.transform = CGAffineTransformMakeScale(0.9, 0.9)
            }
        }
    }
    
    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        super.pressesEnded(presses, with: event)
        if presses.first?.type == .select {
            sendActions(for: .primaryActionTriggered)
            onPrimaryAction?(self)
            self.transform = CGAffineTransformMakeScale(1.0, 1.0)
        }
    }

}
