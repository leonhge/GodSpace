import SwiftUI

struct SwipeView: View {
    @EnvironmentObject var appState: AppState
    @State private var userProfile = UserProfileModel()

    var body: some View {
        TabView {
            findView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                }
            
            ChatPageView()
                .tabItem {
                    Image(systemName: "bubble.fill")
                }
          
            
            
            ProfileView(userProfile: $userProfile) // Binding zu userProfile
                .tabItem {
                    Image(systemName: "person")
                }
                    
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                }
        }
        .accentColor(.blue) // Optional: Farbe des ausgewählten Tabs
        .onAppear {
            // Initialisiere `userProfile` mit dem Benutzernamen aus `appState`
            if let username = appState.loggedInUsername {
                userProfile.username = username
                userProfile.loadUserData(username: username) // Lade die Benutzerdaten
            }
        }
        .onChange(of: appState.loggedInUsername) { oldUsername, newUsername in
            if let username = newUsername {
                userProfile.username = username
                userProfile.loadUserData(username: username) // Lade die Benutzerdaten
            }
        }
    }
}

struct SwipeView_Previews: PreviewProvider {
    static var previews: some View {
        SwipeView()
            .environmentObject(AppState()) // Sicherstellen, dass AppState korrekt initialisiert ist
    }
}
