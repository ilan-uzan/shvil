//
//  ContentView.swift
//  shvil
//
//  Created by Ilan Uzan on 31/08/2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                
                Text("Welcome to Shvil!")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Your iOS app with Supabase integration")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                NavigationLink(destination: SupabaseTestView()) {
                    HStack {
                        Image(systemName: "link")
                        Text("Test Supabase Connection")
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
            .padding()
            .navigationTitle("Shvil")
        }
    }
}

#Preview {
    ContentView()
}
