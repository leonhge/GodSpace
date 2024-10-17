import SwiftUI

struct RegisterView: View {
    @Binding var isPresented: Bool
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var showingAlert: Bool = false
    @State private var alertMessage: String = ""
    @EnvironmentObject var appState: AppState // AppState als Environment-Object hinzufügen

    var body: some View {
        VStack {
            Text("Register")
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

            SecureField("Confirm Password", text: $confirmPassword)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(5.0)
                .padding(.bottom, 20)

            Button(action: {
                if password == confirmPassword {
                    register(username: username, password: password)
                } else {
                    self.alertMessage = "Passwords do not match"
                    self.showingAlert = true
                }
            }) {
                Text("Register")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 220, height: 60)
                    .background(Color.blue)
                    .cornerRadius(15.0)
            }
            .alert(isPresented: $showingAlert) {
                Alert(
                    title: Text("Registration Information"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .padding()
    }

    func register(username: String, password: String) {
        guard let url = URL(string: "http://uploads.elliceleft.de") else {
            self.alertMessage = "Invalid URL"
            self.showingAlert = true
            return
        }

        let registerData = [
            "action": "register",
            "username": username,
            "password": password
        ]

        let body = registerData.map { "\($0.key)=\($0.value)" }.joined(separator: "&")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = body.data(using: .utf8)

        print("Sending request with body: \(body)") // Debug-Ausgabe

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.alertMessage = "Error: \(error.localizedDescription)"
                    self.showingAlert = true
                }
                return
            }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                DispatchQueue.main.async {
                    self.alertMessage = "Server Error: HTTP \(httpResponse.statusCode)"
                    self.showingAlert = true
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    self.alertMessage = "No data received"
                    self.showingAlert = true
                }
                return
            }

            if let responseString = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    print("Received response: \(responseString)") // Debug-Ausgabe
                    if responseString.contains("Registration successful") {
                        self.appState.loggedInUsername = username // Speichere den Nutzernamen
                        self.isPresented = false // Schließt die Registrierung
                    } else {
                        self.alertMessage = responseString
                        self.showingAlert = true
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.alertMessage = "Error decoding response"
                    self.showingAlert = true
                }
            }
        }.resume()
    }
}

// Preview für RegisterView
#Preview {
    RegisterView(isPresented: .constant(true))
        .environmentObject(AppState()) // EnvironmentObject bereitstellen
}
