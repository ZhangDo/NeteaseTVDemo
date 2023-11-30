import UIKit
import NeteaseRequest


class WKInputViewController: UIViewController {
    @IBOutlet weak var serviceTextField: UITextField!
    static func creat() -> WKInputViewController {
        let vc = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(identifier: String(describing: self)) as! WKInputViewController
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.serviceTextField.isSelected = false
        self.serviceTextField.placeholder = "https://"
        self.serviceTextField.text = Settings.service
    }
    
    @IBAction func doneButtonTaped(_ sender: Any) {
        guard let text = self.serviceTextField.text else {
            self.dismiss(animated: true)
            return
        }
        if text == Settings.service || text.count == 0 {
            self.dismiss(animated: true)
            return
        }
        let alert = UIAlertController.init(title: "修改服务地址", message: "确定要修改服务地址么,修改完成后需要重新启动软件", preferredStyle: .alert)
        let cancel = UIAlertAction.init(title: "取消", style: .cancel, handler: nil)
        alert.addAction(cancel)
        let confirm = UIAlertAction(title: "确定", style: .default) { _ in
            Settings.service = self.serviceTextField.text!
            abort()
        }
        alert.addAction(confirm)
        self.present(alert, animated: true, completion: nil)
    }
}


