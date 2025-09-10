//
//  FlexibleHeader.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI

/// Geometry tracking for flexible header effects
@Observable private class FlexibleHeaderGeometry {
    var offset: CGFloat = 0
}

/// A view modifier that stretches content when the containing geometry offset changes.
private struct FlexibleHeaderContentModifier: ViewModifier {
    // Removed safeAreaInsets as it's not available in iOS 18.5
    @Environment(FlexibleHeaderGeometry.self) private var geometry
    
    func body(content: Content) -> some View {
        GeometryReader { geometryReader in
            let height = (geometryReader.size.height / 2) - geometry.offset
            content
                .frame(height: height)
                .padding(.bottom, geometry.offset)
                .offset(y: geometry.offset)
        }
    }
}

/// A view modifier that tracks scroll view geometry to stretch a view with ``FlexibleHeaderContentModifier``.
private struct FlexibleHeaderScrollViewModifier: ViewModifier {
    @State private var geometry = FlexibleHeaderGeometry()
    
    func body(content: Content) -> some View {
        content
            .onScrollGeometryChange(for: CGFloat.self) { geometry in
                min(geometry.contentOffset.y + geometry.contentInsets.top, 0)
            } action: { _, offset in
                geometry.offset = offset
            }
            .environment(geometry)
    }
}

// MARK: - View Extensions

extension ScrollView {
    /// A function that returns a view after it applies `FlexibleHeaderScrollViewModifier` to it.
    @MainActor func flexibleHeaderScrollView() -> some View {
        modifier(FlexibleHeaderScrollViewModifier())
    }
}

extension View {
    /// A function that returns a view after it applies `FlexibleHeaderContentModifier` to it.
    func flexibleHeaderContent() -> some View {
        modifier(FlexibleHeaderContentModifier())
    }
}

// MARK: - Adventure-Specific Flexible Header

/// A specialized flexible header for adventure views with map integration
struct AdventureFlexibleHeader: View {
    let adventure: AdventurePlan
    let onDismiss: () -> Void
    let onStartNavigation: () -> Void
    
    var body: some View {
        ZStack {
            // Map placeholder with gradient
            ZStack {
                LinearGradient(
                    colors: [
                        DesignTokens.Brand.primary.opacity(0.8),
                        DesignTokens.Brand.primaryMid.opacity(0.6),
                        DesignTokens.Brand.primaryDark.opacity(0.4)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                VStack {
                    Image(systemName: "map.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                    Text("Adventure Map")
                        .font(DesignTokens.Typography.headline)
                        .foregroundColor(.white)
                }
            }
            .flexibleHeaderContent()
            
            // Overlay content
            VStack {
                HStack {
                    Button(action: onDismiss) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Button(action: onStartNavigation) {
                        HStack {
                            Image(systemName: "location.fill")
                            Text("Start")
                        }
                        .font(DesignTokens.Typography.callout)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(DesignTokens.Brand.primary)
                        .clipShape(Capsule())
                    }
                }
                .padding()
                
                Spacer()
                
                // Adventure info overlay
                VStack(alignment: .leading, spacing: 8) {
                    Text(adventure.title)
                        .font(DesignTokens.Typography.title)
                        .foregroundColor(.white)
                    
                    Text("\(adventure.stops.count) stops planned")
                        .font(DesignTokens.Typography.caption2)
                        .foregroundColor(.white.opacity(0.8))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(
                    LinearGradient(
                        colors: [Color.clear, Color.black.opacity(0.6)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
        }
    }
}
