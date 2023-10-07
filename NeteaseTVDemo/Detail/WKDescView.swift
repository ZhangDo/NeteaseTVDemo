//
//  WKDescView.swift
//  NeteaseTVDemo
//
//  Created by fengyn on 2023/9/25.
//

import UIKit
import SnapKit
class WKDescView: UIControl {
    let descLabel = UILabel()
    var onPrimaryAction: ((WKDescView) -> Void)?
    private let backgroundView = UIView()
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup() {
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
                make.top.bottom.equalToSuperview()
                make.left.equalToSuperview().offset(-20)
                make.right.equalToSuperview().offset(20)
            }
        })(backgroundView)
        
        ({(label: UILabel) in
            label.numberOfLines = 0
            label.font = UIFont.systemFont(ofSize: 29)
            label.textColor = UIColor(named: "grayColor")
            addSubview(label)
            label.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview()
                make.centerY.equalToSuperview()
                make.bottom.lessThanOrEqualToSuperview().offset(-14)
            }
        })(descLabel)
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
        backgroundView.isHidden = !isFocused
    }

    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        super.pressesEnded(presses, with: event)
        if presses.first?.type == .select {
            sendActions(for: .primaryActionTriggered)
            onPrimaryAction?(self)
        }
    }
    
}
