
import UIKit
import Kingfisher
class WKSwitchAccountVC: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var accountModels: [WKUserModel] {
        if let am:[WKUserModel] = UserDefaults.standard.codable(forKey: "accounts") {
            return am
        }
        return []
    }
    static func creat() -> WKSwitchAccountVC {
        let vc = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(identifier: String(describing: self)) as! WKSwitchAccountVC
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(WKAccountCell.self, forCellWithReuseIdentifier: String(describing: WKAccountCell.self))
        collectionView.collectionViewLayout = makeSwitchAccountLayout()
    }
    
    func makeSwitchAccountLayout () -> UICollectionViewLayout {
        
        UICollectionViewCompositionalLayout {
            [weak self] _, _ in
            return self?.makeGridLayoutSection()
        }
        

    }
    
    func makeGridLayoutSection() -> NSCollectionLayoutSection {
        
//        let style = styleOverride ?? Settings.displayStyle
//        let heightDimension = NSCollectionLayoutDimension.estimated(380)
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1/5),
            heightDimension: .fractionalHeight(1)
        ))
        let hSpacing: CGFloat = 30
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: hSpacing, bottom: 0, trailing: hSpacing)
        let group = NSCollectionLayoutGroup.horizontalGroup(with: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension:.fractionalHeight(1)
        ), repeatingSubitem: item, count: 5)
        let vSpacing: CGFloat =  0
        let baseSpacing: CGFloat = 0
        group.edgeSpacing = NSCollectionLayoutEdgeSpacing(leading: .fixed(baseSpacing), top: .fixed(vSpacing), trailing: .fixed(0), bottom: .fixed(vSpacing))
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 0
        return section
    }


}

extension WKSwitchAccountVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return accountModels.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: WKAccountCell.self), for: indexPath) as! WKAccountCell
        if indexPath.row == accountModels.count {
            cell.userView.image = UIImage(systemName: "person.crop.circle.badge.plus")
            cell.userView.title = ""
        } else {
            KingfisherManager.shared.retrieveImage(with: URL(string: accountModels[indexPath.row].user.avatarUrl)!, options: nil, progressBlock: nil) { result in
                switch result {
                case .success(let value):
                    cell.userView.image = value.image
                case .failure(_):
                    debugPrint("下载图片失败")
                }
            }
            cell.userView.title = accountModels[indexPath.row].user.nickname
        }
//        cell.loadData(with: nil, isAdd: indexPath.row == accountModels.count)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == accountModels.count {
            let loginVC = WKLoginViewController.creat()
            loginVC.modalPresentationStyle = .blurOverFullScreen
            self.present(loginVC, animated: true)
        } else {
            UserDefaults.standard.setValue(accountModels[indexPath.row].cookie, forKey: "cookie")
            cookie = accountModels[indexPath.row].cookie
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "login"), object: nil, userInfo: nil)
        }
    }
}
