//
//  SocializeView.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI

struct SocializeView: View {
    var body: some View {
        VStack {
            Text("Socialize")
                .font(.largeTitle)
                .padding()
            
            Text("Connect with other adventurers")
                .font(.body)
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
}

#Preview {
    SocializeView()
}