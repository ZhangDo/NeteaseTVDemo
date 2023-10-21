import UIKit
extension UIViewController {
    func topMostViewController() -> UIViewController {
        if let presented = presentedViewController {
            return presented.topMostViewController()
        }

        if let navigation = self as? UINavigationController {
            return navigation.visibleViewController?.topMostViewController() ?? navigation
        }

        if let tab = self as? UITabBarController {
            return tab.selectedViewController?.topMostViewController() ?? tab
        }

        return self
    }

    static func topMostViewController() -> UIViewController {
        return AppDelegate.shared.window!.rootViewController!.topMostViewController()
    }
    
     func showAlert(_ message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController.init(title: "提示", message: message, preferredStyle: .alert)
            let confirm = UIAlertAction.init(title: "确定", style: .default, handler: nil)
            alert.addAction(confirm)
            self.present(alert, animated: true, completion: nil)
        }
    }

}
