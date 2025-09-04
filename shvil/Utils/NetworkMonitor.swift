//
//  NetworkMonitor.swift
//  shvil
//
//  Created by ilan on 2024.
//

import Foundation
import Network
import Combine

/// Network connectivity monitoring
class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()
    
    @Published var isConnected = true
    @Published var connectionType: ConnectionType = .wifi
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    init() {
        startMonitoring()
    }
    
    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
                self?.connectionType = self?.determineConnectionType(path) ?? .unknown
            }
        }
        
        monitor.start(queue: queue)
    }
    
    private func determineConnectionType(_ path: NWPath) -> ConnectionType {
        if path.usesInterfaceType(.wifi) {
            return .wifi
        } else if path.usesInterfaceType(.cellular) {
            return .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            return .ethernet
        } else {
            return .unknown
        }
    }
    
    deinit {
        monitor.cancel()
    }
}

enum ConnectionType {
    case wifi
    case cellular
    case ethernet
    case unknown
}
