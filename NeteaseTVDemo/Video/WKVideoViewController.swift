import UIKit
import AVKit
import NeteaseRequest
struct WKPlayInfo {
    var id: Int
    var r: Int
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
        
        Task {
            await loadData()
        }
    }
    
    func loadData() async {
        do {
            let mvUrlModel: NRMVUrlModel = try await fetchMVUrl(id: 14634962)
            player = AVPlayer(url: URL(string: mvUrlModel.url)!)
            player?.play()
        } catch {
            print(error)
        }
    }

}
