import SwiftUI
import Combine

// MARK: - AppState

class AppState: ObservableObject {
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @AppStorage("loggedInUsername") var loggedInUsername: String?
    @AppStorage("id") var id: Int? // Benutzer-ID als Int speichern

    @Published var isLoading = false
    @Published var profileImageURL: String? = nil

    func login(username: String, password: String) {
        guard let url = URL(string: "http://uploads.elliceleft.de/api/login.php") else {
            print("Ungültige URL")
            return
        }
        
        let requestData = [
            "action": "login",
            "username": username,
            "password": password
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestData, options: [])
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Fehler beim Login: \(error.localizedDescription)")
                return
            }
            
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                print("Ungültige Daten")
                return
            }
            
            if let status = json["status"] as? String, status == "success",
               let idString = json["id"] as? String,
               let id = Int(idString) {
                DispatchQueue.main.async {
                    self.isLoggedIn = true
                    self.loggedInUsername = username
                    self.id = id
            
                }
            } else {
                DispatchQueue.main.async {
                    self.isLoggedIn = false
                    print("Login fehlgeschlagen: \(json["error"] ?? "Unbekannter Fehler")")
                }
            }
        }.resume()
    }
    
    func fetchProfileImageURL(for id: Int) {
        guard let url = URL(string: "http://uploads.elliceleft.de/api/getProfileImageURL.php") else {
            print("Ungültige URL")
            return
        }
        
        let requestData = [
            "id": "\(id)",
            "action": "getProfileImageURL"
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestData, options: [])
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Fehler beim Abrufen der Profilbild-URL: \(error.localizedDescription)")
                return
            }
            
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                  let imageURL = json["profileImageURL"] as? String else {
                print("Ungültige Daten oder kein Bild gefunden")
                return
            }
            
            DispatchQueue.main.async {
                self.profileImageURL = imageURL
                print("Profilbild-URL erfolgreich abgerufen: \(imageURL)")
            }
        }.resume()
    }
}
