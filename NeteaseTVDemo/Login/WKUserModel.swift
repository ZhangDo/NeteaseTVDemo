//
//  WKUserModel.swift
//  NeteaseTVDemo
//
//  Created by fengyn on 2023/10/13.
//

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
