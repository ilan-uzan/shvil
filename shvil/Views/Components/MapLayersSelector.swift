//
//  MapLayersSelector.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI
import MapKit

/// Map layers selector with liquid glass styling
struct MapLayersSelector: View {
    @Binding var selectedLayer: MapLayer
    @State private var isExpanded: Bool = false
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 0) {
            if isExpanded {
                // Expanded layers menu
                VStack(spacing: 8) {
                    ForEach(MapLayer.allCases, id: \.self) { layer in
                        LayerOptionButton(
                            layer: layer,
                            isSelected: selectedLayer == layer,
                            onTap: {
                                selectedLayer = layer
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    isExpanded = false
                                }
                            }
                        )
                    }
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                        .saturation(1.1)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.3),
                                            Color.white.opacity(0.1)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 0.5
                                )
                        )
                )
                .shadow(
                    color: Color.black.opacity(0.1),
                    radius: 8,
                    x: 0,
                    y: 4
                )
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.8).combined(with: .opacity),
                    removal: .scale(scale: 0.8).combined(with: .opacity)
                ))
            }
            
            // Main layers button
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            }) {
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .saturation(1.1)
                        .frame(width: 44, height: 44)
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.3),
                                            Color.white.opacity(0.1)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 0.5
                                )
                        )
                    
                    Image(systemName: selectedLayer.icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(Color.gray.opacity(0.6))
                }
            }
            .scaleEffect(isExpanded ? 1.1 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isExpanded)
            .shadow(
                color: Color.black.opacity(0.1),
                radius: 8,
                x: 0,
                y: 4
            )
        }
    }
}

/// Individual layer option button
struct LayerOptionButton: View {
    let layer: MapLayer
    let isSelected: Bool
    let onTap: () -> Void
    
    @State private var isPressed: Bool = false
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: layer.icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isSelected ? DesignTokens.Brand.primary : Color.gray.opacity(0.6))
                    .frame(width: 20)
                
                Text(layer.title)
                    .font(DesignTokens.Typography.body)
                    .foregroundColor(isSelected ? DesignTokens.Text.primary : Color.gray.opacity(0.6))
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(DesignTokens.Brand.primary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        isSelected ? 
                        DesignTokens.Brand.primary.opacity(0.1) :
                        Color.clear
                    )
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0) { pressing in
            isPressed = pressing
        } perform: {
            // Long press action if needed
        }
    }
}

/// Map layer types
enum MapLayer: String, CaseIterable {
    case standard = "standard"
    case satellite = "satellite"
    case hybrid = "hybrid"
    case threeD = "3d"
    case twoD = "2d"
    
    var title: String {
        switch self {
        case .standard: return "Standard"
        case .satellite: return "Satellite"
        case .hybrid: return "Hybrid"
        case .threeD: return "3D"
        case .twoD: return "2D"
        }
    }
    
    var icon: String {
        switch self {
        case .standard: return "map"
        case .satellite: return "globe"
        case .hybrid: return "map.fill"
        case .threeD: return "cube.fill"
        case .twoD: return "square.fill"
        }
    }
    
    var mapType: MKMapType {
        switch self {
        case .standard: return .standard
        case .satellite: return .satellite
        case .hybrid: return .hybrid
        case .threeD: return .standard // 3D will be handled separately
        case .twoD: return .standard // 2D will be handled separately
        }
    }
}

