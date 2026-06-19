//
//  main.swift
//  NeteaseTVDemo
//
//  Created by 秋星桥 on 2024/10/27.
//

import Foundation

Thread { ApiService.bootstrap() }.start()

import UIKit

_ = UIApplicationMain(
    CommandLine.argc,
    CommandLine.unsafeArgv,
    nil,
    NSStringFromClass(AppDelegate.self)
)
