import UIKit
import NeteaseRequest
import Kingfisher
class WKCommentViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var songId: Int?
    var commentModels = [NRCommentModel]()
    static func creat(songId: Int) -> WKCommentViewController {
        let vc = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(identifier: String(describing: self)) as! WKCommentViewController
        vc.songId = songId
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(WKCommentTableViewCell.self, forCellReuseIdentifier: "WKCommentTableViewCell")
        Task {
            await loadComment()
        }
    }
    
    func loadComment() async {
        do {
            commentModels = try await fetchMusicHotComment(id: self.songId!, cookie: cookie, limit: 1000)
            print(commentModels)
            tableView.reloadData()
        } catch {
            print(error)
        }
    }

}

extension WKCommentViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WKCommentTableViewCell", for: indexPath) as! WKCommentTableViewCell
        cell.nameLabel.text = commentModels[indexPath.row].user.nickname
        cell.commentLabel.text = commentModels[indexPath.row].content
        cell.avatarImageView.kf.setImage(with: URL(string: commentModels[indexPath.row].user.avatarUrl))
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = WKDescViewController.creat(desc: commentModels[indexPath.row].content)
        self.present(vc, animated: true)
    }
}
