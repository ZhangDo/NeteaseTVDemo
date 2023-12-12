import Foundation
import NeteaseRequest

var cookie = ""
var likeIds = [Int]()

func fetchLikeIds() async {
    do {
        if let userModel: NRProfileModel = UserDefaults.standard.codable(forKey: "userModel") {
            likeIds = try await fetchLikeMusicList(uid: userModel.userId, cookie: cookie)
        }
    } catch {
        print(error)
    }
    
}
