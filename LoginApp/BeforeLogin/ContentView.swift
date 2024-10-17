import SwiftUI

// MARK: - ContentView
struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var showingAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var isRegistering: Bool = false
    
    var body: some View {
        VStack {
            if appState.isLoggedIn {
                SwipeView()
                    .transition(.move(edge: .trailing)) // Optional: Übergangsanimation hinzufügen
            } else {
                VStack {
                    Text("Login")
                        .font(.largeTitle)
                        .padding(.bottom, 40)
                    
                    TextField("Username", text: $username)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(5.0)
                        .padding(.bottom, 20)
                        .autocapitalization(.none)
                    
                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(5.0)
                        .padding(.bottom, 20)
                    
                    Button(action: {
                        appState.isLoading = true
                        Task {
                            await login(username: username, password: password)
                        }
                    }) {
                        if appState.isLoading {
                            LoadingView() // Dein Ladesymbol
                        } else {
                            Text("Login")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(width: 220, height: 60)
                                .background(Color.blue)
                                .cornerRadius(15.0)
                        }
                    }
                    .alert(isPresented: $showingAlert) {
                        Alert(
                            title: Text("Login Information"),
                            message: Text(alertMessage),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        isRegistering = true
                    }) {
                        Text("Noch kein Konto? Hier registrieren")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                    .sheet(isPresented: $isRegistering) {
                        RegisterView(isPresented: $isRegistering)
                    }
                }
                .padding()
            }
        }
    }
    
    private func login(username: String, password: String) async {
        guard let url = URL(string: "http://uploads.elliceleft.de") else {
            DispatchQueue.main.async {
                self.alertMessage = "Invalid URL"
                self.showingAlert = true
                self.appState.isLoading = false
            }
            return
        }
        
        let loginData = [
            "username": username,
            "password": password,
            "action": "login"
        ]
        
        let body = loginData.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = body.data(using: .utf8)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request) // Behandle Fehler mit `try`
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                DispatchQueue.main.async {
                    self.alertMessage = "Server Error: HTTP \(httpResponse.statusCode)"
                    self.showingAlert = true
                    self.appState.isLoading = false
                }
                return
            }
            
            // Log the raw response data
            let responseString = String(data: data, encoding: .utf8) ?? "No response data"
            print("Raw Response Data: \(responseString)")
            
            // Verwende JSONSerialization für das Parsen
            if let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                DispatchQueue.main.async {
                    if let message = jsonResponse["message"] as? String, message.contains("Login successful") {
                        self.appState.isLoggedIn = true
                        self.appState.loggedInUsername = username
                        
                        // Extrahiere die ID und speichere sie
                        if let id = jsonResponse["id"] as? Int {
                            self.appState.id = id
                            print("Login successful, user ID: \(id)")
                        } else {
                            print("ID not found in response")
                        }
                    } else {
                        self.alertMessage = "Login failed with message: \("Unknown error")"
                        self.showingAlert = true
                    }
                    self.appState.isLoading = false
                }
            } else {
                DispatchQueue.main.async {
                    self.alertMessage = "Unexpected response format"
                    self.showingAlert = true
                    self.appState.isLoading = false
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.alertMessage = "Error: \(error.localizedDescription)"
                self.showingAlert = true
                self.appState.isLoading = false
            }
        }
    }
}
