import SwiftUI
import FamilyControls

struct ContentView: View {
    @Binding var selection: FamilyActivitySelection
    @State var isPickerPresented = false
    @State var selectedAppNames: [String] = []
    @State var passcode = ""
    @State var isLocked = true
    @Binding var removeShields: () -> Void
    @Binding var applyShields: () -> Void

    var body: some View {
        VStack {
            if isLocked {
                TextField("Enter passcode", text: $passcode)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button("Unlock") {
                    if passcode == "1234" {
                        isLocked = false
                        removeShields()
                        print("Shields removed due to correct passcode")
                    } else {
                        print("Incorrect passcode")
                    }
                    passcode = ""
                }
            } else {
                if selectedAppNames.isEmpty {
                    Text("No apps selected")
                        .padding()
                } else {
                    Text("Selected Apps: \(selectedAppNames.joined(separator: ", "))")
                        .padding()
                }

                // Debugging print to ensure button is there
                Text("Is picker presented: \(isPickerPresented ? "Yes" : "No")")
                
                // This is the button to select apps
                Button("Select Apps to Discourage") {
                    print("Select Apps button tapped")
                    isPickerPresented = true
                }
                .padding()
                .familyActivityPicker(isPresented: $isPickerPresented, selection: $selection)
                .onChange(of: selection) { newSelection in
                    updateSelectedAppNames(newSelection)
                }
                
                Button("Lock") {
                    isLocked = true
                    applyShields()
                }
                .padding()
            }
        }
        .padding()
    }
    
    func updateSelectedAppNames(_ selection: FamilyActivitySelection) {
        let selectedApplications = selection.applications
        
        selectedAppNames = selectedApplications.compactMap { app in
            app.localizedDisplayName ?? "Unknown App"
        }
        
        print("Selected Applications: \(selectedAppNames)")
    }
}

#Preview {
    ContentView(
        selection: .constant(FamilyActivitySelection()),
        removeShields: .constant({}),
        applyShields: .constant({})
    )
}

