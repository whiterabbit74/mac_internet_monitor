#!/bin/bash

# Internet Monitor - Simple Network Status Checker
# Bash script to demonstrate real network monitoring

echo "🌐 Internet Monitor - Проверка сети в реальном времени"
echo "======================================================"
echo "Используйте Ctrl+C для остановки"
echo ""

# Функция для проверки пинга
check_ping() {
    local host="$1"
    local timeout=2

    # Используем ping с таймаутом
    if ping -c 1 -W $timeout "$host" >/dev/null 2>&1; then
        # Извлекаем время пинга из вывода
        ping_time=$(ping -c 1 -W $timeout "$host" 2>/dev/null | grep "time=" | cut -d "=" -f 4 | cut -d " " -f 1)
        echo "SUCCESS:$ping_time"
    else
        echo "FAILED:0"
    fi
}

# Функция для определения статуса
get_status() {
    local host="$1"
    local ping_result=$(check_ping "$host")

    if [[ $ping_result == "FAILED"* ]]; then
        echo "🔴 Отключено:-1:100"
    else
        # Извлекаем latency
        latency=$(echo $ping_result | cut -d ":" -f 2)

        # Определяем статус на основе latency
        if (( $(echo "$latency < 50" | bc -l 2>/dev/null) )); then
            echo "🟢 Подключено:$latency:0"
        elif (( $(echo "$latency < 150" | bc -l 2>/dev/null) )); then
            echo "🟡 Нестабильно:$latency:15"
        else
            echo "🔴 Отключено:$latency:100"
        fi
    fi
}

# Основной цикл мониторинга
echo "📡 Начинаем мониторинг..."
echo "Host: 8.8.8.8 (Google DNS)"
echo ""

check_count=1
while true; do
    timestamp=$(date +"%T")

    # Проверяем соединение
    result=$(get_status "8.8.8.8")
    status=$(echo $result | cut -d ":" -f 1)
    latency=$(echo $result | cut -d ":" -f 2)
    packet_loss=$(echo $result | cut -d ":" -f 3)

    # Выводим результат
    echo "[$timestamp] Проверка $check_count"
    echo "Статус: $status"
    if [[ "$latency" != "-1" ]]; then
        echo "Latency: ${latency}ms"
    fi
    echo "Packet Loss: ${packet_loss}%"
    echo ""

    check_count=$((check_count + 1))
    sleep 3  # Интервал проверки 3 секунды
done
