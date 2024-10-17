
import SwiftUI

// Struktur, die ein Benutzerprofil repräsentiert
struct UserProfile: Identifiable, Codable {
    var id: Int
    var name: String
    var email: String
    var bio: String
}

// ChatPageView
struct ChatPageView: View {
    @State private var profiles: [UserProfile] = [] // Die Liste der Profile
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            ScrollView { // Ersetzt List mit ScrollView
                if isLoading {
                    ProgressView() // Ladeanzeige
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5, anchor: .center)
                        .padding()
                } else {
                    VStack(alignment: .leading) { // Vertikale Ansicht
                        ForEach(profiles) { profile in // ForEach für mehrere Einträge
                            NavigationLink(destination: ProfileDetailView(profile: profile)) {
                                HStack {
                                    // Profilbild (hier ein Symbol)
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                        .foregroundColor(.blue)
                                    
                                    VStack(alignment: .leading) {
                                        Text(profile.name)
                                            .font(.headline)
                                        Text(profile.email)
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding()
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Chats")
            .onAppear(perform: fetchProfiles) // Hole die Profile beim Anzeigen der View
        }
    }
    
    private func fetchProfiles() {
        isLoading = true // Ladeanzeige aktivieren
        
        guard let url = URL(string: "http://chats.elliceleft.de") else {
            errorMessage = "Ungültige URL"
            isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false // Ladeanzeige deaktivieren
            }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Fehler: \(error.localizedDescription)"
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.errorMessage = "Keine Daten empfangen"
                }
                return
            }
            
            do {
                // Dekodiere die empfangenen Daten in UserProfile
                let decodedProfiles = try JSONDecoder().decode([UserProfile].self, from: data)
                DispatchQueue.main.async {
                    self.profiles = decodedProfiles // Weise die abgerufenen Profile zu
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Fehler beim Dekodieren: \(error)"
                }
            }
        }.resume()
    }
}

// Detailansicht für ein spezifisches Profil
struct ProfileDetailView: View {
    var profile: UserProfile
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(.blue)
                .clipShape(Circle())
                .padding(.top, 40)
            
            Text(profile.name)
                .font(.title)
                .fontWeight(.bold)
            
            Text(profile.email)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Text(profile.bio)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
        }
        .padding()
        .navigationTitle(profile.name)
    }
}

struct ChatPageView_Previews: PreviewProvider {
    static var previews: some View {
        ChatPageView()
    }
}
