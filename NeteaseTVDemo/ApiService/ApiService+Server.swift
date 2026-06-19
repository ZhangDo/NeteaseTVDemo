//
//  ApiService+Server.swift
//  NEMusic
//
//  Created by 秋星桥 on 2024/10/27.
//

import Foundation
import NodeMobile

extension ApiService {
    private(set) static var port: Int = .random(in: 11451 ... 14514)

    static func bootstrap() -> Never {
        setenv("PORT", "\(port)", 1)
        try! prepareSource()

        print("[*] starting server...")
        let commandArgs: [String] = [
            CommandLine.arguments.first ?? Bundle.main.executableURL!.path,
            sourceURL!.path,
        ]
        chdir(commandArgs.first!)
        var cArgs = commandArgs.map { strdup($0) } + [nil]
        defer { cArgs.forEach { free($0) } }
        node_start(.init(commandArgs.count), &cArgs)

        exit(1)
    }
}
