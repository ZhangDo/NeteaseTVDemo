import UIKit
import AVKit
import NeteaseRequest
import Kingfisher
struct WKPlayInfo {
    var id: Int
    var r: Int
    var isMV: Bool
}

class WKVideoViewController: AVPlayerViewController {
    var playInfo: WKPlayInfo
    private var playerInfo: [AVMetadataItem]?
    
    var playerItem: AVPlayerItem? {
        didSet {
            if let playerItem = playerItem {
//                removeObservarPlayerItem()
//                observePlayerItem(playerItem)
                if let playerInfo = playerInfo {
                    playerItem.externalMetadata = playerInfo
                }
            }
        }
    }
    
    init(playInfo: WKPlayInfo) {
        self.playInfo = playInfo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.transportBarIncludesTitleView = true
        if self.playInfo.isMV {
            Task {
                await loadData()
            }
        }
    }
    
    func loadData() async {
        do {
            
            let mvDetai: NRMVDetailModel = try await fetchMVDetail(mvid: self.playInfo.id, cookie: cookie)
            setPlayerInfo(title: mvDetai.name, subTitle: "", desp: mvDetai.briefDesc, pic: URL(string: mvDetai.cover))
            
            let mvUrlModel: NRMVUrlModel = try await fetchMVUrl(id: self.playInfo.id, cookie: cookie)
            if let url = mvUrlModel.url {
                let asset = AVURLAsset(url: URL(string: url)!)
                playerItem = AVPlayerItem(asset: asset)
                player = AVPlayer(playerItem: playerItem)
                player?.play()
            } else {
                showAlert(mvUrlModel.msg ?? "")
            }
            
        } catch {
            print(error)
            showAlert(error.localizedDescription)
        }
    }
    
    func setPlayerInfo(title: String?, subTitle: String?, desp: String?, pic: URL?) {
        let desp = desp?.components(separatedBy: "\n").joined(separator: " ")
        let mapping: [AVMetadataIdentifier: Any?] = [
            .commonIdentifierTitle: title,
            .iTunesMetadataTrackSubTitle: subTitle,
            .commonIdentifierDescription: desp,
        ]
        let meta = mapping.compactMap { createMetadataItem(for: $0, value: $1) }
        playerInfo = meta
        playerItem?.externalMetadata = meta

        if let pic = pic {
            let resource = Kingfisher.KF.ImageResource(downloadURL: pic)
            KingfisherManager.shared.retrieveImage(with: resource) {
                [weak self] result in
                guard let self = self,
                      let data = try? result.get().image.pngData(),
                      let item = self.createMetadataItem(for: .commonIdentifierArtwork, value: data)
                else { return }

                self.playerInfo?.removeAll { $0.identifier == .commonIdentifierArtwork }
                self.playerInfo?.append(item)
                self.playerItem?.externalMetadata = self.playerInfo ?? []
            }
        }
    }
    
    func createMetadataItem(for identifier: AVMetadataIdentifier,
                            value: Any?) -> AVMetadataItem?
    {
        if value == nil { return nil }
        let item = AVMutableMetadataItem()
        item.identifier = identifier
        item.value = value as? NSCopying & NSObjectProtocol
        // Specify "und" to indicate an undefined language.
        item.extendedLanguageTag = "und"
        return item.copy() as? AVMetadataItem
    }

}

extension WKVideoViewController: AVPlayerViewControllerDelegate {
    @objc func playerViewControllerShouldDismiss(_ playerViewController: AVPlayerViewController) -> Bool {
        if let presentedViewController = UIViewController.topMostViewController() as? AVPlayerViewController,
           presentedViewController == playerViewController
        {
            return true
        }
        return false
    }
    
    @objc func playerViewControllerShouldAutomaticallyDismissAtPictureInPictureStart(_ playerViewController: AVPlayerViewController) -> Bool {
        return true
    }
}
