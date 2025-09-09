//
//  Constants.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI

/// Constant values that the app defines.
/// Following Landmarks Liquid Glass patterns for consistency and maintainability.
struct Constants {
    // MARK: - App-wide constants
    
    static let cornerRadius: CGFloat = 15.0
    static let leadingContentInset: CGFloat = 26.0
    static let standardPadding: CGFloat = 14.0
    static let safeAreaPadding: CGFloat = 30.0
    static let titleTopPadding: CGFloat = 8.0
    static let titleBottomPadding: CGFloat = -4.0
    
    // MARK: - Map constants
    
    static let mapAspectRatio: CGFloat = 1.2
    static let mapDefaultSpan: Double = 0.01
    static let mapDefaultLatitude: Double = 31.7683  // Israel
    static let mapDefaultLongitude: Double = 35.2137
    
    // MARK: - Adventure constants
    
    static let adventureCardHeight: CGFloat = 200.0
    static let adventureCardCornerRadius: CGFloat = 16.0
    static let stopCardHeight: CGFloat = 120.0
    static let stopCardCornerRadius: CGFloat = 12.0
    static let adventureImagePadding: CGFloat = 14.0
    
    // MARK: - Collection grid constants
    
    static let collectionGridSpacing: CGFloat = 14.0
    static let collectionGridItemCornerRadius: CGFloat = 8.0
    
    @MainActor static var collectionGridItemMinSize: CGFloat {
        #if os(iOS)
        if UIDevice.current.userInterfaceIdiom == .pad {
            return 220.0
        } else {
            return 160.0
        }
        #else
        return 220.0
        #endif
    }
    
    static let collectionGridItemMaxSize: CGFloat = 290.0
    
    // MARK: - Social constants
    
    static let groupCardHeight: CGFloat = 100.0
    static let groupCardCornerRadius: CGFloat = 12.0
    static let planCardHeight: CGFloat = 120.0
    static let planCardCornerRadius: CGFloat = 12.0
    
    // MARK: - Hunt constants
    
    static let huntCardHeight: CGFloat = 140.0
    static let huntCardCornerRadius: CGFloat = 12.0
    static let checkpointSize: CGFloat = 40.0
    static let checkpointCornerRadius: CGFloat = 20.0
    
    // MARK: - Search constants
    
    static let searchResultHeight: CGFloat = 80.0
    static let searchResultCornerRadius: CGFloat = 12.0
    static let searchBarHeight: CGFloat = 44.0
    static let searchBarCornerRadius: CGFloat = 22.0
    
    // MARK: - Navigation constants
    
    static let navigationBarHeight: CGFloat = 44.0
    static let tabBarHeight: CGFloat = 83.0
    static let bottomSheetMinHeight: CGFloat = 84.0
    static let bottomSheetMaxHeight: CGFloat = 400.0
    
    // MARK: - Button constants
    
    static let buttonHeight: CGFloat = 44.0
    static let buttonCornerRadius: CGFloat = 12.0
    static let fabSize: CGFloat = 56.0
    static let fabCornerRadius: CGFloat = 28.0
    
    // MARK: - Badge constants
    
    static let badgeSize: CGFloat = 52.0
    static let badgeCornerRadius: CGFloat = 24.0
    static let hexagonSize: CGFloat = 48.0
    static let badgeSpacing: CGFloat = 14.0
    
    // MARK: - Animation constants
    
    static let microAnimationDuration: Double = 0.15
    static let standardAnimationDuration: Double = 0.25
    static let complexAnimationDuration: Double = 0.4
    static let springResponse: Double = 0.5
    static let springDamping: Double = 0.8
    
    // MARK: - Shadow constants
    
    static let lightShadowRadius: CGFloat = 6.0
    static let mediumShadowRadius: CGFloat = 12.0
    static let heavyShadowRadius: CGFloat = 18.0
    static let glassShadowRadius: CGFloat = 24.0
    
    // MARK: - Spacing scale
    
    static let spacingXS: CGFloat = 4.0
    static let spacingSM: CGFloat = 8.0
    static let spacingMD: CGFloat = 14.0
    static let spacingLG: CGFloat = 20.0
    static let spacingXL: CGFloat = 26.0
    static let spacingXXL: CGFloat = 30.0
    static let spacingXXXL: CGFloat = 40.0
    static let spacingXXXXL: CGFloat = 64.0
    
    // MARK: - Typography scale
    
    static let largeTitleSize: CGFloat = 34.0
    static let titleSize: CGFloat = 28.0
    static let title2Size: CGFloat = 22.0
    static let title3Size: CGFloat = 20.0
    static let headlineSize: CGFloat = 17.0
    static let bodySize: CGFloat = 17.0
    static let calloutSize: CGFloat = 16.0
    static let subheadlineSize: CGFloat = 15.0
    static let footnoteSize: CGFloat = 13.0
    static let captionSize: CGFloat = 12.0
    static let caption2Size: CGFloat = 11.0
    
    // MARK: - Device-specific constants
    
    @MainActor static var isIPad: Bool {
        #if os(iOS)
        return UIDevice.current.userInterfaceIdiom == .pad
        #else
        return false
        #endif
    }
    
    @MainActor static var isIPhone: Bool {
        #if os(iOS)
        return UIDevice.current.userInterfaceIdiom == .phone
        #else
        return false
        #endif
    }
    
    // MARK: - Style constants
    
    #if os(macOS)
    static let editingBackgroundStyle = WindowBackgroundShapeStyle.windowBackground
    #else
    static let editingBackgroundStyle = Material.ultraThickMaterial
    #endif
}
