
import UIKit
import NeteaseRequest
import EFQRCode
class WKLoginViewController: UIViewController {

    @IBOutlet weak var qrCodeImageView: UIImageView!
    var timer: Timer?
    @IBOutlet weak var tipsLabel: UILabel!
    var code: Int?
    static func creat() -> WKLoginViewController {
        let vc = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(identifier: String(describing: self)) as! WKLoginViewController
        vc.modalPresentationStyle = .blurOverFullScreen
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Task {
            await loadQRCode()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopValidationTimer()
    }
    
    func loadQRCode() async {
        let key: String = try! await fetchQRKey().unikey
        let qrurl: String = try! await fetchQRCode(key: key).qrurl
        
        if let image = EFQRCode.generate(
            for: qrurl,
            watermark: UIImage(named: "bge")?.cgImage
        ) {
            print("Create QRCode image success \(image)")
            self.qrCodeImageView.image = UIImage(cgImage: image)
        } else {
            print("Create QRCode image failed!")
        }
        self.startValidationTimer(key: key)
        
    }
    
    func startValidationTimer(key: String) {
        timer = Timer.scheduledTimer(withTimeInterval: 4, repeats: true) { [self] _ in
            if code == 803 {
                self.stopValidationTimer()
            }
            Task {
                await self.loopValidation(key: key)
            }
        }
        timer?.fire()
        print("")
    }
    
    func stopValidationTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func loopValidation(key: String) async {
        do {
            let checkModel: NRQRCodeCheckModel = try await checkQRCode(key: key)
            print(checkModel)
            
            if checkModel.code == 803 {
                print("授权成功")
                UserDefaults.standard.setValue(checkModel.cookie, forKey: "cookie")
                cookie = checkModel.cookie!
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "login"), object: nil, userInfo: nil)
//
                do {
                    let userModel: NRProfileModel = try await fetchAccountInfo(cookie: cookie)
                    let newAccount = WKUserModel(isSelected: true, user: userModel, cookie: cookie)
                    var accounts: [WKUserModel] = UserDefaults.standard.codable(forKey: "accounts") ?? []
                    accounts.removeAll { $0.user.userId == userModel.userId }
                    accounts.append(newAccount)
                    UserDefaults.standard.set(codable: accounts, forKey: "accounts")
                    UserDefaults.standard.set(codable: accounts.last?.user, forKey: "userModel")
                } catch {
                    print(error)
                }
                
                self.dismiss(animated: true)
                AppDelegate.shared.showTabBar()
            } else if checkModel.code == 800 {
                print("二维码过期")
                tipsLabel.text = "二维码过期，请重新扫码"
                self.showAlert("二维码过期，请重新扫码")
                timer?.invalidate()
                await loadQRCode()
            } else if checkModel.code == 801 {
                print("等待扫码")
                tipsLabel.text = "等待扫码"
            } else if checkModel.code == 802 {
                print("等待确认")
                tipsLabel.text = "等待确认"
            }
        } catch {
            print(error)
            showAlert(error.localizedDescription)
            await loopValidation(key: key)
        }

    }

}
