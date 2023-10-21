
import UIKit
import TVUIKit
import NeteaseRequest
class WKProfileViewController: UIViewController {

//    @IBOutlet weak var userHeaderView: TVMonogramView!
    
    @IBOutlet weak var tableView: UITableView!
    fileprivate var cellContents = ["最近播放", "我的收藏", "我创建的歌单", "基础设置"]
    fileprivate var userInfo: NRProfileModel?
    static func creat() -> WKProfileViewController {
        let vc = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(identifier: String(describing: self)) as! WKProfileViewController
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(WKProfileHeader.self, forHeaderFooterViewReuseIdentifier: "profileHeader")
//        self.userHeaderView.contentMode = .scaleAspectFill
        Task {
            await loadUserInfo()
        }
    }
    
    
    func loadUserInfo() async {
        do {
            userInfo = try await fetchAccountInfo(cookie: cookie)
            self.tableView.reloadData()
//            self.userHeaderView.kf.setImage(with: URL(string: userIno.avatarUrl))
//            self.userHeaderView.title = userIno.nickname
        } catch {
            print(error)
        }
    }
    
//    @IBAction func changeAccount(_ sender: Any) {
//        let loginVC = WKLoginViewController.creat()
//        loginVC.modalPresentationStyle = .blurOverFullScreen
//        self.present(loginVC, animated: true)
//    }
}

extension WKProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellContents.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 400
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "profileHeader") as! WKProfileHeader
        if let avatar = userInfo?.avatarUrl, let name = userInfo?.nickname {
            header.nameLabel.text = name
            header.avatarView.imageView.kf.setImage(with: URL(string: avatar))
        }
        header.clickAvatarAction = {
            let loginVC = WKLoginViewController.creat()
            loginVC.modalPresentationStyle = .blurOverFullScreen
            self.present(loginVC, animated: true)
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
}
