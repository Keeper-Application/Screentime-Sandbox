import SwiftUI
import FamilyControls
import DeviceActivity
import ManagedSettings

class MyMonitor: DeviceActivityMonitor {
    let store = ManagedSettingsStore()
    
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        
        if let storedApps = UserDefaults.standard.array(forKey: "storedApplications") as? [String] {
            store.shield.applications = Set(storedApps.compactMap { ApplicationToken($0) })
        }
    }
    
    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        store.shield.applications = nil
    }
}

@main
struct Screentime_SandboxApp: App {
    let authorizationCenter = AuthorizationCenter.shared
    let deviceActivityCenter = DeviceActivityCenter()
    @State var selection = FamilyActivitySelection()
    @State var isPickerPresented = false

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    Task {
                        do {
                            try await authorizationCenter.requestAuthorization(for: .individual)
                            print("Authorization successful")
                            loadStoredApplications()
                            startMonitoring()
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
                    storeApplications(newSelection)
                }
        }
    }

    func startMonitoring() {
        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59),
            repeats: true
        )
        
        do {
            try deviceActivityCenter.startMonitoring(.daily, during: schedule)
            print("Monitoring started successfully")
        } catch {
            print("Failed to start monitoring: \(error.localizedDescription)")
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

    func storeApplications(_ selection: FamilyActivitySelection) {
        let selectedApps = selection.applications.map { $0.token.rawValue }
        UserDefaults.standard.set(selectedApps, forKey: "storedApplications")
        
        let appNames = selection.applications.compactMap { app in
            app.localizedDisplayName ?? "Unknown App"
        }
        UserDefaults.standard.set(appNames, forKey: "storedApplicationNames")
    }

    func loadStoredApplications() {
        if let storedApps = UserDefaults.standard.array(forKey: "storedApplications") as? [String],
           let storedAppNames = UserDefaults.standard.array(forKey: "storedApplicationNames") as? [String] {
            print("Loaded Applications: \(storedApps)")
            print("Loaded Application Names: \(storedAppNames)")
        }
    }
}

extension DeviceActivityName {
    static let daily = Self("daily")
}
