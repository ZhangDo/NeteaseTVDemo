
import UIKit

class WKDescViewController: UIViewController {
    var descStr:String?
    @IBOutlet weak var textView: UITextView!
    static func creat(desc: String) -> WKDescViewController {
        let vc = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(identifier: String(describing: self)) as! WKDescViewController
//        vc.modalPresentationStyle = .custom
        vc.descStr = desc
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.textView.text = self.descStr!
        self.textView.panGestureRecognizer.allowedTouchTypes = [NSNumber(value: UITouch.TouchType.indirect.rawValue)]
        self.textView.isScrollEnabled = true
        self.textView.isUserInteractionEnabled = true
        self.textView.isSelectable = true
        // Do any additional setup after loading the view.
    }

}
