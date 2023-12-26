
import UIKit
import TVUIKit

class WKAccountCell: UICollectionViewCell {
    
    let userView = TVMonogramView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        ({(view: TVMonogramView) in
            view.image = UIImage(named: "bgImage")
            view.title = "名字"
            self.contentView.addSubview(view)
            view.snp.makeConstraints { make in
                make.edges.equalTo(self.contentView)
            }
        })(userView)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
