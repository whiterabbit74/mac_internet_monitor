//
//  StatusBarController.swift
//  InternetMonitor
//
//  Created by Internet Monitor App
//  Copyright © 2024. All rights reserved.
//

import AppKit
import UserNotifications

class StatusBarController: NSObject {

    // MARK: - Properties
    private var statusItem: NSStatusItem?
    private var networkMonitor: NetworkMonitor
    private var currentStatus: ConnectionStatus = .unknown

    // Настройки прозрачности и размера
    private(set) var iconOpacity: CGFloat = 0.5  // По умолчанию 50%
    private(set) var iconSize: CGFloat = 18.0     // По умолчанию 18px

    // Иконки для разных состояний (векторные)
    private lazy var connectedIcon = createVectorIcon(.connected)
    private lazy var unstableIcon = createVectorIcon(.unstable)
    private lazy var disconnectedIcon = createVectorIcon(.disconnected)

    // Функция для создания векторной иконки
    private func createVectorIcon(_ status: ConnectionStatus) -> NSImage {
        let image = NSImage(size: NSSize(width: iconSize, height: iconSize))

        image.lockFocus()

        // Получаем цвет в зависимости от темы и статуса
        let (fillColor, strokeColor) = getColorsForStatus(status)

        // Создаем контекст
        let context = NSGraphicsContext.current?.cgContext
        context?.saveGState()

        // Центрируем элемент
        let center = CGPoint(x: iconSize / 2, y: iconSize / 2)
        let radius = min(iconSize / 2 - 2, 9) // Максимальный радиус 9px

        // Рисуем кольцо с заливкой
        let outerPath = NSBezierPath(ovalIn: NSRect(
            x: center.x - radius,
            y: center.y - radius,
            width: radius * 2,
            height: radius * 2
        ))

        // Заливка
        fillColor.setFill()
        outerPath.fill()

        // Обводка для лучшего контраста
        strokeColor.setStroke()
        outerPath.lineWidth = 1.0
        outerPath.stroke()

        // Добавляем индикатор подключения для connected статуса
        if status == .connected {
            let innerRadius = radius * 0.4
            let innerPath = NSBezierPath(ovalIn: NSRect(
                x: center.x - innerRadius,
                y: center.y - innerRadius,
                width: innerRadius * 2,
                height: innerRadius * 2
            ))

            NSColor.white.withAlphaComponent(0.8).setFill()
            innerPath.fill()
        }

        // Добавляем предупреждающий символ для unstable статуса
        if status == .unstable {
            drawWarningSymbol(in: center, radius: radius * 0.6)
        }

        // Добавляем крестик для disconnected статуса
        if status == .disconnected {
            drawCrossSymbol(in: center, radius: radius * 0.5)
        }

        context?.restoreGState()
        image.unlockFocus()

        // Применяем прозрачность
        return applyOpacity(to: image, opacity: iconOpacity)
    }

    // Получение цветов для статуса с учетом темы
    private func getColorsForStatus(_ status: ConnectionStatus) -> (fill: NSColor, stroke: NSColor) {
        let isDarkMode = NSApp.effectiveAppearance.name == .darkAqua

        switch status {
        case .connected:
            if isDarkMode {
                return (NSColor.systemGreen.withAlphaComponent(0.9), NSColor.systemGreen.withAlphaComponent(0.6))
            } else {
                return (NSColor.systemGreen, NSColor.systemGreen.withAlphaComponent(0.8))
            }
        case .unstable:
            if isDarkMode {
                return (NSColor.systemYellow.withAlphaComponent(0.9), NSColor.systemYellow.withAlphaComponent(0.6))
            } else {
                return (NSColor.systemOrange, NSColor.systemOrange.withAlphaComponent(0.8))
            }
        case .disconnected:
            if isDarkMode {
                return (NSColor.systemRed.withAlphaComponent(0.9), NSColor.systemRed.withAlphaComponent(0.6))
            } else {
                return (NSColor.systemRed, NSColor.systemRed.withAlphaComponent(0.8))
            }
        case .unknown:
            if isDarkMode {
                return (NSColor.systemGray.withAlphaComponent(0.9), NSColor.systemGray.withAlphaComponent(0.6))
            } else {
                return (NSColor.systemGray, NSColor.systemGray.withAlphaComponent(0.8))
            }
        }
    }

    // Рисование предупреждающего символа
    private func drawWarningSymbol(in center: CGPoint, radius: CGFloat) {
        let path = NSBezierPath()
        let height = radius * 1.4
        let width = height * 0.866 // √3/2 для равностороннего треугольника

        // Треугольник
        path.move(to: CGPoint(x: center.x, y: center.y + height/2))
        path.line(to: CGPoint(x: center.x - width/2, y: center.y - height/2))
        path.line(to: CGPoint(x: center.x + width/2, y: center.y - height/2))
        path.close()

        NSColor.white.withAlphaComponent(0.9).setFill()
        path.fill()

        // Восклицательный знак
        let exclamationPath = NSBezierPath()
        exclamationPath.move(to: CGPoint(x: center.x, y: center.y + height/4))
        exclamationPath.line(to: CGPoint(x: center.x, y: center.y - height/8))
        exclamationPath.lineWidth = 1.5
        NSColor.black.setStroke()
        exclamationPath.stroke()

        // Точка
        let dotPath = NSBezierPath(ovalIn: NSRect(
            x: center.x - 0.8,
            y: center.y - height/3,
            width: 1.6,
            height: 1.6
        ))
        NSColor.black.setFill()
        dotPath.fill()
    }

    // Рисование крестика
    private func drawCrossSymbol(in center: CGPoint, radius: CGFloat) {
        let path = NSBezierPath()

        // Первая линия крестика
        path.move(to: CGPoint(x: center.x - radius, y: center.y - radius))
        path.line(to: CGPoint(x: center.x + radius, y: center.y + radius))

        // Вторая линия крестика
        path.move(to: CGPoint(x: center.x - radius, y: center.y + radius))
        path.line(to: CGPoint(x: center.x + radius, y: center.y - radius))

        path.lineWidth = 2.0
        NSColor.white.withAlphaComponent(0.9).setStroke()
        path.stroke()
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
        connectedIcon = createVectorIcon(.connected)
        unstableIcon = createVectorIcon(.unstable)
        disconnectedIcon = createVectorIcon(.disconnected)

        // Обновляем текущую иконку с анимацией
        updateIconWithAnimation()
    }

    // Обновление размера всех иконок
    func updateIconSize() {
        loadIconSizeSettings()
        // Пересоздаем иконки с новым размером и учетом темы
        connectedIcon = createVectorIcon(.connected)
        unstableIcon = createVectorIcon(.unstable)
        disconnectedIcon = createVectorIcon(.disconnected)

        // Обновляем текущую иконку с анимацией
        updateIconWithAnimation()
    }

    // Обновление иконок при изменении темы
    func updateIconsForThemeChange() {
        // Пересоздаем иконки с учетом новой темы
        connectedIcon = createVectorIcon(.connected)
        unstableIcon = createVectorIcon(.unstable)
        disconnectedIcon = createVectorIcon(.disconnected)

        // Обновляем текущую иконку с плавной анимацией
        updateIconWithAnimation()
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
        requestNotificationPermission()
        setupNotificationDelegate()
    }

    // Запрос разрешения на уведомления
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, error in
            if let error = error {
                print("❌ Ошибка запроса разрешений уведомлений: \(error.localizedDescription)")
            } else if granted {
                print("✅ Разрешения на уведомления получены")
            } else {
                print("⚠️ Пользователь отклонил разрешения на уведомления")
            }
        }
    }

    // Настройка делегата для обработки действий уведомлений
    private func setupNotificationDelegate() {
        UNUserNotificationCenter.current().delegate = self
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

            let newStatus = self.convertStatus(status)

            // Обновляем с анимацией только при изменении статуса
            if newStatus != self.currentStatus {
                self.currentStatus = newStatus
                self.updateIconWithAnimation()
                self.showStatusChangeNotification()
            } else {
                // Просто обновляем иконку без анимации (новые метрики)
                self.updateIcon()
            }

            self.updateMenu()
        }
    }

    // Показ уведомления об изменении статуса
    private func showStatusChangeNotification() {
        // Показываем уведомление о отключении только если это разрешено
        if currentStatus == .disconnected {
            let disconnectNotificationsEnabled = UserDefaults.standard.object(forKey: "disconnectNotificationEnabled") == nil ? true : UserDefaults.standard.bool(forKey: "disconnectNotificationEnabled")

            if disconnectNotificationsEnabled {
                showDisconnectionNotification()
            }
        }

        // Показываем общие уведомления о смене статуса (если разрешено)
        if UserDefaults.standard.bool(forKey: "notificationsEnabled") && currentStatus != .disconnected {
            showGeneralStatusNotification()
        }
    }

    private func showGeneralStatusNotification() {
        let content = UNMutableNotificationContent()
        content.title = "🌐 Internet Monitor"

        let statusText = getStatusText().replacingOccurrences(of: "Статус: ", with: "")
        content.body = statusText
        content.sound = nil // Бесшумное уведомление для обычных смен статуса

        let request = UNNotificationRequest(
            identifier: "status-change",
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Ошибка отправки уведомления: \(error.localizedDescription)")
            }
        }
    }

    private func showDisconnectionNotification() {
        let content = UNMutableNotificationContent()
        content.title = "🔴 Internet Monitor"
        content.body = "Интернет-соединение прервано"
        content.sound = .default

        // Добавляем действие для быстрого обновления
        let refreshAction = UNNotificationAction(
            identifier: "REFRESH_ACTION",
            title: "Обновить",
            options: []
        )

        let category = UNNotificationCategory(
            identifier: "INTERNET_STATUS",
            actions: [refreshAction],
            intentIdentifiers: [],
            options: []
        )

        UNUserNotificationCenter.current().setNotificationCategories([category])
        content.categoryIdentifier = "INTERNET_STATUS"

        let request = UNNotificationRequest(
            identifier: "internet-disconnected",
            content: content,
            trigger: nil // Показать немедленно
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Ошибка отправки уведомления: \(error.localizedDescription)")
            } else {
                print("✅ Уведомление о отключении отправлено")
            }
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

        // Добавляем tooltip только если включена соответствующая настройка
        if UserDefaults.standard.bool(forKey: "tooltipsEnabled") {
            button.toolTip = getTooltipText()
        } else {
            button.toolTip = nil
        }
    }

    // Анимированное обновление иконки
    private func updateIconWithAnimation() {
        guard let button = statusItem?.button else { return }

        // Плавная анимация смены иконки
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.3
            context.allowsImplicitAnimation = true
            button.alphaValue = 0.5
        }) {
            self.updateIcon()
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.3
                context.allowsImplicitAnimation = true
                button.alphaValue = 1.0
            })
        }
    }

    // Получение текста для tooltip
    private func getTooltipText() -> String {
        let statusText = getStatusText().replacingOccurrences(of: "Статус: ", with: "")

        if let metrics = networkMonitor.getCurrentMetrics() {
            return "\(statusText)\nLatency: \(metrics.latency)ms\nPacket Loss: \(metrics.packetLoss)%"
        }

        return statusText
    }

    private func updateMenu() {
        guard let menu = statusItem?.menu else { return }

        menu.removeAllItems()

        // Заголовок приложения с версией
        let titleItem = NSMenuItem(title: "🌐 Internet Monitor v1.0.3", action: nil, keyEquivalent: "")
        titleItem.isEnabled = false
        let titleFont = NSFont.systemFont(ofSize: 13, weight: .semibold)
        titleItem.attributedTitle = NSAttributedString(
            string: titleItem.title,
            attributes: [.font: titleFont, .foregroundColor: NSColor.labelColor]
        )
        menu.addItem(titleItem)

        menu.addItem(NSMenuItem.separator())

        // Статус соединения с цветом
        let statusText = getStatusText()
        let statusItem = NSMenuItem(title: statusText, action: nil, keyEquivalent: "")
        statusItem.isEnabled = false
        let statusColor = getStatusColor()
        let statusFont = NSFont.systemFont(ofSize: 13, weight: .medium)
        statusItem.attributedTitle = NSAttributedString(
            string: statusText,
            attributes: [.font: statusFont, .foregroundColor: statusColor]
        )
        menu.addItem(statusItem)

        // Метрики сети с форматированием
        if let metrics = networkMonitor.getCurrentMetrics() {
            let latencyText = metrics.latency >= 0 ? "\(metrics.latency)ms" : "N/A"
            let latencyColor = getLatencyColor(metrics.latency)
            let latencyItem = NSMenuItem(title: "⏱️ Latency: \(latencyText)", action: nil, keyEquivalent: "")
            latencyItem.isEnabled = false
            latencyItem.attributedTitle = NSAttributedString(
                string: latencyItem.title,
                attributes: [.font: NSFont.monospacedDigitSystemFont(ofSize: 12, weight: .regular), .foregroundColor: latencyColor]
            )
            menu.addItem(latencyItem)

            let packetLossColor = getPacketLossColor(metrics.packetLoss)
            let packetLossItem = NSMenuItem(title: "📦 Packet Loss: \(metrics.packetLoss)%", action: nil, keyEquivalent: "")
            packetLossItem.isEnabled = false
            packetLossItem.attributedTitle = NSAttributedString(
                string: packetLossItem.title,
                attributes: [.font: NSFont.monospacedDigitSystemFont(ofSize: 12, weight: .regular), .foregroundColor: packetLossColor]
            )
            menu.addItem(packetLossItem)

            // Время последней проверки
            let formatter = DateFormatter()
            formatter.timeStyle = .medium
            let lastCheckItem = NSMenuItem(title: "🕰️ Last check: \(formatter.string(from: metrics.timestamp))", action: nil, keyEquivalent: "")
            lastCheckItem.isEnabled = false
            lastCheckItem.attributedTitle = NSAttributedString(
                string: lastCheckItem.title,
                attributes: [.font: NSFont.systemFont(ofSize: 11), .foregroundColor: NSColor.secondaryLabelColor]
            )
            menu.addItem(lastCheckItem)
        }

        menu.addItem(NSMenuItem.separator())

        // Действия с клавиатурными сокращениями
        let refreshItem = NSMenuItem(title: "🔄 Refresh Now", action: #selector(refreshStatus), keyEquivalent: "r")
        refreshItem.target = self
        menu.addItem(refreshItem)

        let preferencesItem = NSMenuItem(title: "⚙️ Preferences...", action: #selector(openPreferences), keyEquivalent: ",")
        preferencesItem.target = self
        menu.addItem(preferencesItem)

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(title: "❌ Quit Internet Monitor", action: #selector(quitApplication), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
    }

    // Получение цвета для статуса
    private func getStatusColor() -> NSColor {
        switch currentStatus {
        case .connected:
            return NSColor.systemGreen
        case .unstable:
            return NSColor.systemOrange
        case .disconnected, .unknown:
            return NSColor.systemRed
        }
    }

    // Получение цвета для latency
    private func getLatencyColor(_ latency: Int) -> NSColor {
        if latency < 0 { return NSColor.systemGray }
        if latency < 50 { return NSColor.systemGreen }
        if latency < 150 { return NSColor.systemOrange }
        return NSColor.systemRed
    }

    // Получение цвета для packet loss
    private func getPacketLossColor(_ packetLoss: Int) -> NSColor {
        if packetLoss == 0 { return NSColor.systemGreen }
        if packetLoss < 10 { return NSColor.systemYellow }
        if packetLoss < 30 { return NSColor.systemOrange }
        return NSColor.systemRed
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

// MARK: - UNUserNotificationCenterDelegate
extension StatusBarController: UNUserNotificationCenterDelegate {
    // Обработка нажатия на действие в уведомлении
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        switch response.actionIdentifier {
        case "REFRESH_ACTION":
            // Пользователь нажал "Обновить"
            networkMonitor.refreshStatus()
        case UNNotificationDefaultActionIdentifier:
            // Пользователь нажал на само уведомление
            break
        default:
            break
        }
        completionHandler()
    }

    // Показываем уведомления даже когда приложение активно
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        if #available(macOS 11.0, *) {
            completionHandler([.banner, .sound])
        } else {
            completionHandler([.alert, .sound])
        }
    }
}
