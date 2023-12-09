import UIKit

class WKAvatarView: UIControl {
    var onPrimaryAction: ((WKAvatarView) -> Void)?
    var imageView = UIImageView()
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup() {
        ({(view: UIImageView) in
            view.image = UIImage(named: "bgImage")
            view.layer.cornerRadius = 100
            view.layer.masksToBounds = true
            addSubview(view)
            view.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        })(imageView)
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
        if isFocused {
            coordinator.addCoordinatedAnimations {
                self.transform = CGAffineTransformMakeScale(1.1, 1.1)
            }
        } else {
            coordinator.addCoordinatedAnimations {
                self.transform = CGAffineTransformMakeScale(1.0, 1.0)
            }
        }
    }
    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        super.pressesEnded(presses, with: event)
        if presses.first?.type == .select {
            sendActions(for: .primaryActionTriggered)
            onPrimaryAction?(self)
        }
    }

}
