import Foundation
import SwiftUI

func sendMessage(senderId: String, receiverId: String, message: String) {
    guard let url = URL(string: "http://send.elliceleft.de") else {
        print("Invalid URL")
        return
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    
    // Prüfe, ob die IDs korrekt übergeben werden
    print("Sending message from senderId: \(senderId) to receiverId: \(receiverId)")
    
    // Korrekte Body-Daten mit URL-Encoding
    let parameters: [String: String] = [
        "sender_id": senderId,
        "receiver_id": receiverId,
        "message": message
    ]
    
    // URL-Encoded Body
    let bodyData = parameters.map { "\($0)=\($1)" }.joined(separator: "&")
    request.httpBody = bodyData.data(using: .utf8)
    
    // Setze Content-Type Header
    request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

    // HTTP-Request senden
    URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Error: \(error)")
        } else if let data = data {
            if let responseString = String(data: data, encoding: .utf8) {
                print("Response: \(responseString)")
            }
        }
    }
}
