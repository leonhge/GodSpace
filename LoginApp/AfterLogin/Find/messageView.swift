import SwiftUI

struct MessageView: View {
    @State private var messages: [Message] = [] // Verwende explizit MessageView.Message
    @State private var newMessage = ""
    var user: User
    var currentUserId: String // Dynamische Benutzer-ID (muss übergeben werden)

    var body: some View {
        VStack {
            List(messages) { message in
                VStack(alignment: .leading) {
                    Text("Von: \(message.senderId)")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(message.message)
                }
            }

            HStack {
                TextField("Nachricht", text: $newMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button(action: {
                    let trimmedMessage = newMessage.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !trimmedMessage.isEmpty {
                        // Konvertiere user.id (UUID) in einen String
                        let receiverIdString = user.id.uuidString
                        
                        // Füge die neue Nachricht sofort zum Array hinzu
                        let newMessageItem = Message(id: messages.count + 1, senderId: currentUserId, receiverId: receiverIdString, message: trimmedMessage, timestamp: "\(Date())") // Beispiel für Timestamp
                        messages.append(newMessageItem) // Sofortige Anzeige der Nachricht
                        
                        // Sende die Nachricht
                        sendMessage(senderId: currentUserId, receiverId: receiverIdString, message: trimmedMessage)
                        newMessage = ""
                    }
                }) {
                    Text("Senden")
                }
                .padding()
            }
            .padding()
        }
        .onAppear {
            // Konvertiere user.id (UUID) in einen String
            let receiverIdString = user.id.uuidString
            fetchMessages(senderId: currentUserId, receiverId: receiverIdString) { fetchedMessages in
                messages = fetchedMessages // Weise die abgerufenen Nachrichten zu
            }
        }
        .navigationTitle("Chat with \(user.name)")
    }

    struct Message: Identifiable, Codable {
        var id: Int
        var senderId: String
        var receiverId: String
        var message: String
        var timestamp: String
    }
}

// Beispiel für die fetchMessages-Funktion:
func fetchMessages(senderId: String, receiverId: String, completion: @escaping ([MessageView.Message]) -> Void) {
    guard let url = URL(string: "https://www.get.elliceleft.de") else {
        print("Invalid URL")
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    
    let bodyData = "sender_id=\(senderId)&receiver_id=\(receiverId)"
    request.httpBody = bodyData.data(using: .utf8)
    
    URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Error: \(error)")
            return
        }
        
        guard let data = data else {
            print("No data received")
            return
        }
        
        do {
            // Verwende Message hier explizit
            let messages = try JSONDecoder().decode([MessageView.Message].self, from: data)
            DispatchQueue.main.async {
                completion(messages)
            }
        } catch {
            print("Decoding error: \(error)")
        }
    }.resume()
}
