//
//  HuntView.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI

struct HuntView: View {
    var body: some View {
        VStack {
            Text("Hunt")
                .font(.largeTitle)
                .padding()
            
            Text("Discover hidden gems")
                .font(.body)
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
}

#Preview {
    HuntView()
}