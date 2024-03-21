import UIKit
import ColorfulX
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
    
    func getDefalutColors() -> [RGBColor] {
//        [make(254, 116, 97), make(243, 8, 32), make(250, 193, 208), make(193, 123, 126)]
//        [make(22, 4, 74), make(240, 54, 248), make(79, 216, 248), make(74, 0, 217)]
        let colors = [UIColor(red: 22.0 / 255.0, green: 4.0 / 255.0, blue: 74.0 / 255.0, alpha: 1.0),
                      UIColor(red: 240.0 / 255.0, green: 54.0 / 255.0, blue: 248.0 / 255.0, alpha: 1.0),
                      UIColor(red: 79.0 / 255.0, green: 216.0 / 255.0, blue: 248.0 / 255.0, alpha: 1.0),
                      UIColor(red: 74.0 / 255.0, green: 0.0 / 255.0, blue: 217.0 / 255.0, alpha: 1.0)]
        var rgbColors: [RGBColor] = []
        for color in colors {
            rgbColors.append(RGBColor(color))
        }
        return rgbColors
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
