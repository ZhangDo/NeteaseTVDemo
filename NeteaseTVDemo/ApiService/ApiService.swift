//
//  ApiService.swift
//  NEMusic
//
//  Created by 秋星桥 on 2024/10/27.
//

import CommonCrypto
import NodeMobile
import ZipArchive

enum ApiService {
    static func throwError(text: String) throws {
        throw NSError(
            domain: NSLocalizedString("Music Service", comment: ""),
            code: 1,
            userInfo: [NSLocalizedDescriptionKey: text]
        )
    }
}
