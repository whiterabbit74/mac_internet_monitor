//
//  StatusBarController.swift
//  InternetMonitor
//
//  Created by Internet Monitor App
//  Copyright © 2024. All rights reserved.
//

import AppKit

class StatusBarController: NSObject {

    // MARK: - Properties
    private var statusItem: NSStatusItem?
    private var networkMonitor: NetworkMonitor
    private var currentStatus: ConnectionStatus = .unknown

    // Настройки прозрачности и размера
    private(set) var iconOpacity: CGFloat = 0.5  // По умолчанию 50%
    private(set) var iconSize: CGFloat = 18.0     // По умолчанию 18px

    // Иконки для разных состояний (эмодзи)
    private lazy var connectedIcon = createEmojiIcon("🟢")
    private lazy var unstableIcon = createEmojiIcon("🟡")
    private lazy var disconnectedIcon = createEmojiIcon("🔴")

    // Функция для создания иконки из эмодзи
    private func createEmojiIcon(_ emoji: String) -> NSImage {
        let fontSize: CGFloat = iconSize - 2  // Размер шрифта чуть меньше размера иконки
        let font = NSFont.systemFont(ofSize: fontSize)

        // Определяем цвет в зависимости от темы
        let isDarkMode = NSApp.effectiveAppearance.name == .darkAqua
        let emojiColor: NSColor

        if isDarkMode {
            // В темной теме используем более светлый цвет для лучшей видимости
            emojiColor = NSColor.labelColor.withAlphaComponent(0.9)
        } else {
            // В светлой теме используем стандартный цвет
            emojiColor = NSColor.labelColor
        }

        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: emojiColor
        ]

        let attributedString = NSAttributedString(string: emoji, attributes: attributes)
        let textSize = attributedString.size()

        // Создаем квадратное изображение
        let iconNSSize = NSSize(width: iconSize, height: iconSize)
        let image = NSImage(size: iconNSSize)

        image.lockFocus()

        // Центрируем эмодзи в квадрате
        let x = (iconNSSize.width - textSize.width) / 2
        let y = (iconNSSize.height - textSize.height) / 2
        attributedString.draw(at: NSPoint(x: x, y: y))

        image.unlockFocus()

        // Применяем прозрачность
        return applyOpacity(to: image, opacity: iconOpacity)
    }

    // Применение прозрачности к изображению
    private func applyOpacity(to image: NSImage, opacity: CGFloat) -> NSImage {
        let newImage = NSImage(size: image.size)
        newImage.lockFocus()

        // Рисуем оригинальное изображение с прозрачностью
        image.draw(in: NSRect(origin: .zero, size: image.size),
                   from: NSRect(origin: .zero, size: image.size),
                   operation: .sourceOver,
                   fraction: opacity)

        newImage.unlockFocus()
        return newImage
    }

    // Загрузка настроек прозрачности
    private func loadIconOpacitySettings() {
        let defaults = UserDefaults.standard
        let opacity = defaults.float(forKey: "iconOpacity")
        iconOpacity = opacity > 0 ? CGFloat(opacity) : 0.5  // По умолчанию 50%
        print("📱 Загружена прозрачность иконки: \(Int(iconOpacity * 100))%")
    }

    // Загрузка настроек размера иконки
    private func loadIconSizeSettings() {
        let defaults = UserDefaults.standard
        let size = defaults.float(forKey: "iconSize")
        iconSize = size > 0 ? CGFloat(size) : 18.0  // По умолчанию 18px
        print("📏 Загружен размер иконки: \(Int(iconSize))px")
    }

    // Обновление прозрачности всех иконок
    func updateIconOpacity() {
        loadIconOpacitySettings()
        // Пересоздаем иконки с новой прозрачностью и учетом темы
        connectedIcon = createEmojiIcon("🟢")
        unstableIcon = createEmojiIcon("🟡")
        disconnectedIcon = createEmojiIcon("🔴")

        // Обновляем текущую иконку
        updateIcon()
    }

    // Обновление размера всех иконок
    func updateIconSize() {
        loadIconSizeSettings()
        // Пересоздаем иконки с новым размером и учетом темы
        connectedIcon = createEmojiIcon("🟢")
        unstableIcon = createEmojiIcon("🟡")
        disconnectedIcon = createEmojiIcon("🔴")

        // Обновляем текущую иконку
        updateIcon()
    }

    // Обновление иконок при изменении темы
    func updateIconsForThemeChange() {
        // Пересоздаем иконки с учетом новой темы
        connectedIcon = createEmojiIcon("🟢")
        unstableIcon = createEmojiIcon("🟡")
        disconnectedIcon = createEmojiIcon("🔴")

        // Обновляем текущую иконку
        updateIcon()
    }

    // MARK: - Enums
    enum ConnectionStatus {
        case connected
        case unstable
        case disconnected
        case unknown
    }

    // MARK: - Initialization
    init(networkMonitor: NetworkMonitor) {
        self.networkMonitor = networkMonitor
        super.init()
        loadIconOpacitySettings()
        loadIconSizeSettings()
        setupStatusBarItem()
        setupNetworkMonitoring()
    }

    deinit {
        removeStatusBarItem()
    }

    // MARK: - Setup
    private func setupStatusBarItem() {
        // Создаем status item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        // Настраиваем базовые свойства
        statusItem?.button?.image = disconnectedIcon
        statusItem?.button?.image?.size = NSSize(width: iconSize, height: iconSize)

        // Создаем меню
        let menu = NSMenu()
        menu.delegate = self
        statusItem?.menu = menu

        // Добавляем действие при клике
        statusItem?.button?.action = #selector(statusItemClicked)
        statusItem?.button?.target = self
    }

    private func setupNetworkMonitoring() {
        // Настраиваем коллбэк для обновления статуса
        networkMonitor.onStatusChange = { [weak self] status in
            self?.updateStatus(status)
        }
    }

    // MARK: - Status Updates
    private func updateStatus(_ status: NetworkMonitor.ConnectionStatus) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            self.currentStatus = self.convertStatus(status)
            self.updateIcon()
            self.updateMenu()
        }
    }

    private func convertStatus(_ status: NetworkMonitor.ConnectionStatus) -> ConnectionStatus {
        switch status {
        case .connected:
            return .connected
        case .unstable:
            return .unstable
        case .disconnected:
            return .disconnected
        }
    }

    private func updateIcon() {
        guard let button = statusItem?.button else { return }

        let icon: NSImage?
        switch currentStatus {
        case .connected:
            icon = connectedIcon
        case .unstable:
            icon = unstableIcon
        case .disconnected:
            icon = disconnectedIcon
        case .unknown:
            icon = disconnectedIcon
        }

        button.image = icon
        button.image?.size = NSSize(width: iconSize, height: iconSize)
    }

    private func updateMenu() {
        guard let menu = statusItem?.menu else { return }

        menu.removeAllItems()

        // Заголовок приложения
        let titleItem = NSMenuItem(title: "🌐 Internet Monitor v1.0", action: nil, keyEquivalent: "")
        titleItem.isEnabled = false
        menu.addItem(titleItem)

        menu.addItem(NSMenuItem.separator())

        // Статус соединения
        let statusText = getStatusText()
        let statusItem = NSMenuItem(title: statusText, action: nil, keyEquivalent: "")
        statusItem.isEnabled = false
        menu.addItem(statusItem)

        // Метрики сети
        if let metrics = networkMonitor.getCurrentMetrics() {
            let latencyItem = NSMenuItem(title: "Latency: \(metrics.latency)ms", action: nil, keyEquivalent: "")
            latencyItem.isEnabled = false
            menu.addItem(latencyItem)

            let packetLossItem = NSMenuItem(title: "Packet Loss: \(metrics.packetLoss)%", action: nil, keyEquivalent: "")
            packetLossItem.isEnabled = false
            menu.addItem(packetLossItem)
        }

        menu.addItem(NSMenuItem.separator())

        // Действия
        let refreshItem = NSMenuItem(title: "📊 Обновить сейчас", action: #selector(refreshStatus), keyEquivalent: "r")
        refreshItem.target = self
        menu.addItem(refreshItem)

        let preferencesItem = NSMenuItem(title: "⚙️ Настройки...", action: #selector(openPreferences), keyEquivalent: ",")
        preferencesItem.target = self
        menu.addItem(preferencesItem)

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(title: "❌ Выйти", action: #selector(quitApplication), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
    }

    private func getStatusText() -> String {
        switch currentStatus {
        case .connected:
            return "Статус: 🟢 Подключено"
        case .unstable:
            return "Статус: 🟡 Нестабильно"
        case .disconnected:
            return "Статус: 🔴 Отключено"
        case .unknown:
            return "Статус: Неизвестно"
        }
    }

    // MARK: - Actions
    @objc private func statusItemClicked() {
        statusItem?.button?.performClick(nil)
    }

    @objc private func refreshStatus() {
        networkMonitor.refreshStatus()
    }

    @objc private func openPreferences() {
        // Получаем AppDelegate и открываем настройки
        if let appDelegate = NSApp.delegate as? AppDelegate {
            appDelegate.showPreferences()
        }
    }

    @objc private func quitApplication() {
        NSApp.terminate(nil)
    }

    // MARK: - Cleanup
    private func removeStatusBarItem() {
        if let statusItem = statusItem {
            NSStatusBar.system.removeStatusItem(statusItem)
        }
        statusItem = nil
    }
}

// MARK: - NSMenuDelegate
extension StatusBarController: NSMenuDelegate {
    func menuWillOpen(_ menu: NSMenu) {
        // Обновляем меню перед открытием
        updateMenu()
    }
}
