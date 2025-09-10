//
//  PerformanceMonitor.swift
//  shvil
//
//  Created by ilan on 2024.
//

import Foundation
import SwiftUI

/// Performance monitoring service for tracking app performance metrics
@MainActor
class PerformanceMonitor: ObservableObject {
    static let shared = PerformanceMonitor()
    
    @Published var isMonitoring = false
    @Published var currentFPS: Double = 60.0
    @Published var averageFPS: Double = 60.0
    @Published var memoryUsage: Double = 0.0
    @Published var cpuUsage: Double = 0.0
    
    private var displayLink: CADisplayLink?
    private var frameCount = 0
    private var lastTimestamp: CFTimeInterval = 0
    private var fpsHistory: [Double] = []
    private let maxHistoryCount = 60 // Keep last 60 frames
    
    private init() {
        startMonitoring()
    }
    
    deinit {
        Task { @MainActor in
            stopMonitoring()
        }
    }
    
    func startMonitoring() {
        guard !isMonitoring else { return }
        
        isMonitoring = true
        displayLink = CADisplayLink(target: self, selector: #selector(displayLinkTick))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    func stopMonitoring() {
        isMonitoring = false
        displayLink?.invalidate()
        displayLink = nil
    }
    
    @objc private func displayLinkTick(_ displayLink: CADisplayLink) {
        let currentTimestamp = displayLink.timestamp
        
        if lastTimestamp == 0 {
            lastTimestamp = currentTimestamp
            return
        }
        
        frameCount += 1
        let deltaTime = currentTimestamp - lastTimestamp
        
        if deltaTime >= 1.0 {
            let fps = Double(frameCount) / deltaTime
            updateFPS(fps)
            
            frameCount = 0
            lastTimestamp = currentTimestamp
        }
        
        updateMemoryUsage()
        updateCPUUsage()
    }
    
    private func updateFPS(_ fps: Double) {
        currentFPS = fps
        fpsHistory.append(fps)
        
        if fpsHistory.count > maxHistoryCount {
            fpsHistory.removeFirst()
        }
        
        averageFPS = fpsHistory.reduce(0, +) / Double(fpsHistory.count)
    }
    
    private func updateMemoryUsage() {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            memoryUsage = Double(info.resident_size) / 1024.0 / 1024.0 // Convert to MB
        }
    }
    
    private func updateCPUUsage() {
        // Simplified CPU usage calculation
        // This is a placeholder implementation
        // In a real app, you'd use proper system APIs
        cpuUsage = 0.0
    }
    
    func getPerformanceReport() -> PerformanceReport {
        return PerformanceReport(
            currentFPS: currentFPS,
            averageFPS: averageFPS,
            memoryUsage: memoryUsage,
            cpuUsage: cpuUsage,
            timestamp: Date()
        )
    }
}

// MARK: - Performance Report

struct PerformanceReport {
    let currentFPS: Double
    let averageFPS: Double
    let memoryUsage: Double
    let cpuUsage: Double
    let timestamp: Date
    
    var isPerformanceGood: Bool {
        return averageFPS >= 55.0 && memoryUsage < 100.0 && cpuUsage < 80.0
    }
    
    var performanceGrade: String {
        if averageFPS >= 58.0 && memoryUsage < 80.0 && cpuUsage < 70.0 {
            return "A"
        } else if averageFPS >= 55.0 && memoryUsage < 100.0 && cpuUsage < 80.0 {
            return "B"
        } else if averageFPS >= 50.0 && memoryUsage < 120.0 && cpuUsage < 90.0 {
            return "C"
        } else {
            return "D"
        }
    }
}

// MARK: - Performance View Modifier

struct PerformanceOptimized: ViewModifier {
    let enableOptimizations: Bool
    
    func body(content: Content) -> some View {
        if enableOptimizations {
            content
                .drawingGroup() // Rasterize complex views
                .compositingGroup() // Optimize compositing
        } else {
            content
        }
    }
}

extension View {
    func performanceOptimized(_ enabled: Bool = true) -> some View {
        modifier(PerformanceOptimized(enableOptimizations: enabled))
    }
}
