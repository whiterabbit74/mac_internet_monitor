#!/usr/bin/env swift

// Test script to check preferences window size

import AppKit

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate

// Запуск приложения
_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
