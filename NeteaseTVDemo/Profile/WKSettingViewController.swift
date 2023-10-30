
import UIKit

class WKSettingViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    let settings = ["默认音频音质"]
    
    static func creat() -> WKSettingViewController {
        let vc = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(identifier: String(describing: self)) as! WKSettingViewController
        return vc
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        // Do any additional setup after loading the view.
    }

}

extension WKSettingViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
//        cell.accessoryType = .disclosureIndicator
        var content = cell.defaultContentConfiguration()
        content.text = settings[indexPath.row]
        content.secondaryText = "errrrrr"
        cell.contentConfiguration = content
        return cell
    }
}
