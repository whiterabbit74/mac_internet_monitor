//
//  AppDelegate.swift
//  InternetMonitor
//
//  Created by Internet Monitor App
//  Copyright © 2024. All rights reserved.
//

import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {

    // MARK: - Properties
    private var statusBarController: StatusBarController?
    private var networkMonitor: NetworkMonitor?
    private var preferencesWindowController: PreferencesWindowController?

    // MARK: - Application Lifecycle
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        print("🌐 Internet Monitor starting...")

        // Проверяем настройки отображения в доке
        setupDockVisibility()

        // Инициализация компонентов
        setupApplication()

        // Запуск мониторинга
        startMonitoring()

        print("✅ Internet Monitor started successfully!")
    }

    // Настройка видимости в доке
    private func setupDockVisibility() {
        let showInDock = UserDefaults.standard.bool(forKey: "showInDock")
        if showInDock {
            NSApp.setActivationPolicy(.regular)
        } else {
            NSApp.setActivationPolicy(.accessory)
        }
        print("🗂️ Dock visibility: \(showInDock ? "visible" : "hidden")")
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        print("🛑 Internet Monitor terminating...")

        // Очистка ресурсов перед завершением
        cleanup()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false // Не закрывать приложение при закрытии последнего окна
    }

    // MARK: - Setup
    private func setupApplication() {
        // Создаем NetworkMonitor
        networkMonitor = NetworkMonitor()

        // Создаем StatusBarController с NetworkMonitor
        if let networkMonitor = networkMonitor {
            statusBarController = StatusBarController(networkMonitor: networkMonitor)
        }

        // Создаем PreferencesWindowController
        preferencesWindowController = PreferencesWindowController()

        // Настраиваем наблюдение за изменениями настроек
        setupSettingsObserver()

        // Настраиваем наблюдение за изменениями темы
        setupThemeObserver()
    }

    // MARK: - Settings Observer
    private func setupSettingsObserver() {
        // Наблюдение за изменениями настроек прозрачности
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(settingsDidChange),
            name: UserDefaults.didChangeNotification,
            object: nil
        )
    }

    private func setupThemeObserver() {
        // Наблюдение за изменениями темы системы
        DistributedNotificationCenter.default().addObserver(
            self,
            selector: #selector(systemAppearanceDidChange),
            name: NSNotification.Name("AppleInterfaceThemeChangedNotification"),
            object: nil
        )
    }

    @objc private func settingsDidChange() {
        // Проверяем, изменилась ли настройка прозрачности
        let defaults = UserDefaults.standard
        let newOpacity = defaults.float(forKey: "iconOpacity")

        if newOpacity > 0 && abs(CGFloat(newOpacity) - (statusBarController?.iconOpacity ?? 0.5)) > 0.01 {
            print("🔄 Обнаружено изменение прозрачности иконки")
            statusBarController?.updateIconOpacity()
        }

        // Проверяем, изменился ли размер иконки
        let newSize = defaults.float(forKey: "iconSize")
        if newSize > 0 && abs(CGFloat(newSize) - (statusBarController?.iconSize ?? 18.0)) > 0.1 {
            print("📏 Обнаружено изменение размера иконки")
            statusBarController?.updateIconSize()
        }

        // Проверяем, изменились ли сетевые настройки
        let newEndpoint = defaults.string(forKey: "endpoint")
        let newInterval = defaults.integer(forKey: "checkInterval")

        if newEndpoint != nil || newInterval > 0 {
            print("🌐 Обнаружено изменение сетевых настроек - перезапускаем мониторинг")
            networkMonitor?.restartMonitoring()
        }
    }

    // MARK: - Theme Support
    @objc private func systemAppearanceDidChange() {
        // Обновляем иконки при изменении темы системы
        DispatchQueue.main.async { [weak self] in
            if let statusBarController = self?.statusBarController {
                print("🎨 Изменение темы системы - обновляем иконки")
                statusBarController.updateIconsForThemeChange()
            }
        }
    }

    // MARK: - Monitoring
    private func startMonitoring() {
        networkMonitor?.startMonitoring()
    }

    private func stopMonitoring() {
        networkMonitor?.stopMonitoring()
    }

    // MARK: - Cleanup
    private func cleanup() {
        stopMonitoring()
        statusBarController = nil
        networkMonitor = nil
        preferencesWindowController = nil
    }

    // MARK: - Public Methods
    func showPreferences() {
        preferencesWindowController?.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func refreshStatus() {
        networkMonitor?.refreshStatus()
    }

    deinit {
        // Удаляем наблюдатели для предотвращения утечек памяти
        NotificationCenter.default.removeObserver(self, name: UserDefaults.didChangeNotification, object: nil)
        DistributedNotificationCenter.default().removeObserver(self, name: NSNotification.Name("AppleInterfaceThemeChangedNotification"), object: nil)
    }
}
