//
//  main.swift
//  InternetMonitor
//
//  Created by Internet Monitor App
//  Copyright © 2024. All rights reserved.
//

import AppKit

// MARK: - Application Entry Point
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate

// Запуск приложения
_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
