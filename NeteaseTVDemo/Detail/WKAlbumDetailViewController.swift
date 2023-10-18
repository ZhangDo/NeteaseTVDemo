
import UIKit
import NeteaseRequest
class WKAlbumDetailViewController: UIViewController {
    
    @IBOutlet weak var bgView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var coverImageView: UIImageView!
    
    @IBOutlet weak var collectButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var descView: WKDescView!
    
    @IBOutlet weak var userView: UICollectionView!
    private var albumId: Int!
    private var albumDetail: NRAlbumDetailModel?
    
    var allModels: [CustomAudioModel] = [CustomAudioModel]()
    
    static func creat(playListId: Int) -> WKAlbumDetailViewController {
        let vc = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(identifier: String(describing: self)) as! WKAlbumDetailViewController
        vc.albumId = playListId
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.coverImageView.layer.cornerRadius = 10;
        tableView.register(WKPlayListTableViewCell.self, forCellReuseIdentifier: "WKPlayListTableViewCell")
        userView.register(WKUserCollectionViewCell.self, forCellWithReuseIdentifier: "WKUserCollectionViewCell")
        userView.collectionViewLayout = makeUserCollectionViewLayout()
        Task {
            await loadData()
        }
        
    }
    
    func loadData() async {
        albumDetail = try! await fetchAlbumDetail(id: self.albumId)
        
        self.bgView.kf.setImage(with: URL(string: (albumDetail?.album!.picUrl!)!),options: [.transition(.flipFromBottom(0.6))])
        self.coverImageView.kf.setImage(with: URL(string: (albumDetail?.album!.picUrl!)!))
        self.nameLabel.text = albumDetail?.album!.name
        //todo: if description null 则隐藏 descView
        self.descView.descLabel.text = albumDetail?.album!.description!
        self.descView.onPrimaryAction = { [weak self] model in
            let vc = WKDescViewController.creat(desc: self!.albumDetail?.album?.description ?? "")
            self!.present(vc, animated: true)
        }
        self.collectButton.isHidden = false
        
        guard let songs = albumDetail?.songs else { return }
        
        for songModel in songs {
            let model = CustomAudioModel()
            model.audioId = songModel.id
            model.isFree = 1
            model.freeTime = 0
            model.audioTitle = songModel.name
            model.audioPicUrl = songModel.al?.picUrl
            model.fee = songModel.fee
            let min = (songModel.dt ?? 0) / 1000 / 60
            let sec = (songModel.dt ?? 0) / 1000 % 60
            model.audioTime = String(format: "%d:%02d", min, sec)
            if let singerModel = songModel.ar {
                model.singer = singerModel.map { $0.name! }.joined(separator: "/")
            }
            self.allModels.append(model)
        }
        
        tableView.reloadData()
        userView.reloadData()
        self.playButton.isHidden = false
    }
    
    @IBAction func playAll(_ sender: Any) {
        if self.allModels.count > 0 {
            wk_player.allOriginalModels = self.allModels
            try? wk_player.play(index: 0)
            let playingVC = ViewController.creat()
            playingVC.modalPresentationStyle = .blurOverFullScreen
            self.present(playingVC, animated: true)
        }
        
    }

}

extension WKAlbumDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.allModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WKPlayListTableViewCell", for: indexPath) as! WKPlayListTableViewCell
        cell.setModel(self.allModels[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model: [CustomAudioModel] = [self.allModels[indexPath.row]]
        wk_player.allOriginalModels = model
        try? wk_player.play(index: 0)
        let playingVC = ViewController.creat()
        self.present(playingVC, animated: true)
    }
}

extension WKAlbumDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albumDetail?.album?.artists?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let userCell = collectionView.dequeueReusableCell(withReuseIdentifier: "WKUserCollectionViewCell", for: indexPath) as! WKUserCollectionViewCell
        userCell.nameLabel.text = albumDetail?.album?.artists![indexPath.row].name
        return userCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let singerDetailVC = WKSingerDetailViewController.creat(singerId: (albumDetail?.album?.artists![indexPath.row].id)!)
        singerDetailVC.modalPresentationStyle = .blurOverFullScreen
        self.present(singerDetailVC, animated: true)
    }
    
}


extension WKAlbumDetailViewController {
    func makeUserCollectionViewLayout () -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout {
            _, _ in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous
            section.interGroupSpacing = 0
            return section
        }
    }
}
