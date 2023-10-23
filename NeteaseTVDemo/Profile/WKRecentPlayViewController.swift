import UIKit

class WKRecentPlayViewController: UIViewController {

    @IBOutlet weak var contentView: UIView!
    fileprivate var recentSongListVC = WKRecentSongListVC.creat()
    static func creat() -> WKRecentPlayViewController {
        let vc = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(identifier: String(describing: self)) as! WKRecentPlayViewController
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addChileVC()
    }
    
    func addChileVC() {
        addChild(recentSongListVC)
        contentView.addSubview(recentSongListVC.view)
        recentSongListVC.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

}
