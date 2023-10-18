
import Foundation
import NeteaseRequest

struct WKUserModel: Codable {
    var isSelected: Bool
    var user: NRProfileModel
    
    init(isSelected: Bool, user: NRProfileModel) {
        self.isSelected = isSelected
        self.user = user
    }
}
