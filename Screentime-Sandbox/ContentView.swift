//
//  ContentView.swift
//  Screentime-Sandbox
//
//  Created by Ayub Mohamed on 2024-09-11.
//


import SwiftUI
import FamilyControls

struct ContentView: View {
    @State var selection = FamilyActivitySelection()   // Captures user choices
    @State var isPickerPresented = false                // Controls the picker presentation
    @State var selectedAppNames: [String] = []          // Stores selected app names

    var body: some View {
        VStack {
            // Display selected app names or a default message
            if selectedAppNames.isEmpty {
                Text("Hello, Ayub!")
                    .padding()
            } else {
                Text("Selected Apps: \(selectedAppNames.joined(separator: ", "))")
                    .padding()
            }

            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
                .padding()

            // Button to present FamilyActivityPicker
            Button("Select Apps/Websites") {
                isPickerPresented = true
            }
            .padding()

            // FamilyActivityPicker presented as a sheet
            .familyActivityPicker(isPresented: $isPickerPresented, selection: $selection)
            .onChange(of: selection) { newSelection in
                updateSelectedAppNames(newSelection)
            }
        }
        .padding()  // Apply padding to the entire VStack
    }

    // Function to update the selected app names
    func updateSelectedAppNames(_ selection: FamilyActivitySelection) {
        let selectedApplications = selection.applications
        
        // Convert the selected application tokens into readable names
        selectedAppNames = selectedApplications.compactMap { app in
            app.localizedDisplayName ?? "Unknown App"
        }
        
        // Print selected items to the console (optional for debugging)
        print("Selected Applications: \(selectedAppNames)")
    }
}

#Preview {
    ContentView()
}
