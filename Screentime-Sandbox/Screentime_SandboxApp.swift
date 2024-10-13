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
                    } catch {
                        print("Authorization failed: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    func handleSelectionChange(_ newSelection: FamilyActivitySelection) {
        print("Selection changed")
        // Here you would typically save the selection and set up monitoring
    }
}

class MyMonitor: DeviceActivityMonitor {
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        // Implement shielding logic here
    }
    
    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        // Remove shields here
    }
}

extension DeviceActivityName {
    static let daily = Self("daily")
}
