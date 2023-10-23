import UIKit

public protocol WKSliderDelegate: AnyObject {
    func forward()
    func backward()
    func playOrPause()
}

class WKSlider: UIProgressView {
    
    public weak var delegate: WKSliderDelegate?
    
    override func becomeFirstResponder() -> Bool {
        return true
    }

    override var canBecomeFocused: Bool {
        return true
    }
    
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        super.pressesBegan(presses, with: event)
        for press in presses {
            if press.type == .rightArrow {
                delegate?.forward()
            } else if press.type == .leftArrow {
                delegate?.backward()
            } else if press.type == .select {
                delegate?.playOrPause()
                self.transform = CGAffineTransformMakeScale(1.0, 1.0)
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//                    self.transform = CGAffineTransformMakeScale(1.0, 1.1)
//                }
                
            }
        }
    }
    
    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        for press in presses {
            if press.type == .select {
                self.transform = CGAffineTransformMakeScale(1.0, 1.1)
            }
        }
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if isFocused {
            coordinator.addCoordinatedAnimations {
                self.transform = CGAffineTransformMakeScale(1.0, 1.1)
            }
        } else {
            coordinator.addCoordinatedAnimations {
                self.transform = CGAffineTransformIdentity
            }
        }
    }
    
    
}
