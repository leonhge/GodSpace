import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState // Verwende EnvironmentObject, um die globale Instanz zu nutzen
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Username")
                    .font(.title2)
                    .padding()
                Divider()
                Text("Password")
                    .font(.title2)
                    .padding()
                Divider()
                Text("Instagram")
                    .font(.title2)
                    .padding()
                Divider()
                Text("Security Settings")
                    .font(.title2)
                    .padding()
                Divider()
                Text("Biographie")
                    .font(.title2)
                    .padding()
                Divider()
                Text("Info & Help")
                    .font(.title2)
                    .padding()
                
                Divider() // Trennlinie zwischen den Einträgen
                
                Button(action: {
                                    // Setze isLoggedIn auf false
                                    appState.isLoggedIn = false
                                    // Setze isLoading auf false
                                    appState.isLoading = false
                                    // Lösche die Benutzer-ID
                                    deleteid()
                                }) {
                                    Text("Logout")
                                        .font(.title2)
                                        .foregroundColor(.red)
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
            }
            .padding()
        }
        .navigationTitle("Settings")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(AppState()) // Füge die EnvironmentObject Instanz für die Vorschau hinzu
    }
}

// Funktion zum Löschen der Benutzer-ID aus den UserDefaults
func deleteid() {
    UserDefaults.standard.removeObject(forKey: "id")
}
