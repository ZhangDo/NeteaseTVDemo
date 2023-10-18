
import Foundation
import NeteaseRequest
struct WKFindModel {
    var title: String
    var cateInfoModels: [NRCatInfoModel]
    init(title: String, cateInfoModels: [NRCatInfoModel]) {
        self.title = title
        self.cateInfoModels = cateInfoModels
    }
}
