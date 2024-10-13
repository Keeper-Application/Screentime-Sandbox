import SwiftUI
import FamilyControls
import DeviceActivity
import ManagedSettings

@main
struct Screentime_SandboxApp: App {
    let center = AuthorizationCenter.shared
    @State var selection = FamilyActivitySelection()
    let store = ManagedSettingsStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView(
                selection: $selection,
                removeShields: .constant({ removeAllShields() }),
                applyShields: .constant({ applyStoredShields() })
            )
            .onAppear {
                Task {
                    do {
                        try await center.requestAuthorization(for: .individual)
                        print("Authorization successful")
                        setupMonitoring()
                    } catch {
                        print("Authorization failed: \(error.localizedDescription)")
                    }
                }
            }
            .onChange(of: selection) { newSelection in
                handleSelectionChange(newSelection)
            }
        }
    }
    
    func handleSelectionChange(_ newSelection: FamilyActivitySelection) {
        let selectedApps = newSelection.applications
        let appTokens = Set(selectedApps.compactMap { $0.token })
        
        let tokenData = try? JSONEncoder().encode(appTokens)
        let tokenData = try? JSONEncoder().encode(appTokens)
        UserDefaults.standard.set(tokenData, forKey: "selectedAppsToDiscourage")
        
        applyAppShields(appTokens: appTokens)
        print("Selected apps to discourage: \(appTokens)")
    }
    ß
    func setupMonitoring() {
        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59),
            repeats: true
        )
        let center = DeviceActivityCenter()
        do {
            try center.startMonitoring(.daily, during: schedule)
            print("Monitoring started successfully")
        } catch {
            print("Failed to start monitoring: \(error)")
        }
    }
    
    func applyAppShields(appTokens: Set<ApplicationToken>) {
        if appTokens.isEmpty {
            store.shield.applications = nil
            print("Shields removed from all apps")
        } else {
            store.shield.applications = appTokens
            print("Shields applied to apps: \(appTokens)")
        }
    }
    
    func removeAllShields() {
        store.shield.applications = nil
        print("All shields removed")
    }
    
    func applyStoredShields() {
        if let tokenData = UserDefaults.standard.data(forKey: "selectedAppsToDiscourage"),
           let applicationTokens = try? JSONDecoder().decode(Set<ApplicationToken>.self, from: tokenData) {
            store.shield.applications = applicationTokens.isEmpty ? nil : applicationTokens
            print("Stored shields reapplied to apps: \(applicationTokens)")
        }
    }
}

class MyMonitor: DeviceActivityMonitor {
    let store = ManagedSettingsStore()
    
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        
        if let tokenData = UserDefaults.standard.data(forKey: "selectedAppsToDiscourage"),
           let applicationTokens = try? JSONDecoder().decode(Set<ApplicationToken>.self, from: tokenData) {
            store.shield.applications = applicationTokens.isEmpty ? nil : applicationTokens
            print("Shielding applied to apps: \(applicationTokens)")
        }
    }
    
    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        store.shield.applications = nil
        print("Shields removed from all apps")
    }
}

extension DeviceActivityName {
    static let daily = Self("daily")
}
