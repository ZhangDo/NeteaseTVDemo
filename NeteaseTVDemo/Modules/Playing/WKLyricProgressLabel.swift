import UIKit

class WKLyricProgressLabel: UILabel {
    var progress: CGFloat = 0.0 {
        didSet {
            if progress < 0 {
                progress = 0
            } else if progress > 1 {
                progress = 1
            }
            setNeedsDisplay()
        }
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let fillRect = CGRect(x: 0, y: 0, width: self.bounds.size.width * self.progress, height: self.bounds.size.height)
        
        UIColor(red: 45/255, green: 185/255, blue: 105/255, alpha: 1.0).set()
        context.setBlendMode(.sourceIn)
        context.fill(fillRect)
    }
}

