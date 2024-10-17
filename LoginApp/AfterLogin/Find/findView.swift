import SwiftUI

// Die User-Struktur zum Dekodieren der Benutzerdaten
struct User: Identifiable, Codable {
    var id = UUID() // Einzigartige ID für die Identifikation, wird hier erzeugt
    let name: String
}

struct findView: View {
    @State private var findText: String = ""
    @State private var users: [User] = []
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    
    // Beispielnutzer, die in der ScrollView angezeigt werden
    private let exampleUsers: [User] = []
    
    var body: some View {
        NavigationView {
            VStack {
                // Suchleiste
                TextField("Username", text: $findText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .onChange(of: findText) { oldValue, newValue in
                        findUsers()
                    }
                
                // Ladeanzeige oder Suchergebnisse anzeigen
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5, anchor: .center)
                        .padding()
                } else {
                    // ScrollView mit Suchergebnissen oder Beispielnutzern, im Stil einer Chat-Ansicht
                    ScrollView {
                        VStack(alignment: .leading, spacing: 10) {
                            if users.isEmpty {
                                ForEach(exampleUsers) { user in
                                    HStack {
                                        NavigationLink(destination: UserProfileView(user: user, profileImage: Image(systemName: "person.circle.fill"), bio: "This is a default biography.")) {
                                            HStack {
                                                Image(systemName: "person.circle.fill")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: 50, height: 50)
                                                    .foregroundColor(.gray)
                                                    .padding(.trailing, 10)
                                                    .clipShape(Circle())
                                                
                                                VStack(alignment: .leading) {
                                                    Text(user.name)
                                                        .font(.headline)
                                                        .foregroundColor(.primary)
                                                    Text("Last seen recently")
                                                        .font(.subheadline)
                                                        .foregroundColor(.secondary)
                                                }
                                            }
                                        }
                                        Spacer()
                                        // Hier wird der Chat-Button erstellt
                                        NavigationLink(destination: MessageView(user: user, currentUserId: user.id.uuidString)) {
                                            Text("Chat")
                                                .foregroundColor(.white)
                                                .padding(8)
                                                .background(Color.green)
                                                .cornerRadius(8)
                                        }
                                    }
                                    .padding(.vertical, 10)
                                    .padding(.horizontal)
                                    Divider()
                                }
                            } else {
                                ForEach(users) { user in
                                    HStack {
                                        NavigationLink(destination: UserProfileView(user: user, profileImage: Image(systemName: "person.circle.fill"), bio: "This is a default biography.")) {
                                            HStack {
                                                Image(systemName: "person.circle.fill")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: 50, height: 50)
                                                    .foregroundColor(.gray)
                                                    .padding(.trailing, 10)
                                                    .clipShape(Circle())
                                                
                                                VStack(alignment: .leading) {
                                                    Text(user.name)
                                                        .font(.headline)
                                                        .foregroundColor(.primary)
                                                    Text("Last seen recently")
                                                        .font(.subheadline)
                                                        .foregroundColor(.secondary)
                                                }
                                            }
                                        }
                                        Spacer()
                                        // Hier wird der Chat-Button erstellt
                                        NavigationLink(destination: MessageView(user: user, currentUserId: user.id.uuidString)) {
                                            Text("Chat")
                                                .foregroundColor(.white)
                                                .padding(8)
                                                .background(Color.green)
                                                .cornerRadius(8)
                                        }
                                    }
                                    .padding(.vertical, 10)
                                    .padding(.horizontal)
                                    Divider()
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding()
            .navigationTitle("Find")
        }
    }

    private func findUsers() {
        guard !findText.isEmpty else {
            self.users = []
            self.errorMessage = nil
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: "http://uploads.elliceleft.de") else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let postString = "action=search&searchTerm=\(findText)"
        request.httpBody = postString.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
            }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Error: \(error.localizedDescription)"
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.errorMessage = "No data received"
                }
                return
            }
            
            do {
                let decodedNames = try JSONDecoder().decode([String].self, from: data)
                DispatchQueue.main.async {
                    self.users = decodedNames.map { User(name: $0) }
                }
            } catch {
                DispatchQueue.main.async {
                    self.users = []
                    self.errorMessage = nil
                }
            }
        }.resume()
    }
}

struct findView_Previews: PreviewProvider {
    static var previews: some View {
        findView()
    }
}
