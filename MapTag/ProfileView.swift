//
//  ProfileView.swift
//  MapTag
//
//  Created by Cam Graham on 01/04/2024.
//

import SwiftUI

struct ProfileView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                Text("Hello, World!")
            }
            .navigationTitle("Profile")
            .toolbar(content: {
                ToolbarItem {
                    Button("Dismiss", action: dismiss.callAsFunction)
                }
            })
        }
    }
}

#Preview {
    ProfileView()
}
