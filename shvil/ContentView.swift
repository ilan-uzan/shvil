//
//  ContentView.swift
//  shvil
//
//  Created by Ilan Uzan on 31/08/2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var locationService: LocationService
    @EnvironmentObject private var supabaseManager: SupabaseManager
    @EnvironmentObject private var authManager: AuthenticationManager
    @EnvironmentObject private var navigationService: NavigationService
    
    var body: some View {
        ModernTabView()
            .environmentObject(locationService)
            .environmentObject(supabaseManager)
            .environmentObject(authManager)
            .environmentObject(navigationService)
    }
}

#Preview {
    ContentView()
        .environmentObject(LocationService.shared)
        .environmentObject(SupabaseManager.shared)
        .environmentObject(AuthenticationManager.shared)
        .environmentObject(NavigationService.shared)
}
