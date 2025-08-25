//
//  NetworkMonitor.swift
//  InternetMonitor
//
//  Created by Internet Monitor App
//  Copyright © 2024. All rights reserved.
//

import Foundation

class NetworkMonitor {

    // MARK: - Types
    enum ConnectionStatus {
        case connected
        case unstable
        case disconnected
    }

    struct NetworkMetrics {
        let latency: Int // milliseconds
        let packetLoss: Int // percentage 0-100
        let timestamp: Date
    }

    // MARK: - Properties
    private var monitoringTimer: Timer?
    private var currentMetrics: NetworkMetrics?
    private var currentStatus: ConnectionStatus = .disconnected

    // Настройки мониторинга
    private let defaultEndpoint = "apple.com" // Apple endpoint - должен быть доступен
    private let defaultTimeout: TimeInterval = 4.0 // 4 seconds
    private let defaultRetryCount = 1 // Меньше попыток для скорости
    private var monitoringInterval: TimeInterval = 3.0 // 3 seconds - будет обновляться из настроек

    // Пороги для определения статуса
    private let unstablePacketLossThreshold = 30 // %
    private let badLatencyThreshold = 500 // ms

    // Коллбэк для уведомления об изменении статуса
    var onStatusChange: ((ConnectionStatus) -> Void)?

    // MARK: - Initialization
    init() {
        setupDefaultSettings()
    }

    deinit {
        stopMonitoring()
    }

    // MARK: - Public Methods
    func startMonitoring() {
        stopMonitoring() // Останавливаем существующий таймер

        monitoringTimer = Timer.scheduledTimer(withTimeInterval: monitoringInterval,
                                             repeats: true) { [weak self] _ in
            self?.performNetworkCheck()
        }

        // Выполняем первую проверку сразу
        performNetworkCheck()
    }

    func stopMonitoring() {
        monitoringTimer?.invalidate()
        monitoringTimer = nil
    }

    func refreshStatus() {
        performNetworkCheck()
    }

    func restartMonitoring() {
        print("🔄 Restarting network monitoring with new settings...")

        // Останавливаем существующий мониторинг
        stopMonitoring()

        // Запускаем с новыми настройками
        startMonitoring()

        // Делаем немедленную проверку
        performNetworkCheck()
    }

    func getCurrentMetrics() -> NetworkMetrics? {
        return currentMetrics
    }

    func getCurrentStatus() -> ConnectionStatus {
        return currentStatus
    }

    // MARK: - Network Checking
    private func performNetworkCheck() {
        // Сначала пробуем HTTP запрос
        checkConnectivity { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let metrics):
                self.handleSuccessfulCheck(metrics)
            case .failure(_):
                print("🌐 HTTP check failed, trying ping...")
                // Если HTTP не работает, пробуем ping
                self.checkWithPing()
            }
        }
    }

    private func checkWithPing() {
        let endpoint = "8.8.8.8" // Google DNS для ping

        // Используем системный ping
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/sbin/ping")
        process.arguments = ["-c", "1", "-W", "2", endpoint]

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardInput = nil
        process.standardError = pipe

        do {
            try process.run()
            process.waitUntilExit()

            let status = process.terminationStatus
            if status == 0 {
                print("✅ Ping successful")
                let metrics = NetworkMetrics(latency: 50, packetLoss: 0, timestamp: Date())
                self.handleSuccessfulCheck(metrics)
            } else {
                print("❌ Ping failed")
                self.handleFailedCheck(NSError(domain: "NetworkMonitor", code: -1, userInfo: [NSLocalizedDescriptionKey: "Ping failed"]))
            }
        } catch {
            print("❌ Ping error: \(error.localizedDescription)")
            self.handleFailedCheck(error)
        }
    }

    private func checkConnectivity(completion: @escaping (Result<NetworkMetrics, Error>) -> Void) {
        let endpoint = getEndpoint()
        let url = URL(string: "https://\(endpoint)")!
        print("🌐 Checking connectivity to: \(url.absoluteString)")

        var request = URLRequest(url: url)
        request.timeoutInterval = defaultTimeout
        request.httpMethod = "HEAD" // Используем HEAD для меньшего трафика

        let startTime = Date()

        URLSession.shared.dataTask(with: request) { data, response, error in
            let endTime = Date()
            let latency = Int(endTime.timeIntervalSince(startTime) * 1000)

            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")
                // Пробуем еще несколько раз перед тем, как считать неудачей
                self.retryCheck(endpoint: endpoint, attempt: 1, completion: completion)
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("📊 HTTP Response: \(httpResponse.statusCode)")
                if (200...299).contains(httpResponse.statusCode) {
                    print("✅ Network check successful: \(latency)ms")
                    let metrics = NetworkMetrics(latency: latency, packetLoss: 0, timestamp: Date())
                    completion(.success(metrics))
                } else {
                    print("❌ Invalid response code: \(httpResponse.statusCode)")
                    let error = NSError(domain: "NetworkMonitor",
                                      code: httpResponse.statusCode,
                                      userInfo: [NSLocalizedDescriptionKey: "HTTP \(httpResponse.statusCode)"])
                    completion(.failure(error))
                }
            } else {
                print("❌ No HTTP response received")
                let error = NSError(domain: "NetworkMonitor",
                                  code: -1,
                                  userInfo: [NSLocalizedDescriptionKey: "No response"])
                completion(.failure(error))
            }
        }.resume()
    }

    private func retryCheck(endpoint: String, attempt: Int, completion: @escaping (Result<NetworkMetrics, Error>) -> Void) {
        if attempt >= defaultRetryCount {
            // Все попытки исчерпаны
            let error = NSError(domain: "NetworkMonitor",
                              code: -2,
                              userInfo: [NSLocalizedDescriptionKey: "Connection failed after \(defaultRetryCount) attempts"])
            completion(.failure(error))
            return
        }

        // Ждем немного перед следующей попыткой
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) { [weak self] in
            let url = URL(string: "https://\(endpoint)/status/200")!
            var request = URLRequest(url: url)
            request.timeoutInterval = self?.defaultTimeout ?? 2.0
            request.httpMethod = "HEAD"

            let startTime = Date()

            URLSession.shared.dataTask(with: request) { data, response, error in
                let endTime = Date()
                let latency = Int(endTime.timeIntervalSince(startTime) * 1000)

                if error != nil {
                    // Рекурсивно пробуем еще раз
                    self?.retryCheck(endpoint: endpoint, attempt: attempt + 1, completion: completion)
                    return
                }

                if let httpResponse = response as? HTTPURLResponse,
                   (200...299).contains(httpResponse.statusCode) {

                    let metrics = NetworkMetrics(latency: latency, packetLoss: 0, timestamp: Date())
                    completion(.success(metrics))
                } else {
                    self?.retryCheck(endpoint: endpoint, attempt: attempt + 1, completion: completion)
                }
            }.resume()
        }
    }

    // MARK: - Status Handling
    private func handleSuccessfulCheck(_ metrics: NetworkMetrics) {
        currentMetrics = metrics

        // Определяем статус на основе метрик
        let newStatus = determineStatus(from: metrics)

        // Уведомляем только если статус изменился
        if newStatus != currentStatus {
            currentStatus = newStatus
            notifyStatusChange()
        }
    }

    private func handleFailedCheck(_ error: Error) {
        print("Network check failed: \(error.localizedDescription)")

        // Создаем метрики с packet loss 100%
        let failedMetrics = NetworkMetrics(latency: -1, packetLoss: 100, timestamp: Date())
        currentMetrics = failedMetrics

        // Если статус не был disconnected, меняем на disconnected
        if currentStatus != .disconnected {
            currentStatus = .disconnected
            notifyStatusChange()
        }
    }

    private func determineStatus(from metrics: NetworkMetrics) -> ConnectionStatus {
        // Если packet loss высокий или latency слишком большой
        if metrics.packetLoss >= unstablePacketLossThreshold || metrics.latency >= badLatencyThreshold {
            return .unstable
        }

        // Если все в порядке
        return .connected
    }

    private func notifyStatusChange() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self, let onStatusChange = self.onStatusChange else { return }
            onStatusChange(self.currentStatus)
        }
    }

    // MARK: - Settings
    private func setupDefaultSettings() {
        // Загружаем актуальные настройки из UserDefaults
        monitoringInterval = getMonitoringInterval()
    }

    private func getEndpoint() -> String {
        let defaults = UserDefaults.standard
        let savedEndpoint = defaults.string(forKey: "endpoint")
        return savedEndpoint ?? defaultEndpoint
    }

    private func getMonitoringInterval() -> TimeInterval {
        let defaults = UserDefaults.standard
        let savedInterval = defaults.integer(forKey: "checkInterval")
        return TimeInterval(savedInterval > 0 ? savedInterval : 5) // По умолчанию 5 секунд
    }

    // MARK: - Utility Methods
    func getStatusDescription() -> String {
        switch currentStatus {
        case .connected:
            return "Интернет-соединение активно"
        case .unstable:
            return "Нестабильное соединение"
        case .disconnected:
            return "Отсутствует интернет-соединение"
        }
    }
}
