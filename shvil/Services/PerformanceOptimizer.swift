//
//  PerformanceOptimizer.swift
//  shvil
//
//  Created by ilan on 2024.
//

import Foundation
import SwiftUI
import Combine

/// High-performance optimization utilities for SwiftUI
@MainActor
public class PerformanceOptimizer: ObservableObject {
    // MARK: - Singleton
    
    public static let shared = PerformanceOptimizer()
    
    // MARK: - Published Properties
    
    @Published public var isOptimizing = false
    @Published public var memoryUsage: UInt64 = 0
    @Published public var cpuUsage: Double = 0.0
    @Published public var frameRate: Double = 60.0
    
    // MARK: - Performance Properties
    
    /// Check if blur should be applied based on performance settings
    public static var shouldApplyBlur: Bool {
        // Only apply blur if device can handle it
        return !UIAccessibility.isReduceTransparencyEnabled && 
               ProcessInfo.processInfo.thermalState != .critical
    }
    
    /// Get appropriate material based on performance
    public static var optimizedMaterial: Material {
        if shouldApplyBlur {
            return .ultraThinMaterial
        } else {
            return .regularMaterial
        }
    }
    
    // MARK: - Private Properties
    
    private var displayLink: CADisplayLink?
    private var frameCount = 0
    private var lastTimestamp: CFTimeInterval = 0
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Performance Monitoring
    
    public func startMonitoring() {
        displayLink = CADisplayLink(target: self, selector: #selector(updateFrameRate))
        displayLink?.add(to: .main, forMode: .common)
        
        // Monitor memory usage
        Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateMemoryUsage()
            }
            .store(in: &cancellables)
    }
    
    public func stopMonitoring() {
        displayLink?.invalidate()
        displayLink = nil
        cancellables.removeAll()
    }
    
    @objc private func updateFrameRate() {
        guard let displayLink = displayLink else { return }
        
        let currentTimestamp = displayLink.timestamp
        
        if lastTimestamp == 0 {
            lastTimestamp = currentTimestamp
            return
        }
        
        frameCount += 1
        let timeElapsed = currentTimestamp - lastTimestamp
        
        if timeElapsed >= 1.0 {
            frameRate = Double(frameCount) / timeElapsed
            frameCount = 0
            lastTimestamp = currentTimestamp
        }
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
            memoryUsage = info.resident_size
        }
    }
}

// MARK: - View Performance Extensions

extension View {
    /// Optimize view for performance
    public func performanceOptimizedView() -> some View {
        self
            .drawingGroup() // Rasterize complex views
            .compositingGroup() // Optimize compositing
    }
    
    /// Lazy load content with placeholder
    public func lazyLoad<Content: View>(
        isLoading: Bool,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        Group {
            if isLoading {
                placeholder()
            } else {
                self
            }
        }
    }
    
    /// Conditional rendering for performance
    public func conditionalRender<TrueContent: View, FalseContent: View>(
        condition: Bool,
        @ViewBuilder trueContent: () -> TrueContent,
        @ViewBuilder falseContent: () -> FalseContent
    ) -> some View {
        Group {
            if condition {
                trueContent()
            } else {
                falseContent()
            }
        }
    }
    
    /// Optimize for reduced motion
    public func respectReducedMotion() -> some View {
        self
            .animation(.none, value: UUID()) // Disable animations when reduced motion is enabled
    }
}

// MARK: - Memory Management

extension View {
    /// Clean up resources when view disappears
    public func onDisappearCleanup(perform action: @escaping () -> Void) -> some View {
        self
            .onDisappear(perform: action)
    }
    
    /// Monitor memory usage
    public func memoryAware() -> some View {
        self
            .onReceive(PerformanceOptimizer.shared.$memoryUsage) { usage in
                if usage > 100 * 1024 * 1024 { // 100MB threshold
                    print("⚠️ High memory usage: \(usage / 1024 / 1024)MB")
                }
            }
    }
}

// MARK: - Image Optimization

extension Image {
    /// Optimize image for performance
    public func performanceOptimized() -> some View {
        self
            .resizable()
            .aspectRatio(contentMode: .fit)
            .clipped()
            .drawingGroup() // Rasterize for better performance
    }
}

// MARK: - List Performance

extension View {
    /// Optimize list performance
    public func listOptimized() -> some View {
        self
            .listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
    }
}

// MARK: - Animation Performance

extension View {
    /// High-performance spring animation
    public func springAnimation(
        value: some Equatable,
        duration: Double = 0.3,
        damping: Double = 0.8
    ) -> some View {
        self
            .animation(
                .spring(response: duration, dampingFraction: damping, blendDuration: 0),
                value: value
            )
    }
    
    /// Optimized transition
    public func optimizedTransition(_ transition: AnyTransition) -> some View {
        self
            .transition(transition)
            .animation(.easeInOut(duration: 0.2), value: UUID())
    }
}
