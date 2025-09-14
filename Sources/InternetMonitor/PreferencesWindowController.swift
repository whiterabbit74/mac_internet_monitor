//
//  PreferencesWindowController.swift
//  InternetMonitor
//
//  Created by Internet Monitor App
//  Copyright © 2024. All rights reserved.
//

import AppKit

class PreferencesWindowController: NSWindowController {

    // MARK: - Properties
    private var preferencesViewController: PreferencesViewController?

    // MARK: - Initialization
    init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 540, height: 620),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )

        super.init(window: window)

        setupViewController()
        setupWindow()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    private func setupWindow() {
        guard let window = window else { return }

        window.title = "Internet Monitor Settings"

        // Устанавливаем размер окна
        let contentSize = NSSize(width: 540, height: 620)
        window.setContentSize(contentSize)
        window.center()
        window.setFrameAutosaveName("PreferencesWindow")

        // Современные настройки окна
        window.styleMask.insert(.fullSizeContentView)
        window.titlebarAppearsTransparent = true
        window.isMovableByWindowBackground = true
        window.backgroundColor = NSColor.windowBackgroundColor

        // Эффект вибранции настроится в setupViewController
    }

    private func setupViewController() {
        preferencesViewController = PreferencesViewController()

        // Создаем визуальный эффект как базовый view
        let visualEffect = NSVisualEffectView()
        visualEffect.blendingMode = .behindWindow
        visualEffect.material = .windowBackground
        visualEffect.state = .active

        // Устанавливаем controller в качестве содержимого
        preferencesViewController?.view.wantsLayer = true
        preferencesViewController?.view.layer?.backgroundColor = NSColor.clear.cgColor

        // Добавляем controller view к visual effect view
        visualEffect.addSubview(preferencesViewController!.view)
        preferencesViewController!.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            preferencesViewController!.view.topAnchor.constraint(equalTo: visualEffect.topAnchor),
            preferencesViewController!.view.bottomAnchor.constraint(equalTo: visualEffect.bottomAnchor),
            preferencesViewController!.view.leadingAnchor.constraint(equalTo: visualEffect.leadingAnchor),
            preferencesViewController!.view.trailingAnchor.constraint(equalTo: visualEffect.trailingAnchor)
        ])

        window?.contentView = visualEffect
    }

    // MARK: - Public Methods
    override func showWindow(_ sender: Any?) {
        super.showWindow(sender)

        // Приводим окно на передний план
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

// MARK: - PreferencesViewController
class PreferencesViewController: NSViewController {

    // MARK: - UI Elements
    private let endpointLabel = NSTextField(labelWithString: "Endpoint:")
    private let endpointPopup = NSPopUpButton(frame: NSRect(x: 0, y: 0, width: 150, height: 24), pullsDown: false)
    private let customEndpointLabel = NSTextField(labelWithString: "Custom endpoint:")
    private let customEndpointTextField = NSTextField(string: "")

    private let intervalLabel = NSTextField(labelWithString: "Check interval (seconds):")
    private let intervalTextField = NSTextField(string: "5")

    private let notificationsCheckbox = NSButton(checkboxWithTitle: "Enable notifications", target: nil, action: nil)
    private let disconnectNotificationCheckbox = NSButton(checkboxWithTitle: "Show disconnect notifications", target: nil, action: nil)
    private let tooltipCheckbox = NSButton(checkboxWithTitle: "Show tooltips", target: nil, action: nil)
    private let autoStartCheckbox = NSButton(checkboxWithTitle: "Launch at login", target: nil, action: nil)
    private let showInDockCheckbox = NSButton(checkboxWithTitle: "Show in Dock", target: nil, action: nil)

    private let opacityLabel = NSTextField(labelWithString: "Icon opacity:")
    private let opacitySlider = NSSlider(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
    private let opacityValueLabel = NSTextField(labelWithString: "50%")

    private let sizeLabel = NSTextField(labelWithString: "Icon size:")
    private let sizeSlider = NSSlider(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
    private let sizeValueLabel = NSTextField(labelWithString: "18px")

    private let saveButton = NSButton(title: "Save", target: nil, action: #selector(savePreferences))
    private let cancelButton = NSButton(title: "Cancel", target: nil, action: #selector(cancelPreferences))

    // MARK: - View Lifecycle
    override func loadView() {
        let view = NSView(frame: NSRect(x: 0, y: 0, width: 540, height: 620))
        view.wantsLayer = true
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadCurrentPreferences()
        setupThemeObserver()
    }

    private func setupThemeObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(systemAppearanceChanged),
            name: NSNotification.Name(rawValue: "AppleInterfaceThemeChangedNotification"),
            object: nil
        )
    }

    // MARK: - Setup
    private func setupUI() {
        // Настраиваем общий вид с поддержкой тем
        setupViewAppearance()

        // Настраиваем шрифты лейблов
        setupLabels()

        // Настраиваем поля ввода
        setupTextFields()

        // Настраиваем popup button
        setupEndpointPopup()

        // Настраиваем чекбоксы
        setupCheckboxes()

        // Настраиваем слайдер прозрачности
        setupOpacitySlider()

        // Настраиваем слайдер размера иконки
        setupSizeSlider()

        // Настраиваем кнопки
        setupButtons()

        // Создаем layout
        createLayout()
    }

    private func setupViewAppearance() {
        // Простой системный фон
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.controlBackgroundColor.cgColor
    }

    private func setupLabels() {
        // Системные шрифты для всех лейблов
        let labels = [endpointLabel, customEndpointLabel, intervalLabel,
                      opacityLabel, sizeLabel, opacityValueLabel, sizeValueLabel]

        labels.forEach { label in
            label.font = NSFont.systemFont(ofSize: NSFont.systemFontSize)
            label.textColor = NSColor.labelColor
        }

        // Меньшие лейблы для значений
        opacityValueLabel.font = NSFont.systemFont(ofSize: NSFont.smallSystemFontSize)
        opacityValueLabel.textColor = NSColor.secondaryLabelColor
        sizeValueLabel.font = NSFont.systemFont(ofSize: NSFont.smallSystemFontSize)
        sizeValueLabel.textColor = NSColor.secondaryLabelColor

        // Системные шрифты для чекбоксов
        let checkboxes = [notificationsCheckbox, disconnectNotificationCheckbox,
                         tooltipCheckbox, autoStartCheckbox, showInDockCheckbox]
        checkboxes.forEach { checkbox in
            checkbox.font = NSFont.systemFont(ofSize: NSFont.systemFontSize)
        }
    }


    private func setupTextFields() {
        customEndpointTextField.placeholderString = "e.g., google.com or 8.8.8.8"
        intervalTextField.placeholderString = "5"

        // Ограничиваем ввод только числами для интервала
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimum = 1
        formatter.maximum = 60
        intervalTextField.formatter = formatter

        // Системные стили для текстовых полей
        [customEndpointTextField, intervalTextField].forEach { field in
            field.font = NSFont.systemFont(ofSize: NSFont.systemFontSize)
            field.textColor = NSColor.controlTextColor
        }
    }

    private func setupEndpointPopup() {
        // Популярные endpoints
        endpointPopup.addItem(withTitle: "8.8.8.8 (Google DNS)")
        endpointPopup.addItem(withTitle: "apple.com (Apple)")
        endpointPopup.addItem(withTitle: "1.1.1.1 (Cloudflare)")
        endpointPopup.addItem(withTitle: "yandex.ru (Yandex)")
        endpointPopup.addItem(withTitle: "Custom endpoint...")

        // Системный стиль для popup button
        endpointPopup.font = NSFont.systemFont(ofSize: NSFont.systemFontSize)
        endpointPopup.bezelStyle = .rounded

        // Лёгкая тень
        endpointPopup.layer?.shadowColor = NSColor.black.withAlphaComponent(0.1).cgColor
        endpointPopup.layer?.shadowOffset = NSSize(width: 0, height: 1)
        endpointPopup.layer?.shadowRadius = 2
        endpointPopup.layer?.shadowOpacity = 1

        endpointPopup.target = self
        endpointPopup.action = #selector(endpointPopupChanged)
    }

    private func setupOpacitySlider() {
        // Настраиваем слайдер (0.0 - 1.0)
        opacitySlider.minValue = 0.1  // Минимальная прозрачность 10%
        opacitySlider.maxValue = 1.0  // Максимальная прозрачность 100%
        opacitySlider.floatValue = 0.5  // По умолчанию 50%

        // Стиль слайдера с поддержкой тем
        opacitySlider.wantsLayer = true
        opacitySlider.layer?.cornerRadius = 3

        opacitySlider.target = self
        opacitySlider.action = #selector(opacitySliderChanged)

        // Настраиваем лейбл значения с поддержкой тем
        opacityValueLabel.alignment = .center
        opacityValueLabel.font = NSFont.systemFont(ofSize: 11)
        opacityValueLabel.textColor = NSColor.secondaryLabelColor
    }

    private func setupSizeSlider() {
        // Настраиваем слайдер (12.0 - 24.0 px)
        sizeSlider.minValue = 12.0  // Минимальный размер 12px
        sizeSlider.maxValue = 24.0  // Максимальный размер 24px
        sizeSlider.floatValue = 18.0  // По умолчанию 18px

        // Стиль слайдера с поддержкой тем
        sizeSlider.wantsLayer = true
        sizeSlider.layer?.cornerRadius = 3

        sizeSlider.target = self
        sizeSlider.action = #selector(sizeSliderChanged)

        // Настраиваем лейбл значения с поддержкой тем
        sizeValueLabel.alignment = .center
        sizeValueLabel.font = NSFont.systemFont(ofSize: 11)
        sizeValueLabel.textColor = NSColor.secondaryLabelColor
    }

    private func setupCheckboxes() {
        // Стиль чекбоксов с поддержкой тем
        [notificationsCheckbox, disconnectNotificationCheckbox, tooltipCheckbox, autoStartCheckbox, showInDockCheckbox].forEach { checkbox in
            checkbox.font = NSFont.systemFont(ofSize: 13)
            checkbox.setButtonType(.switch)
        }

        notificationsCheckbox.state = .on
        tooltipCheckbox.state = .on
        disconnectNotificationCheckbox.state = .on
        showInDockCheckbox.state = .off // По умолчанию выключена

        // Добавляем обработчик для чекбокса дока
        showInDockCheckbox.target = self
        showInDockCheckbox.action = #selector(showInDockChanged)
    }

    private func setupButtons() {
        saveButton.target = self
        cancelButton.target = self

        // Современный стиль для кнопок
        setupButton(saveButton, isPrimary: true)
        setupButton(cancelButton, isPrimary: false)

        // Клавиатурные сокращения
        saveButton.keyEquivalent = "\r"  // Enter для сохранения
        saveButton.keyEquivalentModifierMask = []
        cancelButton.keyEquivalent = "\u{1B}"  // Escape для отмены
    }

    private func setupButton(_ button: NSButton, isPrimary: Bool) {
        button.bezelStyle = .rounded
        button.font = NSFont.systemFont(ofSize: NSFont.systemFontSize)

        if isPrimary {
            button.hasDestructiveAction = false
        }
    }

    // MARK: - Theme Support
    @objc private func systemAppearanceChanged() {
        // Обновляем фон для соответствия системной теме
        view.layer?.backgroundColor = NSColor.controlBackgroundColor.cgColor
    }

    // MARK: - Animation and Visual Feedback
    private func animateSaveAction(completion: @escaping () -> Void) {
        // Меняем текст кнопки на "Сохраняем..."
        let originalTitle = saveButton.title
        saveButton.title = "Saving..."
        saveButton.isEnabled = false

        // Пульсирующая анимация
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.15
            context.allowsImplicitAnimation = true
            self.saveButton.layer?.transform = CATransform3DMakeScale(0.95, 0.95, 1.0)
        }) {
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.15
                context.allowsImplicitAnimation = true
                self.saveButton.layer?.transform = CATransform3DIdentity
            }) {
                // Выполняем сохранение
                completion()

                // Возвращаем кнопку в обычное состояние
                self.saveButton.title = originalTitle
                self.saveButton.isEnabled = true
            }
        }
    }

    private func provideLivePreview() {
        // Мгновенное обновление статус-бара для показа изменений
        // Посылаем уведомление о смене настроек
        NotificationCenter.default.post(name: UserDefaults.didChangeNotification, object: nil)
    }

    deinit {
        // Удаляем наблюдатели для предотвращения утечек памяти
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "AppleInterfaceThemeChangedNotification"), object: nil)
    }

    private func createLayout() {
        // Добавляем элементы в view
        view.addSubview(endpointLabel)
        view.addSubview(endpointPopup)
        view.addSubview(customEndpointLabel)
        view.addSubview(customEndpointTextField)
        view.addSubview(intervalLabel)
        view.addSubview(intervalTextField)
        view.addSubview(notificationsCheckbox)
        view.addSubview(disconnectNotificationCheckbox)
        view.addSubview(tooltipCheckbox)
        view.addSubview(autoStartCheckbox)
        view.addSubview(showInDockCheckbox)
        view.addSubview(opacityLabel)
        view.addSubview(opacitySlider)
        view.addSubview(opacityValueLabel)
        view.addSubview(sizeLabel)
        view.addSubview(sizeSlider)
        view.addSubview(sizeValueLabel)
        view.addSubview(saveButton)
        view.addSubview(cancelButton)

        // Настраиваем layout
        setupConstraints()
    }

    private func setupConstraints() {
        let margin: CGFloat = 30
        let sectionSpacing: CGFloat = 25
        let fieldHeight: CGFloat = 24

        // Устанавливаем translatesAutoresizingMaskIntoConstraints = false для всех элементов
        [endpointLabel, endpointPopup, customEndpointLabel, customEndpointTextField,
         intervalLabel, intervalTextField, notificationsCheckbox, disconnectNotificationCheckbox, tooltipCheckbox,
         autoStartCheckbox, showInDockCheckbox, opacityLabel, opacitySlider, opacityValueLabel,
         sizeLabel, sizeSlider, sizeValueLabel,
         saveButton, cancelButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        // Endpoint selection
        NSLayoutConstraint.activate([
            endpointLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: margin + 10), // Добавляем верхний отступ
            endpointLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),

            endpointPopup.topAnchor.constraint(equalTo: endpointLabel.topAnchor),
            endpointPopup.leadingAnchor.constraint(equalTo: endpointLabel.trailingAnchor, constant: 12),
            endpointPopup.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),
            endpointPopup.heightAnchor.constraint(equalToConstant: fieldHeight)
        ])

        // Custom endpoint
        NSLayoutConstraint.activate([
            customEndpointLabel.topAnchor.constraint(equalTo: endpointPopup.bottomAnchor, constant: sectionSpacing),
            customEndpointLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),

            customEndpointTextField.topAnchor.constraint(equalTo: customEndpointLabel.topAnchor),
            customEndpointTextField.leadingAnchor.constraint(equalTo: customEndpointLabel.trailingAnchor, constant: 12),
            customEndpointTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),
            customEndpointTextField.heightAnchor.constraint(equalToConstant: fieldHeight)
        ])

        // Interval
        NSLayoutConstraint.activate([
            intervalLabel.topAnchor.constraint(equalTo: customEndpointTextField.bottomAnchor, constant: sectionSpacing),
            intervalLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),

            intervalTextField.topAnchor.constraint(equalTo: intervalLabel.topAnchor),
            intervalTextField.leadingAnchor.constraint(equalTo: intervalLabel.trailingAnchor, constant: 12),
            intervalTextField.widthAnchor.constraint(equalToConstant: 70),
            intervalTextField.heightAnchor.constraint(equalToConstant: fieldHeight)
        ])

        // Checkboxes
        NSLayoutConstraint.activate([
            notificationsCheckbox.topAnchor.constraint(equalTo: intervalTextField.bottomAnchor, constant: sectionSpacing + 5),
            notificationsCheckbox.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),

            disconnectNotificationCheckbox.topAnchor.constraint(equalTo: notificationsCheckbox.bottomAnchor, constant: 12),
            disconnectNotificationCheckbox.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin + 20), // Небольшой отступ для подчеркивания иерархии

            tooltipCheckbox.topAnchor.constraint(equalTo: disconnectNotificationCheckbox.bottomAnchor, constant: 15),
            tooltipCheckbox.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),

            autoStartCheckbox.topAnchor.constraint(equalTo: tooltipCheckbox.bottomAnchor, constant: 15),
            autoStartCheckbox.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),

            showInDockCheckbox.topAnchor.constraint(equalTo: autoStartCheckbox.bottomAnchor, constant: 15),
            showInDockCheckbox.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin)
        ])

        // Opacity slider
        NSLayoutConstraint.activate([
            opacityLabel.topAnchor.constraint(equalTo: showInDockCheckbox.bottomAnchor, constant: sectionSpacing + 5),
            opacityLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),

            opacitySlider.topAnchor.constraint(equalTo: opacityLabel.bottomAnchor, constant: 10),
            opacitySlider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
            opacitySlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),
            opacitySlider.heightAnchor.constraint(equalToConstant: fieldHeight),

            opacityValueLabel.topAnchor.constraint(equalTo: opacitySlider.bottomAnchor, constant: 6),
            opacityValueLabel.centerXAnchor.constraint(equalTo: opacitySlider.centerXAnchor),
            opacityValueLabel.widthAnchor.constraint(equalToConstant: 45)
        ])

        // Size slider
        NSLayoutConstraint.activate([
            sizeLabel.topAnchor.constraint(equalTo: opacityValueLabel.bottomAnchor, constant: 15),
            sizeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),

            sizeSlider.topAnchor.constraint(equalTo: sizeLabel.bottomAnchor, constant: 10),
            sizeSlider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
            sizeSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),
            sizeSlider.heightAnchor.constraint(equalToConstant: fieldHeight),

            sizeValueLabel.topAnchor.constraint(equalTo: sizeSlider.bottomAnchor, constant: 6),
            sizeValueLabel.centerXAnchor.constraint(equalTo: sizeSlider.centerXAnchor),
            sizeValueLabel.widthAnchor.constraint(equalToConstant: 50)
        ])

        // Buttons
        NSLayoutConstraint.activate([
            saveButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -margin - 5), // Добавляем нижний отступ
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),

            cancelButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -margin - 5),
            cancelButton.trailingAnchor.constraint(equalTo: saveButton.leadingAnchor, constant: -12)
        ])
    }

    // MARK: - Actions
    @objc private func endpointPopupChanged() {
        let selectedIndex = endpointPopup.indexOfSelectedItem
        if selectedIndex == 4 { // "Свой вариант..."
            customEndpointTextField.isEnabled = true
            customEndpointTextField.becomeFirstResponder()
        } else {
            customEndpointTextField.isEnabled = false
            customEndpointTextField.stringValue = ""
        }
    }

    @objc private func showInDockChanged() {
        let showInDock = showInDockCheckbox.state == .on
        UserDefaults.standard.set(showInDock, forKey: "showInDock")
        UserDefaults.standard.synchronize()

        // Мгновенно применяем изменения
        if showInDock {
            NSApp.setActivationPolicy(.regular)
        } else {
            NSApp.setActivationPolicy(.accessory)
        }
    }

    @objc private func opacitySliderChanged() {
        let opacityValue = opacitySlider.floatValue
        let percentage = Int(opacityValue * 100)
        opacityValueLabel.stringValue = "\(percentage)%"

        // Мгновенное применение с визуальной обратной связью
        UserDefaults.standard.set(opacityValue, forKey: "iconOpacity")
        UserDefaults.standard.synchronize()
        provideLivePreview()
    }

    @objc private func sizeSliderChanged() {
        let sizeValue = sizeSlider.floatValue
        let sizeInt = Int(sizeValue)
        sizeValueLabel.stringValue = "\(sizeInt)px"

        // Мгновенное применение с визуальной обратной связью
        UserDefaults.standard.set(sizeValue, forKey: "iconSize")
        UserDefaults.standard.synchronize()
        provideLivePreview()
    }

    // MARK: - Preferences Management
    private func loadCurrentPreferences() {
        let defaults = UserDefaults.standard

        // Загружаем выбранный endpoint
        let selectedEndpointIndex = defaults.integer(forKey: "selectedEndpointIndex")
        endpointPopup.selectItem(at: selectedEndpointIndex)

        // Загружаем пользовательский endpoint
        customEndpointTextField.stringValue = defaults.string(forKey: "customEndpoint") ?? ""
        customEndpointTextField.isEnabled = (selectedEndpointIndex == 4)

        // Загружаем остальные настройки
        intervalTextField.stringValue = String(defaults.integer(forKey: "checkInterval") != 0 ? defaults.integer(forKey: "checkInterval") : 5)
        notificationsCheckbox.state = defaults.bool(forKey: "notificationsEnabled") ? .on : .off
        // Если настройка не задана явно, включаем по умолчанию
        disconnectNotificationCheckbox.state = defaults.object(forKey: "disconnectNotificationEnabled") == nil ? .on : (defaults.bool(forKey: "disconnectNotificationEnabled") ? .on : .off)
        tooltipCheckbox.state = defaults.bool(forKey: "tooltipsEnabled") ? .on : .off
        autoStartCheckbox.state = defaults.bool(forKey: "autoStartEnabled") ? .on : .off
        showInDockCheckbox.state = defaults.bool(forKey: "showInDock") ? .on : .off

        // Загружаем настройку прозрачности
        let iconOpacity = defaults.float(forKey: "iconOpacity")
        opacitySlider.floatValue = iconOpacity > 0 ? iconOpacity : 0.5  // По умолчанию 50%
        opacitySliderChanged()  // Обновляем лейбл

        // Загружаем настройку размера иконки
        let iconSize = defaults.float(forKey: "iconSize")
        sizeSlider.floatValue = iconSize > 0 ? iconSize : 18.0  // По умолчанию 18px
        sizeSliderChanged()  // Обновляем лейбл
    }

    @objc private func savePreferences() {
        // Показываем анимацию сохранения
        animateSaveAction {
            let defaults = UserDefaults.standard

            // Сохраняем выбранный endpoint
            let selectedIndex = self.endpointPopup.indexOfSelectedItem
            defaults.set(selectedIndex, forKey: "selectedEndpointIndex")

            // Определяем endpoint на основе выбора
            var endpointToSave = "apple.com" // default
            if selectedIndex == 0 {
                endpointToSave = "8.8.8.8"
            } else if selectedIndex == 1 {
                endpointToSave = "apple.com"
            } else if selectedIndex == 2 {
                endpointToSave = "1.1.1.1"
            } else if selectedIndex == 3 {
                endpointToSave = "yandex.ru"
            } else if selectedIndex == 4 && !self.customEndpointTextField.stringValue.isEmpty {
                endpointToSave = self.customEndpointTextField.stringValue
            }

            defaults.set(endpointToSave, forKey: "endpoint")
            defaults.set(self.customEndpointTextField.stringValue, forKey: "customEndpoint")
            defaults.set(Int(self.intervalTextField.stringValue) ?? 5, forKey: "checkInterval")
            defaults.set(self.notificationsCheckbox.state == .on, forKey: "notificationsEnabled")
            defaults.set(self.disconnectNotificationCheckbox.state == .on, forKey: "disconnectNotificationEnabled")
            defaults.set(self.tooltipCheckbox.state == .on, forKey: "tooltipsEnabled")
            defaults.set(self.autoStartCheckbox.state == .on, forKey: "autoStartEnabled")
            defaults.set(self.showInDockCheckbox.state == .on, forKey: "showInDock")
            defaults.set(self.opacitySlider.floatValue, forKey: "iconOpacity")
            defaults.set(self.sizeSlider.floatValue, forKey: "iconSize")

            defaults.synchronize()

            // Обрабатываем автозапуск
            self.handleAutoStart(self.autoStartCheckbox.state == .on)

            // Обрабатываем отображение в доке
            let showInDock = self.showInDockCheckbox.state == .on
            if showInDock {
                NSApp.setActivationPolicy(.regular)
            } else {
                NSApp.setActivationPolicy(.accessory)
            }

            // Закрываем окно с анимацией
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.view.window?.close()
            }
        }
    }

    @objc private func cancelPreferences() {
        // Плавное закрытие окна
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.2
            context.allowsImplicitAnimation = true
            self.view.alphaValue = 0.0
        }) {
            self.view.window?.close()
            self.view.alphaValue = 1.0 // Восстанавливаем для следующего открытия
        }
    }

    // MARK: - Auto Start Management
    private func handleAutoStart(_ enable: Bool) {
        if enable {
            enableAutoStart()
        } else {
            disableAutoStart()
        }
    }

    private func enableAutoStart() {
        let appPath = Bundle.main.bundlePath
        let script = """
        tell application "System Events"
            make new login item with properties {path:"\(appPath)", hidden:false}
        end tell
        """

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
        process.arguments = ["-e", script]

        do {
            try process.run()
            print("✅ Auto-start enabled")
        } catch {
            print("❌ Error enabling auto-start: \(error.localizedDescription)")
        }
    }

    private func disableAutoStart() {
        let appName = Bundle.main.bundleURL.deletingPathExtension().lastPathComponent
        let script = """
        tell application "System Events"
            delete (every login item whose name is "\(appName)")
        end tell
        """

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
        process.arguments = ["-e", script]

        do {
            try process.run()
            print("✅ Auto-start disabled")
        } catch {
            print("❌ Error disabling auto-start: \(error.localizedDescription)")
        }
    }


}
