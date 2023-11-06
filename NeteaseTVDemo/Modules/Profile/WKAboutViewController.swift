
import UIKit

class WKAboutViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    let cells = [["title":"GitHub","subtitle":"https://github.com/ZhangDo/NeteaseTVDemo"]]
    static func creat() -> WKAboutViewController {
        let vc = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(identifier: String(describing: self)) as! WKAboutViewController
        return vc
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

}

extension WKAboutViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        //        cell.accessoryType = .disclosureIndicator
        var content = cell.defaultContentConfiguration()
        content.text = cells[indexPath.row]["title"]
        content.secondaryText = cells[indexPath.row]["subtitle"]
        cell.contentConfiguration = content
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = WKBrowserViewController()
        vc.modalPresentationStyle = .blurOverFullScreen
        vc.url = cells[indexPath.row]["subtitle"]!
        self.present(vc, animated: true)
    }
}
