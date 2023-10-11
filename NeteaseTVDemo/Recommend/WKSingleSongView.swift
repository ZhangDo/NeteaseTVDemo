//
//  WKSingleSongView.swift
//  NeteaseTVDemo
//
//  Created by fengyn on 2023/9/27.
//

import UIKit
import MarqueeLabel
import NeteaseRequest
class WKSingleSongView: UIControl {
    private var picView = UIImageView ()
    private var songNameLabel = MarqueeLabel()
    private var singerLabel = MarqueeLabel()
    var audioModel = CustomAudioModel()
    var onPrimaryAction: ((CustomAudioModel) -> Void)?
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
            view.backgroundColor = UIColor(white: 0.9, alpha: 0.4)
            view.layer.shadowOffset = CGSizeMake(0, 10)
            view.layer.shadowOpacity = 0.15
            view.layer.shadowRadius = 16.0
            view.layer.cornerRadius = 20
            view.layer.cornerCurve = .continuous
            view.isHidden = !isFocused
            addSubview(view)
            view.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview()
                make.left.equalToSuperview()
                make.right.equalToSuperview()
            }
        })(backgroundView)
        
        ({(picView: UIImageView) in
            picView.contentMode = .scaleAspectFit
            picView.layer.cornerRadius = 10
            picView.clipsToBounds = true
            picView.layer.masksToBounds = true
            addSubview(picView)
            picView.snp.makeConstraints { make in
                make.left.equalToSuperview()
                make.top.bottom.equalToSuperview()
                make.size.equalTo(100)
            }
        })(picView)
        
        ({(label: MarqueeLabel) in
            label.text = "SONG NAME"
            label.textColor = UIColor(named: "titleColor")
            addSubview(label)
            label.snp.makeConstraints { make in
                make.left.equalTo(picView.snp.right).offset(20)
                make.right.equalToSuperview()
                make.bottom.equalTo(self.snp.centerY).offset(-5)
            }
        })(songNameLabel)
        
        ({(label: UILabel) in
            label.text = "SONG NAME"
            label.textColor = UIColor(named: "titleColor")
            label.font = .systemFont(ofSize: 30)
            addSubview(label)
            label.snp.makeConstraints { make in
                make.left.equalTo(picView.snp.right).offset(20)
                make.right.equalTo(self).offset(-30)
                make.top.equalTo(self.snp.centerY).offset(5)
            }
        })(singerLabel)
    }
    
    func setModel(audioModel: CustomAudioModel) {
        self.audioModel = audioModel
        self.picView.kf.setImage(with: URL(string: audioModel.wk_audioPic ?? ""))
        self.songNameLabel.text = audioModel.wk_sourceName
        self.singerLabel.text = audioModel.wk_singerName
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
        
//        backgroundView.isHidden = !isFocused
    }

    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        super.pressesEnded(presses, with: event)
        if presses.first?.type == .select {
            sendActions(for: .primaryActionTriggered)
            onPrimaryAction?(audioModel)
        }
    }
}
