//
//  AdventureSetupView.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI

struct AdventureSetupView: View {
    var body: some View {
        VStack {
            Text("Adventure Setup")
                .font(.largeTitle)
                .padding()
            
            Text("Create your next adventure")
                .font(.body)
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
}

#Preview {
    AdventureSetupView()
}