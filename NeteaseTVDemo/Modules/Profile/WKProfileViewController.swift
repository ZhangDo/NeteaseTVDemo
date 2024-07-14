
import UIKit
import TVUIKit
import NeteaseRequest
import ColorfulX
class WKProfileViewController: UIViewController {
    @IBOutlet weak var bgImageView: UIImageView!
    var animateView = AnimatedMulticolorGradientView()
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var rightBgView: UIView!
    fileprivate var cellContents = ["最近播放", "我的收藏","我喜欢的音乐", "我的歌单", "我的音乐云盘", "基础设置", "关于"]
    fileprivate var userInfo: NRUserDetailModel?
    fileprivate var recentPlayVC = WKRecentPlayViewController.creat()
    fileprivate var myCollectionVC = WKMyCollectionVC.creat()
    fileprivate var myLikeVC = WKSongCollectionVC.creat()
    fileprivate var myCloudSongVC = WKMyCloudSongVC.creat()
    fileprivate var myPlaylistVC = WKMyPlaylistViewController.creat()
    fileprivate var settingVC = WKSettingViewController.creat()
    fileprivate var aboutVC = WKAboutViewController.creat()
    static func creat() -> WKProfileViewController {
        let vc = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(identifier: String(describing: self)) as! WKProfileViewController
        return vc
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animateView.isHidden = !Settings.fluidBg
        animateView.isPaused = !Settings.fluidBg
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        animateView.setColors(self.getDefalutColors(), interpolationEnabled: false)
        animateView.isHidden = !Settings.fluidBg
        animateView.isPaused = !Settings.fluidBg
        animateView.speed = 1
        animateView.transitionDuration = 5.2
        animateView.noise = 10
        self.bgImageView.addSubview(animateView)
        animateView.snp.makeConstraints { make in
            make.edges.equalTo(self.bgImageView)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: NSNotification.Name(rawValue: "login"), object: nil)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(WKProfileHeader.self, forHeaderFooterViewReuseIdentifier: "profileHeader")
        tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .none)
        
        addChildVC()
        Task {
            await loadUserDetailInfo()
        }
    }
    
    
    func addChildVC() {
        addChild(recentPlayVC)
        self.rightBgView.addSubview(recentPlayVC.view)
        recentPlayVC.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        addChild(myCollectionVC)
        self.rightBgView.addSubview(myCollectionVC.view)
        myCollectionVC.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        addChild(myLikeVC)
        self.rightBgView.addSubview(myLikeVC.view)
        myLikeVC.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        addChild(myPlaylistVC)
        self.rightBgView.addSubview(myPlaylistVC.view)
        myPlaylistVC.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        addChild(myCloudSongVC)
        self.rightBgView.addSubview(myCloudSongVC.view)
        myCloudSongVC.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        addChild(settingVC)
        self.rightBgView.addSubview(settingVC.view)
        settingVC.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        addChild(aboutVC)
        self.rightBgView.addSubview(aboutVC.view)
        aboutVC.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        recentPlayVC.view.isHidden = false
        myCollectionVC.view.isHidden = true
        myLikeVC.view.isHidden = true
        myPlaylistVC.view.isHidden = true
        myCloudSongVC.view.isHidden = true
        settingVC.view.isHidden = true
        aboutVC.view.isHidden = true
    }
    
    func loadUserDetailInfo() async {
        do {
            if  let userModel: NRProfileModel = UserDefaults.standard.codable(forKey: "userModel") {
                userInfo = try await fetchUserInfoDetail(uid: userModel.userId, cookie: cookie)
            }
            self.tableView.reloadData()
            tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .none)
        } catch {
            print(error)
        }
    }
    
    @objc func reloadData() {
        Task {
            await loadUserDetailInfo()
        }
    }
}

extension WKProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellContents.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 420
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "profileHeader") as! WKProfileHeader
        header.nameLabel.text = userInfo?.profile.nickname ?? "游客"
        if let avatar = userInfo?.profile.avatarUrl {
            header.avatarView.imageView.kf.setImage(with: URL(string: avatar))
        }
        if (header.nameLabel.text == "游客") {
            header.signatureView.descLabel.text = "选中头像可扫码登录账号"
        } else {
            header.signatureView.descLabel.text = userInfo?.profile.signature ?? ""
        }
        
        header.signatureView.onPrimaryAction = { [weak self] model in
            let vc = WKDescViewController.creat(desc: self?.userInfo?.profile.signature ?? "")
            self!.present(vc, animated: true)
        }
        header.followedsLabel.text = "\(userInfo?.profile.followeds ?? 0)" + " 粉丝"
        header.followsLabel.text = "\(userInfo?.profile.follows ?? 0)" + " 关注"
        header.levelLabel.text = "Lv.\(userInfo?.level ?? 0)"
        
        
        header.clickAvatarAction = {
            if let am:[WKUserModel] = UserDefaults.standard.codable(forKey: "accounts"), am.count > 0 {
                let loginVC = WKSwitchAccountVC.creat()
                loginVC.modalPresentationStyle = .blurOverFullScreen
                self.present(loginVC, animated: true)
            } else {
                let loginVC = WKLoginViewController.creat()
                loginVC.modalPresentationStyle = .blurOverFullScreen
                self.present(loginVC, animated: true)
            }
        }
        return header
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
//        cell.accessoryType = .disclosureIndicator
        var content = cell.defaultContentConfiguration()
        content.text = cellContents[indexPath.row]
//        content.secondaryText = "errrrrr"
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            recentPlayVC.view.isHidden = false
            myCollectionVC.view.isHidden = true
            myLikeVC.view.isHidden = true
            myPlaylistVC.view.isHidden = true
            myCloudSongVC.view.isHidden = true
            settingVC.view.isHidden = true
            aboutVC.view.isHidden = true
        case 1:
            recentPlayVC.view.isHidden = true
            myCollectionVC.view.isHidden = false
            myLikeVC.view.isHidden = true
            myPlaylistVC.view.isHidden = true
            myCloudSongVC.view.isHidden = true
            settingVC.view.isHidden = true
            aboutVC.view.isHidden = true
        case 2:
            recentPlayVC.view.isHidden = true
            myCollectionVC.view.isHidden = true
            myLikeVC.view.isHidden = false
            myPlaylistVC.view.isHidden = true
            myCloudSongVC.view.isHidden = true
            settingVC.view.isHidden = true
            aboutVC.view.isHidden = true
        case 3:
            recentPlayVC.view.isHidden = true
            myCollectionVC.view.isHidden = true
            myLikeVC.view.isHidden = true
            myPlaylistVC.view.isHidden = false
            myCloudSongVC.view.isHidden = true
            settingVC.view.isHidden = true
            aboutVC.view.isHidden = true
        case 4:
            recentPlayVC.view.isHidden = true
            myCollectionVC.view.isHidden = true
            myLikeVC.view.isHidden = true
            myPlaylistVC.view.isHidden = true
            myCloudSongVC.view.isHidden = false
            settingVC.view.isHidden = true
            aboutVC.view.isHidden = true
        case 5:
            recentPlayVC.view.isHidden = true
            myCollectionVC.view.isHidden = true
            myLikeVC.view.isHidden = true
            myPlaylistVC.view.isHidden = true
            myCloudSongVC.view.isHidden = true
            settingVC.view.isHidden = false
            aboutVC.view.isHidden = true
        case 6:
            recentPlayVC.view.isHidden = true
            myCollectionVC.view.isHidden = true
            myLikeVC.view.isHidden = true
            myPlaylistVC.view.isHidden = true
            myCloudSongVC.view.isHidden = true
            settingVC.view.isHidden = true
            aboutVC.view.isHidden = false
        default: break
        }
    }
}
