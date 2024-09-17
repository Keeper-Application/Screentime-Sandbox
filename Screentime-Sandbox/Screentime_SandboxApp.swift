
//  Screentime_SandboxApp.swift
//  Screentime-Sandbox
//
//  Created by Ayub Mohamed on 2024-09-11.
//

import SwiftUI
import FamilyControls
import DeviceActivity
import ManagedSettings


@main
struct Screentime_SandboxApp: App {
    let center = AuthorizationCenter.shared
    @State var selection = FamilyActivitySelection()  // FamilyActivitySelection to capture the user's choices
    @State var isPickerPresented = false               // Controls whether the picker is shown
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    Task {
                        do {
                            // Request authorization to use Family Controls
                            try await center.requestAuthorization(for: .individual)
                            print("Authorization successful")
                        } catch {
                            print("Authorization failed: \(error.localizedDescription)")
                        }
                    }
                }
                .toolbar {
                    // Add a button to show the FamilyActivityPicker
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Select Apps/Websites") {
                            isPickerPresented = true
                        }
                    }
                }
                // Present the FamilyActivityPicker as a sheet
                .familyActivityPicker(isPresented: $isPickerPresented, selection: $selection)
                .onChange(of: selection) { newSelection in
                    // Log the selected apps, categories, and web domains
                    logSelection(newSelection)
                }
        }
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
