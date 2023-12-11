
import UIKit
import MarqueeLabel
class WKSongCollectionViewCell: UICollectionViewCell {
    private var picView = UIImageView ()
    private var songNameLabel = MarqueeLabel()
    private var singerLabel = MarqueeLabel()
    var scaleFactor: CGFloat = 1.05
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = 10
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    func setupViews() {
        ({(picView: UIImageView) in
            picView.contentMode = .scaleAspectFit
            picView.layer.cornerRadius = 10
            picView.clipsToBounds = true
            picView.layer.masksToBounds = true
            addSubview(picView)
            picView.snp.makeConstraints { make in
                make.left.equalToSuperview()
                make.top.bottom.equalToSuperview()
                make.width.equalTo(picView.snp.height)
            }
        })(picView)
        
        ({(label: MarqueeLabel) in
            label.textColor = UIColor(named: "titleColor")
            label.text = "这是一段比较长的歌名儿，123456789abcdeFG"
            addSubview(label)
            label.snp.makeConstraints { make in
                make.left.equalTo(picView.snp.right).offset(20)
                make.right.equalToSuperview()
                make.bottom.equalTo(self.snp.centerY).offset(-5)
            }
        })(songNameLabel)
        
        ({(label: UILabel) in
            label.textColor = UIColor(named: "titleColor")
            label.font = .systemFont(ofSize: 30)
            label.text = "这是一段比较长的歌手名儿，123456789abcdeFG"
            addSubview(label)
            label.snp.makeConstraints { make in
                make.left.equalTo(picView.snp.right).offset(20)
                make.right.equalTo(self).offset(-30)
                make.top.equalTo(self.snp.centerY).offset(5)
            }
        })(singerLabel)
    }
    
    func loadData(with model: CustomAudioModel) {
        self.picView.kf.setImage(with: URL(string: model.wk_audioPic ?? ""))
        self.songNameLabel.text = model.wk_sourceName
        self.singerLabel.text = model.wk_singerName
        
    }
    
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
        if isFocused {
            let scaleFactor = self.scaleFactor
            coordinator.addCoordinatedAnimations {
                self.transform = CGAffineTransformMakeScale(scaleFactor, scaleFactor)
                let scaleDiff = (self.bounds.size.height * scaleFactor - self.bounds.size.height) / 2
                self.transform = CGAffineTransformTranslate(self.transform, 0, -scaleDiff)
                self.layer.shadowOffset = CGSizeMake(0, 16)
                self.layer.shadowOpacity = 0.2
                self.layer.shadowRadius = 18.0
                self.layer.cornerRadius = 10
            }
        } else {
            coordinator.addCoordinatedAnimations {
                self.transform = CGAffineTransformIdentity
                self.layer.shadowOpacity = 0
                self.layer.shadowOffset = CGSizeMake(0, 0)
                self.layer.cornerRadius = 10
            }
        }
    }
}
