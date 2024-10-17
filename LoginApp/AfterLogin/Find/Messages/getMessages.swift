import Foundation
import SwiftUI

// Definiere den Message-Typ hier, bevor du ihn in fetchMessages verwendest
struct Message: Identifiable, Codable {
    var id: Int
    var senderId: String
    var receiverId: String
    var message: String
    var timestamp: String
}


func fetchMessages(senderId: String, receiverId: String, completion: @escaping ([Message]) -> Void) {
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
            let messages = try JSONDecoder().decode([Message].self, from: data)
            DispatchQueue.main.async {
                completion(messages)
            }
        } catch {
            print("Decoding error: \(error)")
        }
    }.resume()
}



