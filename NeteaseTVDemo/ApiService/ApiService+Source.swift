//
//  ApiService+Source.swift
//  NEMusic
//
//  Created by 秋星桥 on 2024/10/27.
//

import CommonCrypto
import Foundation
import ZipArchive

extension ApiService {
    private(set) static var sourceURL: URL?
    static func prepareSource() throws {
        guard sourceURL == nil else { return }

        guard let payload = Bundle.main.url(forResource: "Service", withExtension: "zip") else {
            try throwError(text: NSLocalizedString("Failed to open music api source", comment: ""))
            fatalError()
        }
        let data = try Data(contentsOf: payload)
        let sha1 = data.withUnsafeBytes { bytes in
            var ctx = CC_SHA1_CTX()
            CC_SHA1_Init(&ctx)
            CC_SHA1_Update(&ctx, bytes.baseAddress, CC_LONG(data.count))
            var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
            CC_SHA1_Final(&digest, &ctx)
            return digest.map { String(format: "%02x", $0) }.joined()
        }
        print("[*] payload sha1: \(sha1)")

        let targetDir = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("node_dist")

        try? FileManager.default.removeItem(at: targetDir)
        try FileManager.default.createDirectory(at: targetDir, withIntermediateDirectories: true, attributes: nil)
        print("[*] sending payload to \(targetDir.path)")

        SSZipArchive.unzipFile(atPath: payload.path, toDestination: targetDir.path)

        let url = targetDir.appendingPathComponent("bundle.js")
        guard FileManager.default.fileExists(atPath: url.path) else {
            try throwError(text: NSLocalizedString("Failed to prepare source file", comment: ""))
            fatalError()
        }

        sourceURL = url
    }
}
