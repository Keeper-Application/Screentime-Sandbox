import SwiftUI
import FamilyControls
import DeviceActivity
import ManagedSettings

@main
struct Screentime_SandboxApp: App {
    let center = AuthorizationCenter.shared
    let store = ManagedSettingsStore()
    @State var selection = FamilyActivitySelection()
    @State var isPickerPresented = false
    
    var body: some Scene {
        WindowGroup {
            VStack {
                Button("Select Apps to Discourage") {
                    isPickerPresented = true
                }
                .familyActivityPicker(isPresented: $isPickerPresented, selection: $selection)
                .onChange(of: selection) { newSelection in
                    handleSelectionChange(newSelection)
                }
            }
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
        }
    }
    
    func handleSelectionChange(_ newSelection: FamilyActivitySelection) {
        let selectedApps = newSelection.applicationTokens.map { $0.rawValue }
        UserDefaults.standard.set(selectedApps, forKey: "selectedAppsToDiscourage")
        print("Selected apps to discourage: \(selectedApps)")
    }
    
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
}

class MyMonitor: DeviceActivityMonitor {
    let store = ManagedSettingsStore()
    
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        
        if let storedAppTokens = UserDefaults.standard.array(forKey: "selectedAppsToDiscourage") as? [String] {
            let applicationTokens = Set(storedAppTokens.compactMap { ApplicationToken($0) })
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
