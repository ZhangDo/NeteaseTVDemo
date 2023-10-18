import UIKit
import AVKit
import NeteaseRequest
struct WKPlayInfo {
    var id: Int
    var r: Int
    var isMV: Bool
}

class WKVideoViewController: AVPlayerViewController {
    var playInfo: WKPlayInfo
    init(playInfo: WKPlayInfo) {
        self.playInfo = playInfo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.playInfo.isMV {
            Task {
                await loadData()
            }
        }
    }
    
    func loadData() async {
        do {
            let mvUrlModel: NRMVUrlModel = try await fetchMVUrl(id: self.playInfo.id)
            if let url = mvUrlModel.url {
                player = AVPlayer(url: URL(string: url)!)
                player?.play()
            } else {
                showAlert(mvUrlModel.msg ?? "")
            }
            
        } catch {
            print(error)
            showAlert(error.localizedDescription)
        }
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
