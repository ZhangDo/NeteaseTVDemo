//
//  WKFindModel.swift
//  NeteaseTVDemo
//
//  Created by fengyn on 2023/10/11.
//

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
