#!/usr/bin/env swift

// Internet Monitor - macOS Status Bar Application
// Simple Swift script to demonstrate the functionality

import Foundation

print("🌐 Internet Monitor - Запуск приложения...")
print("=====================================")

// Симуляция проверки интернет-соединения
func checkInternetConnection() -> (status: String, latency: Int, packetLoss: Int) {
    let endpoints = ["8.8.8.8", "1.1.1.1", "apple.com"]
    let randomStatus = Int.random(in: 0...2)
    let latency = Int.random(in: 10...200)
    let packetLoss = Int.random(in: 0...50)

    switch randomStatus {
    case 0:
        return ("🟢 Подключено", latency, 0)
    case 1:
        return ("🟡 Нестабильно", latency, packetLoss)
    default:
        return ("🔴 Отключено", -1, 100)
    }
}

// Основная логика приложения
func startMonitoring() {
    print("📱 Запуск мониторинга интернет-соединения...")
    print("⏰ Интервал проверки: 5 секунд")
    print("")

    for i in 1...10 {
        let (status, latency, packetLoss) = checkInternetConnection()
        let timestamp = Date().formatted(date: .omitted, time: .standard)

        print("[\(timestamp)] Проверка \(i)/10")
        print("Статус: \(status)")
        if latency > 0 {
            print("Latency: \(latency)ms")
        }
        print("Packet Loss: \(packetLoss)%")
        print("")

        if i < 10 {
            print("⏳ Ожидание следующей проверки...")
            sleep(2) // Симулируем 2 секунды вместо 5
            print("")
        }
    }

    print("✅ Мониторинг завершен!")
}

// Настройки приложения
func showSettings() {
    print("⚙️ Настройки Internet Monitor")
    print("=============================")
    print("Endpoint: 8.8.8.8 (Google DNS)")
    print("Интервал проверки: 5 секунд")
    print("Уведомления: Включены")
    print("Подсказки: Включены")
    print("")
}

// Меню приложения
func showMenu() {
    print("📋 Меню Internet Monitor")
    print("========================")
    print("🌐 Internet Monitor v1.0")
    print("Статус: 🟢 Подключено")
    print("Latency: 23ms")
    print("Packet Loss: 0%")
    print("")
    print("📊 Обновить сейчас")
    print("⚙️ Настройки...")
    print("❌ Выйти")
    print("")
}

// Главная функция
func main() {
    print("🚀 Добро пожаловать в Internet Monitor!")
    print("======================================")
    print("Это демонстрация функциональности приложения.")
    print("В реальном приложении вы увидите иконку в статус-баре macOS.")
    print("")

    showMenu()
    showSettings()

    let shouldStartMonitoring = askUser("Начать мониторинг? (y/n): ")

    if shouldStartMonitoring.lowercased() == "y" || shouldStartMonitoring.lowercased() == "yes" {
        startMonitoring()
    }

    print("👋 Спасибо за использование Internet Monitor!")
    print("🔧 Для реального запуска в macOS нужны дополнительные настройки.")
}

// Функция для запроса ввода пользователя
func askUser(_ question: String) -> String {
    print(question, terminator: "")
    return readLine() ?? ""
}

// Запуск приложения
main()
