
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
    @State var selection = FamilyActivitySelection()
    @State var isPickerPresented = false

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    Task {
                        do {
                            try await center.requestAuthorization(for: .individual)
                            print("Authorization successful")
                            loadStoredApplications()  // Load stored applications on app start
                        } catch {
                            print("Authorization failed: \(error.localizedDescription)")
                        }
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Select Apps/Websites") {
                            isPickerPresented = true
                        }
                    }
                }
                .familyActivityPicker(isPresented: $isPickerPresented, selection: $selection)
                .onChange(of: selection) { newSelection in
                    logSelection(newSelection)
                    storeApplications(newSelection)  // Store selected applications
                }
        }
    }

    func logSelection(_ selection: FamilyActivitySelection) {
        let selectedApplications = selection.applications
        let selectedCategories = selection.categories
        let selectedWebDomains = selection.webDomains
        
        print("Selected Applications: \(selectedApplications)")
        print("Selected Categories: \(selectedCategories)")
        print("Selected Web Domains: \(selectedWebDomains)")
    }

    // Store selected applications in UserDefaults
    func storeApplications(_ selection: FamilyActivitySelection) {
        let selectedApps = selection.applications.map { $0.token }
        UserDefaults.standard.set(selectedApps, forKey: "storedApplications")
        
        // Optionally store names if you can map them
        let appNames = selection.applications.compactMap { app in
            // Assuming you have a way to get localized names
            app.localizedDisplayName ?? "Unknown App"
        }
        UserDefaults.standard.set(appNames, forKey: "storedApplicationNames")
    }

    // Load stored applications from UserDefaults
    func loadStoredApplications() {
        if let storedApps = UserDefaults.standard.array(forKey: "storedApplications") as? [ActivityCategoryToken],
           let storedAppNames = UserDefaults.standard.array(forKey: "storedApplicationNames") as? [String] {
            print("Loaded Applications: \(storedApps)")
            print("Loaded Application Names: \(storedAppNames)")
        }
    }
}
