//
//  SettingsView.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        VStack {
            Text("Settings")
                .font(.largeTitle)
                .padding()
            
            Text("Configure your preferences")
                .font(.body)
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
}

#Preview {
    SettingsView()
}
