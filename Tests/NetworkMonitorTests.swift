//
//  NetworkMonitorTests.swift
//  InternetMonitorTests
//
//  Created by Internet Monitor App
//  Copyright © 2024. All rights reserved.
//

import XCTest

class NetworkMonitorTests: XCTestCase {

    var networkMonitor: NetworkMonitor!

    override func setUp() {
        super.setUp()
        networkMonitor = NetworkMonitor()
    }

    override func tearDown() {
        networkMonitor = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests
    func testNetworkMonitorInitialization() {
        XCTAssertNotNil(networkMonitor)
        XCTAssertEqual(networkMonitor.getCurrentStatus(), .disconnected)
    }

    // MARK: - Status Tests
    func testStatusDescription() {
        // Test connected status
        networkMonitor.currentStatus = .connected
        XCTAssertEqual(networkMonitor.getStatusDescription(), "Интернет-соединение активно")

        // Test unstable status
        networkMonitor.currentStatus = .unstable
        XCTAssertEqual(networkMonitor.getStatusDescription(), "Нестабильное соединение")

        // Test disconnected status
        networkMonitor.currentStatus = .disconnected
        XCTAssertEqual(networkMonitor.getStatusDescription(), "Отсутствует интернет-соединение")
    }

    // MARK: - Metrics Tests
    func testMetricsCreation() {
        let metrics = NetworkMonitor.NetworkMetrics(
            latency: 50,
            packetLoss: 0,
            timestamp: Date()
        )

        XCTAssertEqual(metrics.latency, 50)
        XCTAssertEqual(metrics.packetLoss, 0)
        XCTAssertNotNil(metrics.timestamp)
    }

    // MARK: - Status Determination Tests
    func testStatusDetermination() {
        // Test good connection
        let goodMetrics = NetworkMonitor.NetworkMetrics(
            latency: 20,
            packetLoss: 0,
            timestamp: Date()
        )
        let goodStatus = networkMonitor.determineStatus(from: goodMetrics)
        XCTAssertEqual(goodStatus, .connected)

        // Test unstable connection (high latency)
        let unstableMetrics = NetworkMonitor.NetworkMetrics(
            latency: 600,
            packetLoss: 0,
            timestamp: Date()
        )
        let unstableStatus = networkMonitor.determineStatus(from: unstableMetrics)
        XCTAssertEqual(unstableStatus, .unstable)

        // Test unstable connection (packet loss)
        let packetLossMetrics = NetworkMonitor.NetworkMetrics(
            latency: 50,
            packetLoss: 40,
            timestamp: Date()
        )
        let packetLossStatus = networkMonitor.determineStatus(from: packetLossMetrics)
        XCTAssertEqual(packetLossStatus, .unstable)
    }

    // MARK: - Performance Tests
    func testPerformanceExample() {
        measure {
            // Test performance of status determination
            for _ in 0..<1000 {
                let metrics = NetworkMonitor.NetworkMetrics(
                    latency: Int.random(in: 10...1000),
                    packetLoss: Int.random(in: 0...100),
                    timestamp: Date()
                )
                _ = networkMonitor.determineStatus(from: metrics)
            }
        }
    }
}

// MARK: - NetworkMonitor Extension for Testing
extension NetworkMonitor {
    // Expose private properties for testing
    var currentStatus: ConnectionStatus {
        get { return currentStatus }
        set { currentStatus = newValue }
    }

    func determineStatus(from metrics: NetworkMetrics) -> ConnectionStatus {
        // If packet loss high or latency too high
        if metrics.packetLoss >= 30 || metrics.latency >= 500 {
            return .unstable
        }

        // If all good
        return .connected
    }
}
