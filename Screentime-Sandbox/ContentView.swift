//
//  ContentView.swift
//  Screentime-Sandbox
//
//  Created by Ayub Mohamed on 2024-09-11.
//

import SwiftUI
import FamilyControls

struct ContentView: View {
    @State var selection = FamilyActivitySelection()  // FamilyActivitySelection to capture the user's choices
    @State var isPickerPresented = false               // Controls whether the picker is shown

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, Ayub!")
                .padding()

            // Button to trigger FamilyActivityPicker
            Button("Select Apps/Websites") {
                isPickerPresented = true
            }
            .padding()

            // FamilyActivityPicker presented as a sheet
            .familyActivityPicker(isPresented: $isPickerPresented, selection: $selection)
            .onChange(of: selection) { newSelection in
                logSelection(newSelection)
            }
        }
        .padding()
    }

    // Function to log selected items for now
    func logSelection(_ selection: FamilyActivitySelection) {
        let selectedApplications = selection.applications
        let selectedCategories = selection.categories
        let selectedWebDomains = selection.webDomains
        
        // Print selected items to the console
        print("Selected Applications: \(selectedApplications)")
        print("Selected Categories: \(selectedCategories)")
        print("Selected Web Domains: \(selectedWebDomains)")
    }
}

#Preview {
    ContentView()
}

