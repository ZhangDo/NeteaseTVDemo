//
//  WKSingerDetailViewController.swift
//  NeteaseTVDemo
//
//  Created by fengyn on 2023/10/17.
//

import UIKit
import NeteaseRequest
class WKSingerDetailViewController: UIViewController {
    
    private var singerId: Int!
    @IBOutlet weak var singerNameLabel: UILabel!
    
    @IBOutlet weak var aliasLabel: UILabel!
    @IBOutlet weak var fansCountLabel: UILabel!
    @IBOutlet weak var identifyLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var singerImageView: UIImageView!
    static func creat(singerId: Int) -> WKSingerDetailViewController {
        let vc = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(identifier: String(describing: self)) as! WKSingerDetailViewController
        vc.singerId = singerId
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        Task {
            await loadSingerDetail()
        }
    }
    
    func loadSingerDetail() async {
        do {
            let singerDetail: NRArtistDetailModel = try await fetchArtistDetail(id: singerId)
            self.singerImageView.kf.setImage(with: URL(string: singerDetail.artist?.cover ?? ""))
            self.singerNameLabel.text = singerDetail.artist?.name
            self.aliasLabel.text = "JJ Lin"
            self.fansCountLabel.text = "1056.3万粉丝"
            self.identifyLabel.text = singerDetail.identify?.imageDesc
            self.descLabel.text = singerDetail.artist?.briefDesc
        } catch {
            print(error)
        }
    }
}
