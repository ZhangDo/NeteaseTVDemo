
import UIKit

class WKSwitchAccountVC: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
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
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: WKAccountCell.self), for: indexPath) as! WKAccountCell
        return cell
    }
}
