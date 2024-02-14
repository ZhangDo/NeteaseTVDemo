
import Foundation
import NeteaseRequest

struct WKUserModel: Codable {
    var isSelected: Bool
    var user: NRProfileModel
    var cookie: String

    init(isSelected: Bool, user: NRProfileModel, cookie: String) {
        self.isSelected = isSelected
        self.user = user
        self.cookie = cookie
    }
}
