//
//  PerformanceOptimizer.swift
//  shvil
//
//  Performance optimization utilities for Shvil
//

import SwiftUI
import Combine

/// Performance optimization utilities
public struct PerformanceOptimizer {
    
    // MARK: - Blur Optimization
    
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
    
    // MARK: - Image Caching
    
    /// Image cache for performance
    private static let imageCache = NSCache<NSString, UIImage>()
    
    /// Cache an image
    public static func cacheImage(_ image: UIImage, for key: String) {
        imageCache.setObject(image, forKey: key as NSString)
    }
    
    /// Get cached image
    public static func cachedImage(for key: String) -> UIImage? {
        return imageCache.object(forKey: key as NSString)
    }
    
    // MARK: - Debouncing
    
    /// Debounce a value change
    public static func debounce<T: Equatable>(
        _ value: T,
        delay: TimeInterval = 0.3,
        action: @escaping (T) -> Void
    ) -> AnyPublisher<T, Never> {
        return Just(value)
            .delay(for: .seconds(delay), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { action($0) }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Memory Management
    
    /// Check if device is under memory pressure
    public static var isUnderMemoryPressure: Bool {
        return ProcessInfo.processInfo.thermalState == .critical
    }
    
    /// Get appropriate image quality based on memory pressure
    public static var imageQuality: Double {
        if isUnderMemoryPressure {
            return 0.7  // Lower quality under pressure
        } else {
            return 1.0  // Full quality
        }
    }
    
    // MARK: - Animation Performance
    
    /// Check if animations should be reduced
    public static var shouldReduceAnimations: Bool {
        return UIAccessibility.isReduceMotionEnabled || 
               ProcessInfo.processInfo.thermalState == .critical
    }
    
    /// Get optimized animation
    public static func optimizedAnimation(_ animation: Animation) -> Animation {
        if shouldReduceAnimations {
            return .linear(duration: 0.1)
        } else {
            return animation
        }
    }
}

/// Performance-optimized view modifiers
extension View {
    
    /// Apply performance-optimized blur
    public func optimizedBlur() -> some View {
        if PerformanceOptimizer.shouldApplyBlur {
            return self.background(.ultraThinMaterial)
        } else {
            return self.background(Color.white.opacity(0.9))
        }
    }
    
    /// Apply performance-optimized animation
    public func optimizedAnimation<T: Equatable>(
        _ animation: Animation,
        value: T
    ) -> some View {
        self.animation(PerformanceOptimizer.optimizedAnimation(animation), value: value)
    }
    
    /// Apply lazy loading for images
    public func lazyImage(_ url: String, placeholder: Image? = nil) -> some View {
        LazyImage(url: url, placeholder: placeholder)
    }
}

/// Lazy image loader with caching
struct LazyImage: View {
    let url: String
    let placeholder: Image?
    @State private var image: UIImage?
    @State private var isLoading = false
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else if let placeholder = placeholder {
                placeholder
                    .foregroundColor(.gray)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
            }
        }
        .onAppear {
            loadImage()
        }
    }
    
    private func loadImage() {
        // Check cache first
        if let cachedImage = PerformanceOptimizer.cachedImage(for: url) {
            self.image = cachedImage
            return
        }
        
        isLoading = true
        
        // Load image asynchronously
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: URL(string: url)!)
                let loadedImage = UIImage(data: data)
                
                await MainActor.run {
                    self.image = loadedImage
                    self.isLoading = false
                    
                    // Cache the image
                    if let image = loadedImage {
                        PerformanceOptimizer.cacheImage(image, for: url)
                    }
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                }
            }
        }
    }
}

/// Performance monitoring
public class PerformanceMonitor: ObservableObject {
    @Published public var fps: Double = 60.0
    @Published public var memoryUsage: Double = 0.0
    @Published public var isPerformingWell = true
    
    private var displayLink: CADisplayLink?
    private var lastTimestamp: CFTimeInterval = 0
    
    public init() {
        startMonitoring()
    }
    
    deinit {
        stopMonitoring()
    }
    
    private func startMonitoring() {
        displayLink = CADisplayLink(target: self, selector: #selector(updatePerformance))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    private func stopMonitoring() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    @objc private func updatePerformance() {
        guard let displayLink = displayLink else { return }
        
        let currentTimestamp = displayLink.timestamp
        
        if lastTimestamp != 0 {
            let deltaTime = currentTimestamp - lastTimestamp
            fps = 1.0 / deltaTime
            
            // Update memory usage
            updateMemoryUsage()
            
            // Determine if performing well
            isPerformingWell = fps >= 55.0 && memoryUsage < 0.8
        }
        
        lastTimestamp = currentTimestamp
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
            let usedMemory = Double(info.resident_size)
            let totalMemory = Double(ProcessInfo.processInfo.physicalMemory)
            memoryUsage = usedMemory / totalMemory
        }
    }
}
