//
//  WKLoginViewController.swift
//  NeteaseTVDemo
//
//  Created by fengyn on 2023/10/10.
//

import UIKit
import NeteaseRequest
import EFQRCode
class WKLoginViewController: UIViewController {

    @IBOutlet weak var qrCodeImageView: UIImageView!
    var timer: Timer?
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
                self.dismiss(animated: true)
                AppDelegate.shared.showTabBar()
            } else if checkModel.code == 800 {
                print("二维码过期")
            } else if checkModel.code == 801 {
                print("等待扫码")
            } else if checkModel.code == 802 {
                print("等待确认")
            }
        } catch {
            print(error)
            await loopValidation(key: key)
        }

    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
